// RTL for a) the index of the first set bit in 32-bit input. b) Number of 1’s in 32-bit input signal. 
module calc_index #(

    parameter int unsigned DATA_WIDTH = 32

) (
    input [DATA_WIDTH-1:0] data_in,
    output logic [$clog2(DATA_WIDTH)-1:0] index,
    output [$clog2(DATA_WIDTH)-1:0] num_ones
);

  // Return the index of the first set bit in 32-bit input
  // 4'b0110 (index 1)

  // index of first set bit
  always_comb begin
    index = 0;
    for (int unsigned i = DATA_WIDTH - 1; i >= 0; i--) begin
      if (data_in[i]) 
        index = i;
    end
  end

  // number of 1s in 32-bit input signal
  logic [$clog2(DATA_WIDTH)-1:0] num_ones_i;
  assign num_ones = num_ones_i;
  always_comb begin
    num_ones_i = 0;
    for (int i = 0; i < $clog2(DATA_WIDTH); i++) begin
      num_ones_i = num_ones_i + $clog2(DATA_WIDTH)'(data_in[i]);
    end
  end


endmodule
