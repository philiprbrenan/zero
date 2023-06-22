//-----------------------------------------------------------------------------
// Step
// Philip R Brenan at appaapps dot com, Appa Apps Ltd Inc., 2023
//------------------------------------------------------------------------------
module step
 (input  wire in);

  reg[2:0] mid1 = 0;
  reg[2:0] mid2 = 0;
  reg[2:0] mid3;
  assign mid3 = {mid1[1],mid2[1]}[1];

  always @(posedge in) begin
    $display("BBBB1");
    mid1 <= mid1 + 1;
    $display("BBBB2");
    mid2 <= mid2 + 1;
    $display("BBBB3");
  end
  always @(posedge mid1) begin
    $display("CCCC %d", mid1);
  end
  always @(posedge mid2) begin
    $display("DDDD %d", mid2);
  end
  always @(posedge (mid1 || mid2)) begin
    $display("EEEE");
  end
endmodule
