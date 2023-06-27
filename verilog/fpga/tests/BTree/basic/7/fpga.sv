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
  parameter integer NArrays        =   20;                                      // Maximum number of arrays
  parameter integer NHeap          =  100;                                      // Amount of heap memory
  parameter integer NLocal         =  600;                                      // Size of local memory
  parameter integer NOut           =  100;                                      // Size of output area
  parameter integer NFreedArrays   =   20;                                      // Freed arrays
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
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 2] = 7;
              ip = 2;
      end

          2 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = 0;
              ip = 3;
      end

          3 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 0] = 0;
              ip = 4;
      end

          4 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 1] = 0;
              ip = 5;
      end

          5 :
      begin                                                                     // array
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
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = 0;
              ip = 7;
      end

          7 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = 0;
              ip = 8;
      end

          8 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 2] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 2] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 2]] = 0;
              ip = 9;
      end

          9 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 4] = localMem[0+2];
              ip = 10;
      end

         10 :
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
              ip = 11;
      end

         11 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 5] = localMem[0+3];
              ip = 12;
      end

         12 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 6] = 0;
              ip = 13;
      end

         13 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 3] = localMem[0+0];
              ip = 14;
      end

         14 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 15;
      end

         15 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 16;
      end

         16 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 4] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 4] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 4]] = 0;
              ip = 17;
      end

         17 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 6] = localMem[0+4];
              ip = 18;
      end

         18 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 5] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 5] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 5]] = 0;
              ip = 19;
      end

         19 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 0] = 0;
              ip = 20;
      end

         20 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 2] = 0;
              ip = 21;
      end

         21 :
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
              ip = 22;
      end

         22 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 4] = localMem[0+6];
              ip = 23;
      end

         23 :
      begin                                                                     // array
              if (freedArraysTop > 0) begin
                freedArraysTop = freedArraysTop - 1;
                localMem[0 + 7] = freedArrays[freedArraysTop];
              end
              else begin
                localMem[0 + 7] = allocs;
                allocs = allocs + 1;

              end
              arraySizes[localMem[0 + 7]] = 0;
              ip = 24;
      end

         24 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 5] = localMem[0+7];
              ip = 25;
      end

         25 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 6] = 0;
              ip = 26;
      end

         26 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 3] = localMem[0+0];
              ip = 27;
      end

         27 :
      begin                                                                     // add
              heapMem[localMem[0+0]*10 + 1] = heapMem[localMem[0+0]*10 + 1] + 1;
              ip = 28;
      end

         28 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 1] = heapMem[localMem[0+0]*10 + 1];
              ip = 29;
      end

         29 :
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
              ip = 30;
      end

         30 :
      begin                                                                     // mov
              heapMem[localMem[0+5]*10 + 6] = localMem[0+8];
              ip = 31;
      end

         31 :
      begin                                                                     // mov
              localMem[0 + 9] = heapMem[localMem[0+1]*10 + 4];
              ip = 32;
      end

         32 :
      begin                                                                     // mov
              heapMem[localMem[0+9]*10 + 0] = 11;
              ip = 33;
      end

         33 :
      begin                                                                     // mov
              localMem[0 + 10] = heapMem[localMem[0+1]*10 + 5];
              ip = 34;
      end

         34 :
      begin                                                                     // mov
              heapMem[localMem[0+10]*10 + 0] = 21;
              ip = 35;
      end

         35 :
      begin                                                                     // mov
              localMem[0 + 11] = heapMem[localMem[0+1]*10 + 6];
              ip = 36;
      end

         36 :
      begin                                                                     // mov
              heapMem[localMem[0+11]*10 + 0] = 31;
              ip = 37;
      end

         37 :
      begin                                                                     // mov
              localMem[0 + 12] = heapMem[localMem[0+5]*10 + 4];
              ip = 38;
      end

         38 :
      begin                                                                     // mov
              heapMem[localMem[0+12]*10 + 0] = 41;
              ip = 39;
      end

         39 :
      begin                                                                     // mov
              localMem[0 + 13] = heapMem[localMem[0+5]*10 + 5];
              ip = 40;
      end

         40 :
      begin                                                                     // mov
              heapMem[localMem[0+13]*10 + 0] = 51;
              ip = 41;
      end

         41 :
      begin                                                                     // mov
              localMem[0 + 14] = heapMem[localMem[0+5]*10 + 6];
              ip = 42;
      end

         42 :
      begin                                                                     // mov
              heapMem[localMem[0+14]*10 + 0] = 61;
              ip = 43;
      end

         43 :
      begin                                                                     // mov
              localMem[0 + 15] = heapMem[localMem[0+1]*10 + 4];
              ip = 44;
      end

         44 :
      begin                                                                     // mov
              heapMem[localMem[0+15]*10 + 1] = 12;
              ip = 45;
      end

         45 :
      begin                                                                     // mov
              localMem[0 + 16] = heapMem[localMem[0+1]*10 + 5];
              ip = 46;
      end

         46 :
      begin                                                                     // mov
              heapMem[localMem[0+16]*10 + 1] = 22;
              ip = 47;
      end

         47 :
      begin                                                                     // mov
              localMem[0 + 17] = heapMem[localMem[0+1]*10 + 6];
              ip = 48;
      end

         48 :
      begin                                                                     // mov
              heapMem[localMem[0+17]*10 + 1] = 32;
              ip = 49;
      end

         49 :
      begin                                                                     // mov
              localMem[0 + 18] = heapMem[localMem[0+5]*10 + 4];
              ip = 50;
      end

         50 :
      begin                                                                     // mov
              heapMem[localMem[0+18]*10 + 1] = 42;
              ip = 51;
      end

         51 :
      begin                                                                     // mov
              localMem[0 + 19] = heapMem[localMem[0+5]*10 + 5];
              ip = 52;
      end

         52 :
      begin                                                                     // mov
              heapMem[localMem[0+19]*10 + 1] = 52;
              ip = 53;
      end

         53 :
      begin                                                                     // mov
              localMem[0 + 20] = heapMem[localMem[0+5]*10 + 6];
              ip = 54;
      end

         54 :
      begin                                                                     // mov
              heapMem[localMem[0+20]*10 + 1] = 62;
              ip = 55;
      end

         55 :
      begin                                                                     // mov
              localMem[0 + 21] = heapMem[localMem[0+1]*10 + 4];
              ip = 56;
      end

         56 :
      begin                                                                     // mov
              heapMem[localMem[0+21]*10 + 2] = 13;
              ip = 57;
      end

         57 :
      begin                                                                     // mov
              localMem[0 + 22] = heapMem[localMem[0+1]*10 + 5];
              ip = 58;
      end

         58 :
      begin                                                                     // mov
              heapMem[localMem[0+22]*10 + 2] = 23;
              ip = 59;
      end

         59 :
      begin                                                                     // mov
              localMem[0 + 23] = heapMem[localMem[0+1]*10 + 6];
              ip = 60;
      end

         60 :
      begin                                                                     // mov
              heapMem[localMem[0+23]*10 + 2] = 33;
              ip = 61;
      end

         61 :
      begin                                                                     // mov
              localMem[0 + 24] = heapMem[localMem[0+5]*10 + 4];
              ip = 62;
      end

         62 :
      begin                                                                     // mov
              heapMem[localMem[0+24]*10 + 2] = 43;
              ip = 63;
      end

         63 :
      begin                                                                     // mov
              localMem[0 + 25] = heapMem[localMem[0+5]*10 + 5];
              ip = 64;
      end

         64 :
      begin                                                                     // mov
              heapMem[localMem[0+25]*10 + 2] = 53;
              ip = 65;
      end

         65 :
      begin                                                                     // mov
              localMem[0 + 26] = heapMem[localMem[0+5]*10 + 6];
              ip = 66;
      end

         66 :
      begin                                                                     // mov
              heapMem[localMem[0+26]*10 + 2] = 63;
              ip = 67;
      end

         67 :
      begin                                                                     // mov
              localMem[0 + 27] = heapMem[localMem[0+1]*10 + 4];
              ip = 68;
      end

         68 :
      begin                                                                     // mov
              heapMem[localMem[0+27]*10 + 3] = 14;
              ip = 69;
      end

         69 :
      begin                                                                     // mov
              localMem[0 + 28] = heapMem[localMem[0+1]*10 + 5];
              ip = 70;
      end

         70 :
      begin                                                                     // mov
              heapMem[localMem[0+28]*10 + 3] = 24;
              ip = 71;
      end

         71 :
      begin                                                                     // mov
              localMem[0 + 29] = heapMem[localMem[0+1]*10 + 6];
              ip = 72;
      end

         72 :
      begin                                                                     // mov
              heapMem[localMem[0+29]*10 + 3] = 34;
              ip = 73;
      end

         73 :
      begin                                                                     // mov
              localMem[0 + 30] = heapMem[localMem[0+5]*10 + 4];
              ip = 74;
      end

         74 :
      begin                                                                     // mov
              heapMem[localMem[0+30]*10 + 3] = 44;
              ip = 75;
      end

         75 :
      begin                                                                     // mov
              localMem[0 + 31] = heapMem[localMem[0+5]*10 + 5];
              ip = 76;
      end

         76 :
      begin                                                                     // mov
              heapMem[localMem[0+31]*10 + 3] = 54;
              ip = 77;
      end

         77 :
      begin                                                                     // mov
              localMem[0 + 32] = heapMem[localMem[0+5]*10 + 6];
              ip = 78;
      end

         78 :
      begin                                                                     // mov
              heapMem[localMem[0+32]*10 + 3] = 64;
              ip = 79;
      end

         79 :
      begin                                                                     // mov
              localMem[0 + 33] = heapMem[localMem[0+1]*10 + 4];
              ip = 80;
      end

         80 :
      begin                                                                     // mov
              heapMem[localMem[0+33]*10 + 4] = 15;
              ip = 81;
      end

         81 :
      begin                                                                     // mov
              localMem[0 + 34] = heapMem[localMem[0+1]*10 + 5];
              ip = 82;
      end

         82 :
      begin                                                                     // mov
              heapMem[localMem[0+34]*10 + 4] = 25;
              ip = 83;
      end

         83 :
      begin                                                                     // mov
              localMem[0 + 35] = heapMem[localMem[0+1]*10 + 6];
              ip = 84;
      end

         84 :
      begin                                                                     // mov
              heapMem[localMem[0+35]*10 + 4] = 35;
              ip = 85;
      end

         85 :
      begin                                                                     // mov
              localMem[0 + 36] = heapMem[localMem[0+5]*10 + 4];
              ip = 86;
      end

         86 :
      begin                                                                     // mov
              heapMem[localMem[0+36]*10 + 4] = 45;
              ip = 87;
      end

         87 :
      begin                                                                     // mov
              localMem[0 + 37] = heapMem[localMem[0+5]*10 + 5];
              ip = 88;
      end

         88 :
      begin                                                                     // mov
              heapMem[localMem[0+37]*10 + 4] = 55;
              ip = 89;
      end

         89 :
      begin                                                                     // mov
              localMem[0 + 38] = heapMem[localMem[0+5]*10 + 6];
              ip = 90;
      end

         90 :
      begin                                                                     // mov
              heapMem[localMem[0+38]*10 + 4] = 65;
              ip = 91;
      end

         91 :
      begin                                                                     // mov
              localMem[0 + 39] = heapMem[localMem[0+1]*10 + 4];
              ip = 92;
      end

         92 :
      begin                                                                     // mov
              heapMem[localMem[0+39]*10 + 5] = 16;
              ip = 93;
      end

         93 :
      begin                                                                     // mov
              localMem[0 + 40] = heapMem[localMem[0+1]*10 + 5];
              ip = 94;
      end

         94 :
      begin                                                                     // mov
              heapMem[localMem[0+40]*10 + 5] = 26;
              ip = 95;
      end

         95 :
      begin                                                                     // mov
              localMem[0 + 41] = heapMem[localMem[0+1]*10 + 6];
              ip = 96;
      end

         96 :
      begin                                                                     // mov
              heapMem[localMem[0+41]*10 + 5] = 36;
              ip = 97;
      end

         97 :
      begin                                                                     // mov
              localMem[0 + 42] = heapMem[localMem[0+5]*10 + 4];
              ip = 98;
      end

         98 :
      begin                                                                     // mov
              heapMem[localMem[0+42]*10 + 5] = 46;
              ip = 99;
      end

         99 :
      begin                                                                     // mov
              localMem[0 + 43] = heapMem[localMem[0+5]*10 + 5];
              ip = 100;
      end

        100 :
      begin                                                                     // mov
              heapMem[localMem[0+43]*10 + 5] = 56;
              ip = 101;
      end

        101 :
      begin                                                                     // mov
              localMem[0 + 44] = heapMem[localMem[0+5]*10 + 6];
              ip = 102;
      end

        102 :
      begin                                                                     // mov
              heapMem[localMem[0+44]*10 + 5] = 66;
              ip = 103;
      end

        103 :
      begin                                                                     // mov
              localMem[0 + 45] = heapMem[localMem[0+1]*10 + 4];
              ip = 104;
      end

        104 :
      begin                                                                     // mov
              heapMem[localMem[0+45]*10 + 6] = 17;
              ip = 105;
      end

        105 :
      begin                                                                     // mov
              localMem[0 + 46] = heapMem[localMem[0+1]*10 + 5];
              ip = 106;
      end

        106 :
      begin                                                                     // mov
              heapMem[localMem[0+46]*10 + 6] = 27;
              ip = 107;
      end

        107 :
      begin                                                                     // mov
              localMem[0 + 47] = heapMem[localMem[0+1]*10 + 6];
              ip = 108;
      end

        108 :
      begin                                                                     // mov
              heapMem[localMem[0+47]*10 + 6] = 37;
              ip = 109;
      end

        109 :
      begin                                                                     // mov
              localMem[0 + 48] = heapMem[localMem[0+5]*10 + 4];
              ip = 110;
      end

        110 :
      begin                                                                     // mov
              heapMem[localMem[0+48]*10 + 6] = 47;
              ip = 111;
      end

        111 :
      begin                                                                     // mov
              localMem[0 + 49] = heapMem[localMem[0+5]*10 + 5];
              ip = 112;
      end

        112 :
      begin                                                                     // mov
              heapMem[localMem[0+49]*10 + 6] = 57;
              ip = 113;
      end

        113 :
      begin                                                                     // mov
              localMem[0 + 50] = heapMem[localMem[0+5]*10 + 6];
              ip = 114;
      end

        114 :
      begin                                                                     // mov
              heapMem[localMem[0+50]*10 + 6] = 67;
              ip = 115;
      end

        115 :
      begin                                                                     // mov
              localMem[0 + 51] = heapMem[localMem[0+1]*10 + 6];
              ip = 116;
      end

        116 :
      begin                                                                     // mov
              heapMem[localMem[0+51]*10 + 7] = 97;
              ip = 117;
      end

        117 :
      begin                                                                     // mov
              localMem[0 + 52] = heapMem[localMem[0+5]*10 + 6];
              ip = 118;
      end

        118 :
      begin                                                                     // mov
              heapMem[localMem[0+52]*10 + 7] = 99;
              ip = 119;
      end

        119 :
      begin                                                                     // mov
              localMem[0 + 53] = heapMem[localMem[0+1]*10 + 4];
              ip = 120;
      end

        120 :
      begin                                                                     // mov
              localMem[0 + 54] = heapMem[localMem[0+5]*10 + 4];
              ip = 121;
      end

        121 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 2) begin
                  heapMem[NArea * localMem[0+54] + 0 + i] = heapMem[NArea * localMem[0+53] + 3 + i];
                end
              end
              ip = 122;
      end

        122 :
      begin                                                                     // mov
              localMem[0 + 55] = heapMem[localMem[0+1]*10 + 5];
              ip = 123;
      end

        123 :
      begin                                                                     // mov
              localMem[0 + 56] = heapMem[localMem[0+5]*10 + 5];
              ip = 124;
      end

        124 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 2) begin
                  heapMem[NArea * localMem[0+56] + 0 + i] = heapMem[NArea * localMem[0+55] + 3 + i];
                end
              end
              ip = 125;
      end

        125 :
      begin                                                                     // mov
              localMem[0 + 57] = heapMem[localMem[0+1]*10 + 6];
              ip = 126;
      end

        126 :
      begin                                                                     // mov
              localMem[0 + 58] = heapMem[localMem[0+5]*10 + 6];
              ip = 127;
      end

        127 :
      begin                                                                     // add
              localMem[0 + 59] = 2 + 1;
              ip = 128;
      end

        128 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < localMem[0+59]) begin
                  heapMem[NArea * localMem[0+58] + 0 + i] = heapMem[NArea * localMem[0+57] + 3 + i];
                end
              end
              ip = 129;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=    130) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
