module b2g (  /*AUTOARG*/
    // Outputs
    g_out,
    // Inputs
    b_in
);
  parameter int DATA_WIDTH = 4;

  input [DATA_WIDTH-1:0] b_in;
  output [DATA_WIDTH-1:0] g_out;

  // Keep MSB for both binary / grey
  // XOR i , i+1 of binary to get the grey code

  always_comb begin
    g_out[DATA_WIDTH-1] = b_in[DATA_WIDTH-1];
    for (int i = 0; i < DATA_WIDTH - 1; i++) begin
      g_out[i] = b_in[i] ^ b_in[i+1];
    end
  end

endmodule
