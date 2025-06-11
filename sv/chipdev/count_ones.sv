module count_ones (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    din
);

  parameter int DATA_WIDTH = 16;
  input [DATA_WIDTH-1:0] din;
  output logic [$clog2(DATA_WIDTH):0] dout;

  always_comb begin
    dout = 0;
    for (int i = 0; i < DATA_WIDTH; i++) begin
      if (din[i] == 1'b1) dout = dout + 1;
    end
  end
endmodule
