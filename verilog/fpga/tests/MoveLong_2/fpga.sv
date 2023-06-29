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
$display("AAAA %4d %4d", steps, ip);
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
              ip = 2;
      end

          2 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 0] = 11;
$display("move %10d", 11);
              ip = 3;
      end

          3 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 1] = 22;
$display("move %10d", 22);
              ip = 4;
      end

          4 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 2] = 33;
$display("move %10d", 33);
              ip = 5;
      end

          5 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 3] = 44;
$display("move %10d", 44);
              ip = 6;
      end

          6 :
      begin                                                                     // mov
              heapMem[localMem[0+0]*10 + 4] = 55;
$display("move %10d", 55);
              ip = 7;
      end

          7 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 0] = 66;
$display("move %10d", 66);
              ip = 8;
      end

          8 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 1] = 77;
$display("move %10d", 77);
              ip = 9;
      end

          9 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 2] = 88;
$display("move %10d", 88);
              ip = 10;
      end

         10 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 3] = 99;
$display("move %10d", 99);
              ip = 11;
      end

         11 :
      begin                                                                     // mov
              heapMem[localMem[0+1]*10 + 4] = 101;
$display("move %10d", 101);
              ip = 12;
      end

         12 :
      begin                                                                     // resize
              arraySizes[localMem[0+0]] = 5;
              ip = 13;
      end

         13 :
      begin                                                                     // resize
              arraySizes[localMem[0+1]] = 5;
              ip = 14;
      end

         14 :
      begin                                                                     // arraySize
              localMem[0 + 2] = arraySizes[localMem[0+0]];
              ip = 15;
      end

         15 :
      begin                                                                     // label
              ip = 16;
      end

         16 :
      begin                                                                     // mov
              localMem[0 + 3] = 0;
$display("move %10d", 0);
              ip = 17;
      end

         17 :
      begin                                                                     // label
              ip = 18;
      end

         18 :
      begin                                                                     // jGe
              ip = localMem[0+3] >= localMem[0+2] ? 24 : 19;
      end

         19 :
      begin                                                                     // mov
              localMem[0 + 4] = heapMem[localMem[0+0]*10 + localMem[0+3]];
$display("move %10d", heapMem[localMem[0+0]*10 + localMem[0+3]]);
              ip = 20;
      end

         20 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+4];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 21;
      end

         21 :
      begin                                                                     // label
              ip = 22;
      end

         22 :
      begin                                                                     // add
$display("add %4d %4d", localMem[0+3], 1);
              localMem[0 + 3] = localMem[0+3] + 1;
              ip = 23;
      end

         23 :
      begin                                                                     // jmp
              ip = 17;
      end

         24 :
      begin                                                                     // label
              ip = 25;
      end

         25 :
      begin                                                                     // arraySize
              localMem[0 + 5] = arraySizes[localMem[0+1]];
              ip = 26;
      end

         26 :
      begin                                                                     // label
              ip = 27;
      end

         27 :
      begin                                                                     // mov
              localMem[0 + 6] = 0;
$display("move %10d", 0);
              ip = 28;
      end

         28 :
      begin                                                                     // label
              ip = 29;
      end

         29 :
      begin                                                                     // jGe
              ip = localMem[0+6] >= localMem[0+5] ? 35 : 30;
      end

         30 :
      begin                                                                     // mov
              localMem[0 + 7] = heapMem[localMem[0+1]*10 + localMem[0+6]];
$display("move %10d", heapMem[localMem[0+1]*10 + localMem[0+6]]);
              ip = 31;
      end

         31 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+7];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 32;
      end

         32 :
      begin                                                                     // label
              ip = 33;
      end

         33 :
      begin                                                                     // add
$display("add %4d %4d", localMem[0+6], 1);
              localMem[0 + 6] = localMem[0+6] + 1;
              ip = 34;
      end

         34 :
      begin                                                                     // jmp
              ip = 28;
      end

         35 :
      begin                                                                     // label
              ip = 36;
      end

         36 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 2) begin
                  heapMem[NArea * localMem[0+0] + 1 + i] = heapMem[NArea * localMem[0+1] + 2 + i];
                end
              end
              ip = 37;
      end

         37 :
      begin                                                                     // arraySize
              localMem[0 + 8] = arraySizes[localMem[0+0]];
              ip = 38;
      end

         38 :
      begin                                                                     // label
              ip = 39;
      end

         39 :
      begin                                                                     // mov
              localMem[0 + 9] = 0;
$display("move %10d", 0);
              ip = 40;
      end

         40 :
      begin                                                                     // label
              ip = 41;
      end

         41 :
      begin                                                                     // jGe
              ip = localMem[0+9] >= localMem[0+8] ? 47 : 42;
      end

         42 :
      begin                                                                     // mov
              localMem[0 + 10] = heapMem[localMem[0+0]*10 + localMem[0+9]];
$display("move %10d", heapMem[localMem[0+0]*10 + localMem[0+9]]);
              ip = 43;
      end

         43 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+10];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 44;
      end

         44 :
      begin                                                                     // label
              ip = 45;
      end

         45 :
      begin                                                                     // add
$display("add %4d %4d", localMem[0+9], 1);
              localMem[0 + 9] = localMem[0+9] + 1;
              ip = 46;
      end

         46 :
      begin                                                                     // jmp
              ip = 40;
      end

         47 :
      begin                                                                     // label
              ip = 48;
      end

         48 :
      begin                                                                     // arraySize
              localMem[0 + 11] = arraySizes[localMem[0+1]];
              ip = 49;
      end

         49 :
      begin                                                                     // label
              ip = 50;
      end

         50 :
      begin                                                                     // mov
              localMem[0 + 12] = 0;
$display("move %10d", 0);
              ip = 51;
      end

         51 :
      begin                                                                     // label
              ip = 52;
      end

         52 :
      begin                                                                     // jGe
              ip = localMem[0+12] >= localMem[0+11] ? 58 : 53;
      end

         53 :
      begin                                                                     // mov
              localMem[0 + 13] = heapMem[localMem[0+1]*10 + localMem[0+12]];
$display("move %10d", heapMem[localMem[0+1]*10 + localMem[0+12]]);
              ip = 54;
      end

         54 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+13];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 55;
      end

         55 :
      begin                                                                     // label
              ip = 56;
      end

         56 :
      begin                                                                     // add
$display("add %4d %4d", localMem[0+12], 1);
              localMem[0 + 12] = localMem[0+12] + 1;
              ip = 57;
      end

         57 :
      begin                                                                     // jmp
              ip = 51;
      end

         58 :
      begin                                                                     // label
              ip = 59;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 11;
        success  = success && outMem[1] == 22;
        success  = success && outMem[2] == 33;
        success  = success && outMem[3] == 44;
        success  = success && outMem[4] == 55;
        success  = success && outMem[5] == 66;
        success  = success && outMem[6] == 77;
        success  = success && outMem[7] == 88;
        success  = success && outMem[8] == 99;
        success  = success && outMem[9] == 101;
        success  = success && outMem[10] == 11;
        success  = success && outMem[11] == 88;
        success  = success && outMem[12] == 99;
        success  = success && outMem[13] == 44;
        success  = success && outMem[14] == 55;
        success  = success && outMem[15] == 66;
        success  = success && outMem[16] == 77;
        success  = success && outMem[17] == 88;
        success  = success && outMem[18] == 99;
        success  = success && outMem[19] == 101;
        finished = 1;
      end
    endcase
    if (steps <=    180) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
