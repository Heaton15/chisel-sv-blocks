module synchronizer_toggle (  /*AUTOARG*/
    // Outputs
    out,
    // Inputs
    clk_a,
    clk_b,
    rst_a,
    rst_b,
    in
);

  parameter int DATA_WIDTH = 1;
  parameter int SYNC_DEPTH = 2;

  input clk_a, clk_b;
  input rst_a, rst_b;

  input in;
  output out;

  logic a_r;
  logic a_d ;
  logic b_r;
  logic a_r_sync;

  assign a_d = in ? ~a_r : a_r;
  assign out = a_r_sync ^ b_r;

  always_ff @(posedge clk_a or negedge rst_a) begin
    if (!rst_a) a_r <= 0;
    else begin
      a_r <= a_d;
    end
  end

  always_ff @(posedge clk_b or negedge rst_b) begin
    if (!rst_b) begin
      b_r <= 0;
    end else begin
      b_r <= a_r_sync;
    end
  end

  synchronizer_ff #(
      .DATA_WIDTH(DATA_WIDTH),
      .SYNC_DEPTH(SYNC_DEPTH)
  ) sync (
      // Outputs
      .out(a_r_sync),
      // Inputs
      .rst(rst_b),
      .clk(clk_b),
      .in (a_r)
  );

endmodule

// Local Variables:
// verilog-auto-wire-comment:nil
// verilog-auto-inst-param-value:t
// verilog-library-flags:("-f ../vmode.f")
// End:
