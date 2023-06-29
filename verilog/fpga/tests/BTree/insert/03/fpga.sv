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

       1061 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 476] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 476] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 476]] = 0;
              ip = 1062;
      end

       1062 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1063;
      end

       1063 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 477] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1064;
      end

       1064 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[477] != 0 ? 1087 : 1065;
      end

       1065 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 478] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 478] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 478]] = 0;
              ip = 1066;
      end

       1066 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[478]*10 + 0] = 1;
              updateArrayLength(1, localMem[478], 0);
              ip = 1067;
      end

       1067 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[478]*10 + 2] = 0;
              updateArrayLength(1, localMem[478], 2);
              ip = 1068;
      end

       1068 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 479] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 479] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 479]] = 0;
              ip = 1069;
      end

       1069 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[478]*10 + 4] = localMem[479];
              updateArrayLength(1, localMem[478], 4);
              ip = 1070;
      end

       1070 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 480] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 480] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 480]] = 0;
              ip = 1071;
      end

       1071 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[478]*10 + 5] = localMem[480];
              updateArrayLength(1, localMem[478], 5);
              ip = 1072;
      end

       1072 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[478]*10 + 6] = 0;
              updateArrayLength(1, localMem[478], 6);
              ip = 1073;
      end

       1073 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[478]*10 + 3] = localMem[0];
              updateArrayLength(1, localMem[478], 3);
              ip = 1074;
      end

       1074 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 1] = heapMem[localMem[0]*10 + 1] + 1;
              ip = 1075;
      end

       1075 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[478]*10 + 1] = heapMem[localMem[0]*10 + 1];
              updateArrayLength(1, localMem[478], 1);
              ip = 1076;
      end

       1076 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 481] = heapMem[localMem[478]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1077;
      end

       1077 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[481]*10 + 0] = 2;
              updateArrayLength(1, localMem[481], 0);
              ip = 1078;
      end

       1078 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 482] = heapMem[localMem[478]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1079;
      end

       1079 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[482]*10 + 0] = 22;
              updateArrayLength(1, localMem[482], 0);
              ip = 1080;
      end

       1080 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 1081;
      end

       1081 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 3] = localMem[478];
              updateArrayLength(1, localMem[0], 3);
              ip = 1082;
      end

       1082 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 483] = heapMem[localMem[478]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1083;
      end

       1083 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[483]] = 1;
              ip = 1084;
      end

       1084 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 484] = heapMem[localMem[478]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1085;
      end

       1085 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[484]] = 1;
              ip = 1086;
      end

       1086 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2115;
      end

       1087 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1088;
      end

       1088 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 485] = heapMem[localMem[477]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1089;
      end

       1089 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 486] = heapMem[localMem[0]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1090;
      end

       1090 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[485] >= localMem[486] ? 1126 : 1091;
      end

       1091 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 487] = heapMem[localMem[477]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1092;
      end

       1092 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[487] != 0 ? 1125 : 1093;
      end

       1093 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 488] = !heapMem[localMem[477]*10 + 6];
              ip = 1094;
      end

       1094 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[488] == 0 ? 1124 : 1095;
      end

       1095 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 489] = heapMem[localMem[477]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1096;
      end

       1096 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 490] = 0; k = arraySizes[localMem[489]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[489] * NArea + i] == 2) localMem[0 + 490] = i + 1;
              end
              ip = 1097;
      end

       1097 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[490] == 0 ? 1102 : 1098;
      end

       1098 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 490] = localMem[490] - 1;
              ip = 1099;
      end

       1099 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 491] = heapMem[localMem[477]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1100;
      end

       1100 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[491]*10 + localMem[490]] = 22;
              updateArrayLength(1, localMem[491], localMem[490]);
              ip = 1101;
      end

       1101 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2115;
      end

       1102 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1103;
      end

       1103 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[489]] = localMem[485];
              ip = 1104;
      end

       1104 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 492] = heapMem[localMem[477]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1105;
      end

       1105 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[492]] = localMem[485];
              ip = 1106;
      end

       1106 :
      begin                                                                     // arrayCountGreater
//$display("AAAA %4d %4d arrayCountGreater", steps, ip);
              j = 0; k = arraySizes[localMem[489]];
//$display("AAAAA k=%d  source2=%d", k, 2);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[489] * NArea + i]);
                if (i < k && heapMem[localMem[489] * NArea + i] > 2) j = j + 1;
              end
              localMem[0 + 493] = j;
              ip = 1107;
      end

       1107 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[493] != 0 ? 1115 : 1108;
      end

       1108 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 494] = heapMem[localMem[477]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1109;
      end

       1109 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[494]*10 + localMem[485]] = 2;
              updateArrayLength(1, localMem[494], localMem[485]);
              ip = 1110;
      end

       1110 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 495] = heapMem[localMem[477]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1111;
      end

       1111 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[495]*10 + localMem[485]] = 22;
              updateArrayLength(1, localMem[495], localMem[485]);
              ip = 1112;
      end

       1112 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[477]*10 + 0] = localMem[485] + 1;
              ip = 1113;
      end

       1113 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 1114;
      end

       1114 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2115;
      end

       1115 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1116;
      end

       1116 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[489]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[489] * NArea + i] < 2) j = j + 1;
              end
              localMem[0 + 496] = j;
              ip = 1117;
      end

       1117 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 497] = heapMem[localMem[477]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1118;
      end

       1118 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 498] = heapMem[localMem[477]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1120;
      end

       1120 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[477]*10 + 0] = heapMem[localMem[477]*10 + 0] + 1;
              ip = 1122;
      end

       1122 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 1123;
      end

       1123 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2115;
      end

       1124 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1125;
      end

       1125 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1126;
      end

       1126 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1127;
      end

       1127 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 499] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1128;
      end

       1128 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1129;
      end

       1129 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 501] = heapMem[localMem[499]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1130;
      end

       1130 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 502] = heapMem[localMem[499]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1131;
      end

       1131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 503] = heapMem[localMem[502]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1132;
      end

       1132 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[501] <  localMem[503] ? 1352 : 1133;
      end

       1133 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 504] = localMem[503];
              updateArrayLength(2, 0, 0);
              ip = 1134;
      end

       1134 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 504] = localMem[504] >> 1;
              ip = 1135;
      end

       1135 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 505] = localMem[504] + 1;
              ip = 1136;
      end

       1136 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 506] = heapMem[localMem[499]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1137;
      end

       1137 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[506] == 0 ? 1234 : 1138;
      end

       1138 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 507] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 507] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 507]] = 0;
              ip = 1139;
      end

       1139 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 0] = localMem[504];
              updateArrayLength(1, localMem[507], 0);
              ip = 1140;
      end

       1140 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 2] = 0;
              updateArrayLength(1, localMem[507], 2);
              ip = 1141;
      end

       1141 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 508] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 508] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 508]] = 0;
              ip = 1142;
      end

       1142 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 4] = localMem[508];
              updateArrayLength(1, localMem[507], 4);
              ip = 1143;
      end

       1143 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 509] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 509] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 509]] = 0;
              ip = 1144;
      end

       1144 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 5] = localMem[509];
              updateArrayLength(1, localMem[507], 5);
              ip = 1145;
      end

       1145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 6] = 0;
              updateArrayLength(1, localMem[507], 6);
              ip = 1146;
      end

       1146 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 3] = localMem[502];
              updateArrayLength(1, localMem[507], 3);
              ip = 1147;
      end

       1147 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[502]*10 + 1] = heapMem[localMem[502]*10 + 1] + 1;
              ip = 1148;
      end

       1148 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 1] = heapMem[localMem[502]*10 + 1];
              updateArrayLength(1, localMem[507], 1);
              ip = 1149;
      end

       1149 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 510] = !heapMem[localMem[499]*10 + 6];
              ip = 1150;
      end

       1150 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[510] != 0 ? 1179 : 1151;
      end

       1151 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 511] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 511] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 511]] = 0;
              ip = 1152;
      end

       1152 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 6] = localMem[511];
              updateArrayLength(1, localMem[507], 6);
              ip = 1153;
      end

       1153 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 512] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1154;
      end

       1154 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 513] = heapMem[localMem[507]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1155;
      end

       1155 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 514] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1157;
      end

       1157 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 515] = heapMem[localMem[507]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1158;
      end

       1158 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 516] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1160;
      end

       1160 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 517] = heapMem[localMem[507]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1161;
      end

       1161 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 518] = localMem[504] + 1;
              ip = 1162;
      end

       1162 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 519] = heapMem[localMem[507]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1164;
      end

       1164 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 520] = localMem[519] + 1;
              ip = 1165;
      end

       1165 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 521] = heapMem[localMem[507]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1166;
      end

       1166 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1167;
      end

       1167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 522] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1168;
      end

       1168 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1169;
      end

       1169 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[522] >= localMem[520] ? 1175 : 1170;
      end

       1170 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 523] = heapMem[localMem[521]*10 + localMem[522]];
              updateArrayLength(2, 0, 0);
              ip = 1171;
      end

       1171 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[523]*10 + 2] = localMem[507];
              updateArrayLength(1, localMem[523], 2);
              ip = 1172;
      end

       1172 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1173;
      end

       1173 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 522] = localMem[522] + 1;
              ip = 1174;
      end

       1174 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1168;
      end

       1175 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1176;
      end

       1176 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 524] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1177;
      end

       1177 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[524]] = localMem[505];
              ip = 1178;
      end

       1178 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1186;
      end

       1179 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1180;
      end

       1180 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 525] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1181;
      end

       1181 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 526] = heapMem[localMem[507]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1182;
      end

       1182 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 527] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1184;
      end

       1184 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 528] = heapMem[localMem[507]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1185;
      end

       1185 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1187;
      end

       1187 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[499]*10 + 0] = localMem[504];
              updateArrayLength(1, localMem[499], 0);
              ip = 1188;
      end

       1188 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[507]*10 + 2] = localMem[506];
              updateArrayLength(1, localMem[507], 2);
              ip = 1189;
      end

       1189 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 529] = heapMem[localMem[506]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1190;
      end

       1190 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 530] = heapMem[localMem[506]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1191;
      end

       1191 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 531] = heapMem[localMem[530]*10 + localMem[529]];
              updateArrayLength(2, 0, 0);
              ip = 1192;
      end

       1192 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[531] != localMem[499] ? 1211 : 1193;
      end

       1193 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 532] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1194;
      end

       1194 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 533] = heapMem[localMem[532]*10 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1195;
      end

       1195 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 534] = heapMem[localMem[506]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1196;
      end

       1196 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[534]*10 + localMem[529]] = localMem[533];
              updateArrayLength(1, localMem[534], localMem[529]);
              ip = 1197;
      end

       1197 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 535] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1198;
      end

       1198 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 536] = heapMem[localMem[535]*10 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1199;
      end

       1199 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 537] = heapMem[localMem[506]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1200;
      end

       1200 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[537]*10 + localMem[529]] = localMem[536];
              updateArrayLength(1, localMem[537], localMem[529]);
              ip = 1201;
      end

       1201 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 538] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1202;
      end

       1202 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[538]] = localMem[504];
              ip = 1203;
      end

       1203 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 539] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1204;
      end

       1204 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[539]] = localMem[504];
              ip = 1205;
      end

       1205 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 540] = localMem[529] + 1;
              ip = 1206;
      end

       1206 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[506]*10 + 0] = localMem[540];
              updateArrayLength(1, localMem[506], 0);
              ip = 1207;
      end

       1207 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 541] = heapMem[localMem[506]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1208;
      end

       1208 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[541]*10 + localMem[540]] = localMem[507];
              updateArrayLength(1, localMem[541], localMem[540]);
              ip = 1209;
      end

       1209 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1349;
      end

       1210 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1233;
      end

       1211 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1212;
      end

       1212 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1213;
      end

       1213 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 542] = heapMem[localMem[506]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1214;
      end

       1214 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 543] = 0; k = arraySizes[localMem[542]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[542] * NArea + i] == localMem[499]) localMem[0 + 543] = i + 1;
              end
              ip = 1215;
      end

       1215 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 543] = localMem[543] - 1;
              ip = 1216;
      end

       1216 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 544] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1217;
      end

       1217 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 545] = heapMem[localMem[544]*10 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1218;
      end

       1218 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 546] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1219;
      end

       1219 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 547] = heapMem[localMem[546]*10 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1220;
      end

       1220 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 548] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1221;
      end

       1221 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[548]] = localMem[504];
              ip = 1222;
      end

       1222 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 549] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1223;
      end

       1223 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[549]] = localMem[504];
              ip = 1224;
      end

       1224 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 550] = heapMem[localMem[506]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1225;
      end

       1225 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 551] = heapMem[localMem[506]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1227;
      end

       1227 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 552] = heapMem[localMem[506]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1229;
      end

       1229 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 553] = localMem[543] + 1;
              ip = 1230;
      end

       1230 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[506]*10 + 0] = heapMem[localMem[506]*10 + 0] + 1;
              ip = 1232;
      end

       1232 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1349;
      end

       1233 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1234;
      end

       1234 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1235;
      end

       1235 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 554] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 554] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 554]] = 0;
              ip = 1236;
      end

       1236 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 0] = localMem[504];
              updateArrayLength(1, localMem[554], 0);
              ip = 1237;
      end

       1237 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 2] = 0;
              updateArrayLength(1, localMem[554], 2);
              ip = 1238;
      end

       1238 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 555] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 555] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 555]] = 0;
              ip = 1239;
      end

       1239 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 4] = localMem[555];
              updateArrayLength(1, localMem[554], 4);
              ip = 1240;
      end

       1240 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 556] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 556] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 556]] = 0;
              ip = 1241;
      end

       1241 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 5] = localMem[556];
              updateArrayLength(1, localMem[554], 5);
              ip = 1242;
      end

       1242 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 6] = 0;
              updateArrayLength(1, localMem[554], 6);
              ip = 1243;
      end

       1243 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 3] = localMem[502];
              updateArrayLength(1, localMem[554], 3);
              ip = 1244;
      end

       1244 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[502]*10 + 1] = heapMem[localMem[502]*10 + 1] + 1;
              ip = 1245;
      end

       1245 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 1] = heapMem[localMem[502]*10 + 1];
              updateArrayLength(1, localMem[554], 1);
              ip = 1246;
      end

       1246 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 557] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 557] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 557]] = 0;
              ip = 1247;
      end

       1247 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 0] = localMem[504];
              updateArrayLength(1, localMem[557], 0);
              ip = 1248;
      end

       1248 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 2] = 0;
              updateArrayLength(1, localMem[557], 2);
              ip = 1249;
      end

       1249 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 558] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 558] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 558]] = 0;
              ip = 1250;
      end

       1250 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 4] = localMem[558];
              updateArrayLength(1, localMem[557], 4);
              ip = 1251;
      end

       1251 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 559] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 559] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 559]] = 0;
              ip = 1252;
      end

       1252 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 5] = localMem[559];
              updateArrayLength(1, localMem[557], 5);
              ip = 1253;
      end

       1253 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 6] = 0;
              updateArrayLength(1, localMem[557], 6);
              ip = 1254;
      end

       1254 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 3] = localMem[502];
              updateArrayLength(1, localMem[557], 3);
              ip = 1255;
      end

       1255 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[502]*10 + 1] = heapMem[localMem[502]*10 + 1] + 1;
              ip = 1256;
      end

       1256 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 1] = heapMem[localMem[502]*10 + 1];
              updateArrayLength(1, localMem[557], 1);
              ip = 1257;
      end

       1257 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 560] = !heapMem[localMem[499]*10 + 6];
              ip = 1258;
      end

       1258 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[560] != 0 ? 1310 : 1259;
      end

       1259 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 561] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 561] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 561]] = 0;
              ip = 1260;
      end

       1260 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 6] = localMem[561];
              updateArrayLength(1, localMem[554], 6);
              ip = 1261;
      end

       1261 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 562] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 562] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 562]] = 0;
              ip = 1262;
      end

       1262 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 6] = localMem[562];
              updateArrayLength(1, localMem[557], 6);
              ip = 1263;
      end

       1263 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 563] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1264;
      end

       1264 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 564] = heapMem[localMem[554]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1265;
      end

       1265 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 565] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1267;
      end

       1267 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 566] = heapMem[localMem[554]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1268;
      end

       1268 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 567] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1270;
      end

       1270 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 568] = heapMem[localMem[554]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1271;
      end

       1271 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 569] = localMem[504] + 1;
              ip = 1272;
      end

       1272 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 570] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1274;
      end

       1274 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 571] = heapMem[localMem[557]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1275;
      end

       1275 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 572] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1277;
      end

       1277 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 573] = heapMem[localMem[557]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1278;
      end

       1278 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 574] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1280;
      end

       1280 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 575] = heapMem[localMem[557]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1281;
      end

       1281 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 576] = localMem[504] + 1;
              ip = 1282;
      end

       1282 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 577] = heapMem[localMem[554]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1284;
      end

       1284 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 578] = localMem[577] + 1;
              ip = 1285;
      end

       1285 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 579] = heapMem[localMem[554]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1286;
      end

       1286 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1287;
      end

       1287 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 580] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1288;
      end

       1288 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1289;
      end

       1289 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[580] >= localMem[578] ? 1295 : 1290;
      end

       1290 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 581] = heapMem[localMem[579]*10 + localMem[580]];
              updateArrayLength(2, 0, 0);
              ip = 1291;
      end

       1291 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[581]*10 + 2] = localMem[554];
              updateArrayLength(1, localMem[581], 2);
              ip = 1292;
      end

       1292 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1293;
      end

       1293 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 580] = localMem[580] + 1;
              ip = 1294;
      end

       1294 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1288;
      end

       1295 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1296;
      end

       1296 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 582] = heapMem[localMem[557]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1297;
      end

       1297 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 583] = localMem[582] + 1;
              ip = 1298;
      end

       1298 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 584] = heapMem[localMem[557]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1299;
      end

       1299 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1300;
      end

       1300 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 585] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1301;
      end

       1301 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1302;
      end

       1302 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[585] >= localMem[583] ? 1308 : 1303;
      end

       1303 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 586] = heapMem[localMem[584]*10 + localMem[585]];
              updateArrayLength(2, 0, 0);
              ip = 1304;
      end

       1304 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[586]*10 + 2] = localMem[557];
              updateArrayLength(1, localMem[586], 2);
              ip = 1305;
      end

       1305 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1306;
      end

       1306 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 585] = localMem[585] + 1;
              ip = 1307;
      end

       1307 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1301;
      end

       1308 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1309;
      end

       1309 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1325;
      end

       1310 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1311;
      end

       1311 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 587] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 587] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 587]] = 0;
              ip = 1312;
      end

       1312 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[499]*10 + 6] = localMem[587];
              updateArrayLength(1, localMem[499], 6);
              ip = 1313;
      end

       1313 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 588] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1314;
      end

       1314 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 589] = heapMem[localMem[554]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1315;
      end

       1315 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 590] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1317;
      end

       1317 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 591] = heapMem[localMem[554]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1318;
      end

       1318 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 592] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1320;
      end

       1320 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 593] = heapMem[localMem[557]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1321;
      end

       1321 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 594] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1323;
      end

       1323 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 595] = heapMem[localMem[557]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1324;
      end

       1324 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1326;
      end

       1326 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[554]*10 + 2] = localMem[499];
              updateArrayLength(1, localMem[554], 2);
              ip = 1327;
      end

       1327 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[557]*10 + 2] = localMem[499];
              updateArrayLength(1, localMem[557], 2);
              ip = 1328;
      end

       1328 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 596] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1329;
      end

       1329 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 597] = heapMem[localMem[596]*10 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1330;
      end

       1330 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 598] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1331;
      end

       1331 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 599] = heapMem[localMem[598]*10 + localMem[504]];
              updateArrayLength(2, 0, 0);
              ip = 1332;
      end

       1332 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 600] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1333;
      end

       1333 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[600]*10 + 0] = localMem[597];
              updateArrayLength(1, localMem[600], 0);
              ip = 1334;
      end

       1334 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 601] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1335;
      end

       1335 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[601]*10 + 0] = localMem[599];
              updateArrayLength(1, localMem[601], 0);
              ip = 1336;
      end

       1336 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 602] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1337;
      end

       1337 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[602]*10 + 0] = localMem[554];
              updateArrayLength(1, localMem[602], 0);
              ip = 1338;
      end

       1338 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 603] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1339;
      end

       1339 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[603]*10 + 1] = localMem[557];
              updateArrayLength(1, localMem[603], 1);
              ip = 1340;
      end

       1340 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[499]*10 + 0] = 1;
              updateArrayLength(1, localMem[499], 0);
              ip = 1341;
      end

       1341 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 604] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1342;
      end

       1342 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[604]] = 1;
              ip = 1343;
      end

       1343 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 605] = heapMem[localMem[499]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1344;
      end

       1344 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[605]] = 1;
              ip = 1345;
      end

       1345 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 606] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1346;
      end

       1346 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[606]] = 2;
              ip = 1347;
      end

       1347 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1349;
      end

       1348 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1354;
      end

       1349 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1350;
      end

       1350 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 500] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1351;
      end

       1351 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1354;
      end

       1352 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1353;
      end

       1353 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 500] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1354;
      end

       1354 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1355;
      end

       1355 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1356;
      end

       1356 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1357;
      end

       1357 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 607] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1358;
      end

       1358 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1359;
      end

       1359 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[607] >= 99 ? 1857 : 1360;
      end

       1360 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 608] = heapMem[localMem[499]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1361;
      end

       1361 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 609] = localMem[608] - 1;
              ip = 1362;
      end

       1362 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 610] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1363;
      end

       1363 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 611] = heapMem[localMem[610]*10 + localMem[609]];
              updateArrayLength(2, 0, 0);
              ip = 1364;
      end

       1364 :
      begin                                                                     // jLe
//$display("AAAA %4d %4d jLe", steps, ip);
              ip = 2 <= localMem[611] ? 1605 : 1365;
      end

       1365 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 612] = !heapMem[localMem[499]*10 + 6];
              ip = 1366;
      end

       1366 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[612] == 0 ? 1371 : 1367;
      end

       1367 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 0] = localMem[499];
              updateArrayLength(1, localMem[476], 0);
              ip = 1368;
      end

       1368 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 1] = 2;
              updateArrayLength(1, localMem[476], 1);
              ip = 1369;
      end

       1369 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[476]*10 + 2] = localMem[608] - 1;
              ip = 1370;
      end

       1370 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1861;
      end

       1371 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1372;
      end

       1372 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 613] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1373;
      end

       1373 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 614] = heapMem[localMem[613]*10 + localMem[608]];
              updateArrayLength(2, 0, 0);
              ip = 1374;
      end

       1374 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1375;
      end

       1375 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 616] = heapMem[localMem[614]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1376;
      end

       1376 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 617] = heapMem[localMem[614]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1377;
      end

       1377 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 618] = heapMem[localMem[617]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1378;
      end

       1378 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[616] <  localMem[618] ? 1598 : 1379;
      end

       1379 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 619] = localMem[618];
              updateArrayLength(2, 0, 0);
              ip = 1380;
      end

       1380 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 619] = localMem[619] >> 1;
              ip = 1381;
      end

       1381 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 620] = localMem[619] + 1;
              ip = 1382;
      end

       1382 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 621] = heapMem[localMem[614]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1383;
      end

       1383 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[621] == 0 ? 1480 : 1384;
      end

       1384 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 622] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 622] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 622]] = 0;
              ip = 1385;
      end

       1385 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 0] = localMem[619];
              updateArrayLength(1, localMem[622], 0);
              ip = 1386;
      end

       1386 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 2] = 0;
              updateArrayLength(1, localMem[622], 2);
              ip = 1387;
      end

       1387 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 623] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 623] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 623]] = 0;
              ip = 1388;
      end

       1388 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 4] = localMem[623];
              updateArrayLength(1, localMem[622], 4);
              ip = 1389;
      end

       1389 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 624] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 624] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 624]] = 0;
              ip = 1390;
      end

       1390 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 5] = localMem[624];
              updateArrayLength(1, localMem[622], 5);
              ip = 1391;
      end

       1391 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 6] = 0;
              updateArrayLength(1, localMem[622], 6);
              ip = 1392;
      end

       1392 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 3] = localMem[617];
              updateArrayLength(1, localMem[622], 3);
              ip = 1393;
      end

       1393 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[617]*10 + 1] = heapMem[localMem[617]*10 + 1] + 1;
              ip = 1394;
      end

       1394 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 1] = heapMem[localMem[617]*10 + 1];
              updateArrayLength(1, localMem[622], 1);
              ip = 1395;
      end

       1395 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 625] = !heapMem[localMem[614]*10 + 6];
              ip = 1396;
      end

       1396 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[625] != 0 ? 1425 : 1397;
      end

       1397 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 626] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 626] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 626]] = 0;
              ip = 1398;
      end

       1398 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 6] = localMem[626];
              updateArrayLength(1, localMem[622], 6);
              ip = 1399;
      end

       1399 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 627] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1400;
      end

       1400 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 628] = heapMem[localMem[622]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1401;
      end

       1401 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 629] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1403;
      end

       1403 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 630] = heapMem[localMem[622]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1404;
      end

       1404 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 631] = heapMem[localMem[614]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1406;
      end

       1406 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 632] = heapMem[localMem[622]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1407;
      end

       1407 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 633] = localMem[619] + 1;
              ip = 1408;
      end

       1408 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 634] = heapMem[localMem[622]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1410;
      end

       1410 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 635] = localMem[634] + 1;
              ip = 1411;
      end

       1411 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 636] = heapMem[localMem[622]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1412;
      end

       1412 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1413;
      end

       1413 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 637] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1414;
      end

       1414 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1415;
      end

       1415 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[637] >= localMem[635] ? 1421 : 1416;
      end

       1416 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 638] = heapMem[localMem[636]*10 + localMem[637]];
              updateArrayLength(2, 0, 0);
              ip = 1417;
      end

       1417 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[638]*10 + 2] = localMem[622];
              updateArrayLength(1, localMem[638], 2);
              ip = 1418;
      end

       1418 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1419;
      end

       1419 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 637] = localMem[637] + 1;
              ip = 1420;
      end

       1420 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1414;
      end

       1421 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1422;
      end

       1422 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 639] = heapMem[localMem[614]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1423;
      end

       1423 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[639]] = localMem[620];
              ip = 1424;
      end

       1424 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1432;
      end

       1425 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1426;
      end

       1426 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 640] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1427;
      end

       1427 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 641] = heapMem[localMem[622]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1428;
      end

       1428 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 642] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1430;
      end

       1430 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 643] = heapMem[localMem[622]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1431;
      end

       1431 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1433;
      end

       1433 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[614]*10 + 0] = localMem[619];
              updateArrayLength(1, localMem[614], 0);
              ip = 1434;
      end

       1434 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[622]*10 + 2] = localMem[621];
              updateArrayLength(1, localMem[622], 2);
              ip = 1435;
      end

       1435 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 644] = heapMem[localMem[621]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1436;
      end

       1436 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 645] = heapMem[localMem[621]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1437;
      end

       1437 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 646] = heapMem[localMem[645]*10 + localMem[644]];
              updateArrayLength(2, 0, 0);
              ip = 1438;
      end

       1438 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[646] != localMem[614] ? 1457 : 1439;
      end

       1439 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 647] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1440;
      end

       1440 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 648] = heapMem[localMem[647]*10 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1441;
      end

       1441 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 649] = heapMem[localMem[621]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1442;
      end

       1442 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[649]*10 + localMem[644]] = localMem[648];
              updateArrayLength(1, localMem[649], localMem[644]);
              ip = 1443;
      end

       1443 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 650] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1444;
      end

       1444 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 651] = heapMem[localMem[650]*10 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1445;
      end

       1445 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 652] = heapMem[localMem[621]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1446;
      end

       1446 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[652]*10 + localMem[644]] = localMem[651];
              updateArrayLength(1, localMem[652], localMem[644]);
              ip = 1447;
      end

       1447 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 653] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1448;
      end

       1448 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[653]] = localMem[619];
              ip = 1449;
      end

       1449 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 654] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1450;
      end

       1450 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[654]] = localMem[619];
              ip = 1451;
      end

       1451 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 655] = localMem[644] + 1;
              ip = 1452;
      end

       1452 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[621]*10 + 0] = localMem[655];
              updateArrayLength(1, localMem[621], 0);
              ip = 1453;
      end

       1453 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 656] = heapMem[localMem[621]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1454;
      end

       1454 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[656]*10 + localMem[655]] = localMem[622];
              updateArrayLength(1, localMem[656], localMem[655]);
              ip = 1455;
      end

       1455 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1595;
      end

       1456 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1479;
      end

       1457 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1458;
      end

       1458 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1459;
      end

       1459 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 657] = heapMem[localMem[621]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1460;
      end

       1460 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 658] = 0; k = arraySizes[localMem[657]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[657] * NArea + i] == localMem[614]) localMem[0 + 658] = i + 1;
              end
              ip = 1461;
      end

       1461 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 658] = localMem[658] - 1;
              ip = 1462;
      end

       1462 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 659] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1463;
      end

       1463 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 660] = heapMem[localMem[659]*10 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1464;
      end

       1464 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 661] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1465;
      end

       1465 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 662] = heapMem[localMem[661]*10 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1466;
      end

       1466 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 663] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1467;
      end

       1467 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[663]] = localMem[619];
              ip = 1468;
      end

       1468 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 664] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1469;
      end

       1469 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[664]] = localMem[619];
              ip = 1470;
      end

       1470 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 665] = heapMem[localMem[621]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1471;
      end

       1471 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 666] = heapMem[localMem[621]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1473;
      end

       1473 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 667] = heapMem[localMem[621]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1475;
      end

       1475 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 668] = localMem[658] + 1;
              ip = 1476;
      end

       1476 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[621]*10 + 0] = heapMem[localMem[621]*10 + 0] + 1;
              ip = 1478;
      end

       1478 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1595;
      end

       1479 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1480;
      end

       1480 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1481;
      end

       1481 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 669] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 669] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 669]] = 0;
              ip = 1482;
      end

       1482 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 0] = localMem[619];
              updateArrayLength(1, localMem[669], 0);
              ip = 1483;
      end

       1483 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 2] = 0;
              updateArrayLength(1, localMem[669], 2);
              ip = 1484;
      end

       1484 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 670] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 670] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 670]] = 0;
              ip = 1485;
      end

       1485 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 4] = localMem[670];
              updateArrayLength(1, localMem[669], 4);
              ip = 1486;
      end

       1486 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 671] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 671] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 671]] = 0;
              ip = 1487;
      end

       1487 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 5] = localMem[671];
              updateArrayLength(1, localMem[669], 5);
              ip = 1488;
      end

       1488 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 6] = 0;
              updateArrayLength(1, localMem[669], 6);
              ip = 1489;
      end

       1489 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 3] = localMem[617];
              updateArrayLength(1, localMem[669], 3);
              ip = 1490;
      end

       1490 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[617]*10 + 1] = heapMem[localMem[617]*10 + 1] + 1;
              ip = 1491;
      end

       1491 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 1] = heapMem[localMem[617]*10 + 1];
              updateArrayLength(1, localMem[669], 1);
              ip = 1492;
      end

       1492 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 672] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 672] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 672]] = 0;
              ip = 1493;
      end

       1493 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 0] = localMem[619];
              updateArrayLength(1, localMem[672], 0);
              ip = 1494;
      end

       1494 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 2] = 0;
              updateArrayLength(1, localMem[672], 2);
              ip = 1495;
      end

       1495 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 673] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 673] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 673]] = 0;
              ip = 1496;
      end

       1496 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 4] = localMem[673];
              updateArrayLength(1, localMem[672], 4);
              ip = 1497;
      end

       1497 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 674] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 674] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 674]] = 0;
              ip = 1498;
      end

       1498 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 5] = localMem[674];
              updateArrayLength(1, localMem[672], 5);
              ip = 1499;
      end

       1499 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 6] = 0;
              updateArrayLength(1, localMem[672], 6);
              ip = 1500;
      end

       1500 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 3] = localMem[617];
              updateArrayLength(1, localMem[672], 3);
              ip = 1501;
      end

       1501 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[617]*10 + 1] = heapMem[localMem[617]*10 + 1] + 1;
              ip = 1502;
      end

       1502 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 1] = heapMem[localMem[617]*10 + 1];
              updateArrayLength(1, localMem[672], 1);
              ip = 1503;
      end

       1503 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 675] = !heapMem[localMem[614]*10 + 6];
              ip = 1504;
      end

       1504 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[675] != 0 ? 1556 : 1505;
      end

       1505 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 676] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 676] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 676]] = 0;
              ip = 1506;
      end

       1506 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 6] = localMem[676];
              updateArrayLength(1, localMem[669], 6);
              ip = 1507;
      end

       1507 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 677] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 677] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 677]] = 0;
              ip = 1508;
      end

       1508 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 6] = localMem[677];
              updateArrayLength(1, localMem[672], 6);
              ip = 1509;
      end

       1509 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 678] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1510;
      end

       1510 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 679] = heapMem[localMem[669]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1511;
      end

       1511 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 680] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1513;
      end

       1513 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 681] = heapMem[localMem[669]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1514;
      end

       1514 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 682] = heapMem[localMem[614]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1516;
      end

       1516 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 683] = heapMem[localMem[669]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1517;
      end

       1517 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 684] = localMem[619] + 1;
              ip = 1518;
      end

       1518 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 685] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1520;
      end

       1520 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 686] = heapMem[localMem[672]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1521;
      end

       1521 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 687] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1523;
      end

       1523 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 688] = heapMem[localMem[672]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1524;
      end

       1524 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 689] = heapMem[localMem[614]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1526;
      end

       1526 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 690] = heapMem[localMem[672]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1527;
      end

       1527 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 691] = localMem[619] + 1;
              ip = 1528;
      end

       1528 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 692] = heapMem[localMem[669]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1530;
      end

       1530 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 693] = localMem[692] + 1;
              ip = 1531;
      end

       1531 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 694] = heapMem[localMem[669]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1532;
      end

       1532 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1533;
      end

       1533 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 695] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1534;
      end

       1534 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1535;
      end

       1535 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[695] >= localMem[693] ? 1541 : 1536;
      end

       1536 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 696] = heapMem[localMem[694]*10 + localMem[695]];
              updateArrayLength(2, 0, 0);
              ip = 1537;
      end

       1537 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[696]*10 + 2] = localMem[669];
              updateArrayLength(1, localMem[696], 2);
              ip = 1538;
      end

       1538 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1539;
      end

       1539 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 695] = localMem[695] + 1;
              ip = 1540;
      end

       1540 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1534;
      end

       1541 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1542;
      end

       1542 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 697] = heapMem[localMem[672]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1543;
      end

       1543 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 698] = localMem[697] + 1;
              ip = 1544;
      end

       1544 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 699] = heapMem[localMem[672]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1545;
      end

       1545 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1546;
      end

       1546 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 700] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1547;
      end

       1547 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1548;
      end

       1548 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[700] >= localMem[698] ? 1554 : 1549;
      end

       1549 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 701] = heapMem[localMem[699]*10 + localMem[700]];
              updateArrayLength(2, 0, 0);
              ip = 1550;
      end

       1550 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[701]*10 + 2] = localMem[672];
              updateArrayLength(1, localMem[701], 2);
              ip = 1551;
      end

       1551 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1552;
      end

       1552 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 700] = localMem[700] + 1;
              ip = 1553;
      end

       1553 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1547;
      end

       1554 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1555;
      end

       1555 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1571;
      end

       1556 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1557;
      end

       1557 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 702] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 702] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 702]] = 0;
              ip = 1558;
      end

       1558 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[614]*10 + 6] = localMem[702];
              updateArrayLength(1, localMem[614], 6);
              ip = 1559;
      end

       1559 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 703] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1560;
      end

       1560 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 704] = heapMem[localMem[669]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1561;
      end

       1561 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 705] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1563;
      end

       1563 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 706] = heapMem[localMem[669]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1564;
      end

       1564 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 707] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1566;
      end

       1566 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 708] = heapMem[localMem[672]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1567;
      end

       1567 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 709] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1569;
      end

       1569 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 710] = heapMem[localMem[672]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1570;
      end

       1570 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1572;
      end

       1572 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[669]*10 + 2] = localMem[614];
              updateArrayLength(1, localMem[669], 2);
              ip = 1573;
      end

       1573 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[672]*10 + 2] = localMem[614];
              updateArrayLength(1, localMem[672], 2);
              ip = 1574;
      end

       1574 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 711] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1575;
      end

       1575 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 712] = heapMem[localMem[711]*10 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1576;
      end

       1576 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 713] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1577;
      end

       1577 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 714] = heapMem[localMem[713]*10 + localMem[619]];
              updateArrayLength(2, 0, 0);
              ip = 1578;
      end

       1578 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 715] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1579;
      end

       1579 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[715]*10 + 0] = localMem[712];
              updateArrayLength(1, localMem[715], 0);
              ip = 1580;
      end

       1580 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 716] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1581;
      end

       1581 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[716]*10 + 0] = localMem[714];
              updateArrayLength(1, localMem[716], 0);
              ip = 1582;
      end

       1582 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 717] = heapMem[localMem[614]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1583;
      end

       1583 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[717]*10 + 0] = localMem[669];
              updateArrayLength(1, localMem[717], 0);
              ip = 1584;
      end

       1584 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 718] = heapMem[localMem[614]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1585;
      end

       1585 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[718]*10 + 1] = localMem[672];
              updateArrayLength(1, localMem[718], 1);
              ip = 1586;
      end

       1586 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[614]*10 + 0] = 1;
              updateArrayLength(1, localMem[614], 0);
              ip = 1587;
      end

       1587 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 719] = heapMem[localMem[614]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1588;
      end

       1588 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[719]] = 1;
              ip = 1589;
      end

       1589 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 720] = heapMem[localMem[614]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1590;
      end

       1590 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[720]] = 1;
              ip = 1591;
      end

       1591 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 721] = heapMem[localMem[614]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1592;
      end

       1592 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[721]] = 2;
              ip = 1593;
      end

       1593 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1595;
      end

       1594 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1600;
      end

       1595 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1596;
      end

       1596 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 615] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1597;
      end

       1597 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1600;
      end

       1598 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1599;
      end

       1599 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 615] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1600;
      end

       1600 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1601;
      end

       1601 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[615] != 0 ? 1603 : 1602;
      end

       1602 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 499] = localMem[614];
              updateArrayLength(2, 0, 0);
              ip = 1603;
      end

       1603 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1604;
      end

       1604 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1854;
      end

       1605 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1606;
      end

       1606 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 722] = heapMem[localMem[499]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1607;
      end

       1607 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 723] = 0; k = arraySizes[localMem[722]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[722] * NArea + i] == 2) localMem[0 + 723] = i + 1;
              end
              ip = 1608;
      end

       1608 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[723] == 0 ? 1613 : 1609;
      end

       1609 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 0] = localMem[499];
              updateArrayLength(1, localMem[476], 0);
              ip = 1610;
      end

       1610 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 1] = 1;
              updateArrayLength(1, localMem[476], 1);
              ip = 1611;
      end

       1611 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[476]*10 + 2] = localMem[723] - 1;
              ip = 1612;
      end

       1612 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1861;
      end

       1613 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1614;
      end

       1614 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[722]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[722] * NArea + i] < 2) j = j + 1;
              end
              localMem[0 + 724] = j;
              ip = 1615;
      end

       1615 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 725] = !heapMem[localMem[499]*10 + 6];
              ip = 1616;
      end

       1616 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[725] == 0 ? 1621 : 1617;
      end

       1617 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 0] = localMem[499];
              updateArrayLength(1, localMem[476], 0);
              ip = 1618;
      end

       1618 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 1] = 0;
              updateArrayLength(1, localMem[476], 1);
              ip = 1619;
      end

       1619 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[476]*10 + 2] = localMem[724];
              updateArrayLength(1, localMem[476], 2);
              ip = 1620;
      end

       1620 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1861;
      end

       1621 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1622;
      end

       1622 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 726] = heapMem[localMem[499]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1623;
      end

       1623 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 727] = heapMem[localMem[726]*10 + localMem[724]];
              updateArrayLength(2, 0, 0);
              ip = 1624;
      end

       1624 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1625;
      end

       1625 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 729] = heapMem[localMem[727]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1626;
      end

       1626 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 730] = heapMem[localMem[727]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1627;
      end

       1627 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 731] = heapMem[localMem[730]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1628;
      end

       1628 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[729] <  localMem[731] ? 1848 : 1629;
      end

       1629 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 732] = localMem[731];
              updateArrayLength(2, 0, 0);
              ip = 1630;
      end

       1630 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 732] = localMem[732] >> 1;
              ip = 1631;
      end

       1631 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 733] = localMem[732] + 1;
              ip = 1632;
      end

       1632 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 734] = heapMem[localMem[727]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1633;
      end

       1633 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[734] == 0 ? 1730 : 1634;
      end

       1634 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 735] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 735] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 735]] = 0;
              ip = 1635;
      end

       1635 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 0] = localMem[732];
              updateArrayLength(1, localMem[735], 0);
              ip = 1636;
      end

       1636 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 2] = 0;
              updateArrayLength(1, localMem[735], 2);
              ip = 1637;
      end

       1637 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 736] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 736] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 736]] = 0;
              ip = 1638;
      end

       1638 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 4] = localMem[736];
              updateArrayLength(1, localMem[735], 4);
              ip = 1639;
      end

       1639 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 737] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 737] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 737]] = 0;
              ip = 1640;
      end

       1640 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 5] = localMem[737];
              updateArrayLength(1, localMem[735], 5);
              ip = 1641;
      end

       1641 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 6] = 0;
              updateArrayLength(1, localMem[735], 6);
              ip = 1642;
      end

       1642 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 3] = localMem[730];
              updateArrayLength(1, localMem[735], 3);
              ip = 1643;
      end

       1643 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[730]*10 + 1] = heapMem[localMem[730]*10 + 1] + 1;
              ip = 1644;
      end

       1644 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 1] = heapMem[localMem[730]*10 + 1];
              updateArrayLength(1, localMem[735], 1);
              ip = 1645;
      end

       1645 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 738] = !heapMem[localMem[727]*10 + 6];
              ip = 1646;
      end

       1646 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[738] != 0 ? 1675 : 1647;
      end

       1647 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 739] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 739] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 739]] = 0;
              ip = 1648;
      end

       1648 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 6] = localMem[739];
              updateArrayLength(1, localMem[735], 6);
              ip = 1649;
      end

       1649 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 740] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1650;
      end

       1650 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 741] = heapMem[localMem[735]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1651;
      end

       1651 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 742] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1653;
      end

       1653 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 743] = heapMem[localMem[735]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1654;
      end

       1654 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 744] = heapMem[localMem[727]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1656;
      end

       1656 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 745] = heapMem[localMem[735]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1657;
      end

       1657 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 746] = localMem[732] + 1;
              ip = 1658;
      end

       1658 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 747] = heapMem[localMem[735]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1660;
      end

       1660 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 748] = localMem[747] + 1;
              ip = 1661;
      end

       1661 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 749] = heapMem[localMem[735]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1662;
      end

       1662 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1663;
      end

       1663 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 750] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1664;
      end

       1664 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1665;
      end

       1665 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[750] >= localMem[748] ? 1671 : 1666;
      end

       1666 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 751] = heapMem[localMem[749]*10 + localMem[750]];
              updateArrayLength(2, 0, 0);
              ip = 1667;
      end

       1667 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[751]*10 + 2] = localMem[735];
              updateArrayLength(1, localMem[751], 2);
              ip = 1668;
      end

       1668 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1669;
      end

       1669 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 750] = localMem[750] + 1;
              ip = 1670;
      end

       1670 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1664;
      end

       1671 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1672;
      end

       1672 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 752] = heapMem[localMem[727]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1673;
      end

       1673 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[752]] = localMem[733];
              ip = 1674;
      end

       1674 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1682;
      end

       1675 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1676;
      end

       1676 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 753] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1677;
      end

       1677 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 754] = heapMem[localMem[735]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1678;
      end

       1678 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 755] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1680;
      end

       1680 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 756] = heapMem[localMem[735]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1681;
      end

       1681 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1683;
      end

       1683 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[727]*10 + 0] = localMem[732];
              updateArrayLength(1, localMem[727], 0);
              ip = 1684;
      end

       1684 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[735]*10 + 2] = localMem[734];
              updateArrayLength(1, localMem[735], 2);
              ip = 1685;
      end

       1685 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 757] = heapMem[localMem[734]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1686;
      end

       1686 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 758] = heapMem[localMem[734]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1687;
      end

       1687 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 759] = heapMem[localMem[758]*10 + localMem[757]];
              updateArrayLength(2, 0, 0);
              ip = 1688;
      end

       1688 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[759] != localMem[727] ? 1707 : 1689;
      end

       1689 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 760] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1690;
      end

       1690 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 761] = heapMem[localMem[760]*10 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1691;
      end

       1691 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 762] = heapMem[localMem[734]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1692;
      end

       1692 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[762]*10 + localMem[757]] = localMem[761];
              updateArrayLength(1, localMem[762], localMem[757]);
              ip = 1693;
      end

       1693 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 763] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1694;
      end

       1694 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 764] = heapMem[localMem[763]*10 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1695;
      end

       1695 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 765] = heapMem[localMem[734]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1696;
      end

       1696 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[765]*10 + localMem[757]] = localMem[764];
              updateArrayLength(1, localMem[765], localMem[757]);
              ip = 1697;
      end

       1697 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 766] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1698;
      end

       1698 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[766]] = localMem[732];
              ip = 1699;
      end

       1699 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 767] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1700;
      end

       1700 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[767]] = localMem[732];
              ip = 1701;
      end

       1701 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 768] = localMem[757] + 1;
              ip = 1702;
      end

       1702 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[734]*10 + 0] = localMem[768];
              updateArrayLength(1, localMem[734], 0);
              ip = 1703;
      end

       1703 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 769] = heapMem[localMem[734]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1704;
      end

       1704 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[769]*10 + localMem[768]] = localMem[735];
              updateArrayLength(1, localMem[769], localMem[768]);
              ip = 1705;
      end

       1705 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1845;
      end

       1706 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1729;
      end

       1707 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1708;
      end

       1708 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1709;
      end

       1709 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 770] = heapMem[localMem[734]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1710;
      end

       1710 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 771] = 0; k = arraySizes[localMem[770]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[770] * NArea + i] == localMem[727]) localMem[0 + 771] = i + 1;
              end
              ip = 1711;
      end

       1711 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 771] = localMem[771] - 1;
              ip = 1712;
      end

       1712 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 772] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1713;
      end

       1713 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 773] = heapMem[localMem[772]*10 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1714;
      end

       1714 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 774] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1715;
      end

       1715 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 775] = heapMem[localMem[774]*10 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1716;
      end

       1716 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 776] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1717;
      end

       1717 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[776]] = localMem[732];
              ip = 1718;
      end

       1718 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 777] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1719;
      end

       1719 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[777]] = localMem[732];
              ip = 1720;
      end

       1720 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 778] = heapMem[localMem[734]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1721;
      end

       1721 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 779] = heapMem[localMem[734]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1723;
      end

       1723 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 780] = heapMem[localMem[734]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1725;
      end

       1725 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 781] = localMem[771] + 1;
              ip = 1726;
      end

       1726 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[734]*10 + 0] = heapMem[localMem[734]*10 + 0] + 1;
              ip = 1728;
      end

       1728 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1845;
      end

       1729 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1730;
      end

       1730 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1731;
      end

       1731 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 782] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 782] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 782]] = 0;
              ip = 1732;
      end

       1732 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 0] = localMem[732];
              updateArrayLength(1, localMem[782], 0);
              ip = 1733;
      end

       1733 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 2] = 0;
              updateArrayLength(1, localMem[782], 2);
              ip = 1734;
      end

       1734 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 783] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 783] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 783]] = 0;
              ip = 1735;
      end

       1735 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 4] = localMem[783];
              updateArrayLength(1, localMem[782], 4);
              ip = 1736;
      end

       1736 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 784] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 784] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 784]] = 0;
              ip = 1737;
      end

       1737 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 5] = localMem[784];
              updateArrayLength(1, localMem[782], 5);
              ip = 1738;
      end

       1738 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 6] = 0;
              updateArrayLength(1, localMem[782], 6);
              ip = 1739;
      end

       1739 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 3] = localMem[730];
              updateArrayLength(1, localMem[782], 3);
              ip = 1740;
      end

       1740 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[730]*10 + 1] = heapMem[localMem[730]*10 + 1] + 1;
              ip = 1741;
      end

       1741 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 1] = heapMem[localMem[730]*10 + 1];
              updateArrayLength(1, localMem[782], 1);
              ip = 1742;
      end

       1742 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 785] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 785] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 785]] = 0;
              ip = 1743;
      end

       1743 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 0] = localMem[732];
              updateArrayLength(1, localMem[785], 0);
              ip = 1744;
      end

       1744 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 2] = 0;
              updateArrayLength(1, localMem[785], 2);
              ip = 1745;
      end

       1745 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 786] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 786] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 786]] = 0;
              ip = 1746;
      end

       1746 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 4] = localMem[786];
              updateArrayLength(1, localMem[785], 4);
              ip = 1747;
      end

       1747 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 787] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 787] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 787]] = 0;
              ip = 1748;
      end

       1748 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 5] = localMem[787];
              updateArrayLength(1, localMem[785], 5);
              ip = 1749;
      end

       1749 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 6] = 0;
              updateArrayLength(1, localMem[785], 6);
              ip = 1750;
      end

       1750 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 3] = localMem[730];
              updateArrayLength(1, localMem[785], 3);
              ip = 1751;
      end

       1751 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[730]*10 + 1] = heapMem[localMem[730]*10 + 1] + 1;
              ip = 1752;
      end

       1752 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 1] = heapMem[localMem[730]*10 + 1];
              updateArrayLength(1, localMem[785], 1);
              ip = 1753;
      end

       1753 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 788] = !heapMem[localMem[727]*10 + 6];
              ip = 1754;
      end

       1754 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[788] != 0 ? 1806 : 1755;
      end

       1755 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 789] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 789] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 789]] = 0;
              ip = 1756;
      end

       1756 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 6] = localMem[789];
              updateArrayLength(1, localMem[782], 6);
              ip = 1757;
      end

       1757 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 790] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 790] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 790]] = 0;
              ip = 1758;
      end

       1758 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 6] = localMem[790];
              updateArrayLength(1, localMem[785], 6);
              ip = 1759;
      end

       1759 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 791] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1760;
      end

       1760 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 792] = heapMem[localMem[782]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1761;
      end

       1761 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 793] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1763;
      end

       1763 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 794] = heapMem[localMem[782]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1764;
      end

       1764 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 795] = heapMem[localMem[727]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1766;
      end

       1766 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 796] = heapMem[localMem[782]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1767;
      end

       1767 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 797] = localMem[732] + 1;
              ip = 1768;
      end

       1768 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 798] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1770;
      end

       1770 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 799] = heapMem[localMem[785]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1771;
      end

       1771 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 800] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1773;
      end

       1773 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 801] = heapMem[localMem[785]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1774;
      end

       1774 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 802] = heapMem[localMem[727]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1776;
      end

       1776 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 803] = heapMem[localMem[785]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1777;
      end

       1777 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 804] = localMem[732] + 1;
              ip = 1778;
      end

       1778 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 805] = heapMem[localMem[782]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1780;
      end

       1780 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 806] = localMem[805] + 1;
              ip = 1781;
      end

       1781 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 807] = heapMem[localMem[782]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1782;
      end

       1782 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1783;
      end

       1783 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 808] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1784;
      end

       1784 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1785;
      end

       1785 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[808] >= localMem[806] ? 1791 : 1786;
      end

       1786 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 809] = heapMem[localMem[807]*10 + localMem[808]];
              updateArrayLength(2, 0, 0);
              ip = 1787;
      end

       1787 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[809]*10 + 2] = localMem[782];
              updateArrayLength(1, localMem[809], 2);
              ip = 1788;
      end

       1788 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1789;
      end

       1789 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 808] = localMem[808] + 1;
              ip = 1790;
      end

       1790 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1784;
      end

       1791 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1792;
      end

       1792 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 810] = heapMem[localMem[785]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1793;
      end

       1793 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 811] = localMem[810] + 1;
              ip = 1794;
      end

       1794 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 812] = heapMem[localMem[785]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1795;
      end

       1795 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1796;
      end

       1796 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 813] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1797;
      end

       1797 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1798;
      end

       1798 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[813] >= localMem[811] ? 1804 : 1799;
      end

       1799 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 814] = heapMem[localMem[812]*10 + localMem[813]];
              updateArrayLength(2, 0, 0);
              ip = 1800;
      end

       1800 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[814]*10 + 2] = localMem[785];
              updateArrayLength(1, localMem[814], 2);
              ip = 1801;
      end

       1801 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1802;
      end

       1802 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 813] = localMem[813] + 1;
              ip = 1803;
      end

       1803 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1797;
      end

       1804 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1805;
      end

       1805 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1821;
      end

       1806 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1807;
      end

       1807 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 815] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 815] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 815]] = 0;
              ip = 1808;
      end

       1808 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[727]*10 + 6] = localMem[815];
              updateArrayLength(1, localMem[727], 6);
              ip = 1809;
      end

       1809 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 816] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1810;
      end

       1810 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 817] = heapMem[localMem[782]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1811;
      end

       1811 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 818] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1813;
      end

       1813 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 819] = heapMem[localMem[782]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1814;
      end

       1814 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 820] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1816;
      end

       1816 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 821] = heapMem[localMem[785]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1817;
      end

       1817 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 822] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1819;
      end

       1819 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 823] = heapMem[localMem[785]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1820;
      end

       1820 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1822;
      end

       1822 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[782]*10 + 2] = localMem[727];
              updateArrayLength(1, localMem[782], 2);
              ip = 1823;
      end

       1823 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[785]*10 + 2] = localMem[727];
              updateArrayLength(1, localMem[785], 2);
              ip = 1824;
      end

       1824 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 824] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1825;
      end

       1825 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 825] = heapMem[localMem[824]*10 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1826;
      end

       1826 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 826] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1827;
      end

       1827 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 827] = heapMem[localMem[826]*10 + localMem[732]];
              updateArrayLength(2, 0, 0);
              ip = 1828;
      end

       1828 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 828] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1829;
      end

       1829 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[828]*10 + 0] = localMem[825];
              updateArrayLength(1, localMem[828], 0);
              ip = 1830;
      end

       1830 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 829] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1831;
      end

       1831 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[829]*10 + 0] = localMem[827];
              updateArrayLength(1, localMem[829], 0);
              ip = 1832;
      end

       1832 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 830] = heapMem[localMem[727]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1833;
      end

       1833 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[830]*10 + 0] = localMem[782];
              updateArrayLength(1, localMem[830], 0);
              ip = 1834;
      end

       1834 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 831] = heapMem[localMem[727]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1835;
      end

       1835 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[831]*10 + 1] = localMem[785];
              updateArrayLength(1, localMem[831], 1);
              ip = 1836;
      end

       1836 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[727]*10 + 0] = 1;
              updateArrayLength(1, localMem[727], 0);
              ip = 1837;
      end

       1837 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 832] = heapMem[localMem[727]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1838;
      end

       1838 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[832]] = 1;
              ip = 1839;
      end

       1839 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 833] = heapMem[localMem[727]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1840;
      end

       1840 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[833]] = 1;
              ip = 1841;
      end

       1841 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 834] = heapMem[localMem[727]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1842;
      end

       1842 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[834]] = 2;
              ip = 1843;
      end

       1843 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1845;
      end

       1844 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1850;
      end

       1845 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1846;
      end

       1846 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 728] = 1;
              updateArrayLength(2, 0, 0);
              ip = 1847;
      end

       1847 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1850;
      end

       1848 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1849;
      end

       1849 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 728] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1850;
      end

       1850 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1851;
      end

       1851 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[728] != 0 ? 1853 : 1852;
      end

       1852 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 499] = localMem[727];
              updateArrayLength(2, 0, 0);
              ip = 1853;
      end

       1853 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1854;
      end

       1854 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1855;
      end

       1855 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 607] = localMem[607] + 1;
              ip = 1856;
      end

       1856 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1358;
      end

       1857 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1858;
      end

       1858 :
      begin                                                                     // assert
//$display("AAAA %4d %4d assert", steps, ip);
            ip = 1859;
      end

       1859 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1860;
      end

       1860 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1861;
      end

       1861 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1862;
      end

       1862 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 835] = heapMem[localMem[476]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1863;
      end

       1863 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 836] = heapMem[localMem[476]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 1864;
      end

       1864 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 837] = heapMem[localMem[476]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1865;
      end

       1865 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[836] != 1 ? 1869 : 1866;
      end

       1866 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 838] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1867;
      end

       1867 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[838]*10 + localMem[837]] = 22;
              updateArrayLength(1, localMem[838], localMem[837]);
              ip = 1868;
      end

       1868 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2115;
      end

       1869 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1870;
      end

       1870 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[836] != 2 ? 1878 : 1871;
      end

       1871 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 839] = localMem[837] + 1;
              ip = 1872;
      end

       1872 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 840] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1873;
      end

       1873 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 841] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1875;
      end

       1875 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[835]*10 + 0] = heapMem[localMem[835]*10 + 0] + 1;
              ip = 1877;
      end

       1877 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1884;
      end

       1878 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1879;
      end

       1879 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 842] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1880;
      end

       1880 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 843] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1882;
      end

       1882 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[835]*10 + 0] = heapMem[localMem[835]*10 + 0] + 1;
              ip = 1884;
      end

       1884 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1885;
      end

       1885 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 1886;
      end

       1886 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1887;
      end

       1887 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 845] = heapMem[localMem[835]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1888;
      end

       1888 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 846] = heapMem[localMem[835]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 1889;
      end

       1889 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 847] = heapMem[localMem[846]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1890;
      end

       1890 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[845] <  localMem[847] ? 2110 : 1891;
      end

       1891 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 848] = localMem[847];
              updateArrayLength(2, 0, 0);
              ip = 1892;
      end

       1892 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 848] = localMem[848] >> 1;
              ip = 1893;
      end

       1893 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 849] = localMem[848] + 1;
              ip = 1894;
      end

       1894 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 850] = heapMem[localMem[835]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 1895;
      end

       1895 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[850] == 0 ? 1992 : 1896;
      end

       1896 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 851] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 851] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 851]] = 0;
              ip = 1897;
      end

       1897 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 0] = localMem[848];
              updateArrayLength(1, localMem[851], 0);
              ip = 1898;
      end

       1898 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 2] = 0;
              updateArrayLength(1, localMem[851], 2);
              ip = 1899;
      end

       1899 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 852] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 852] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 852]] = 0;
              ip = 1900;
      end

       1900 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 4] = localMem[852];
              updateArrayLength(1, localMem[851], 4);
              ip = 1901;
      end

       1901 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 853] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 853] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 853]] = 0;
              ip = 1902;
      end

       1902 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 5] = localMem[853];
              updateArrayLength(1, localMem[851], 5);
              ip = 1903;
      end

       1903 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 6] = 0;
              updateArrayLength(1, localMem[851], 6);
              ip = 1904;
      end

       1904 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 3] = localMem[846];
              updateArrayLength(1, localMem[851], 3);
              ip = 1905;
      end

       1905 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[846]*10 + 1] = heapMem[localMem[846]*10 + 1] + 1;
              ip = 1906;
      end

       1906 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 1] = heapMem[localMem[846]*10 + 1];
              updateArrayLength(1, localMem[851], 1);
              ip = 1907;
      end

       1907 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 854] = !heapMem[localMem[835]*10 + 6];
              ip = 1908;
      end

       1908 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[854] != 0 ? 1937 : 1909;
      end

       1909 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 855] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 855] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 855]] = 0;
              ip = 1910;
      end

       1910 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 6] = localMem[855];
              updateArrayLength(1, localMem[851], 6);
              ip = 1911;
      end

       1911 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 856] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1912;
      end

       1912 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 857] = heapMem[localMem[851]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1913;
      end

       1913 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 858] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1915;
      end

       1915 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 859] = heapMem[localMem[851]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1916;
      end

       1916 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 860] = heapMem[localMem[835]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1918;
      end

       1918 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 861] = heapMem[localMem[851]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1919;
      end

       1919 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 862] = localMem[848] + 1;
              ip = 1920;
      end

       1920 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 863] = heapMem[localMem[851]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1922;
      end

       1922 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 864] = localMem[863] + 1;
              ip = 1923;
      end

       1923 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 865] = heapMem[localMem[851]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1924;
      end

       1924 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1925;
      end

       1925 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 866] = 0;
              updateArrayLength(2, 0, 0);
              ip = 1926;
      end

       1926 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1927;
      end

       1927 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[866] >= localMem[864] ? 1933 : 1928;
      end

       1928 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 867] = heapMem[localMem[865]*10 + localMem[866]];
              updateArrayLength(2, 0, 0);
              ip = 1929;
      end

       1929 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[867]*10 + 2] = localMem[851];
              updateArrayLength(1, localMem[867], 2);
              ip = 1930;
      end

       1930 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1931;
      end

       1931 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 866] = localMem[866] + 1;
              ip = 1932;
      end

       1932 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1926;
      end

       1933 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1934;
      end

       1934 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 868] = heapMem[localMem[835]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1935;
      end

       1935 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[868]] = localMem[849];
              ip = 1936;
      end

       1936 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1944;
      end

       1937 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1938;
      end

       1938 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 869] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1939;
      end

       1939 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 870] = heapMem[localMem[851]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1940;
      end

       1940 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 871] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1942;
      end

       1942 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 872] = heapMem[localMem[851]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1943;
      end

       1943 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1945;
      end

       1945 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[835]*10 + 0] = localMem[848];
              updateArrayLength(1, localMem[835], 0);
              ip = 1946;
      end

       1946 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[851]*10 + 2] = localMem[850];
              updateArrayLength(1, localMem[851], 2);
              ip = 1947;
      end

       1947 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 873] = heapMem[localMem[850]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 1948;
      end

       1948 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 874] = heapMem[localMem[850]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1949;
      end

       1949 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 875] = heapMem[localMem[874]*10 + localMem[873]];
              updateArrayLength(2, 0, 0);
              ip = 1950;
      end

       1950 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[875] != localMem[835] ? 1969 : 1951;
      end

       1951 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 876] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1952;
      end

       1952 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 877] = heapMem[localMem[876]*10 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1953;
      end

       1953 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 878] = heapMem[localMem[850]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1954;
      end

       1954 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[878]*10 + localMem[873]] = localMem[877];
              updateArrayLength(1, localMem[878], localMem[873]);
              ip = 1955;
      end

       1955 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 879] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1956;
      end

       1956 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 880] = heapMem[localMem[879]*10 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1957;
      end

       1957 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 881] = heapMem[localMem[850]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1958;
      end

       1958 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[881]*10 + localMem[873]] = localMem[880];
              updateArrayLength(1, localMem[881], localMem[873]);
              ip = 1959;
      end

       1959 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 882] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1960;
      end

       1960 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[882]] = localMem[848];
              ip = 1961;
      end

       1961 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 883] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1962;
      end

       1962 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[883]] = localMem[848];
              ip = 1963;
      end

       1963 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 884] = localMem[873] + 1;
              ip = 1964;
      end

       1964 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[850]*10 + 0] = localMem[884];
              updateArrayLength(1, localMem[850], 0);
              ip = 1965;
      end

       1965 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 885] = heapMem[localMem[850]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1966;
      end

       1966 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[885]*10 + localMem[884]] = localMem[851];
              updateArrayLength(1, localMem[885], localMem[884]);
              ip = 1967;
      end

       1967 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2107;
      end

       1968 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 1991;
      end

       1969 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1970;
      end

       1970 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 1971;
      end

       1971 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 886] = heapMem[localMem[850]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1972;
      end

       1972 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 887] = 0; k = arraySizes[localMem[886]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[886] * NArea + i] == localMem[835]) localMem[0 + 887] = i + 1;
              end
              ip = 1973;
      end

       1973 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 887] = localMem[887] - 1;
              ip = 1974;
      end

       1974 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 888] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1975;
      end

       1975 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 889] = heapMem[localMem[888]*10 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1976;
      end

       1976 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 890] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1977;
      end

       1977 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 891] = heapMem[localMem[890]*10 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 1978;
      end

       1978 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 892] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1979;
      end

       1979 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[892]] = localMem[848];
              ip = 1980;
      end

       1980 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 893] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1981;
      end

       1981 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[893]] = localMem[848];
              ip = 1982;
      end

       1982 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 894] = heapMem[localMem[850]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 1983;
      end

       1983 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 895] = heapMem[localMem[850]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 1985;
      end

       1985 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 896] = heapMem[localMem[850]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 1987;
      end

       1987 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 897] = localMem[887] + 1;
              ip = 1988;
      end

       1988 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
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
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[850]*10 + 0] = heapMem[localMem[850]*10 + 0] + 1;
              ip = 1990;
      end

       1990 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2107;
      end

       1991 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1992;
      end

       1992 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 1993;
      end

       1993 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 898] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 898] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 898]] = 0;
              ip = 1994;
      end

       1994 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 0] = localMem[848];
              updateArrayLength(1, localMem[898], 0);
              ip = 1995;
      end

       1995 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 2] = 0;
              updateArrayLength(1, localMem[898], 2);
              ip = 1996;
      end

       1996 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 899] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 899] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 899]] = 0;
              ip = 1997;
      end

       1997 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 4] = localMem[899];
              updateArrayLength(1, localMem[898], 4);
              ip = 1998;
      end

       1998 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 900] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 900] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 900]] = 0;
              ip = 1999;
      end

       1999 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 5] = localMem[900];
              updateArrayLength(1, localMem[898], 5);
              ip = 2000;
      end

       2000 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 6] = 0;
              updateArrayLength(1, localMem[898], 6);
              ip = 2001;
      end

       2001 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 3] = localMem[846];
              updateArrayLength(1, localMem[898], 3);
              ip = 2002;
      end

       2002 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[846]*10 + 1] = heapMem[localMem[846]*10 + 1] + 1;
              ip = 2003;
      end

       2003 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 1] = heapMem[localMem[846]*10 + 1];
              updateArrayLength(1, localMem[898], 1);
              ip = 2004;
      end

       2004 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 901] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 901] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 901]] = 0;
              ip = 2005;
      end

       2005 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 0] = localMem[848];
              updateArrayLength(1, localMem[901], 0);
              ip = 2006;
      end

       2006 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 2] = 0;
              updateArrayLength(1, localMem[901], 2);
              ip = 2007;
      end

       2007 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 902] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 902] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 902]] = 0;
              ip = 2008;
      end

       2008 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 4] = localMem[902];
              updateArrayLength(1, localMem[901], 4);
              ip = 2009;
      end

       2009 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 903] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 903] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 903]] = 0;
              ip = 2010;
      end

       2010 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 5] = localMem[903];
              updateArrayLength(1, localMem[901], 5);
              ip = 2011;
      end

       2011 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 6] = 0;
              updateArrayLength(1, localMem[901], 6);
              ip = 2012;
      end

       2012 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 3] = localMem[846];
              updateArrayLength(1, localMem[901], 3);
              ip = 2013;
      end

       2013 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[846]*10 + 1] = heapMem[localMem[846]*10 + 1] + 1;
              ip = 2014;
      end

       2014 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 1] = heapMem[localMem[846]*10 + 1];
              updateArrayLength(1, localMem[901], 1);
              ip = 2015;
      end

       2015 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 904] = !heapMem[localMem[835]*10 + 6];
              ip = 2016;
      end

       2016 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[904] != 0 ? 2068 : 2017;
      end

       2017 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 905] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 905] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 905]] = 0;
              ip = 2018;
      end

       2018 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 6] = localMem[905];
              updateArrayLength(1, localMem[898], 6);
              ip = 2019;
      end

       2019 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 906] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 906] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 906]] = 0;
              ip = 2020;
      end

       2020 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 6] = localMem[906];
              updateArrayLength(1, localMem[901], 6);
              ip = 2021;
      end

       2021 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 907] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2022;
      end

       2022 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 908] = heapMem[localMem[898]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2023;
      end

       2023 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 909] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2025;
      end

       2025 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 910] = heapMem[localMem[898]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2026;
      end

       2026 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 911] = heapMem[localMem[835]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2028;
      end

       2028 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 912] = heapMem[localMem[898]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2029;
      end

       2029 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 913] = localMem[848] + 1;
              ip = 2030;
      end

       2030 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 914] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2032;
      end

       2032 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 915] = heapMem[localMem[901]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2033;
      end

       2033 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 916] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2035;
      end

       2035 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 917] = heapMem[localMem[901]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2036;
      end

       2036 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 918] = heapMem[localMem[835]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2038;
      end

       2038 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 919] = heapMem[localMem[901]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2039;
      end

       2039 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 920] = localMem[848] + 1;
              ip = 2040;
      end

       2040 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 921] = heapMem[localMem[898]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2042;
      end

       2042 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 922] = localMem[921] + 1;
              ip = 2043;
      end

       2043 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 923] = heapMem[localMem[898]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2044;
      end

       2044 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2045;
      end

       2045 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 924] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2046;
      end

       2046 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2047;
      end

       2047 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[924] >= localMem[922] ? 2053 : 2048;
      end

       2048 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 925] = heapMem[localMem[923]*10 + localMem[924]];
              updateArrayLength(2, 0, 0);
              ip = 2049;
      end

       2049 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[925]*10 + 2] = localMem[898];
              updateArrayLength(1, localMem[925], 2);
              ip = 2050;
      end

       2050 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2051;
      end

       2051 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 924] = localMem[924] + 1;
              ip = 2052;
      end

       2052 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2046;
      end

       2053 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2054;
      end

       2054 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 926] = heapMem[localMem[901]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2055;
      end

       2055 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 927] = localMem[926] + 1;
              ip = 2056;
      end

       2056 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 928] = heapMem[localMem[901]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2057;
      end

       2057 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2058;
      end

       2058 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 929] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2059;
      end

       2059 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2060;
      end

       2060 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[929] >= localMem[927] ? 2066 : 2061;
      end

       2061 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 930] = heapMem[localMem[928]*10 + localMem[929]];
              updateArrayLength(2, 0, 0);
              ip = 2062;
      end

       2062 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[930]*10 + 2] = localMem[901];
              updateArrayLength(1, localMem[930], 2);
              ip = 2063;
      end

       2063 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2064;
      end

       2064 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 929] = localMem[929] + 1;
              ip = 2065;
      end

       2065 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2059;
      end

       2066 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2067;
      end

       2067 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2083;
      end

       2068 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2069;
      end

       2069 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 931] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 931] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 931]] = 0;
              ip = 2070;
      end

       2070 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[835]*10 + 6] = localMem[931];
              updateArrayLength(1, localMem[835], 6);
              ip = 2071;
      end

       2071 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 932] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2072;
      end

       2072 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 933] = heapMem[localMem[898]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2073;
      end

       2073 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 934] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2075;
      end

       2075 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 935] = heapMem[localMem[898]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2076;
      end

       2076 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 936] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2078;
      end

       2078 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 937] = heapMem[localMem[901]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2079;
      end

       2079 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 938] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2081;
      end

       2081 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 939] = heapMem[localMem[901]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2082;
      end

       2082 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
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
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2084;
      end

       2084 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[898]*10 + 2] = localMem[835];
              updateArrayLength(1, localMem[898], 2);
              ip = 2085;
      end

       2085 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[901]*10 + 2] = localMem[835];
              updateArrayLength(1, localMem[901], 2);
              ip = 2086;
      end

       2086 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 940] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2087;
      end

       2087 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 941] = heapMem[localMem[940]*10 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 2088;
      end

       2088 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 942] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2089;
      end

       2089 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 943] = heapMem[localMem[942]*10 + localMem[848]];
              updateArrayLength(2, 0, 0);
              ip = 2090;
      end

       2090 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 944] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2091;
      end

       2091 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[944]*10 + 0] = localMem[941];
              updateArrayLength(1, localMem[944], 0);
              ip = 2092;
      end

       2092 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 945] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2093;
      end

       2093 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[945]*10 + 0] = localMem[943];
              updateArrayLength(1, localMem[945], 0);
              ip = 2094;
      end

       2094 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 946] = heapMem[localMem[835]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2095;
      end

       2095 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[946]*10 + 0] = localMem[898];
              updateArrayLength(1, localMem[946], 0);
              ip = 2096;
      end

       2096 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 947] = heapMem[localMem[835]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2097;
      end

       2097 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[947]*10 + 1] = localMem[901];
              updateArrayLength(1, localMem[947], 1);
              ip = 2098;
      end

       2098 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[835]*10 + 0] = 1;
              updateArrayLength(1, localMem[835], 0);
              ip = 2099;
      end

       2099 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 948] = heapMem[localMem[835]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2100;
      end

       2100 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[948]] = 1;
              ip = 2101;
      end

       2101 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 949] = heapMem[localMem[835]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2102;
      end

       2102 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[949]] = 1;
              ip = 2103;
      end

       2103 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 950] = heapMem[localMem[835]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2104;
      end

       2104 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[950]] = 2;
              ip = 2105;
      end

       2105 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2107;
      end

       2106 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2112;
      end

       2107 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2108;
      end

       2108 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 844] = 1;
              updateArrayLength(2, 0, 0);
              ip = 2109;
      end

       2109 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2112;
      end

       2110 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2111;
      end

       2111 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 844] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2112;
      end

       2112 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2113;
      end

       2113 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2114;
      end

       2114 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2115;
      end

       2115 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2116;
      end

       2116 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
              freedArrays[freedArraysTop] = localMem[476];
              freedArraysTop = freedArraysTop + 1;
              ip = 2117;
      end

       2117 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 951] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 951] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 951]] = 0;
              ip = 2118;
      end

       2118 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2119;
      end

       2119 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 952] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 2120;
      end

       2120 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[952] != 0 ? 2143 : 2121;
      end

       2121 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 953] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 953] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 953]] = 0;
              ip = 2122;
      end

       2122 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[953]*10 + 0] = 1;
              updateArrayLength(1, localMem[953], 0);
              ip = 2123;
      end

       2123 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[953]*10 + 2] = 0;
              updateArrayLength(1, localMem[953], 2);
              ip = 2124;
      end

       2124 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 954] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 954] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 954]] = 0;
              ip = 2125;
      end

       2125 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[953]*10 + 4] = localMem[954];
              updateArrayLength(1, localMem[953], 4);
              ip = 2126;
      end

       2126 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 955] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 955] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 955]] = 0;
              ip = 2127;
      end

       2127 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[953]*10 + 5] = localMem[955];
              updateArrayLength(1, localMem[953], 5);
              ip = 2128;
      end

       2128 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[953]*10 + 6] = 0;
              updateArrayLength(1, localMem[953], 6);
              ip = 2129;
      end

       2129 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[953]*10 + 3] = localMem[0];
              updateArrayLength(1, localMem[953], 3);
              ip = 2130;
      end

       2130 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 1] = heapMem[localMem[0]*10 + 1] + 1;
              ip = 2131;
      end

       2131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[953]*10 + 1] = heapMem[localMem[0]*10 + 1];
              updateArrayLength(1, localMem[953], 1);
              ip = 2132;
      end

       2132 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 956] = heapMem[localMem[953]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2133;
      end

       2133 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[956]*10 + 0] = 3;
              updateArrayLength(1, localMem[956], 0);
              ip = 2134;
      end

       2134 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 957] = heapMem[localMem[953]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2135;
      end

       2135 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[957]*10 + 0] = 33;
              updateArrayLength(1, localMem[957], 0);
              ip = 2136;
      end

       2136 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 2137;
      end

       2137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[0]*10 + 3] = localMem[953];
              updateArrayLength(1, localMem[0], 3);
              ip = 2138;
      end

       2138 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 958] = heapMem[localMem[953]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2139;
      end

       2139 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[958]] = 1;
              ip = 2140;
      end

       2140 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 959] = heapMem[localMem[953]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2141;
      end

       2141 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[959]] = 1;
              ip = 2142;
      end

       2142 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3171;
      end

       2143 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2144;
      end

       2144 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 960] = heapMem[localMem[952]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2145;
      end

       2145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 961] = heapMem[localMem[0]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2146;
      end

       2146 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[960] >= localMem[961] ? 2182 : 2147;
      end

       2147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 962] = heapMem[localMem[952]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2148;
      end

       2148 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[962] != 0 ? 2181 : 2149;
      end

       2149 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 963] = !heapMem[localMem[952]*10 + 6];
              ip = 2150;
      end

       2150 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[963] == 0 ? 2180 : 2151;
      end

       2151 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 964] = heapMem[localMem[952]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2152;
      end

       2152 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 965] = 0; k = arraySizes[localMem[964]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[964] * NArea + i] == 3) localMem[0 + 965] = i + 1;
              end
              ip = 2153;
      end

       2153 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[965] == 0 ? 2158 : 2154;
      end

       2154 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 965] = localMem[965] - 1;
              ip = 2155;
      end

       2155 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 966] = heapMem[localMem[952]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2156;
      end

       2156 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[966]*10 + localMem[965]] = 33;
              updateArrayLength(1, localMem[966], localMem[965]);
              ip = 2157;
      end

       2157 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3171;
      end

       2158 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2159;
      end

       2159 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[964]] = localMem[960];
              ip = 2160;
      end

       2160 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 967] = heapMem[localMem[952]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2161;
      end

       2161 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[967]] = localMem[960];
              ip = 2162;
      end

       2162 :
      begin                                                                     // arrayCountGreater
//$display("AAAA %4d %4d arrayCountGreater", steps, ip);
              j = 0; k = arraySizes[localMem[964]];
//$display("AAAAA k=%d  source2=%d", k, 3);
              for(i = 0; i < NArea; i = i + 1) begin
//$display("AAAAA i=%d  value=%d", i, heapMem[localMem[964] * NArea + i]);
                if (i < k && heapMem[localMem[964] * NArea + i] > 3) j = j + 1;
              end
              localMem[0 + 968] = j;
              ip = 2163;
      end

       2163 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[968] != 0 ? 2171 : 2164;
      end

       2164 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 969] = heapMem[localMem[952]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2165;
      end

       2165 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[969]*10 + localMem[960]] = 3;
              updateArrayLength(1, localMem[969], localMem[960]);
              ip = 2166;
      end

       2166 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 970] = heapMem[localMem[952]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2167;
      end

       2167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[970]*10 + localMem[960]] = 33;
              updateArrayLength(1, localMem[970], localMem[960]);
              ip = 2168;
      end

       2168 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[952]*10 + 0] = localMem[960] + 1;
              ip = 2169;
      end

       2169 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 2170;
      end

       2170 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3171;
      end

       2171 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2172;
      end

       2172 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[964]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[964] * NArea + i] < 3) j = j + 1;
              end
              localMem[0 + 971] = j;
              ip = 2173;
      end

       2173 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 972] = heapMem[localMem[952]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2174;
      end

       2174 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[972] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[971], localMem[972], arraySizes[localMem[972]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[971] && i <= arraySizes[localMem[972]]) begin
                  heapMem[NArea * localMem[972] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[972] + localMem[971]] = 3;                                    // Insert new value
              arraySizes[localMem[972]] = arraySizes[localMem[972]] + 1;                              // Increase array size
              ip = 2175;
      end

       2175 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 973] = heapMem[localMem[952]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2176;
      end

       2176 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[973] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[971], localMem[973], arraySizes[localMem[973]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[971] && i <= arraySizes[localMem[973]]) begin
                  heapMem[NArea * localMem[973] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[973] + localMem[971]] = 33;                                    // Insert new value
              arraySizes[localMem[973]] = arraySizes[localMem[973]] + 1;                              // Increase array size
              ip = 2177;
      end

       2177 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[952]*10 + 0] = heapMem[localMem[952]*10 + 0] + 1;
              ip = 2178;
      end

       2178 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 2179;
      end

       2179 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3171;
      end

       2180 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2181;
      end

       2181 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2182;
      end

       2182 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2183;
      end

       2183 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 974] = heapMem[localMem[0]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 2184;
      end

       2184 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2185;
      end

       2185 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 976] = heapMem[localMem[974]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2186;
      end

       2186 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 977] = heapMem[localMem[974]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 2187;
      end

       2187 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 978] = heapMem[localMem[977]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2188;
      end

       2188 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[976] <  localMem[978] ? 2408 : 2189;
      end

       2189 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 979] = localMem[978];
              updateArrayLength(2, 0, 0);
              ip = 2190;
      end

       2190 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 979] = localMem[979] >> 1;
              ip = 2191;
      end

       2191 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 980] = localMem[979] + 1;
              ip = 2192;
      end

       2192 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 981] = heapMem[localMem[974]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2193;
      end

       2193 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[981] == 0 ? 2290 : 2194;
      end

       2194 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 982] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 982] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 982]] = 0;
              ip = 2195;
      end

       2195 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 0] = localMem[979];
              updateArrayLength(1, localMem[982], 0);
              ip = 2196;
      end

       2196 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 2] = 0;
              updateArrayLength(1, localMem[982], 2);
              ip = 2197;
      end

       2197 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 983] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 983] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 983]] = 0;
              ip = 2198;
      end

       2198 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 4] = localMem[983];
              updateArrayLength(1, localMem[982], 4);
              ip = 2199;
      end

       2199 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 984] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 984] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 984]] = 0;
              ip = 2200;
      end

       2200 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 5] = localMem[984];
              updateArrayLength(1, localMem[982], 5);
              ip = 2201;
      end

       2201 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 6] = 0;
              updateArrayLength(1, localMem[982], 6);
              ip = 2202;
      end

       2202 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 3] = localMem[977];
              updateArrayLength(1, localMem[982], 3);
              ip = 2203;
      end

       2203 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[977]*10 + 1] = heapMem[localMem[977]*10 + 1] + 1;
              ip = 2204;
      end

       2204 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 1] = heapMem[localMem[977]*10 + 1];
              updateArrayLength(1, localMem[982], 1);
              ip = 2205;
      end

       2205 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 985] = !heapMem[localMem[974]*10 + 6];
              ip = 2206;
      end

       2206 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[985] != 0 ? 2235 : 2207;
      end

       2207 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 986] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 986] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 986]] = 0;
              ip = 2208;
      end

       2208 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 6] = localMem[986];
              updateArrayLength(1, localMem[982], 6);
              ip = 2209;
      end

       2209 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 987] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2210;
      end

       2210 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 988] = heapMem[localMem[982]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2211;
      end

       2211 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[988] + 0 + i] = heapMem[NArea * localMem[987] + localMem[980] + i];
                  updateArrayLength(1, localMem[988], 0 + i);
                end
              end
              ip = 2212;
      end

       2212 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 989] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2213;
      end

       2213 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 990] = heapMem[localMem[982]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2214;
      end

       2214 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[990] + 0 + i] = heapMem[NArea * localMem[989] + localMem[980] + i];
                  updateArrayLength(1, localMem[990], 0 + i);
                end
              end
              ip = 2215;
      end

       2215 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 991] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2216;
      end

       2216 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 992] = heapMem[localMem[982]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2217;
      end

       2217 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 993] = localMem[979] + 1;
              ip = 2218;
      end

       2218 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[993]) begin
                  heapMem[NArea * localMem[992] + 0 + i] = heapMem[NArea * localMem[991] + localMem[980] + i];
                  updateArrayLength(1, localMem[992], 0 + i);
                end
              end
              ip = 2219;
      end

       2219 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 994] = heapMem[localMem[982]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2220;
      end

       2220 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 995] = localMem[994] + 1;
              ip = 2221;
      end

       2221 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 996] = heapMem[localMem[982]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2222;
      end

       2222 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2223;
      end

       2223 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 997] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2224;
      end

       2224 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2225;
      end

       2225 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[997] >= localMem[995] ? 2231 : 2226;
      end

       2226 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 998] = heapMem[localMem[996]*10 + localMem[997]];
              updateArrayLength(2, 0, 0);
              ip = 2227;
      end

       2227 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[998]*10 + 2] = localMem[982];
              updateArrayLength(1, localMem[998], 2);
              ip = 2228;
      end

       2228 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2229;
      end

       2229 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 997] = localMem[997] + 1;
              ip = 2230;
      end

       2230 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2224;
      end

       2231 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2232;
      end

       2232 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 999] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2233;
      end

       2233 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[999]] = localMem[980];
              ip = 2234;
      end

       2234 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2242;
      end

       2235 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2236;
      end

       2236 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1000] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2237;
      end

       2237 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1001] = heapMem[localMem[982]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2238;
      end

       2238 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1001] + 0 + i] = heapMem[NArea * localMem[1000] + localMem[980] + i];
                  updateArrayLength(1, localMem[1001], 0 + i);
                end
              end
              ip = 2239;
      end

       2239 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1002] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2240;
      end

       2240 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1003] = heapMem[localMem[982]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2241;
      end

       2241 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1003] + 0 + i] = heapMem[NArea * localMem[1002] + localMem[980] + i];
                  updateArrayLength(1, localMem[1003], 0 + i);
                end
              end
              ip = 2242;
      end

       2242 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2243;
      end

       2243 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[974]*10 + 0] = localMem[979];
              updateArrayLength(1, localMem[974], 0);
              ip = 2244;
      end

       2244 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[982]*10 + 2] = localMem[981];
              updateArrayLength(1, localMem[982], 2);
              ip = 2245;
      end

       2245 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1004] = heapMem[localMem[981]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2246;
      end

       2246 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1005] = heapMem[localMem[981]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2247;
      end

       2247 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1006] = heapMem[localMem[1005]*10 + localMem[1004]];
              updateArrayLength(2, 0, 0);
              ip = 2248;
      end

       2248 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1006] != localMem[974] ? 2267 : 2249;
      end

       2249 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1007] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2250;
      end

       2250 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1008] = heapMem[localMem[1007]*10 + localMem[979]];
              updateArrayLength(2, 0, 0);
              ip = 2251;
      end

       2251 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1009] = heapMem[localMem[981]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2252;
      end

       2252 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1009]*10 + localMem[1004]] = localMem[1008];
              updateArrayLength(1, localMem[1009], localMem[1004]);
              ip = 2253;
      end

       2253 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1010] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2254;
      end

       2254 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1011] = heapMem[localMem[1010]*10 + localMem[979]];
              updateArrayLength(2, 0, 0);
              ip = 2255;
      end

       2255 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1012] = heapMem[localMem[981]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2256;
      end

       2256 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1012]*10 + localMem[1004]] = localMem[1011];
              updateArrayLength(1, localMem[1012], localMem[1004]);
              ip = 2257;
      end

       2257 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1013] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2258;
      end

       2258 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1013]] = localMem[979];
              ip = 2259;
      end

       2259 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1014] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2260;
      end

       2260 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1014]] = localMem[979];
              ip = 2261;
      end

       2261 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1015] = localMem[1004] + 1;
              ip = 2262;
      end

       2262 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[981]*10 + 0] = localMem[1015];
              updateArrayLength(1, localMem[981], 0);
              ip = 2263;
      end

       2263 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1016] = heapMem[localMem[981]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2264;
      end

       2264 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1016]*10 + localMem[1015]] = localMem[982];
              updateArrayLength(1, localMem[1016], localMem[1015]);
              ip = 2265;
      end

       2265 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2405;
      end

       2266 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2289;
      end

       2267 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2268;
      end

       2268 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 2269;
      end

       2269 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1017] = heapMem[localMem[981]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2270;
      end

       2270 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 1018] = 0; k = arraySizes[localMem[1017]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[1017] * NArea + i] == localMem[974]) localMem[0 + 1018] = i + 1;
              end
              ip = 2271;
      end

       2271 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 1018] = localMem[1018] - 1;
              ip = 2272;
      end

       2272 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1019] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2273;
      end

       2273 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1020] = heapMem[localMem[1019]*10 + localMem[979]];
              updateArrayLength(2, 0, 0);
              ip = 2274;
      end

       2274 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1021] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2275;
      end

       2275 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1022] = heapMem[localMem[1021]*10 + localMem[979]];
              updateArrayLength(2, 0, 0);
              ip = 2276;
      end

       2276 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1023] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2277;
      end

       2277 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1023]] = localMem[979];
              ip = 2278;
      end

       2278 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1024] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2279;
      end

       2279 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1024]] = localMem[979];
              ip = 2280;
      end

       2280 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1025] = heapMem[localMem[981]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2281;
      end

       2281 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1025] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1018], localMem[1025], arraySizes[localMem[1025]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1018] && i <= arraySizes[localMem[1025]]) begin
                  heapMem[NArea * localMem[1025] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1025] + localMem[1018]] = localMem[1020];                                    // Insert new value
              arraySizes[localMem[1025]] = arraySizes[localMem[1025]] + 1;                              // Increase array size
              ip = 2282;
      end

       2282 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1026] = heapMem[localMem[981]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2283;
      end

       2283 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1026] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1018], localMem[1026], arraySizes[localMem[1026]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1018] && i <= arraySizes[localMem[1026]]) begin
                  heapMem[NArea * localMem[1026] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1026] + localMem[1018]] = localMem[1022];                                    // Insert new value
              arraySizes[localMem[1026]] = arraySizes[localMem[1026]] + 1;                              // Increase array size
              ip = 2284;
      end

       2284 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1027] = heapMem[localMem[981]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2285;
      end

       2285 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1028] = localMem[1018] + 1;
              ip = 2286;
      end

       2286 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1027] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1028], localMem[1027], arraySizes[localMem[1027]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1028] && i <= arraySizes[localMem[1027]]) begin
                  heapMem[NArea * localMem[1027] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1027] + localMem[1028]] = localMem[982];                                    // Insert new value
              arraySizes[localMem[1027]] = arraySizes[localMem[1027]] + 1;                              // Increase array size
              ip = 2287;
      end

       2287 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[981]*10 + 0] = heapMem[localMem[981]*10 + 0] + 1;
              ip = 2288;
      end

       2288 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2405;
      end

       2289 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2290;
      end

       2290 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2291;
      end

       2291 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1029] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1029] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1029]] = 0;
              ip = 2292;
      end

       2292 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 0] = localMem[979];
              updateArrayLength(1, localMem[1029], 0);
              ip = 2293;
      end

       2293 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 2] = 0;
              updateArrayLength(1, localMem[1029], 2);
              ip = 2294;
      end

       2294 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1030] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1030] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1030]] = 0;
              ip = 2295;
      end

       2295 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 4] = localMem[1030];
              updateArrayLength(1, localMem[1029], 4);
              ip = 2296;
      end

       2296 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1031] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1031] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1031]] = 0;
              ip = 2297;
      end

       2297 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 5] = localMem[1031];
              updateArrayLength(1, localMem[1029], 5);
              ip = 2298;
      end

       2298 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 6] = 0;
              updateArrayLength(1, localMem[1029], 6);
              ip = 2299;
      end

       2299 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 3] = localMem[977];
              updateArrayLength(1, localMem[1029], 3);
              ip = 2300;
      end

       2300 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[977]*10 + 1] = heapMem[localMem[977]*10 + 1] + 1;
              ip = 2301;
      end

       2301 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 1] = heapMem[localMem[977]*10 + 1];
              updateArrayLength(1, localMem[1029], 1);
              ip = 2302;
      end

       2302 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1032] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1032] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1032]] = 0;
              ip = 2303;
      end

       2303 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 0] = localMem[979];
              updateArrayLength(1, localMem[1032], 0);
              ip = 2304;
      end

       2304 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 2] = 0;
              updateArrayLength(1, localMem[1032], 2);
              ip = 2305;
      end

       2305 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1033] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1033] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1033]] = 0;
              ip = 2306;
      end

       2306 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 4] = localMem[1033];
              updateArrayLength(1, localMem[1032], 4);
              ip = 2307;
      end

       2307 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1034] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1034] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1034]] = 0;
              ip = 2308;
      end

       2308 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 5] = localMem[1034];
              updateArrayLength(1, localMem[1032], 5);
              ip = 2309;
      end

       2309 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 6] = 0;
              updateArrayLength(1, localMem[1032], 6);
              ip = 2310;
      end

       2310 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 3] = localMem[977];
              updateArrayLength(1, localMem[1032], 3);
              ip = 2311;
      end

       2311 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[977]*10 + 1] = heapMem[localMem[977]*10 + 1] + 1;
              ip = 2312;
      end

       2312 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 1] = heapMem[localMem[977]*10 + 1];
              updateArrayLength(1, localMem[1032], 1);
              ip = 2313;
      end

       2313 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1035] = !heapMem[localMem[974]*10 + 6];
              ip = 2314;
      end

       2314 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1035] != 0 ? 2366 : 2315;
      end

       2315 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1036] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1036] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1036]] = 0;
              ip = 2316;
      end

       2316 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 6] = localMem[1036];
              updateArrayLength(1, localMem[1029], 6);
              ip = 2317;
      end

       2317 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1037] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1037] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1037]] = 0;
              ip = 2318;
      end

       2318 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 6] = localMem[1037];
              updateArrayLength(1, localMem[1032], 6);
              ip = 2319;
      end

       2319 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1038] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2320;
      end

       2320 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1039] = heapMem[localMem[1029]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2321;
      end

       2321 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1039] + 0 + i] = heapMem[NArea * localMem[1038] + 0 + i];
                  updateArrayLength(1, localMem[1039], 0 + i);
                end
              end
              ip = 2322;
      end

       2322 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1040] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2323;
      end

       2323 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1041] = heapMem[localMem[1029]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2324;
      end

       2324 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1041] + 0 + i] = heapMem[NArea * localMem[1040] + 0 + i];
                  updateArrayLength(1, localMem[1041], 0 + i);
                end
              end
              ip = 2325;
      end

       2325 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1042] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2326;
      end

       2326 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1043] = heapMem[localMem[1029]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2327;
      end

       2327 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1044] = localMem[979] + 1;
              ip = 2328;
      end

       2328 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1044]) begin
                  heapMem[NArea * localMem[1043] + 0 + i] = heapMem[NArea * localMem[1042] + 0 + i];
                  updateArrayLength(1, localMem[1043], 0 + i);
                end
              end
              ip = 2329;
      end

       2329 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1045] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2330;
      end

       2330 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1046] = heapMem[localMem[1032]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2331;
      end

       2331 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1046] + 0 + i] = heapMem[NArea * localMem[1045] + localMem[980] + i];
                  updateArrayLength(1, localMem[1046], 0 + i);
                end
              end
              ip = 2332;
      end

       2332 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1047] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2333;
      end

       2333 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1048] = heapMem[localMem[1032]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2334;
      end

       2334 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1048] + 0 + i] = heapMem[NArea * localMem[1047] + localMem[980] + i];
                  updateArrayLength(1, localMem[1048], 0 + i);
                end
              end
              ip = 2335;
      end

       2335 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1049] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2336;
      end

       2336 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1050] = heapMem[localMem[1032]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2337;
      end

       2337 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1051] = localMem[979] + 1;
              ip = 2338;
      end

       2338 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1051]) begin
                  heapMem[NArea * localMem[1050] + 0 + i] = heapMem[NArea * localMem[1049] + localMem[980] + i];
                  updateArrayLength(1, localMem[1050], 0 + i);
                end
              end
              ip = 2339;
      end

       2339 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1052] = heapMem[localMem[1029]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2340;
      end

       2340 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1053] = localMem[1052] + 1;
              ip = 2341;
      end

       2341 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1054] = heapMem[localMem[1029]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2342;
      end

       2342 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2343;
      end

       2343 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1055] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2344;
      end

       2344 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2345;
      end

       2345 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1055] >= localMem[1053] ? 2351 : 2346;
      end

       2346 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1056] = heapMem[localMem[1054]*10 + localMem[1055]];
              updateArrayLength(2, 0, 0);
              ip = 2347;
      end

       2347 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1056]*10 + 2] = localMem[1029];
              updateArrayLength(1, localMem[1056], 2);
              ip = 2348;
      end

       2348 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2349;
      end

       2349 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1055] = localMem[1055] + 1;
              ip = 2350;
      end

       2350 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2344;
      end

       2351 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2352;
      end

       2352 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1057] = heapMem[localMem[1032]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2353;
      end

       2353 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1058] = localMem[1057] + 1;
              ip = 2354;
      end

       2354 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1059] = heapMem[localMem[1032]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2355;
      end

       2355 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2356;
      end

       2356 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1060] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2357;
      end

       2357 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2358;
      end

       2358 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1060] >= localMem[1058] ? 2364 : 2359;
      end

       2359 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1061] = heapMem[localMem[1059]*10 + localMem[1060]];
              updateArrayLength(2, 0, 0);
              ip = 2360;
      end

       2360 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1061]*10 + 2] = localMem[1032];
              updateArrayLength(1, localMem[1061], 2);
              ip = 2361;
      end

       2361 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2362;
      end

       2362 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1060] = localMem[1060] + 1;
              ip = 2363;
      end

       2363 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2357;
      end

       2364 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2365;
      end

       2365 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2381;
      end

       2366 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2367;
      end

       2367 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1062] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1062] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1062]] = 0;
              ip = 2368;
      end

       2368 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[974]*10 + 6] = localMem[1062];
              updateArrayLength(1, localMem[974], 6);
              ip = 2369;
      end

       2369 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1063] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2370;
      end

       2370 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1064] = heapMem[localMem[1029]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2371;
      end

       2371 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1064] + 0 + i] = heapMem[NArea * localMem[1063] + 0 + i];
                  updateArrayLength(1, localMem[1064], 0 + i);
                end
              end
              ip = 2372;
      end

       2372 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1065] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2373;
      end

       2373 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1066] = heapMem[localMem[1029]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2374;
      end

       2374 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1066] + 0 + i] = heapMem[NArea * localMem[1065] + 0 + i];
                  updateArrayLength(1, localMem[1066], 0 + i);
                end
              end
              ip = 2375;
      end

       2375 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1067] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2376;
      end

       2376 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1068] = heapMem[localMem[1032]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2377;
      end

       2377 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1068] + 0 + i] = heapMem[NArea * localMem[1067] + localMem[980] + i];
                  updateArrayLength(1, localMem[1068], 0 + i);
                end
              end
              ip = 2378;
      end

       2378 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1069] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2379;
      end

       2379 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1070] = heapMem[localMem[1032]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2380;
      end

       2380 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[979]) begin
                  heapMem[NArea * localMem[1070] + 0 + i] = heapMem[NArea * localMem[1069] + localMem[980] + i];
                  updateArrayLength(1, localMem[1070], 0 + i);
                end
              end
              ip = 2381;
      end

       2381 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2382;
      end

       2382 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1029]*10 + 2] = localMem[974];
              updateArrayLength(1, localMem[1029], 2);
              ip = 2383;
      end

       2383 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1032]*10 + 2] = localMem[974];
              updateArrayLength(1, localMem[1032], 2);
              ip = 2384;
      end

       2384 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1071] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2385;
      end

       2385 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1072] = heapMem[localMem[1071]*10 + localMem[979]];
              updateArrayLength(2, 0, 0);
              ip = 2386;
      end

       2386 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1073] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2387;
      end

       2387 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1074] = heapMem[localMem[1073]*10 + localMem[979]];
              updateArrayLength(2, 0, 0);
              ip = 2388;
      end

       2388 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1075] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2389;
      end

       2389 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1075]*10 + 0] = localMem[1072];
              updateArrayLength(1, localMem[1075], 0);
              ip = 2390;
      end

       2390 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1076] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2391;
      end

       2391 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1076]*10 + 0] = localMem[1074];
              updateArrayLength(1, localMem[1076], 0);
              ip = 2392;
      end

       2392 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1077] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2393;
      end

       2393 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1077]*10 + 0] = localMem[1029];
              updateArrayLength(1, localMem[1077], 0);
              ip = 2394;
      end

       2394 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1078] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2395;
      end

       2395 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1078]*10 + 1] = localMem[1032];
              updateArrayLength(1, localMem[1078], 1);
              ip = 2396;
      end

       2396 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[974]*10 + 0] = 1;
              updateArrayLength(1, localMem[974], 0);
              ip = 2397;
      end

       2397 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1079] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2398;
      end

       2398 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1079]] = 1;
              ip = 2399;
      end

       2399 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1080] = heapMem[localMem[974]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2400;
      end

       2400 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1080]] = 1;
              ip = 2401;
      end

       2401 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1081] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2402;
      end

       2402 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1081]] = 2;
              ip = 2403;
      end

       2403 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2405;
      end

       2404 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2410;
      end

       2405 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2406;
      end

       2406 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 975] = 1;
              updateArrayLength(2, 0, 0);
              ip = 2407;
      end

       2407 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2410;
      end

       2408 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2409;
      end

       2409 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 975] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2410;
      end

       2410 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2411;
      end

       2411 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2412;
      end

       2412 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2413;
      end

       2413 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1082] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2414;
      end

       2414 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2415;
      end

       2415 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1082] >= 99 ? 2913 : 2416;
      end

       2416 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1083] = heapMem[localMem[974]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2417;
      end

       2417 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 1084] = localMem[1083] - 1;
              ip = 2418;
      end

       2418 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1085] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2419;
      end

       2419 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1086] = heapMem[localMem[1085]*10 + localMem[1084]];
              updateArrayLength(2, 0, 0);
              ip = 2420;
      end

       2420 :
      begin                                                                     // jLe
//$display("AAAA %4d %4d jLe", steps, ip);
              ip = 3 <= localMem[1086] ? 2661 : 2421;
      end

       2421 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1087] = !heapMem[localMem[974]*10 + 6];
              ip = 2422;
      end

       2422 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[1087] == 0 ? 2427 : 2423;
      end

       2423 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[951]*10 + 0] = localMem[974];
              updateArrayLength(1, localMem[951], 0);
              ip = 2424;
      end

       2424 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[951]*10 + 1] = 2;
              updateArrayLength(1, localMem[951], 1);
              ip = 2425;
      end

       2425 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[951]*10 + 2] = localMem[1083] - 1;
              ip = 2426;
      end

       2426 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2917;
      end

       2427 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2428;
      end

       2428 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1088] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2429;
      end

       2429 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1089] = heapMem[localMem[1088]*10 + localMem[1083]];
              updateArrayLength(2, 0, 0);
              ip = 2430;
      end

       2430 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2431;
      end

       2431 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1091] = heapMem[localMem[1089]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2432;
      end

       2432 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1092] = heapMem[localMem[1089]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 2433;
      end

       2433 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1093] = heapMem[localMem[1092]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2434;
      end

       2434 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[1091] <  localMem[1093] ? 2654 : 2435;
      end

       2435 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1094] = localMem[1093];
              updateArrayLength(2, 0, 0);
              ip = 2436;
      end

       2436 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 1094] = localMem[1094] >> 1;
              ip = 2437;
      end

       2437 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1095] = localMem[1094] + 1;
              ip = 2438;
      end

       2438 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1096] = heapMem[localMem[1089]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2439;
      end

       2439 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[1096] == 0 ? 2536 : 2440;
      end

       2440 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1097] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1097] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1097]] = 0;
              ip = 2441;
      end

       2441 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 0] = localMem[1094];
              updateArrayLength(1, localMem[1097], 0);
              ip = 2442;
      end

       2442 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 2] = 0;
              updateArrayLength(1, localMem[1097], 2);
              ip = 2443;
      end

       2443 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1098] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1098] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1098]] = 0;
              ip = 2444;
      end

       2444 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 4] = localMem[1098];
              updateArrayLength(1, localMem[1097], 4);
              ip = 2445;
      end

       2445 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1099] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1099] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1099]] = 0;
              ip = 2446;
      end

       2446 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 5] = localMem[1099];
              updateArrayLength(1, localMem[1097], 5);
              ip = 2447;
      end

       2447 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 6] = 0;
              updateArrayLength(1, localMem[1097], 6);
              ip = 2448;
      end

       2448 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 3] = localMem[1092];
              updateArrayLength(1, localMem[1097], 3);
              ip = 2449;
      end

       2449 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1092]*10 + 1] = heapMem[localMem[1092]*10 + 1] + 1;
              ip = 2450;
      end

       2450 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 1] = heapMem[localMem[1092]*10 + 1];
              updateArrayLength(1, localMem[1097], 1);
              ip = 2451;
      end

       2451 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1100] = !heapMem[localMem[1089]*10 + 6];
              ip = 2452;
      end

       2452 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1100] != 0 ? 2481 : 2453;
      end

       2453 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1101] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1101] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1101]] = 0;
              ip = 2454;
      end

       2454 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 6] = localMem[1101];
              updateArrayLength(1, localMem[1097], 6);
              ip = 2455;
      end

       2455 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1102] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2456;
      end

       2456 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1103] = heapMem[localMem[1097]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2457;
      end

       2457 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1103] + 0 + i] = heapMem[NArea * localMem[1102] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1103], 0 + i);
                end
              end
              ip = 2458;
      end

       2458 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1104] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2459;
      end

       2459 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1105] = heapMem[localMem[1097]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2460;
      end

       2460 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1105] + 0 + i] = heapMem[NArea * localMem[1104] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1105], 0 + i);
                end
              end
              ip = 2461;
      end

       2461 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1106] = heapMem[localMem[1089]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2462;
      end

       2462 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1107] = heapMem[localMem[1097]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2463;
      end

       2463 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1108] = localMem[1094] + 1;
              ip = 2464;
      end

       2464 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1108]) begin
                  heapMem[NArea * localMem[1107] + 0 + i] = heapMem[NArea * localMem[1106] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1107], 0 + i);
                end
              end
              ip = 2465;
      end

       2465 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1109] = heapMem[localMem[1097]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2466;
      end

       2466 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1110] = localMem[1109] + 1;
              ip = 2467;
      end

       2467 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1111] = heapMem[localMem[1097]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2468;
      end

       2468 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2469;
      end

       2469 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1112] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2470;
      end

       2470 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2471;
      end

       2471 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1112] >= localMem[1110] ? 2477 : 2472;
      end

       2472 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1113] = heapMem[localMem[1111]*10 + localMem[1112]];
              updateArrayLength(2, 0, 0);
              ip = 2473;
      end

       2473 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1113]*10 + 2] = localMem[1097];
              updateArrayLength(1, localMem[1113], 2);
              ip = 2474;
      end

       2474 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2475;
      end

       2475 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1112] = localMem[1112] + 1;
              ip = 2476;
      end

       2476 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2470;
      end

       2477 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2478;
      end

       2478 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1114] = heapMem[localMem[1089]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2479;
      end

       2479 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1114]] = localMem[1095];
              ip = 2480;
      end

       2480 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2488;
      end

       2481 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2482;
      end

       2482 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1115] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2483;
      end

       2483 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1116] = heapMem[localMem[1097]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2484;
      end

       2484 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1116] + 0 + i] = heapMem[NArea * localMem[1115] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1116], 0 + i);
                end
              end
              ip = 2485;
      end

       2485 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1117] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2486;
      end

       2486 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1118] = heapMem[localMem[1097]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2487;
      end

       2487 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1118] + 0 + i] = heapMem[NArea * localMem[1117] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1118], 0 + i);
                end
              end
              ip = 2488;
      end

       2488 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2489;
      end

       2489 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1089]*10 + 0] = localMem[1094];
              updateArrayLength(1, localMem[1089], 0);
              ip = 2490;
      end

       2490 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1097]*10 + 2] = localMem[1096];
              updateArrayLength(1, localMem[1097], 2);
              ip = 2491;
      end

       2491 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1119] = heapMem[localMem[1096]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2492;
      end

       2492 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1120] = heapMem[localMem[1096]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2493;
      end

       2493 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1121] = heapMem[localMem[1120]*10 + localMem[1119]];
              updateArrayLength(2, 0, 0);
              ip = 2494;
      end

       2494 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1121] != localMem[1089] ? 2513 : 2495;
      end

       2495 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1122] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2496;
      end

       2496 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1123] = heapMem[localMem[1122]*10 + localMem[1094]];
              updateArrayLength(2, 0, 0);
              ip = 2497;
      end

       2497 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1124] = heapMem[localMem[1096]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2498;
      end

       2498 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1124]*10 + localMem[1119]] = localMem[1123];
              updateArrayLength(1, localMem[1124], localMem[1119]);
              ip = 2499;
      end

       2499 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1125] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2500;
      end

       2500 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1126] = heapMem[localMem[1125]*10 + localMem[1094]];
              updateArrayLength(2, 0, 0);
              ip = 2501;
      end

       2501 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1127] = heapMem[localMem[1096]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2502;
      end

       2502 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1127]*10 + localMem[1119]] = localMem[1126];
              updateArrayLength(1, localMem[1127], localMem[1119]);
              ip = 2503;
      end

       2503 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1128] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2504;
      end

       2504 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1128]] = localMem[1094];
              ip = 2505;
      end

       2505 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1129] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2506;
      end

       2506 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1129]] = localMem[1094];
              ip = 2507;
      end

       2507 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1130] = localMem[1119] + 1;
              ip = 2508;
      end

       2508 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1096]*10 + 0] = localMem[1130];
              updateArrayLength(1, localMem[1096], 0);
              ip = 2509;
      end

       2509 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1131] = heapMem[localMem[1096]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2510;
      end

       2510 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1131]*10 + localMem[1130]] = localMem[1097];
              updateArrayLength(1, localMem[1131], localMem[1130]);
              ip = 2511;
      end

       2511 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2651;
      end

       2512 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2535;
      end

       2513 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2514;
      end

       2514 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 2515;
      end

       2515 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1132] = heapMem[localMem[1096]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2516;
      end

       2516 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 1133] = 0; k = arraySizes[localMem[1132]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[1132] * NArea + i] == localMem[1089]) localMem[0 + 1133] = i + 1;
              end
              ip = 2517;
      end

       2517 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 1133] = localMem[1133] - 1;
              ip = 2518;
      end

       2518 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1134] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2519;
      end

       2519 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1135] = heapMem[localMem[1134]*10 + localMem[1094]];
              updateArrayLength(2, 0, 0);
              ip = 2520;
      end

       2520 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1136] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2521;
      end

       2521 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1137] = heapMem[localMem[1136]*10 + localMem[1094]];
              updateArrayLength(2, 0, 0);
              ip = 2522;
      end

       2522 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1138] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2523;
      end

       2523 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1138]] = localMem[1094];
              ip = 2524;
      end

       2524 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1139] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2525;
      end

       2525 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1139]] = localMem[1094];
              ip = 2526;
      end

       2526 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1140] = heapMem[localMem[1096]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2527;
      end

       2527 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1140] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1133], localMem[1140], arraySizes[localMem[1140]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1133] && i <= arraySizes[localMem[1140]]) begin
                  heapMem[NArea * localMem[1140] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1140] + localMem[1133]] = localMem[1135];                                    // Insert new value
              arraySizes[localMem[1140]] = arraySizes[localMem[1140]] + 1;                              // Increase array size
              ip = 2528;
      end

       2528 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1141] = heapMem[localMem[1096]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2529;
      end

       2529 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1141] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1133], localMem[1141], arraySizes[localMem[1141]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1133] && i <= arraySizes[localMem[1141]]) begin
                  heapMem[NArea * localMem[1141] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1141] + localMem[1133]] = localMem[1137];                                    // Insert new value
              arraySizes[localMem[1141]] = arraySizes[localMem[1141]] + 1;                              // Increase array size
              ip = 2530;
      end

       2530 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1142] = heapMem[localMem[1096]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2531;
      end

       2531 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1143] = localMem[1133] + 1;
              ip = 2532;
      end

       2532 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1142] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1143], localMem[1142], arraySizes[localMem[1142]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1143] && i <= arraySizes[localMem[1142]]) begin
                  heapMem[NArea * localMem[1142] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1142] + localMem[1143]] = localMem[1097];                                    // Insert new value
              arraySizes[localMem[1142]] = arraySizes[localMem[1142]] + 1;                              // Increase array size
              ip = 2533;
      end

       2533 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1096]*10 + 0] = heapMem[localMem[1096]*10 + 0] + 1;
              ip = 2534;
      end

       2534 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2651;
      end

       2535 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2536;
      end

       2536 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2537;
      end

       2537 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1144] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1144] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1144]] = 0;
              ip = 2538;
      end

       2538 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 0] = localMem[1094];
              updateArrayLength(1, localMem[1144], 0);
              ip = 2539;
      end

       2539 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 2] = 0;
              updateArrayLength(1, localMem[1144], 2);
              ip = 2540;
      end

       2540 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1145] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1145] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1145]] = 0;
              ip = 2541;
      end

       2541 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 4] = localMem[1145];
              updateArrayLength(1, localMem[1144], 4);
              ip = 2542;
      end

       2542 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1146] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1146] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1146]] = 0;
              ip = 2543;
      end

       2543 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 5] = localMem[1146];
              updateArrayLength(1, localMem[1144], 5);
              ip = 2544;
      end

       2544 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 6] = 0;
              updateArrayLength(1, localMem[1144], 6);
              ip = 2545;
      end

       2545 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 3] = localMem[1092];
              updateArrayLength(1, localMem[1144], 3);
              ip = 2546;
      end

       2546 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1092]*10 + 1] = heapMem[localMem[1092]*10 + 1] + 1;
              ip = 2547;
      end

       2547 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 1] = heapMem[localMem[1092]*10 + 1];
              updateArrayLength(1, localMem[1144], 1);
              ip = 2548;
      end

       2548 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1147] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1147] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1147]] = 0;
              ip = 2549;
      end

       2549 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 0] = localMem[1094];
              updateArrayLength(1, localMem[1147], 0);
              ip = 2550;
      end

       2550 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 2] = 0;
              updateArrayLength(1, localMem[1147], 2);
              ip = 2551;
      end

       2551 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1148] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1148] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1148]] = 0;
              ip = 2552;
      end

       2552 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 4] = localMem[1148];
              updateArrayLength(1, localMem[1147], 4);
              ip = 2553;
      end

       2553 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1149] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1149] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1149]] = 0;
              ip = 2554;
      end

       2554 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 5] = localMem[1149];
              updateArrayLength(1, localMem[1147], 5);
              ip = 2555;
      end

       2555 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 6] = 0;
              updateArrayLength(1, localMem[1147], 6);
              ip = 2556;
      end

       2556 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 3] = localMem[1092];
              updateArrayLength(1, localMem[1147], 3);
              ip = 2557;
      end

       2557 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1092]*10 + 1] = heapMem[localMem[1092]*10 + 1] + 1;
              ip = 2558;
      end

       2558 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 1] = heapMem[localMem[1092]*10 + 1];
              updateArrayLength(1, localMem[1147], 1);
              ip = 2559;
      end

       2559 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1150] = !heapMem[localMem[1089]*10 + 6];
              ip = 2560;
      end

       2560 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1150] != 0 ? 2612 : 2561;
      end

       2561 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1151] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1151] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1151]] = 0;
              ip = 2562;
      end

       2562 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 6] = localMem[1151];
              updateArrayLength(1, localMem[1144], 6);
              ip = 2563;
      end

       2563 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1152] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1152] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1152]] = 0;
              ip = 2564;
      end

       2564 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 6] = localMem[1152];
              updateArrayLength(1, localMem[1147], 6);
              ip = 2565;
      end

       2565 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1153] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2566;
      end

       2566 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1154] = heapMem[localMem[1144]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2567;
      end

       2567 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1154] + 0 + i] = heapMem[NArea * localMem[1153] + 0 + i];
                  updateArrayLength(1, localMem[1154], 0 + i);
                end
              end
              ip = 2568;
      end

       2568 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1155] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2569;
      end

       2569 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1156] = heapMem[localMem[1144]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2570;
      end

       2570 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1156] + 0 + i] = heapMem[NArea * localMem[1155] + 0 + i];
                  updateArrayLength(1, localMem[1156], 0 + i);
                end
              end
              ip = 2571;
      end

       2571 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1157] = heapMem[localMem[1089]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2572;
      end

       2572 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1158] = heapMem[localMem[1144]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2573;
      end

       2573 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1159] = localMem[1094] + 1;
              ip = 2574;
      end

       2574 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1159]) begin
                  heapMem[NArea * localMem[1158] + 0 + i] = heapMem[NArea * localMem[1157] + 0 + i];
                  updateArrayLength(1, localMem[1158], 0 + i);
                end
              end
              ip = 2575;
      end

       2575 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1160] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2576;
      end

       2576 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1161] = heapMem[localMem[1147]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2577;
      end

       2577 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1161] + 0 + i] = heapMem[NArea * localMem[1160] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1161], 0 + i);
                end
              end
              ip = 2578;
      end

       2578 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1162] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2579;
      end

       2579 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1163] = heapMem[localMem[1147]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2580;
      end

       2580 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1163] + 0 + i] = heapMem[NArea * localMem[1162] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1163], 0 + i);
                end
              end
              ip = 2581;
      end

       2581 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1164] = heapMem[localMem[1089]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2582;
      end

       2582 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1165] = heapMem[localMem[1147]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2583;
      end

       2583 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1166] = localMem[1094] + 1;
              ip = 2584;
      end

       2584 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1166]) begin
                  heapMem[NArea * localMem[1165] + 0 + i] = heapMem[NArea * localMem[1164] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1165], 0 + i);
                end
              end
              ip = 2585;
      end

       2585 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1167] = heapMem[localMem[1144]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2586;
      end

       2586 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1168] = localMem[1167] + 1;
              ip = 2587;
      end

       2587 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1169] = heapMem[localMem[1144]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2588;
      end

       2588 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2589;
      end

       2589 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1170] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2590;
      end

       2590 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2591;
      end

       2591 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1170] >= localMem[1168] ? 2597 : 2592;
      end

       2592 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1171] = heapMem[localMem[1169]*10 + localMem[1170]];
              updateArrayLength(2, 0, 0);
              ip = 2593;
      end

       2593 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1171]*10 + 2] = localMem[1144];
              updateArrayLength(1, localMem[1171], 2);
              ip = 2594;
      end

       2594 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2595;
      end

       2595 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1170] = localMem[1170] + 1;
              ip = 2596;
      end

       2596 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2590;
      end

       2597 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2598;
      end

       2598 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1172] = heapMem[localMem[1147]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2599;
      end

       2599 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1173] = localMem[1172] + 1;
              ip = 2600;
      end

       2600 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1174] = heapMem[localMem[1147]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2601;
      end

       2601 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2602;
      end

       2602 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1175] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2603;
      end

       2603 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2604;
      end

       2604 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1175] >= localMem[1173] ? 2610 : 2605;
      end

       2605 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1176] = heapMem[localMem[1174]*10 + localMem[1175]];
              updateArrayLength(2, 0, 0);
              ip = 2606;
      end

       2606 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1176]*10 + 2] = localMem[1147];
              updateArrayLength(1, localMem[1176], 2);
              ip = 2607;
      end

       2607 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2608;
      end

       2608 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1175] = localMem[1175] + 1;
              ip = 2609;
      end

       2609 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2603;
      end

       2610 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2611;
      end

       2611 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2627;
      end

       2612 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2613;
      end

       2613 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1177] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1177] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1177]] = 0;
              ip = 2614;
      end

       2614 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1089]*10 + 6] = localMem[1177];
              updateArrayLength(1, localMem[1089], 6);
              ip = 2615;
      end

       2615 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1178] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2616;
      end

       2616 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1179] = heapMem[localMem[1144]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2617;
      end

       2617 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1179] + 0 + i] = heapMem[NArea * localMem[1178] + 0 + i];
                  updateArrayLength(1, localMem[1179], 0 + i);
                end
              end
              ip = 2618;
      end

       2618 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1180] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2619;
      end

       2619 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1181] = heapMem[localMem[1144]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2620;
      end

       2620 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1181] + 0 + i] = heapMem[NArea * localMem[1180] + 0 + i];
                  updateArrayLength(1, localMem[1181], 0 + i);
                end
              end
              ip = 2621;
      end

       2621 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1182] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2622;
      end

       2622 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1183] = heapMem[localMem[1147]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2623;
      end

       2623 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1183] + 0 + i] = heapMem[NArea * localMem[1182] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1183], 0 + i);
                end
              end
              ip = 2624;
      end

       2624 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1184] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2625;
      end

       2625 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1185] = heapMem[localMem[1147]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2626;
      end

       2626 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1094]) begin
                  heapMem[NArea * localMem[1185] + 0 + i] = heapMem[NArea * localMem[1184] + localMem[1095] + i];
                  updateArrayLength(1, localMem[1185], 0 + i);
                end
              end
              ip = 2627;
      end

       2627 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2628;
      end

       2628 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1144]*10 + 2] = localMem[1089];
              updateArrayLength(1, localMem[1144], 2);
              ip = 2629;
      end

       2629 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1147]*10 + 2] = localMem[1089];
              updateArrayLength(1, localMem[1147], 2);
              ip = 2630;
      end

       2630 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1186] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2631;
      end

       2631 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1187] = heapMem[localMem[1186]*10 + localMem[1094]];
              updateArrayLength(2, 0, 0);
              ip = 2632;
      end

       2632 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1188] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2633;
      end

       2633 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1189] = heapMem[localMem[1188]*10 + localMem[1094]];
              updateArrayLength(2, 0, 0);
              ip = 2634;
      end

       2634 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1190] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2635;
      end

       2635 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1190]*10 + 0] = localMem[1187];
              updateArrayLength(1, localMem[1190], 0);
              ip = 2636;
      end

       2636 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1191] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2637;
      end

       2637 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1191]*10 + 0] = localMem[1189];
              updateArrayLength(1, localMem[1191], 0);
              ip = 2638;
      end

       2638 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1192] = heapMem[localMem[1089]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2639;
      end

       2639 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1192]*10 + 0] = localMem[1144];
              updateArrayLength(1, localMem[1192], 0);
              ip = 2640;
      end

       2640 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1193] = heapMem[localMem[1089]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2641;
      end

       2641 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1193]*10 + 1] = localMem[1147];
              updateArrayLength(1, localMem[1193], 1);
              ip = 2642;
      end

       2642 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1089]*10 + 0] = 1;
              updateArrayLength(1, localMem[1089], 0);
              ip = 2643;
      end

       2643 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1194] = heapMem[localMem[1089]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2644;
      end

       2644 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1194]] = 1;
              ip = 2645;
      end

       2645 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1195] = heapMem[localMem[1089]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2646;
      end

       2646 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1195]] = 1;
              ip = 2647;
      end

       2647 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1196] = heapMem[localMem[1089]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2648;
      end

       2648 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1196]] = 2;
              ip = 2649;
      end

       2649 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2651;
      end

       2650 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2656;
      end

       2651 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2652;
      end

       2652 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1090] = 1;
              updateArrayLength(2, 0, 0);
              ip = 2653;
      end

       2653 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2656;
      end

       2654 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2655;
      end

       2655 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1090] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2656;
      end

       2656 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2657;
      end

       2657 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1090] != 0 ? 2659 : 2658;
      end

       2658 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 974] = localMem[1089];
              updateArrayLength(2, 0, 0);
              ip = 2659;
      end

       2659 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2660;
      end

       2660 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2910;
      end

       2661 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2662;
      end

       2662 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1197] = heapMem[localMem[974]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2663;
      end

       2663 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 1198] = 0; k = arraySizes[localMem[1197]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[1197] * NArea + i] == 3) localMem[0 + 1198] = i + 1;
              end
              ip = 2664;
      end

       2664 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[1198] == 0 ? 2669 : 2665;
      end

       2665 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[951]*10 + 0] = localMem[974];
              updateArrayLength(1, localMem[951], 0);
              ip = 2666;
      end

       2666 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[951]*10 + 1] = 1;
              updateArrayLength(1, localMem[951], 1);
              ip = 2667;
      end

       2667 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              heapMem[localMem[951]*10 + 2] = localMem[1198] - 1;
              ip = 2668;
      end

       2668 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2917;
      end

       2669 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2670;
      end

       2670 :
      begin                                                                     // arrayCountLess
//$display("AAAA %4d %4d arrayCountLess", steps, ip);
              j = 0; k = arraySizes[localMem[1197]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[1197] * NArea + i] < 3) j = j + 1;
              end
              localMem[0 + 1199] = j;
              ip = 2671;
      end

       2671 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1200] = !heapMem[localMem[974]*10 + 6];
              ip = 2672;
      end

       2672 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[1200] == 0 ? 2677 : 2673;
      end

       2673 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[951]*10 + 0] = localMem[974];
              updateArrayLength(1, localMem[951], 0);
              ip = 2674;
      end

       2674 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[951]*10 + 1] = 0;
              updateArrayLength(1, localMem[951], 1);
              ip = 2675;
      end

       2675 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[951]*10 + 2] = localMem[1199];
              updateArrayLength(1, localMem[951], 2);
              ip = 2676;
      end

       2676 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2917;
      end

       2677 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2678;
      end

       2678 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1201] = heapMem[localMem[974]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2679;
      end

       2679 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1202] = heapMem[localMem[1201]*10 + localMem[1199]];
              updateArrayLength(2, 0, 0);
              ip = 2680;
      end

       2680 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2681;
      end

       2681 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1204] = heapMem[localMem[1202]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2682;
      end

       2682 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1205] = heapMem[localMem[1202]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 2683;
      end

       2683 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1206] = heapMem[localMem[1205]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2684;
      end

       2684 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[1204] <  localMem[1206] ? 2904 : 2685;
      end

       2685 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1207] = localMem[1206];
              updateArrayLength(2, 0, 0);
              ip = 2686;
      end

       2686 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 1207] = localMem[1207] >> 1;
              ip = 2687;
      end

       2687 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1208] = localMem[1207] + 1;
              ip = 2688;
      end

       2688 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1209] = heapMem[localMem[1202]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2689;
      end

       2689 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[1209] == 0 ? 2786 : 2690;
      end

       2690 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1210] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1210] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1210]] = 0;
              ip = 2691;
      end

       2691 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 0] = localMem[1207];
              updateArrayLength(1, localMem[1210], 0);
              ip = 2692;
      end

       2692 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 2] = 0;
              updateArrayLength(1, localMem[1210], 2);
              ip = 2693;
      end

       2693 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1211] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1211] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1211]] = 0;
              ip = 2694;
      end

       2694 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 4] = localMem[1211];
              updateArrayLength(1, localMem[1210], 4);
              ip = 2695;
      end

       2695 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1212] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1212] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1212]] = 0;
              ip = 2696;
      end

       2696 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 5] = localMem[1212];
              updateArrayLength(1, localMem[1210], 5);
              ip = 2697;
      end

       2697 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 6] = 0;
              updateArrayLength(1, localMem[1210], 6);
              ip = 2698;
      end

       2698 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 3] = localMem[1205];
              updateArrayLength(1, localMem[1210], 3);
              ip = 2699;
      end

       2699 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1205]*10 + 1] = heapMem[localMem[1205]*10 + 1] + 1;
              ip = 2700;
      end

       2700 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 1] = heapMem[localMem[1205]*10 + 1];
              updateArrayLength(1, localMem[1210], 1);
              ip = 2701;
      end

       2701 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1213] = !heapMem[localMem[1202]*10 + 6];
              ip = 2702;
      end

       2702 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1213] != 0 ? 2731 : 2703;
      end

       2703 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1214] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1214] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1214]] = 0;
              ip = 2704;
      end

       2704 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 6] = localMem[1214];
              updateArrayLength(1, localMem[1210], 6);
              ip = 2705;
      end

       2705 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1215] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2706;
      end

       2706 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1216] = heapMem[localMem[1210]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2707;
      end

       2707 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1216] + 0 + i] = heapMem[NArea * localMem[1215] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1216], 0 + i);
                end
              end
              ip = 2708;
      end

       2708 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1217] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2709;
      end

       2709 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1218] = heapMem[localMem[1210]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2710;
      end

       2710 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1218] + 0 + i] = heapMem[NArea * localMem[1217] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1218], 0 + i);
                end
              end
              ip = 2711;
      end

       2711 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1219] = heapMem[localMem[1202]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2712;
      end

       2712 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1220] = heapMem[localMem[1210]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2713;
      end

       2713 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1221] = localMem[1207] + 1;
              ip = 2714;
      end

       2714 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1221]) begin
                  heapMem[NArea * localMem[1220] + 0 + i] = heapMem[NArea * localMem[1219] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1220], 0 + i);
                end
              end
              ip = 2715;
      end

       2715 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1222] = heapMem[localMem[1210]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2716;
      end

       2716 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1223] = localMem[1222] + 1;
              ip = 2717;
      end

       2717 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1224] = heapMem[localMem[1210]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2718;
      end

       2718 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2719;
      end

       2719 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1225] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2720;
      end

       2720 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2721;
      end

       2721 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1225] >= localMem[1223] ? 2727 : 2722;
      end

       2722 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1226] = heapMem[localMem[1224]*10 + localMem[1225]];
              updateArrayLength(2, 0, 0);
              ip = 2723;
      end

       2723 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1226]*10 + 2] = localMem[1210];
              updateArrayLength(1, localMem[1226], 2);
              ip = 2724;
      end

       2724 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2725;
      end

       2725 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1225] = localMem[1225] + 1;
              ip = 2726;
      end

       2726 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2720;
      end

       2727 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2728;
      end

       2728 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1227] = heapMem[localMem[1202]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2729;
      end

       2729 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1227]] = localMem[1208];
              ip = 2730;
      end

       2730 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2738;
      end

       2731 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2732;
      end

       2732 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1228] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2733;
      end

       2733 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1229] = heapMem[localMem[1210]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2734;
      end

       2734 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1229] + 0 + i] = heapMem[NArea * localMem[1228] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1229], 0 + i);
                end
              end
              ip = 2735;
      end

       2735 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1230] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2736;
      end

       2736 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1231] = heapMem[localMem[1210]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2737;
      end

       2737 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1231] + 0 + i] = heapMem[NArea * localMem[1230] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1231], 0 + i);
                end
              end
              ip = 2738;
      end

       2738 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2739;
      end

       2739 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1202]*10 + 0] = localMem[1207];
              updateArrayLength(1, localMem[1202], 0);
              ip = 2740;
      end

       2740 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1210]*10 + 2] = localMem[1209];
              updateArrayLength(1, localMem[1210], 2);
              ip = 2741;
      end

       2741 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1232] = heapMem[localMem[1209]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2742;
      end

       2742 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1233] = heapMem[localMem[1209]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2743;
      end

       2743 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1234] = heapMem[localMem[1233]*10 + localMem[1232]];
              updateArrayLength(2, 0, 0);
              ip = 2744;
      end

       2744 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1234] != localMem[1202] ? 2763 : 2745;
      end

       2745 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1235] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2746;
      end

       2746 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1236] = heapMem[localMem[1235]*10 + localMem[1207]];
              updateArrayLength(2, 0, 0);
              ip = 2747;
      end

       2747 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1237] = heapMem[localMem[1209]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2748;
      end

       2748 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1237]*10 + localMem[1232]] = localMem[1236];
              updateArrayLength(1, localMem[1237], localMem[1232]);
              ip = 2749;
      end

       2749 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1238] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2750;
      end

       2750 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1239] = heapMem[localMem[1238]*10 + localMem[1207]];
              updateArrayLength(2, 0, 0);
              ip = 2751;
      end

       2751 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1240] = heapMem[localMem[1209]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2752;
      end

       2752 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1240]*10 + localMem[1232]] = localMem[1239];
              updateArrayLength(1, localMem[1240], localMem[1232]);
              ip = 2753;
      end

       2753 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1241] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2754;
      end

       2754 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1241]] = localMem[1207];
              ip = 2755;
      end

       2755 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1242] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2756;
      end

       2756 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1242]] = localMem[1207];
              ip = 2757;
      end

       2757 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1243] = localMem[1232] + 1;
              ip = 2758;
      end

       2758 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1209]*10 + 0] = localMem[1243];
              updateArrayLength(1, localMem[1209], 0);
              ip = 2759;
      end

       2759 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1244] = heapMem[localMem[1209]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2760;
      end

       2760 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1244]*10 + localMem[1243]] = localMem[1210];
              updateArrayLength(1, localMem[1244], localMem[1243]);
              ip = 2761;
      end

       2761 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2901;
      end

       2762 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2785;
      end

       2763 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2764;
      end

       2764 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 2765;
      end

       2765 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1245] = heapMem[localMem[1209]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2766;
      end

       2766 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 1246] = 0; k = arraySizes[localMem[1245]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[1245] * NArea + i] == localMem[1202]) localMem[0 + 1246] = i + 1;
              end
              ip = 2767;
      end

       2767 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 1246] = localMem[1246] - 1;
              ip = 2768;
      end

       2768 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1247] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2769;
      end

       2769 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1248] = heapMem[localMem[1247]*10 + localMem[1207]];
              updateArrayLength(2, 0, 0);
              ip = 2770;
      end

       2770 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1249] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2771;
      end

       2771 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1250] = heapMem[localMem[1249]*10 + localMem[1207]];
              updateArrayLength(2, 0, 0);
              ip = 2772;
      end

       2772 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1251] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2773;
      end

       2773 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1251]] = localMem[1207];
              ip = 2774;
      end

       2774 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1252] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2775;
      end

       2775 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1252]] = localMem[1207];
              ip = 2776;
      end

       2776 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1253] = heapMem[localMem[1209]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2777;
      end

       2777 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1253] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1246], localMem[1253], arraySizes[localMem[1253]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1246] && i <= arraySizes[localMem[1253]]) begin
                  heapMem[NArea * localMem[1253] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1253] + localMem[1246]] = localMem[1248];                                    // Insert new value
              arraySizes[localMem[1253]] = arraySizes[localMem[1253]] + 1;                              // Increase array size
              ip = 2778;
      end

       2778 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1254] = heapMem[localMem[1209]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2779;
      end

       2779 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1254] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1246], localMem[1254], arraySizes[localMem[1254]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1246] && i <= arraySizes[localMem[1254]]) begin
                  heapMem[NArea * localMem[1254] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1254] + localMem[1246]] = localMem[1250];                                    // Insert new value
              arraySizes[localMem[1254]] = arraySizes[localMem[1254]] + 1;                              // Increase array size
              ip = 2780;
      end

       2780 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1255] = heapMem[localMem[1209]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2781;
      end

       2781 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1256] = localMem[1246] + 1;
              ip = 2782;
      end

       2782 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1255] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1256], localMem[1255], arraySizes[localMem[1255]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1256] && i <= arraySizes[localMem[1255]]) begin
                  heapMem[NArea * localMem[1255] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1255] + localMem[1256]] = localMem[1210];                                    // Insert new value
              arraySizes[localMem[1255]] = arraySizes[localMem[1255]] + 1;                              // Increase array size
              ip = 2783;
      end

       2783 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1209]*10 + 0] = heapMem[localMem[1209]*10 + 0] + 1;
              ip = 2784;
      end

       2784 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2901;
      end

       2785 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2786;
      end

       2786 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2787;
      end

       2787 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1257] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1257] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1257]] = 0;
              ip = 2788;
      end

       2788 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 0] = localMem[1207];
              updateArrayLength(1, localMem[1257], 0);
              ip = 2789;
      end

       2789 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 2] = 0;
              updateArrayLength(1, localMem[1257], 2);
              ip = 2790;
      end

       2790 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1258] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1258] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1258]] = 0;
              ip = 2791;
      end

       2791 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 4] = localMem[1258];
              updateArrayLength(1, localMem[1257], 4);
              ip = 2792;
      end

       2792 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1259] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1259] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1259]] = 0;
              ip = 2793;
      end

       2793 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 5] = localMem[1259];
              updateArrayLength(1, localMem[1257], 5);
              ip = 2794;
      end

       2794 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 6] = 0;
              updateArrayLength(1, localMem[1257], 6);
              ip = 2795;
      end

       2795 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 3] = localMem[1205];
              updateArrayLength(1, localMem[1257], 3);
              ip = 2796;
      end

       2796 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1205]*10 + 1] = heapMem[localMem[1205]*10 + 1] + 1;
              ip = 2797;
      end

       2797 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 1] = heapMem[localMem[1205]*10 + 1];
              updateArrayLength(1, localMem[1257], 1);
              ip = 2798;
      end

       2798 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1260] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1260] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1260]] = 0;
              ip = 2799;
      end

       2799 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 0] = localMem[1207];
              updateArrayLength(1, localMem[1260], 0);
              ip = 2800;
      end

       2800 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 2] = 0;
              updateArrayLength(1, localMem[1260], 2);
              ip = 2801;
      end

       2801 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1261] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1261] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1261]] = 0;
              ip = 2802;
      end

       2802 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 4] = localMem[1261];
              updateArrayLength(1, localMem[1260], 4);
              ip = 2803;
      end

       2803 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1262] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1262] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1262]] = 0;
              ip = 2804;
      end

       2804 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 5] = localMem[1262];
              updateArrayLength(1, localMem[1260], 5);
              ip = 2805;
      end

       2805 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 6] = 0;
              updateArrayLength(1, localMem[1260], 6);
              ip = 2806;
      end

       2806 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 3] = localMem[1205];
              updateArrayLength(1, localMem[1260], 3);
              ip = 2807;
      end

       2807 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1205]*10 + 1] = heapMem[localMem[1205]*10 + 1] + 1;
              ip = 2808;
      end

       2808 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 1] = heapMem[localMem[1205]*10 + 1];
              updateArrayLength(1, localMem[1260], 1);
              ip = 2809;
      end

       2809 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1263] = !heapMem[localMem[1202]*10 + 6];
              ip = 2810;
      end

       2810 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1263] != 0 ? 2862 : 2811;
      end

       2811 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1264] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1264] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1264]] = 0;
              ip = 2812;
      end

       2812 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 6] = localMem[1264];
              updateArrayLength(1, localMem[1257], 6);
              ip = 2813;
      end

       2813 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1265] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1265] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1265]] = 0;
              ip = 2814;
      end

       2814 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 6] = localMem[1265];
              updateArrayLength(1, localMem[1260], 6);
              ip = 2815;
      end

       2815 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1266] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2816;
      end

       2816 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1267] = heapMem[localMem[1257]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2817;
      end

       2817 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1267] + 0 + i] = heapMem[NArea * localMem[1266] + 0 + i];
                  updateArrayLength(1, localMem[1267], 0 + i);
                end
              end
              ip = 2818;
      end

       2818 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1268] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2819;
      end

       2819 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1269] = heapMem[localMem[1257]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2820;
      end

       2820 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1269] + 0 + i] = heapMem[NArea * localMem[1268] + 0 + i];
                  updateArrayLength(1, localMem[1269], 0 + i);
                end
              end
              ip = 2821;
      end

       2821 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1270] = heapMem[localMem[1202]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2822;
      end

       2822 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1271] = heapMem[localMem[1257]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2823;
      end

       2823 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1272] = localMem[1207] + 1;
              ip = 2824;
      end

       2824 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1272]) begin
                  heapMem[NArea * localMem[1271] + 0 + i] = heapMem[NArea * localMem[1270] + 0 + i];
                  updateArrayLength(1, localMem[1271], 0 + i);
                end
              end
              ip = 2825;
      end

       2825 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1273] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2826;
      end

       2826 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1274] = heapMem[localMem[1260]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2827;
      end

       2827 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1274] + 0 + i] = heapMem[NArea * localMem[1273] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1274], 0 + i);
                end
              end
              ip = 2828;
      end

       2828 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1275] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2829;
      end

       2829 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1276] = heapMem[localMem[1260]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2830;
      end

       2830 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1276] + 0 + i] = heapMem[NArea * localMem[1275] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1276], 0 + i);
                end
              end
              ip = 2831;
      end

       2831 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1277] = heapMem[localMem[1202]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2832;
      end

       2832 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1278] = heapMem[localMem[1260]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2833;
      end

       2833 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1279] = localMem[1207] + 1;
              ip = 2834;
      end

       2834 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1279]) begin
                  heapMem[NArea * localMem[1278] + 0 + i] = heapMem[NArea * localMem[1277] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1278], 0 + i);
                end
              end
              ip = 2835;
      end

       2835 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1280] = heapMem[localMem[1257]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2836;
      end

       2836 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1281] = localMem[1280] + 1;
              ip = 2837;
      end

       2837 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1282] = heapMem[localMem[1257]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2838;
      end

       2838 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2839;
      end

       2839 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1283] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2840;
      end

       2840 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2841;
      end

       2841 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1283] >= localMem[1281] ? 2847 : 2842;
      end

       2842 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1284] = heapMem[localMem[1282]*10 + localMem[1283]];
              updateArrayLength(2, 0, 0);
              ip = 2843;
      end

       2843 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1284]*10 + 2] = localMem[1257];
              updateArrayLength(1, localMem[1284], 2);
              ip = 2844;
      end

       2844 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2845;
      end

       2845 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1283] = localMem[1283] + 1;
              ip = 2846;
      end

       2846 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2840;
      end

       2847 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2848;
      end

       2848 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1285] = heapMem[localMem[1260]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2849;
      end

       2849 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1286] = localMem[1285] + 1;
              ip = 2850;
      end

       2850 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1287] = heapMem[localMem[1260]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2851;
      end

       2851 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2852;
      end

       2852 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1288] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2853;
      end

       2853 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2854;
      end

       2854 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1288] >= localMem[1286] ? 2860 : 2855;
      end

       2855 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1289] = heapMem[localMem[1287]*10 + localMem[1288]];
              updateArrayLength(2, 0, 0);
              ip = 2856;
      end

       2856 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1289]*10 + 2] = localMem[1260];
              updateArrayLength(1, localMem[1289], 2);
              ip = 2857;
      end

       2857 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2858;
      end

       2858 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1288] = localMem[1288] + 1;
              ip = 2859;
      end

       2859 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2853;
      end

       2860 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2861;
      end

       2861 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2877;
      end

       2862 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2863;
      end

       2863 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1290] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1290] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1290]] = 0;
              ip = 2864;
      end

       2864 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1202]*10 + 6] = localMem[1290];
              updateArrayLength(1, localMem[1202], 6);
              ip = 2865;
      end

       2865 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1291] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2866;
      end

       2866 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1292] = heapMem[localMem[1257]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2867;
      end

       2867 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1292] + 0 + i] = heapMem[NArea * localMem[1291] + 0 + i];
                  updateArrayLength(1, localMem[1292], 0 + i);
                end
              end
              ip = 2868;
      end

       2868 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1293] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2869;
      end

       2869 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1294] = heapMem[localMem[1257]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2870;
      end

       2870 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1294] + 0 + i] = heapMem[NArea * localMem[1293] + 0 + i];
                  updateArrayLength(1, localMem[1294], 0 + i);
                end
              end
              ip = 2871;
      end

       2871 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1295] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2872;
      end

       2872 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1296] = heapMem[localMem[1260]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2873;
      end

       2873 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1296] + 0 + i] = heapMem[NArea * localMem[1295] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1296], 0 + i);
                end
              end
              ip = 2874;
      end

       2874 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1297] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2875;
      end

       2875 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1298] = heapMem[localMem[1260]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2876;
      end

       2876 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1207]) begin
                  heapMem[NArea * localMem[1298] + 0 + i] = heapMem[NArea * localMem[1297] + localMem[1208] + i];
                  updateArrayLength(1, localMem[1298], 0 + i);
                end
              end
              ip = 2877;
      end

       2877 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2878;
      end

       2878 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1257]*10 + 2] = localMem[1202];
              updateArrayLength(1, localMem[1257], 2);
              ip = 2879;
      end

       2879 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1260]*10 + 2] = localMem[1202];
              updateArrayLength(1, localMem[1260], 2);
              ip = 2880;
      end

       2880 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1299] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2881;
      end

       2881 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1300] = heapMem[localMem[1299]*10 + localMem[1207]];
              updateArrayLength(2, 0, 0);
              ip = 2882;
      end

       2882 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1301] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2883;
      end

       2883 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1302] = heapMem[localMem[1301]*10 + localMem[1207]];
              updateArrayLength(2, 0, 0);
              ip = 2884;
      end

       2884 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1303] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2885;
      end

       2885 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1303]*10 + 0] = localMem[1300];
              updateArrayLength(1, localMem[1303], 0);
              ip = 2886;
      end

       2886 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1304] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2887;
      end

       2887 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1304]*10 + 0] = localMem[1302];
              updateArrayLength(1, localMem[1304], 0);
              ip = 2888;
      end

       2888 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1305] = heapMem[localMem[1202]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2889;
      end

       2889 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1305]*10 + 0] = localMem[1257];
              updateArrayLength(1, localMem[1305], 0);
              ip = 2890;
      end

       2890 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1306] = heapMem[localMem[1202]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2891;
      end

       2891 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1306]*10 + 1] = localMem[1260];
              updateArrayLength(1, localMem[1306], 1);
              ip = 2892;
      end

       2892 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1202]*10 + 0] = 1;
              updateArrayLength(1, localMem[1202], 0);
              ip = 2893;
      end

       2893 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1307] = heapMem[localMem[1202]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2894;
      end

       2894 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1307]] = 1;
              ip = 2895;
      end

       2895 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1308] = heapMem[localMem[1202]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2896;
      end

       2896 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1308]] = 1;
              ip = 2897;
      end

       2897 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1309] = heapMem[localMem[1202]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2898;
      end

       2898 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1309]] = 2;
              ip = 2899;
      end

       2899 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2901;
      end

       2900 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2906;
      end

       2901 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2902;
      end

       2902 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1203] = 1;
              updateArrayLength(2, 0, 0);
              ip = 2903;
      end

       2903 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2906;
      end

       2904 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2905;
      end

       2905 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1203] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2906;
      end

       2906 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2907;
      end

       2907 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1203] != 0 ? 2909 : 2908;
      end

       2908 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 974] = localMem[1202];
              updateArrayLength(2, 0, 0);
              ip = 2909;
      end

       2909 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2910;
      end

       2910 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2911;
      end

       2911 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1082] = localMem[1082] + 1;
              ip = 2912;
      end

       2912 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2414;
      end

       2913 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2914;
      end

       2914 :
      begin                                                                     // assert
//$display("AAAA %4d %4d assert", steps, ip);
            ip = 2915;
      end

       2915 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2916;
      end

       2916 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2917;
      end

       2917 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2918;
      end

       2918 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1310] = heapMem[localMem[951]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2919;
      end

       2919 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1311] = heapMem[localMem[951]*10 + 1];
              updateArrayLength(2, 0, 0);
              ip = 2920;
      end

       2920 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1312] = heapMem[localMem[951]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2921;
      end

       2921 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1311] != 1 ? 2925 : 2922;
      end

       2922 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1313] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2923;
      end

       2923 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1313]*10 + localMem[1312]] = 33;
              updateArrayLength(1, localMem[1313], localMem[1312]);
              ip = 2924;
      end

       2924 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3171;
      end

       2925 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2926;
      end

       2926 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1311] != 2 ? 2934 : 2927;
      end

       2927 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1314] = localMem[1312] + 1;
              ip = 2928;
      end

       2928 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1315] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2929;
      end

       2929 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1315] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1314], localMem[1315], arraySizes[localMem[1315]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1314] && i <= arraySizes[localMem[1315]]) begin
                  heapMem[NArea * localMem[1315] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1315] + localMem[1314]] = 3;                                    // Insert new value
              arraySizes[localMem[1315]] = arraySizes[localMem[1315]] + 1;                              // Increase array size
              ip = 2930;
      end

       2930 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1316] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2931;
      end

       2931 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1316] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1314], localMem[1316], arraySizes[localMem[1316]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1314] && i <= arraySizes[localMem[1316]]) begin
                  heapMem[NArea * localMem[1316] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1316] + localMem[1314]] = 33;                                    // Insert new value
              arraySizes[localMem[1316]] = arraySizes[localMem[1316]] + 1;                              // Increase array size
              ip = 2932;
      end

       2932 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1310]*10 + 0] = heapMem[localMem[1310]*10 + 0] + 1;
              ip = 2933;
      end

       2933 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2940;
      end

       2934 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2935;
      end

       2935 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1317] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2936;
      end

       2936 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1317] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1312], localMem[1317], arraySizes[localMem[1317]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1312] && i <= arraySizes[localMem[1317]]) begin
                  heapMem[NArea * localMem[1317] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1317] + localMem[1312]] = 3;                                    // Insert new value
              arraySizes[localMem[1317]] = arraySizes[localMem[1317]] + 1;                              // Increase array size
              ip = 2937;
      end

       2937 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1318] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2938;
      end

       2938 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1318] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1312], localMem[1318], arraySizes[localMem[1318]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1312] && i <= arraySizes[localMem[1318]]) begin
                  heapMem[NArea * localMem[1318] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1318] + localMem[1312]] = 33;                                    // Insert new value
              arraySizes[localMem[1318]] = arraySizes[localMem[1318]] + 1;                              // Increase array size
              ip = 2939;
      end

       2939 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1310]*10 + 0] = heapMem[localMem[1310]*10 + 0] + 1;
              ip = 2940;
      end

       2940 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2941;
      end

       2941 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[0]*10 + 0] = heapMem[localMem[0]*10 + 0] + 1;
              ip = 2942;
      end

       2942 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2943;
      end

       2943 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1320] = heapMem[localMem[1310]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2944;
      end

       2944 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1321] = heapMem[localMem[1310]*10 + 3];
              updateArrayLength(2, 0, 0);
              ip = 2945;
      end

       2945 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1322] = heapMem[localMem[1321]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2946;
      end

       2946 :
      begin                                                                     // jLt
//$display("AAAA %4d %4d jLt", steps, ip);
              ip = localMem[1320] <  localMem[1322] ? 3166 : 2947;
      end

       2947 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1323] = localMem[1322];
              updateArrayLength(2, 0, 0);
              ip = 2948;
      end

       2948 :
      begin                                                                     // shiftRight
//$display("AAAA %4d %4d shiftRight", steps, ip);
              localMem[0 + 1323] = localMem[1323] >> 1;
              ip = 2949;
      end

       2949 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1324] = localMem[1323] + 1;
              ip = 2950;
      end

       2950 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1325] = heapMem[localMem[1310]*10 + 2];
              updateArrayLength(2, 0, 0);
              ip = 2951;
      end

       2951 :
      begin                                                                     // jEq
//$display("AAAA %4d %4d jEq", steps, ip);
              ip = localMem[1325] == 0 ? 3048 : 2952;
      end

       2952 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1326] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1326] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1326]] = 0;
              ip = 2953;
      end

       2953 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 0] = localMem[1323];
              updateArrayLength(1, localMem[1326], 0);
              ip = 2954;
      end

       2954 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 2] = 0;
              updateArrayLength(1, localMem[1326], 2);
              ip = 2955;
      end

       2955 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1327] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1327] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1327]] = 0;
              ip = 2956;
      end

       2956 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 4] = localMem[1327];
              updateArrayLength(1, localMem[1326], 4);
              ip = 2957;
      end

       2957 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1328] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1328] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1328]] = 0;
              ip = 2958;
      end

       2958 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 5] = localMem[1328];
              updateArrayLength(1, localMem[1326], 5);
              ip = 2959;
      end

       2959 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 6] = 0;
              updateArrayLength(1, localMem[1326], 6);
              ip = 2960;
      end

       2960 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 3] = localMem[1321];
              updateArrayLength(1, localMem[1326], 3);
              ip = 2961;
      end

       2961 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1321]*10 + 1] = heapMem[localMem[1321]*10 + 1] + 1;
              ip = 2962;
      end

       2962 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 1] = heapMem[localMem[1321]*10 + 1];
              updateArrayLength(1, localMem[1326], 1);
              ip = 2963;
      end

       2963 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1329] = !heapMem[localMem[1310]*10 + 6];
              ip = 2964;
      end

       2964 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1329] != 0 ? 2993 : 2965;
      end

       2965 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1330] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1330] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1330]] = 0;
              ip = 2966;
      end

       2966 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 6] = localMem[1330];
              updateArrayLength(1, localMem[1326], 6);
              ip = 2967;
      end

       2967 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1331] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2968;
      end

       2968 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1332] = heapMem[localMem[1326]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2969;
      end

       2969 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1332] + 0 + i] = heapMem[NArea * localMem[1331] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1332], 0 + i);
                end
              end
              ip = 2970;
      end

       2970 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1333] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2971;
      end

       2971 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1334] = heapMem[localMem[1326]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2972;
      end

       2972 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1334] + 0 + i] = heapMem[NArea * localMem[1333] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1334], 0 + i);
                end
              end
              ip = 2973;
      end

       2973 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1335] = heapMem[localMem[1310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2974;
      end

       2974 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1336] = heapMem[localMem[1326]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2975;
      end

       2975 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1337] = localMem[1323] + 1;
              ip = 2976;
      end

       2976 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1337]) begin
                  heapMem[NArea * localMem[1336] + 0 + i] = heapMem[NArea * localMem[1335] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1336], 0 + i);
                end
              end
              ip = 2977;
      end

       2977 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1338] = heapMem[localMem[1326]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 2978;
      end

       2978 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1339] = localMem[1338] + 1;
              ip = 2979;
      end

       2979 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1340] = heapMem[localMem[1326]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2980;
      end

       2980 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2981;
      end

       2981 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1341] = 0;
              updateArrayLength(2, 0, 0);
              ip = 2982;
      end

       2982 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2983;
      end

       2983 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1341] >= localMem[1339] ? 2989 : 2984;
      end

       2984 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1342] = heapMem[localMem[1340]*10 + localMem[1341]];
              updateArrayLength(2, 0, 0);
              ip = 2985;
      end

       2985 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1342]*10 + 2] = localMem[1326];
              updateArrayLength(1, localMem[1342], 2);
              ip = 2986;
      end

       2986 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2987;
      end

       2987 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1341] = localMem[1341] + 1;
              ip = 2988;
      end

       2988 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 2982;
      end

       2989 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2990;
      end

       2990 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1343] = heapMem[localMem[1310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 2991;
      end

       2991 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1343]] = localMem[1324];
              ip = 2992;
      end

       2992 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3000;
      end

       2993 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 2994;
      end

       2994 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1344] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2995;
      end

       2995 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1345] = heapMem[localMem[1326]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 2996;
      end

       2996 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1345] + 0 + i] = heapMem[NArea * localMem[1344] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1345], 0 + i);
                end
              end
              ip = 2997;
      end

       2997 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1346] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2998;
      end

       2998 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1347] = heapMem[localMem[1326]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 2999;
      end

       2999 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1347] + 0 + i] = heapMem[NArea * localMem[1346] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1347], 0 + i);
                end
              end
              ip = 3000;
      end

       3000 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3001;
      end

       3001 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1310]*10 + 0] = localMem[1323];
              updateArrayLength(1, localMem[1310], 0);
              ip = 3002;
      end

       3002 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1326]*10 + 2] = localMem[1325];
              updateArrayLength(1, localMem[1326], 2);
              ip = 3003;
      end

       3003 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1348] = heapMem[localMem[1325]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 3004;
      end

       3004 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1349] = heapMem[localMem[1325]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3005;
      end

       3005 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1350] = heapMem[localMem[1349]*10 + localMem[1348]];
              updateArrayLength(2, 0, 0);
              ip = 3006;
      end

       3006 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1350] != localMem[1310] ? 3025 : 3007;
      end

       3007 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1351] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3008;
      end

       3008 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1352] = heapMem[localMem[1351]*10 + localMem[1323]];
              updateArrayLength(2, 0, 0);
              ip = 3009;
      end

       3009 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1353] = heapMem[localMem[1325]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3010;
      end

       3010 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1353]*10 + localMem[1348]] = localMem[1352];
              updateArrayLength(1, localMem[1353], localMem[1348]);
              ip = 3011;
      end

       3011 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1354] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3012;
      end

       3012 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1355] = heapMem[localMem[1354]*10 + localMem[1323]];
              updateArrayLength(2, 0, 0);
              ip = 3013;
      end

       3013 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1356] = heapMem[localMem[1325]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3014;
      end

       3014 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1356]*10 + localMem[1348]] = localMem[1355];
              updateArrayLength(1, localMem[1356], localMem[1348]);
              ip = 3015;
      end

       3015 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1357] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3016;
      end

       3016 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1357]] = localMem[1323];
              ip = 3017;
      end

       3017 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1358] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3018;
      end

       3018 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1358]] = localMem[1323];
              ip = 3019;
      end

       3019 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1359] = localMem[1348] + 1;
              ip = 3020;
      end

       3020 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1325]*10 + 0] = localMem[1359];
              updateArrayLength(1, localMem[1325], 0);
              ip = 3021;
      end

       3021 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1360] = heapMem[localMem[1325]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3022;
      end

       3022 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1360]*10 + localMem[1359]] = localMem[1326];
              updateArrayLength(1, localMem[1360], localMem[1359]);
              ip = 3023;
      end

       3023 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3163;
      end

       3024 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3047;
      end

       3025 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3026;
      end

       3026 :
      begin                                                                     // assertNe
//$display("AAAA %4d %4d assertNe", steps, ip);
            ip = 3027;
      end

       3027 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1361] = heapMem[localMem[1325]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3028;
      end

       3028 :
      begin                                                                     // arrayIndex
//$display("AAAA %4d %4d arrayIndex", steps, ip);
              localMem[0 + 1362] = 0; k = arraySizes[localMem[1361]];
              for(i = 0; i < NArea; i = i + 1) begin
                if (i < k && heapMem[localMem[1361] * NArea + i] == localMem[1310]) localMem[0 + 1362] = i + 1;
              end
              ip = 3029;
      end

       3029 :
      begin                                                                     // subtract
//$display("AAAA %4d %4d subtract", steps, ip);
              localMem[0 + 1362] = localMem[1362] - 1;
              ip = 3030;
      end

       3030 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1363] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3031;
      end

       3031 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1364] = heapMem[localMem[1363]*10 + localMem[1323]];
              updateArrayLength(2, 0, 0);
              ip = 3032;
      end

       3032 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1365] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3033;
      end

       3033 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1366] = heapMem[localMem[1365]*10 + localMem[1323]];
              updateArrayLength(2, 0, 0);
              ip = 3034;
      end

       3034 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1367] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3035;
      end

       3035 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1367]] = localMem[1323];
              ip = 3036;
      end

       3036 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1368] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3037;
      end

       3037 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1368]] = localMem[1323];
              ip = 3038;
      end

       3038 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1369] = heapMem[localMem[1325]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3039;
      end

       3039 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1369] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1362], localMem[1369], arraySizes[localMem[1369]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1362] && i <= arraySizes[localMem[1369]]) begin
                  heapMem[NArea * localMem[1369] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1369] + localMem[1362]] = localMem[1364];                                    // Insert new value
              arraySizes[localMem[1369]] = arraySizes[localMem[1369]] + 1;                              // Increase array size
              ip = 3040;
      end

       3040 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1370] = heapMem[localMem[1325]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3041;
      end

       3041 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1370] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1362], localMem[1370], arraySizes[localMem[1370]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1362] && i <= arraySizes[localMem[1370]]) begin
                  heapMem[NArea * localMem[1370] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1370] + localMem[1362]] = localMem[1366];                                    // Insert new value
              arraySizes[localMem[1370]] = arraySizes[localMem[1370]] + 1;                              // Increase array size
              ip = 3042;
      end

       3042 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1371] = heapMem[localMem[1325]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3043;
      end

       3043 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1372] = localMem[1362] + 1;
              ip = 3044;
      end

       3044 :
      begin                                                                     // shiftUp
//$display("AAAA %4d %4d shiftUp", steps, ip);
//$display("AAAA %4d %4d shiftUp", steps, ip);
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[1371] + i]; // Copy source array
//$display("BBBB pos=%d array=%d length=%d", localMem[1372], localMem[1371], arraySizes[localMem[1371]]);
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > localMem[1372] && i <= arraySizes[localMem[1371]]) begin
                  heapMem[NArea * localMem[1371] + i] = arrayShift[i-1];
//$display("CCCC index=%d value=%d", i, arrayShift[i-1]);
                end
              end
              heapMem[NArea * localMem[1371] + localMem[1372]] = localMem[1326];                                    // Insert new value
              arraySizes[localMem[1371]] = arraySizes[localMem[1371]] + 1;                              // Increase array size
              ip = 3045;
      end

       3045 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1325]*10 + 0] = heapMem[localMem[1325]*10 + 0] + 1;
              ip = 3046;
      end

       3046 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3163;
      end

       3047 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3048;
      end

       3048 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3049;
      end

       3049 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1373] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1373] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1373]] = 0;
              ip = 3050;
      end

       3050 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 0] = localMem[1323];
              updateArrayLength(1, localMem[1373], 0);
              ip = 3051;
      end

       3051 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 2] = 0;
              updateArrayLength(1, localMem[1373], 2);
              ip = 3052;
      end

       3052 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1374] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1374] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1374]] = 0;
              ip = 3053;
      end

       3053 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 4] = localMem[1374];
              updateArrayLength(1, localMem[1373], 4);
              ip = 3054;
      end

       3054 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1375] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1375] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1375]] = 0;
              ip = 3055;
      end

       3055 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 5] = localMem[1375];
              updateArrayLength(1, localMem[1373], 5);
              ip = 3056;
      end

       3056 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 6] = 0;
              updateArrayLength(1, localMem[1373], 6);
              ip = 3057;
      end

       3057 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 3] = localMem[1321];
              updateArrayLength(1, localMem[1373], 3);
              ip = 3058;
      end

       3058 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1321]*10 + 1] = heapMem[localMem[1321]*10 + 1] + 1;
              ip = 3059;
      end

       3059 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 1] = heapMem[localMem[1321]*10 + 1];
              updateArrayLength(1, localMem[1373], 1);
              ip = 3060;
      end

       3060 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1376] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1376] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1376]] = 0;
              ip = 3061;
      end

       3061 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 0] = localMem[1323];
              updateArrayLength(1, localMem[1376], 0);
              ip = 3062;
      end

       3062 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 2] = 0;
              updateArrayLength(1, localMem[1376], 2);
              ip = 3063;
      end

       3063 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1377] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1377] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1377]] = 0;
              ip = 3064;
      end

       3064 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 4] = localMem[1377];
              updateArrayLength(1, localMem[1376], 4);
              ip = 3065;
      end

       3065 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1378] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1378] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1378]] = 0;
              ip = 3066;
      end

       3066 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 5] = localMem[1378];
              updateArrayLength(1, localMem[1376], 5);
              ip = 3067;
      end

       3067 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 6] = 0;
              updateArrayLength(1, localMem[1376], 6);
              ip = 3068;
      end

       3068 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 3] = localMem[1321];
              updateArrayLength(1, localMem[1376], 3);
              ip = 3069;
      end

       3069 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              heapMem[localMem[1321]*10 + 1] = heapMem[localMem[1321]*10 + 1] + 1;
              ip = 3070;
      end

       3070 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 1] = heapMem[localMem[1321]*10 + 1];
              updateArrayLength(1, localMem[1376], 1);
              ip = 3071;
      end

       3071 :
      begin                                                                     // not
//$display("AAAA %4d %4d not", steps, ip);
              localMem[0 + 1379] = !heapMem[localMem[1310]*10 + 6];
              ip = 3072;
      end

       3072 :
      begin                                                                     // jNe
//$display("AAAA %4d %4d jNe", steps, ip);
              ip = localMem[1379] != 0 ? 3124 : 3073;
      end

       3073 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1380] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1380] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1380]] = 0;
              ip = 3074;
      end

       3074 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 6] = localMem[1380];
              updateArrayLength(1, localMem[1373], 6);
              ip = 3075;
      end

       3075 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1381] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1381] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1381]] = 0;
              ip = 3076;
      end

       3076 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 6] = localMem[1381];
              updateArrayLength(1, localMem[1376], 6);
              ip = 3077;
      end

       3077 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1382] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3078;
      end

       3078 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1383] = heapMem[localMem[1373]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3079;
      end

       3079 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1383] + 0 + i] = heapMem[NArea * localMem[1382] + 0 + i];
                  updateArrayLength(1, localMem[1383], 0 + i);
                end
              end
              ip = 3080;
      end

       3080 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1384] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3081;
      end

       3081 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1385] = heapMem[localMem[1373]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3082;
      end

       3082 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1385] + 0 + i] = heapMem[NArea * localMem[1384] + 0 + i];
                  updateArrayLength(1, localMem[1385], 0 + i);
                end
              end
              ip = 3083;
      end

       3083 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1386] = heapMem[localMem[1310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3084;
      end

       3084 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1387] = heapMem[localMem[1373]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3085;
      end

       3085 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1388] = localMem[1323] + 1;
              ip = 3086;
      end

       3086 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1388]) begin
                  heapMem[NArea * localMem[1387] + 0 + i] = heapMem[NArea * localMem[1386] + 0 + i];
                  updateArrayLength(1, localMem[1387], 0 + i);
                end
              end
              ip = 3087;
      end

       3087 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1389] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3088;
      end

       3088 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1390] = heapMem[localMem[1376]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3089;
      end

       3089 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1390] + 0 + i] = heapMem[NArea * localMem[1389] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1390], 0 + i);
                end
              end
              ip = 3090;
      end

       3090 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1391] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3091;
      end

       3091 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1392] = heapMem[localMem[1376]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3092;
      end

       3092 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1392] + 0 + i] = heapMem[NArea * localMem[1391] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1392], 0 + i);
                end
              end
              ip = 3093;
      end

       3093 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1393] = heapMem[localMem[1310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3094;
      end

       3094 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1394] = heapMem[localMem[1376]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3095;
      end

       3095 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1395] = localMem[1323] + 1;
              ip = 3096;
      end

       3096 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1395]) begin
                  heapMem[NArea * localMem[1394] + 0 + i] = heapMem[NArea * localMem[1393] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1394], 0 + i);
                end
              end
              ip = 3097;
      end

       3097 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1396] = heapMem[localMem[1373]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 3098;
      end

       3098 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1397] = localMem[1396] + 1;
              ip = 3099;
      end

       3099 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1398] = heapMem[localMem[1373]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3100;
      end

       3100 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3101;
      end

       3101 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1399] = 0;
              updateArrayLength(2, 0, 0);
              ip = 3102;
      end

       3102 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3103;
      end

       3103 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1399] >= localMem[1397] ? 3109 : 3104;
      end

       3104 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1400] = heapMem[localMem[1398]*10 + localMem[1399]];
              updateArrayLength(2, 0, 0);
              ip = 3105;
      end

       3105 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1400]*10 + 2] = localMem[1373];
              updateArrayLength(1, localMem[1400], 2);
              ip = 3106;
      end

       3106 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3107;
      end

       3107 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1399] = localMem[1399] + 1;
              ip = 3108;
      end

       3108 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3102;
      end

       3109 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3110;
      end

       3110 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1401] = heapMem[localMem[1376]*10 + 0];
              updateArrayLength(2, 0, 0);
              ip = 3111;
      end

       3111 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1402] = localMem[1401] + 1;
              ip = 3112;
      end

       3112 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1403] = heapMem[localMem[1376]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3113;
      end

       3113 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3114;
      end

       3114 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1404] = 0;
              updateArrayLength(2, 0, 0);
              ip = 3115;
      end

       3115 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3116;
      end

       3116 :
      begin                                                                     // jGe
//$display("AAAA %4d %4d jGe", steps, ip);
              ip = localMem[1404] >= localMem[1402] ? 3122 : 3117;
      end

       3117 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1405] = heapMem[localMem[1403]*10 + localMem[1404]];
              updateArrayLength(2, 0, 0);
              ip = 3118;
      end

       3118 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1405]*10 + 2] = localMem[1376];
              updateArrayLength(1, localMem[1405], 2);
              ip = 3119;
      end

       3119 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3120;
      end

       3120 :
      begin                                                                     // add
//$display("AAAA %4d %4d add", steps, ip);
              localMem[0 + 1404] = localMem[1404] + 1;
              ip = 3121;
      end

       3121 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3115;
      end

       3122 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3123;
      end

       3123 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3139;
      end

       3124 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3125;
      end

       3125 :
      begin                                                                     // array
//$display("AAAA %4d %4d array", steps, ip);
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 1406] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 1406] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 1406]] = 0;
              ip = 3126;
      end

       3126 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1310]*10 + 6] = localMem[1406];
              updateArrayLength(1, localMem[1310], 6);
              ip = 3127;
      end

       3127 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1407] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3128;
      end

       3128 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1408] = heapMem[localMem[1373]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3129;
      end

       3129 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1408] + 0 + i] = heapMem[NArea * localMem[1407] + 0 + i];
                  updateArrayLength(1, localMem[1408], 0 + i);
                end
              end
              ip = 3130;
      end

       3130 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1409] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3131;
      end

       3131 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1410] = heapMem[localMem[1373]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3132;
      end

       3132 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1410] + 0 + i] = heapMem[NArea * localMem[1409] + 0 + i];
                  updateArrayLength(1, localMem[1410], 0 + i);
                end
              end
              ip = 3133;
      end

       3133 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1411] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3134;
      end

       3134 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1412] = heapMem[localMem[1376]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3135;
      end

       3135 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1412] + 0 + i] = heapMem[NArea * localMem[1411] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1412], 0 + i);
                end
              end
              ip = 3136;
      end

       3136 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1413] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3137;
      end

       3137 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1414] = heapMem[localMem[1376]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3138;
      end

       3138 :
      begin                                                                     // moveLong
//$display("AAAA %4d %4d moveLong", steps, ip);
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[1323]) begin
                  heapMem[NArea * localMem[1414] + 0 + i] = heapMem[NArea * localMem[1413] + localMem[1324] + i];
                  updateArrayLength(1, localMem[1414], 0 + i);
                end
              end
              ip = 3139;
      end

       3139 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3140;
      end

       3140 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1373]*10 + 2] = localMem[1310];
              updateArrayLength(1, localMem[1373], 2);
              ip = 3141;
      end

       3141 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1376]*10 + 2] = localMem[1310];
              updateArrayLength(1, localMem[1376], 2);
              ip = 3142;
      end

       3142 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1415] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3143;
      end

       3143 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1416] = heapMem[localMem[1415]*10 + localMem[1323]];
              updateArrayLength(2, 0, 0);
              ip = 3144;
      end

       3144 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1417] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3145;
      end

       3145 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1418] = heapMem[localMem[1417]*10 + localMem[1323]];
              updateArrayLength(2, 0, 0);
              ip = 3146;
      end

       3146 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1419] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3147;
      end

       3147 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1419]*10 + 0] = localMem[1416];
              updateArrayLength(1, localMem[1419], 0);
              ip = 3148;
      end

       3148 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1420] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3149;
      end

       3149 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1420]*10 + 0] = localMem[1418];
              updateArrayLength(1, localMem[1420], 0);
              ip = 3150;
      end

       3150 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1421] = heapMem[localMem[1310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3151;
      end

       3151 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1421]*10 + 0] = localMem[1373];
              updateArrayLength(1, localMem[1421], 0);
              ip = 3152;
      end

       3152 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1422] = heapMem[localMem[1310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3153;
      end

       3153 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1422]*10 + 1] = localMem[1376];
              updateArrayLength(1, localMem[1422], 1);
              ip = 3154;
      end

       3154 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              heapMem[localMem[1310]*10 + 0] = 1;
              updateArrayLength(1, localMem[1310], 0);
              ip = 3155;
      end

       3155 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1423] = heapMem[localMem[1310]*10 + 4];
              updateArrayLength(2, 0, 0);
              ip = 3156;
      end

       3156 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1423]] = 1;
              ip = 3157;
      end

       3157 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1424] = heapMem[localMem[1310]*10 + 5];
              updateArrayLength(2, 0, 0);
              ip = 3158;
      end

       3158 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1424]] = 1;
              ip = 3159;
      end

       3159 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1425] = heapMem[localMem[1310]*10 + 6];
              updateArrayLength(2, 0, 0);
              ip = 3160;
      end

       3160 :
      begin                                                                     // resize
//$display("AAAA %4d %4d resize", steps, ip);
              arraySizes[localMem[1425]] = 2;
              ip = 3161;
      end

       3161 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3163;
      end

       3162 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3168;
      end

       3163 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3164;
      end

       3164 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1319] = 1;
              updateArrayLength(2, 0, 0);
              ip = 3165;
      end

       3165 :
      begin                                                                     // jmp
//$display("AAAA %4d %4d jmp", steps, ip);
              ip = 3168;
      end

       3166 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3167;
      end

       3167 :
      begin                                                                     // mov
//$display("AAAA %4d %4d mov", steps, ip);
              localMem[0 + 1319] = 0;
              updateArrayLength(2, 0, 0);
              ip = 3168;
      end

       3168 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3169;
      end

       3169 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3170;
      end

       3170 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3171;
      end

       3171 :
      begin                                                                     // label
//$display("AAAA %4d %4d label", steps, ip);
              ip = 3172;
      end

       3172 :
      begin                                                                     // free
//$display("AAAA %4d %4d free", steps, ip);
              freedArrays[freedArraysTop] = localMem[951];
              freedArraysTop = freedArraysTop + 1;
              ip = 3173;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=     94) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
//for(i = 0; i < 200; ++i) $write("%4d",   localMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%4d",    heapMem[i]); $display("");
//for(i = 0; i < 200; ++i) $write("%4d", arraySizes[i]); $display("");
  end
endmodule
