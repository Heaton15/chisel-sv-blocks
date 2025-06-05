module reversing_bits #(
    parameter int DATA_WIDTH = 32
) (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    din
);


  input [DATA_WIDTH-1:0] din;
  output [DATA_WIDTH-1:0] dout;

  // Flip the bits in din and put them out dout

  always_comb begin
    for (int i = 0; i < DATA_WIDTH; i++) begin
      dout[i] = din[DATA_WIDTH-1-i];
    end
  end

endmodule
