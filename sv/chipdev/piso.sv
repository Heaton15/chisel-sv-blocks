module piso (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    clk,
    resetn,
    din,
    din_r,
    din_en
);

  parameter int DATA_WIDTH = 16;

  input clk, resetn;
  input [DATA_WIDTH-1:0] din, din_r;
  input din_en;
  output logic dout;

  logic [DATA_WIDTH-1:0] tmp;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      tmp <= 0;
    end else if (din_en) begin
      tmp <= din;
    end else begin
      tmp <= tmp >> 1;
    end
  end

  assign dout = tmp[0];

endmodule
