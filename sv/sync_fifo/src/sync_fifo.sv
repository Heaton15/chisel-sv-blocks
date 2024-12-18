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
  logic [$clog2(FIFO_DEPTH):0] wptr, rptr;

  // Fits 8, 64 bit words
  logic [DATA_WIDTH-1:0] queue[FIFO_DEPTH];
  logic can_write;
  logic can_read;




  // Empty when the pointers are equal
  assign empty = wptr == rptr;
  assign full = (wptr[$clog2(FIFO_DEPTH)] ^ rptr[$clog2(FIFO_DEPTH)]) & (wptr[2:0] == rptr[2:0]);

  assign can_write = wr_en & !full;
  assign can_read = rd_en & !empty;

  always_ff @(posedge clock or negedge rst) begin
    if (!rst) begin
      wptr <= 0;
    end else begin
      if (can_write) begin
        queue[wptr[2:0]] <= din;
        wptr <= wptr + 1'b1;
      end
    end
  end

  always_ff @(posedge clock or negedge rst) begin
    if (!rst) begin
      rptr <= 0;
    end else begin
      if (can_read) begin
        dout <= queue[rptr[2:0]];
        rptr <= rptr + 1'b1;
      end
    end
  end

endmodule

module tb;
  parameter int DATA_WIDTH = 64;

  logic clock;
  logic rst;

  initial begin
    clock = 0;
    #1;
    rst = 0;
    forever begin
      clock = #1 !clock;
    end
  end
  initial dump("sync_fifo.vcd");

  initial begin
    #3;
    rst = 1;
  end

  logic [DATA_WIDTH-1:0] dout;
  logic                  empty;
  logic                  full;
  logic [DATA_WIDTH-1:0] din;
  logic                  rd_en;
  logic                  wr_en;

  initial din = 64'hFFFF;

  initial begin
    wr_en = 0;
    rd_en = 0;

    repeat (5) @(posedge clock);
    wr_en = 1;
    repeat (20) @(posedge clock);
    $finish;
  end



  sync_fifo #(  /*AUTOINSTPARAMS*/) dut (  /*AUTOINST*/
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

// Local Variables:
// verilog-auto-wire-comment:nil
// verilog-auto-inst-param-value:t
// verilog-library-flags:("-f ../../vmode.f")
// End:
