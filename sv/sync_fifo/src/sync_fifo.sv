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

  parameter int FIFO_DEPTH = 8;
  parameter int DATA_WIDTH = 64;


  logic [DATA_WIDTH-1:0] dout;  // From dut of sync_fifo.v
  logic                  empty;  // From dut of sync_fifo.v
  logic                  full;  // From dut of sync_fifo.v
  logic                  clock;  // To dut of sync_fifo.v
  logic [DATA_WIDTH-1:0] din;  // To dut of sync_fifo.v
  logic                  rd_en;  // To dut of sync_fifo.v
  logic                  rst;  // To dut of sync_fifo.v
  logic                  wr_en;  // To dut of sync_fifo.v


  // Insert testbench here

  sync_fifo #(  /*AUTOINSTPARAM*/
      // Parameters
      .FIFO_DEPTH(FIFO_DEPTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (  /*AUTOINST*/
      // Outputs
      .dout (dout[DATA_WIDTH-1:0]),
      .full (full),
      .empty(empty),
      // Inputs
      .clock(clock),
      .rst  (rst),
      .din  (din[DATA_WIDTH-1:0]),
      .wr_en(wr_en),
      .rd_en(rd_en)
  );


endmodule
