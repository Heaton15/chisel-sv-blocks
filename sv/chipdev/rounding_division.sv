module rounding_division (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    din,
    clk,
    rst
);

  parameter int DIV_LOG2 = 3;
  parameter int OUT_WIDTH = 8;
  parameter int IN_WIDTH = OUT_WIDTH + DIV_LOG2;

  input [IN_WIDTH-1:0] din;
  output [OUT_WIDTH-1:0] dout_tmp;

  input clk, rst;


  // 1. Bit shifting to the right will divide by 2
  // 2. This will do an implicit $floor(3.5) = 3 round, but we want $ceil(3.5) = 4
  // 3. The shifted out portion is the fractional piece we can calculate on
  // 4. Output saturation should saturate the bus line 2045 /8 = 255.625 = 256 (all 0s) which should actually cause
  //    a saturation

  // bin(73) -> 8'b1001001
  // bin(78) -> 8'b1001110
  // out = 5 bits
  //
  // 11'b1111111111
  // 8'b    1111111
  //
  // 11'b11111111110
  //  8'b   11111110

  // 73 / 8 -> 9.125 = 9  -> 1001 [0]   01 (round down)
  // 79 / 8 -> 9.875 = 10 -> 1001 [1]   10 (round up)

  wire [DIV_LOG2-1:0] remainder = din[DIV_LOG2-1:0];
  wire [OUT_WIDTH-1:0] divided_number = din >> DIV_LOG2;

  wire round_up = remainder[DIV_LOG2-1];

  assign dout_tmp = round_up ? divided_number + 1'b1 : divided_number;
  assign dout = |din[IN_WIDTH-1:IN_WIDTH-1-DIV_LOG2] ? {OUT_WIDTH{1'b1}} : dout_tmp;

endmodule
