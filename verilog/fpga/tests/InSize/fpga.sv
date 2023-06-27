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
  parameter integer NIn            =     2;                                     // Size of input area
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
    inMem[0] = 88;
    inMem[1] = 44;
  end

  always @(clock) begin                                                         // Each instruction
    steps = steps + 1;
    case(ip)

          0 :
      begin                                                                     // inSize
              localMem[0 + 0] = NIn - inMemPos;
              ip = 1;
      end

          1 :
      begin                                                                     // in
              if (inMemPos < NIn) begin
                localMem[0 + 1] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 2;
      end

          2 :
      begin                                                                     // inSize
              localMem[0 + 2] = NIn - inMemPos;
              ip = 3;
      end

          3 :
      begin                                                                     // in
              if (inMemPos < NIn) begin
                localMem[0 + 3] = inMem[inMemPos];
                inMemPos = inMemPos + 1;
              end
              ip = 4;
      end

          4 :
      begin                                                                     // inSize
              localMem[0 + 4] = NIn - inMemPos;
              ip = 5;
      end

          5 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+1];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 6;
      end

          6 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+3];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 7;
      end

          7 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+0];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 8;
      end

          8 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+2];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 9;
      end

          9 :
      begin                                                                     // out
              outMem[outMemPos] = localMem[0+4];
              outMemPos = (outMemPos + 1) % NOut;
              ip = 10;
      end
      default: begin
        success  = 1;
        success  = success && outMem[0] == 88;
        success  = success && outMem[1] == 44;
        success  = success && outMem[2] == 2;
        success  = success && outMem[3] == 1;
        success  = success && outMem[4] == 0;
        finished = 1;
      end
    endcase
    if (steps <=     11) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
