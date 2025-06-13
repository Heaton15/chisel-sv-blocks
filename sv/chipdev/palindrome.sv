module palindrome (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    din
);
  parameter int DATA_WIDTH = 16;
  output dout;
  input [DATA_WIDTH-1:0] din, din_flipped;


  always_comb begin
    for (int i = 0; i < DATA_WIDTH; i++) begin
      din_flipped[i] = din[DATA_WIDTH-1-i];
    end
  end

  assign dout = din == din_flipped;

endmodule
