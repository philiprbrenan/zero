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
              heapMem[0 + localMem[0+1]*10 + 0] = 0;
              ip = 3;
      end

          3 :
      begin                                                                     // mov
              heapMem[0 + localMem[0+1]*10 + 1] = 1;
              ip = 4;
      end

          4 :
      begin                                                                     // mov
              heapMem[0 + localMem[0+1]*10 + 2] = 2;
              ip = 5;
      end

          5 :
      begin                                                                     // resize
              arraySizes[localMem[0+1]] = 3;
              ip = 6;
      end

          6 :
      begin                                                                     // shiftUp
              for(i = 0; i < NArea; i = i + 1) arrayShift[i] = heapMem[NArea * localMem[0+1] + i]; // Copy source array
              for(i = 0; i < NArea; i = i + 1) begin                            // Move original array up
                if (i > 0) begin
                  heapMem[NArea * localMem[0+1] + i] = arrayShift[i-1];
                end
              end
              heapMem[NArea * localMem[0+1] + 0] = 99;                                    // Insert new value
              arraySizes[localMem[0+1]] = arraySizes[localMem[0+1]] + 1;                              // Increase array size
              ip = 7;
      end

          7 :
      begin                                                                     // arraySize
              localMem[0 + 2] = arraySizes[localMem[0+1]];
              ip = 8;
      end

          8 :
      begin                                                                     // label
              ip = 9;
      end

          9 :
      begin                                                                     // mov
              localMem[0 + 3] = 0;
              ip = 10;
      end

         10 :
      begin                                                                     // label
              ip = 11;
      end

         11 :
      begin                                                                     // jGe
              ip = localMem[0+3] >= localMem[0+2] ? 17 : 12;
      end

         12 :
      begin                                                                     // mov
              localMem[0 + 4] = heapMem[0 + localMem[0+1]*10 + localMem[0+3]];
              ip = 13;
      end

         13 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+4];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 14;
      end

         14 :
      begin                                                                     // label
              ip = 15;
      end

         15 :
      begin                                                                     // add
              localMem[0 + 3] = localMem[0+3] + 1;
              ip = 16;
      end

         16 :
      begin                                                                     // jmp
              ip = 10;
      end

         17 :
      begin                                                                     // label
              ip = 18;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 99;
        success  = success && outMem[1] == 0;
        success  = success && outMem[2] == 1;
        success  = success && outMem[3] == 2;
        finished = 1;
      end
    endcase
    if (steps <=     42) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
