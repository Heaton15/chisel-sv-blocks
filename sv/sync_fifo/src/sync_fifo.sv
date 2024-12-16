module sync_fifo (  /*AUTOARG*/
    // Outputs
    dout,
    full,
    empty,
    // Inputs
    clock,
    rst,
    din,
    wr_en,
    rd_en
);
  /*
  * 1. One clock domain for both sides
  * 2. Queues on one side, dequeues on the other side.
  * 3. R/W pointers target the location of R or of W in the FIFO queue
  *
  * Problems:
  * 1. If the QUEUE is full, there will be input data loss
  *
  * By default, a standard SYNC FIFO will not have handshaking. It just fills and empties
  */

  // Parameters
  parameter int FIFO_DEPTH = 8;  // How many entries can be stored in the queue at a time
  parameter int DATA_WIDTH = 64;  // How big are the entries in the queue

  // I/O
  input logic clock, rst;

  input logic [DATA_WIDTH-1:0] din;
  output logic [DATA_WIDTH-1:0] dout;

  input wr_en, rd_en;
  output full, empty;

  // Points to the address in the queue
  logic [$clog2(FIFO_DEPTH)-1:0] wptr, rptr;

  // Fits 8, 64 bit words
  logic [DATA_WIDTH-1:0] queue[FIFO_DEPTH];

  logic can_write = wr_en & !full;
  logic can_read = rd_en & !empty;


  // Empty when the pointers are equal
  assign empty = wptr == rptr;
  assign full  = (wptr + 1) == rptr;  // Should wrap back around to rptr value

  always_ff @(posedge clock or negedge rst) begin
    if (!rst) begin
      wptr <= 0;
    end else begin
      if (can_write) begin
        queue[wptr] <= din;
        wptr <= wptr + 1;
      end
    end
  end

  always_ff @(posedge clock or negedge rst) begin
    if (!rst) begin
      rptr <= 0;
    end else begin
      if (can_read) begin
        dout <= queue[rptr];
        rptr <= rptr + 1;
      end
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
