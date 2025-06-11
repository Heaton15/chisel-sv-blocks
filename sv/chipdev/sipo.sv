module sipo (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    clk,
    resetn,
    din
);

  parameter int DATA_WIDTH = 16;

  input clk, resetn;
  input din;
  output logic [DATA_WIDTH-1:0] dout;

  always_ff @(posedge clk) begin
    if (~resetn) begin
      dout <= 0;
    end else begin
      dout <= {dout[DATA_WIDTH-2:0], din};
    end
  end

endmodule
