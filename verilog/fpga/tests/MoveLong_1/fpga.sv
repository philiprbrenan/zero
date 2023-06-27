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
      begin                                                                     // label
              ip = 3;
      end

          3 :
      begin                                                                     // mov
              localMem[0 + 2] = 0;
              ip = 4;
      end

          4 :
      begin                                                                     // label
              ip = 5;
      end

          5 :
      begin                                                                     // jGe
              ip = localMem[0+2] >= 10 ? 12 : 6;
      end

          6 :
      begin                                                                     // mov
              heapMem[0 + localMem[0+0]*10 + localMem[0+2]] = localMem[0+2];
              ip = 7;
      end

          7 :
      begin                                                                     // add
              localMem[0 + 3] = localMem[0+2] + 100;
              ip = 8;
      end

          8 :
      begin                                                                     // mov
              heapMem[0 + localMem[0+1]*10 + localMem[0+2]] = localMem[0+3];
              ip = 9;
      end

          9 :
      begin                                                                     // label
              ip = 10;
      end

         10 :
      begin                                                                     // add
              localMem[0 + 2] = localMem[0+2] + 1;
              ip = 11;
      end

         11 :
      begin                                                                     // jmp
              ip = 4;
      end

         12 :
      begin                                                                     // label
              ip = 13;
      end

         13 :
      begin                                                                     // moveLong
              for(i = 0; i < NArea; i = i + 1) begin                            // Copy from source to target
                if (i < 3) begin
                  heapMem[NArea * localMem[0+1] + 2 + i] = heapMem[NArea * localMem[0+0] + 4 + i];
                end
              end
              ip = 14;
      end
      default: begin
        success  = 1;
        finished = 1;
      end
    endcase
    if (steps <=     89) clock <= ~ clock;                                      // Must be non sequential to fire the next iteration
  end
endmodule
