//-----------------------------------------------------------------------------
// Circular buffer - test implementation for use in fpga.sv
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module CircularBuffer                                                           // Circular buffer with options to clear the buffer, add an element to the buffer or remove an element from the buffer in first in, first out order. If there is  room in the buffer as shown by the "inRemainder" pins, the buffer will accept another element fron the "in" pins when "inEnable" is high and the "clock" goes high. Likewise if the "outEnable" pin is high and there is an element in the buffer as shown by the "outRemainder" pins, then an element will be removed from the buffer and placed on the "out" pins when the "clock" goes high. Inthe event that the buffer would run the input request is ignored - the caller must check that ther is space in the buffer  by checking the "inRemainder" pins first.  Likewise, if no output element is available the "out" [pins wil contionue to hold thei last value unless the "outRemainder" pins were not all zero.
 (input  wire clock,                                                            // Clock which drives both input and output
  input  wire reset,                                                            // Reset the buffer
  input  wire inEnable,                                                         // Add input element from "in" to buffer if there is room
  input  wire outEnable,                                                        // Remove element from buffer if possible and plae on "out" pins
  input  wire[NWidth :0] in,                                                    // Input channel
  output wire[NBuffer:0] inRemainder,                                           // Remaining free space in buffer
  output wire[NWidth :0] out,                                                   // Output channel
  output wire[NBuffer:0] outRemainder);                                         // Data available in buffer.  This field plus inRemainder equals the size of the buffer

  parameter integer NBuffer  = 3;                                               // Log2(Size of buffer)
  parameter integer NWidth   = 6;                                               // Width of each buffer element

  reg signed [NWidth:0] buffer[(1<<NBuffer)];                                   // Buffer

  integer signed Pos;                                                           // Start of active buffer
  integer signed End;                                                           // End of active buffer
  integer signed InRemainder;                                                   // Remaining space in buffer - if zero there is no more room until some elements have been read out
  integer signed Out;                                                           // Register to drive "out" pins
  integer signed OutRemainder;                                                  // Number of elements still readable - none when zero

  assign inRemainder  = InRemainder;                                            // Connect results registers to output pins
  assign out          = Out;
  assign outRemainder = OutRemainder;

  task space();                                                                 // Update space available
    fork
      if (End >= Pos) fork                                                      // Buffer not wrapped
        OutRemainder = End - Pos;
        InRemainder  = (1<<NBuffer) + Pos - End;
      join
      if (End < Pos)  fork                                                      // Buffer wrapped
        OutRemainder = (1<<NBuffer) - Pos + End;
        InRemainder  = Pos - End;
      join
      //$display("Space pos=%d end=%d NBuffer=%d r=%d InRemainder=%d OutRemainder=%d", Pos, End, NBuffer, r, InRemainder, OutRemainder);
    join
  endtask

  always @(posedge clock) fork                                                  // Next clock action
  //$display("NControl=%d", NControl);
  //$display("Clock Up reset=%d inEnable=%d outEnable=%d", reset, inEnable, outEnable);
  //$display("Mask = %x", ((1<<NBuffer)-1));
    if (reset) begin                                                            // Clear buffer
      fork
        Pos = 0;
        End = 0;
      join
      space();
    end

    if (inEnable  && ((End + 1) & ((1<<NBuffer)-1)) != Pos) begin               // Input a new element if there is room
      buffer[End] = in;
      End         =  ((End + 1) & ((1<<NBuffer)-1));
      space();
    end

    if (outEnable && ((Pos + 1) & ((1<<NBuffer)-1)) != End) begin               // Output an existing element of there is one
      Out         = buffer[Pos  & ((1<<NBuffer)-1)];
      Pos         = (Pos + 1)   & ((1<<NBuffer)-1);
      space();
    end
  join
endmodule
