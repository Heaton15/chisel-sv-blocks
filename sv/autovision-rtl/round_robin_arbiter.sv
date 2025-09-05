`timescale 1ns / 1ns

// Conventional Round Robin Arbiter
module round_robin_arbiter #(

    parameter int SIZE = 4
) (

    // Outputs
    output [SIZE-1:0] gnt,

    // Inputs
    input [SIZE-1:0] req,
    input clk,
    input rst
);

  logic [$clog2(SIZE)-1:0] prio_ptr;


  always_ff @(posedge clk) begin
    if (rst) begin
      prio_ptr <= 0;
    end else begin
      prio_ptr <= prio_ptr + 1'b1;
    end
  end

  logic [1:0][SIZE-1:0] req_tmp;
  logic [SIZE-1:0] gnt_tmp;

  // Rotate 1
  assign {req_tmp[1], req_tmp[0]} = {2{req}} >> prio_ptr;

  // Priority Arbiter
  wire [SIZE-1:0] tmp = req_tmp[0] & (~req_tmp[0] + 1'b1);

  assign {gnt, gnt_tmp} = {2{tmp}} << prio_ptr;








endmodule

