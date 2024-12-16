module async_fifo (  /*AUTOARG*/);

  /*
  * NOTES:
  *   1. Async FIFO is a queue between 2 clock domains
  *   2. The enqueue and dequeue operations occur based on synchronized R/W pointers
  */

  parameter int FIFO_DEPTH = 8;
  parameter int DATA_WIDTH = 64;

  input clk_a, clk_b;
  input rst_a, rst_b;

  // A Side
  input [DATA_WIDTH-1] din;
  input wr_en;
  output full;

  // B Side
  output [DATA_WIDTH-1] dout;
  input rd_en;
  output empty;

  /*
  * binary -> grey
  * 000 -> 000
  * 001 -> 001
  * 010 -> 011
  * 011 -> 010
  * 100 -> 110
  * 101 -> 111
  * 110 -> 101
  * 111 -> 100
  */


  // Tricky part is remembering to synchronize the pointers

  logic [$clog2(FIFO_DEPTH)-1] wptr, rptr;

  // A Domain
  always_ff @(posedge clk_a or negedge rst_a) begin
    if (!rst) wptr <= 0;
    else begin
    end
  end


  // B Domain
  always_ff @(posedge clk_b or negedge rst_b) begin
    if (!rst) rptr <= 0;
    else begin
    end
  end


endmodule


module tb;
endmodule

// Local Variables:
// verilog-auto-wire-comment:nil
// verilog-auto-inst-param-value:t
// verilog-library-flags:("-f ../../vmode.f")
// End:
