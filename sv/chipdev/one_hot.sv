module one_hot (  /*AUTOARG*/
    // Outputs
    onehot,
    // Inputs
    din
);
  parameter int DATA_WIDTH = 32;
  input [DATA_WIDTH-1:0] din;
  output logic onehot;

  logic [$clog2(DATA_WIDTH)-1:0] cnt;
  always_comb begin
    cnt = 0;
    for (int i = 0; i < DATA_WIDTH; i++) begin
      cnt += din[i];
    end
  end

  assign onehot = cnt == 1;
endmodule
