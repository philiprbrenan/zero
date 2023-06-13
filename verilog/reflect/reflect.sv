//-----------------------------------------------------------------------------
// Reflect a value
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module Reflect
 (input  wire     clk,
  output reg[7:0] out = 0);

  always @(posedge clk) begin
    out <= out + 1;
    $display("Set  %d", out);
  end
endmodule
