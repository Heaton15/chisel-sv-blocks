module g2b (  /*AUTOARG*/
    // Outputs
    b_out,
    // Inputs
    g_in
);

  parameter int DATA_WIDTH = 4;

  input [DATA_WIDTH-1:0] g_in;
  output [DATA_WIDTH-1:0] b_out;

  logic [DATA_WIDTH-1:0] b_tmp;

  assign b_out = b_tmp;

  // Grey -> Binary
  // 1. Keep the MSB for the conversion
  // 2. grey code is then g[i] ^ b[i+1]

  always_comb begin
    b_tmp[DATA_WIDTH-1] = g_in[DATA_WIDTH-1];
    for (int i = DATA_WIDTH - 2; i > 0; i--) begin
      b_tmp[i] = g_in[i] ^ b_tmp[i+1];
    end

  end
endmodule
