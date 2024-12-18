module async_fifo (  /*AUTOARG*/
    // Outputs
    o_empty,
    o_full,
    dout,
    // Inputs
    clk_a,
    clk_b,
    rst_a,
    rst_b,
    din,
    wr_en,
    rd_en
);

  /*
  * NOTES:
  *   1. Async FIFO is a queue between 2 clock domains
  *   2. Design the async memory with RW ports
  *   3. write pointer handler
  *   4. read point handler
  *   5. binary to grey / grey to binary modules
  */

  parameter int FIFO_DEPTH = 8;
  parameter int DATA_WIDTH = 4;
  parameter int SYNC_DEPTH = 2;

  input clk_a, clk_b;
  input rst_a, rst_b;
  output o_empty, o_full;

  // A Side
  input [DATA_WIDTH-1:0] din;
  input wr_en;

  // B Side
  output [DATA_WIDTH-1:0] dout;
  input rd_en;

  logic empty, full;
  assign o_empty = empty;
  assign o_full  = full;

  /*AUTOLOGIC*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [  $clog2(FIFO_DEPTH)-1:0] b_rptr;
  logic [  $clog2(FIFO_DEPTH)-1:0] b_wptr;
  logic [  $clog2(FIFO_DEPTH)-1:0] g_rptr;
  logic [($clog2(FIFO_DEPTH))-1:0] g_rptr_sync;
  logic [  $clog2(FIFO_DEPTH)-1:0] g_wptr;
  logic [($clog2(FIFO_DEPTH))-1:0] g_wptr_sync;
  // End of automatics
  /*AUTOREGINPUT*/

  /* fifo_mem AUTO_TEMPLATE(
    .wptr(b_wptr[]),
    .rptr(b_rptr[]),
    );
  */

  fifo_mem #(  /*AUTOINSTPARAM*/
      // Parameters
      .FIFO_DEPTH(FIFO_DEPTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) mem (  /*AUTOINST*/
      // Outputs
      .dout (dout[DATA_WIDTH-1:0]),
      // Inputs
      .clk_a(clk_a),
      .clk_b(clk_b),
      .din  (din[DATA_WIDTH-1:0]),
      .wptr (b_wptr[$clog2(FIFO_DEPTH)-1:0]),  // Templated
      .rptr (b_rptr[$clog2(FIFO_DEPTH)-1:0]),  // Templated
      .full (full),
      .empty(empty),
      .wr_en(wr_en),
      .rd_en(rd_en)
  );

  /* write_handler AUTO_TEMPLATE(
    .g_rptr(g_rptr_sync[]),
    );
  */

  write_handler #(  /*AUTOINSTPARAM*/
      // Parameters
      .FIFO_DEPTH(FIFO_DEPTH)
  ) write_ctrl (  /*AUTOINST*/
      // Outputs
      .full  (full),
      .g_wptr(g_wptr[$clog2(FIFO_DEPTH)-1:0]),
      .b_wptr(b_wptr[$clog2(FIFO_DEPTH)-1:0]),
      // Inputs
      .clk_a (clk_a),
      .rst_a (rst_a),
      .wr_en (wr_en),
      .g_rptr(g_rptr_sync[$clog2(FIFO_DEPTH)-1:0])
  );  // Templated

  /* read_handler AUTO_TEMPLATE(
    .g_wptr(g_wptr_sync[]),
    );
  */
  read_handler #(  /*AUTOINSTPARAM*/
      // Parameters
      .FIFO_DEPTH(FIFO_DEPTH)
  ) read_ctrl (  /*AUTOINST*/
      // Outputs
      .g_rptr(g_rptr[$clog2(FIFO_DEPTH)-1:0]),
      .b_rptr(b_rptr[$clog2(FIFO_DEPTH)-1:0]),
      // Inputs
      .clk_b (clk_b),
      .rst_b (rst_b),
      .rd_en (rd_en),
      .g_wptr(g_wptr_sync[$clog2(FIFO_DEPTH)-1:0])
  );  // Templated

  /* synchronizer_ff AUTO_TEMPLATE(
    .DATA_WIDTH ($clog2(FIFO_DEPTH)),
    .out (g_rptr_sync[]),
    .in (g_rptr[]),
    .clk (clk_a),
    );
  */
  synchronizer_ff #(  /*AUTOINSTPARAM*/
      // Parameters
      .DATA_WIDTH($clog2(FIFO_DEPTH)),  // Templated
      .SYNC_DEPTH(SYNC_DEPTH)
  ) write_sync (  /*AUTOINST*/
      // Outputs
      .out(g_rptr_sync[($clog2(FIFO_DEPTH))-1:0]),  // Templated
      // Inputs
      .clk(clk_a),                                  // Templated
      .in (g_rptr[($clog2(FIFO_DEPTH))-1:0])
  );  // Templated

  /* synchronizer_ff AUTO_TEMPLATE(
    .DATA_WIDTH ($clog2(FIFO_DEPTH)),
    .out(g_wptr_sync[]),
    .in(g_wptr[]),
    .clk (clk_b),
    );
  */
  synchronizer_ff #(  /*AUTOINSTPARAM*/
      // Parameters
      .DATA_WIDTH($clog2(FIFO_DEPTH)),  // Templated
      .SYNC_DEPTH(SYNC_DEPTH)
  ) read_sync (  /*AUTOINST*/
      // Outputs
      .out(g_wptr_sync[($clog2(FIFO_DEPTH))-1:0]),  // Templated
      // Inputs
      .clk(clk_b),                                  // Templated
      .in (g_wptr[($clog2(FIFO_DEPTH))-1:0])
  );  // Templated


endmodule

module write_handler (  /*AUTOARG*/
    // Outputs
    full,
    g_wptr,
    b_wptr,
    // Inputs
    clk_a,
    rst_a,
    wr_en,
    g_rptr
);

  parameter int FIFO_DEPTH = 4;

  output full;

  input clk_a, rst_a, wr_en;
  input [$clog2(FIFO_DEPTH)-1:0] g_rptr;

  output [$clog2(FIFO_DEPTH)-1:0] g_wptr, b_wptr;
  logic [$clog2(FIFO_DEPTH)-1:0] b_rptr;  // read on the a domain

  // Add the b_wptr logic

  always_ff @(posedge clk_a or negedge rst_a) begin
    if (!rst_a) b_wptr <= 0;
    else begin
      if (!full & wr_en) b_wptr <= b_wptr + 1'b1;
    end
  end

  assign full = (b_wptr + 1) == b_rptr;

  b2g #(
      .DATA_WIDTH(FIFO_DEPTH)
  ) b2g_wptr (
      // Outputs
      .g_out(g_wptr[$clog2(FIFO_DEPTH)-1:0]),
      // Inputs
      .b_in (b_wptr[$clog2(FIFO_DEPTH)-1:0])
  );

  g2b #(
      .DATA_WIDTH(FIFO_DEPTH)
  ) g2b_rptr (
      // Outputs
      .b_out(b_rptr[$clog2(FIFO_DEPTH)-1:0]),
      // Inputs
      .g_in (g_rptr[$clog2(FIFO_DEPTH)-1:0])
  );



endmodule

module read_handler (  /*AUTOARG*/
    // Outputs
    g_rptr,
    b_rptr,
    // Inputs
    clk_b,
    rst_b,
    rd_en,
    g_wptr
);

  parameter int FIFO_DEPTH = 4;

  input clk_b, rst_b, rd_en;

  input [$clog2(FIFO_DEPTH)-1:0] g_wptr;
  output [$clog2(FIFO_DEPTH)-1:0] g_rptr, b_rptr;

  logic [$clog2(FIFO_DEPTH)-1:0] b_wptr;

  logic empty;
  assign empty = b_wptr == b_rptr;

  always_ff @(posedge clk_b or negedge rst_b) begin
    if (!rst_b) b_rptr <= 0;
    else begin
      if (!empty & rd_en) b_rptr <= b_rptr + 1'b1;
    end
  end

  b2g #(
      .DATA_WIDTH(FIFO_DEPTH)
  ) b2g_rptr (
      // Outputs
      .g_out(g_rptr[$clog2(FIFO_DEPTH)-1:0]),
      // Inputs
      .b_in (b_rptr[$clog2(FIFO_DEPTH)-1:0])
  );

  g2b #(
      .DATA_WIDTH(FIFO_DEPTH)
  ) g2b_wptr (
      // Outputs
      .b_out(b_wptr[$clog2(FIFO_DEPTH)-1:0]),
      // Inputs
      .g_in (g_wptr[$clog2(FIFO_DEPTH)-1:0])
  );



endmodule

module fifo_mem (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    clk_a,
    clk_b,
    din,
    wptr,
    rptr,
    full,
    empty,
    wr_en,
    rd_en
);

  parameter int FIFO_DEPTH = 8;
  parameter int DATA_WIDTH = 64;

  input clk_a, clk_b;
  input [DATA_WIDTH-1:0] din;
  output [DATA_WIDTH-1:0] dout;

  input [$clog2(FIFO_DEPTH)-1:0] wptr, rptr;

  input full, empty;
  input wr_en, rd_en;

  // foundry memory
  logic [DATA_WIDTH-1:0] mem[FIFO_DEPTH];

  // Domain A
  always_ff @(posedge clk_a) begin
    if (!full & wr_en) mem[wptr] <= din;
  end

  // Domain B
  always_ff @(posedge clk_b) begin
    if (!empty & rd_en) dout <= mem[rptr];
  end
endmodule

module tb;
endmodule

// Local Variables:
// verilog-auto-wire-comment:nil
// verilog-auto-inst-param-value:t
// verilog-library-flags:("-f ../../vmode.f")
// End:
