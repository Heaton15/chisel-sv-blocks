module trailing_zeros (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    din
);
  parameter int DATA_WIDTH = 32;
  input [DATA_WIDTH-1:0] din;
  output logic [$clog2(DATA_WIDTH):0] dout;


  logic [$clog2(DATA_WIDTH):0] idx;
  logic [DATA_WIDTH-1:0] set_cnt_bit;

  assign set_cnt_bit = din & (~ din + 1); // The only bit set is the value for the number of 0s in the register
  always_comb begin
    idx = 0;
    for (int i = 0; i < DATA_WIDTH; i++) begin
      idx += set_cnt_bit[i] ? i : 0;
    end
  end

  assign dout = {DATA_WIDTH{1'b0}} == din ? DATA_WIDTH : idx;


endmodule
