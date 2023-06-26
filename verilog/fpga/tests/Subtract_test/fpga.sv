//-----------------------------------------------------------------------------
// Fpga test
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module fpga                                                                     // Run test programs
 (input  wire run,                                                              // Run - clock at lest once to allow code to be loaded
  output reg  finished,                                                         // Goes high when the program has finished
  output reg  success);                                                         // Goes high on finish if all the tests passed

  parameter integer MemoryElementWidth =  12;                                   // Memory element width

  parameter integer NArea          =    4;                                      // Size of each area on the heap
  parameter integer NArrays        =   20;                                      // Maximum number of arrays
  parameter integer NHeap          =  100;                                      // Amount of heap memory
  parameter integer NLocal         =  100;                                      // Size of local memory
  parameter integer NOut           =  100;                                      // Size of output area
  parameter integer NFreedArrays   =   20;                                      // Size of output area
  parameter integer NIn            =     0;                                     // Size of input area
  reg [MemoryElementWidth-1:0]   arraySizes[NArrays-1      :0];                 // Size of each array
  reg [MemoryElementWidth-1:0]      heapMem[NHeap-1        :0];                 // Heap memory
  reg [MemoryElementWidth-1:0]     localMem[NLocal-1       :0];                 // Local memory
  reg [MemoryElementWidth-1:0]       outMem[NOut-1         :0];                 // Out channel
  reg [MemoryElementWidth-1:0]        inMem[NIn-1          :0];                 // In channel
  reg [MemoryElementWidth-1:0]  freedArrays[NFreedArrays-1 :0];                 // Freed arrays list implemented as a stack
  reg [MemoryElementWidth-1:0]   arrayShift[NArea-1        :0];                 // Array shift area

  integer inMemPos;                                                             // Current position in input channel
  integer outMemPos;                                                            // Position in output channel
  integer allocs;                                                               // Maximum number of array allocations in use at any one time
  integer freedArraysTop;                                                       // Position in freed arrays stack

  integer ip;                                                                   // Instruction pointer
  reg     clock;                                                                // Clock - has to be one bit wide for yosys
  integer steps;                                                                // Number of steps executed so far

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
      begin                                                                     // subtract
              localMem[0 + 0] = 4 - 2;
              ip = 1;
      end

          1 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+0];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 2;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 2;
        finished = 1;
      end
    endcase
    if (steps <=      3) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
