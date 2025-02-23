module simple_router (  /*AUTOARG*/
    // Outputs
    dout0,
    dout1,
    dout2,
    dout3,
    // Inputs
    din_en,
    addr,
    din
);

  parameter int DATA_SIZE = 32;


  input din_en;
  input [1:0] addr;
  input [DATA_SIZE-1:0] din;
  output [DATA_SIZE-1:0] dout0, dout1, dout2, dout3;

  assign dout0 = (din_en && addr[1:0] == 2'd0) ? din : 32'h0;
  assign dout1 = (din_en && addr[1:0] == 2'd1) ? din : 32'h0;
  assign dout2 = (din_en && addr[1:0] == 2'd2) ? din : 32'h0;
  assign dout3 = (din_en && addr[1:0] == 2'd3) ? din : 32'h0;

endmodule
