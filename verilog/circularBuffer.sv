//-----------------------------------------------------------------------------
// Circular buffer
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module CircularBuffer                                                           // Circular buffer with options to clear the buffer, add an element to the buffer or remove an element from the buffer in first in, first out order. If there is  room in the buffer as shown by the "inRemainder" pins, the buffer will accept another element fron the "in" pins when "inEnable" is high and the "clock" goes high. Likewise if the "outEnable" pin is high and there is an element in the buffer as shown by the "outRemainder" pins, then an element will be removed from the buffer and placed on the "out" pins when the "clock" goes high. In the event that the buffer would run the input request is ignored - the caller must check that there is space in the buffer by checking the "inRemainder" pins first.  Likewise, if no output element is available the "out" pins will continue to hold their last value unless the "outRemainder" pins were not all zero.
 (input  wire clock,                                                            // Clock which drives both input and output
  input  wire reset,                                                            // Reset the buffer
  input  wire inEnable,                                                         // Add input element from "in" to buffer if there is room
  input  wire outEnable,                                                        // Remove element from buffer if possible and place on "out" pins
  input  wire[NWidth:0] in,                                                     // Input channel
  output wire[NSize :0] inRemainder,                                            // Remaining free space in buffer
  output wire[NWidth:0] out,                                                    // Output channel
  output wire[NSize :0] outRemainder);                                          // Data available in buffer. This field plus inRemainder equals the size of the buffer

  parameter integer NSize  = 3;                                                 // Log2(Size of buffer)
  parameter integer NWidth = 6;                                                 // Width of each buffer element

  reg [NWidth:0] buffer[(1<<NSize)];                                            // Buffer

  reg           reset2;                                                         // Buffer input
  reg           inEnable2;
  reg           outEnable2;
  reg[NWidth:0] in2;
  reg[NSize :0]  inRemainder1,  inRemainder2;                                   // Buffer output
  reg[NSize :0] outRemainder1, outRemainder2;
  reg[NWidth:0] out1, out2;
  reg[NSize :0] pos1, pos2;                                                     // Start of active buffer
  reg[NSize :0] end1, end2;                                                     // Finish of active buffer

  assign inRemainder   = inRemainder1;                                          // Connect results registers to output pins
  assign out           = out1;
  assign outRemainder  = outRemainder1;

  always @(posedge clock) begin                                                 // Capture current input on positive edge
    reset2     <= reset;
    inEnable2  <= inEnable;
    outEnable2 <= outEnable;
    in2        <= in;
    pos2       <= pos1;
    end2       <= end1;
  end

  always @(negedge clock) begin                                                 // Reset
    if (reset2) begin                                                           // Clear buffer
      pos1 <= 0;
      end1 <= 0;
      outRemainder1 <= 0;
      inRemainder1  <= 1 << NSize;
    end
  end

  always @(negedge clock) begin                                                 // Input a new element if there is room
    if (inEnable2  && ((end2 + 1) & ((1<<NSize)-1)) != pos2) begin
      buffer[end2]   <= in2;
      end1           <= ((end2 + 1) & ((1<<NSize)-1));
      outRemainder1  <= end2 >= pos2 ? end2+1 - pos2 : (1<<NSize) - pos2 + end2 - 1;
       inRemainder1  <= end2 <= pos2 ? (1<<NSize)- end2 + pos2 - 1 : (1<<NSize) - end2 + pos2 - 1;
    end
  end

  always @(negedge clock) begin                                                 // Output an existing element of there is one
    if (outEnable2 && ((pos2 + 1)  & ((1<<NSize)-1)) != end2) begin
      out1         <= buffer[pos2  & ((1<<NSize)-1)];
      pos1         <=  (pos2 + 1)  & ((1<<NSize)-1);
      outRemainder1  <= end2 >= pos2 ? end2 - pos2 - 1 : (1<<NSize) - pos2 + end2 - 1;
       inRemainder1  <= end2 <= pos2 ? (1<<NSize)- end2 + pos2 - 1 : (1<<NSize) - end2 + pos2 + 1;
    end
  end
endmodule
