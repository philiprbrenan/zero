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
    case(ip)

          0 :
      begin                                                                     // label
              ip = 1;
      end

          1 :
      begin                                                                     // mov
              localMem[0 + 0] = 1;
              ip = 2;
      end

          2 :
      begin                                                                     // mov
              localMem[0 + 1] = 2;
              ip = 3;
      end

          3 :
      begin                                                                     // jEq
              ip = localMem[0+0] == localMem[0+1] ? 8 : 4;
      end

          4 :
      begin                                                                     // out
              outMem[outMemPos] = 111;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 5;
      end

          5 :
      begin                                                                     // jEq
              ip = localMem[0+0] == localMem[0+0] ? 8 : 6;
      end

          6 :
      begin                                                                     // out
              outMem[outMemPos] = 222;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 7;
      end

          7 :
      begin                                                                     // jmp
              ip = 11;
      end

          8 :
      begin                                                                     // label
              ip = 9;
      end

          9 :
      begin                                                                     // out
              outMem[outMemPos] = 333;
              outMemPos = (outMemPos + 1) % NOut;
              ip = 10;
      end

         10 :
      begin                                                                     // label
              ip = 11;
      end

         11 :
      begin                                                                     // label
              ip = 12;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 111;
        success  = success && outMem[1] == 333;
        finished = 1;
      end
    endcase
    if (steps <=     11) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
