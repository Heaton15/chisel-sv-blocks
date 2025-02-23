module second_largest (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    clk,
    resetn,
    din
);
  input clk, resetn;
  parameter int DATA_SIZE = 32;

  input [DATA_SIZE-1:0] din;
  output [DATA_SIZE-1:0] dout;


  logic [DATA_SIZE-1:0] largest_value;
  logic [DATA_SIZE-1:0] second_largest_value;

  // largest_value becomes second_largest_value when largest_value is replaced
  always_ff @(posedge clk or negedge resetn) begin
    if (~resetn) begin
      largest_value <= 0;
      second_largest_value <= 0;
    end else if (din > largest_value) begin
      largest_value <= din;
      second_largest_value <= largest_value;
    end else if (din > second_largest_value) begin
      second_largest_value <= din;
    end
  end

  assign dout = second_largest_value;
endmodule
