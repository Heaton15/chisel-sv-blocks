`timescale 1ns / 1ns
module round_robin_arbiter (  /*AUTOARG*/
    // Outputs
    gnt,
    // Inputs
    req
);
  parameter int SIZE = 4;

  input [SIZE-1:0] req;
  output [SIZE-1:0] gnt;


endmodule

