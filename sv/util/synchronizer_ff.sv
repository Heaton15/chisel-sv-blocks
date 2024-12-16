module synchronizer_ff (  /*AUTOARG*/
    // Outputs
    out,
    // Inputs
    in,
    rst,
    clk
);

  /*
  * NOTES:
  *   1. Can only be used to synchronize a single bit
  *   2. Clock A (source domain) must be slower than Clock B (destination domain)
  *     2.a If fs_B < fs_A, there will be data loss.
  */

  parameter int DATA_WIDTH = 4;
  parameter int SYNC_DEPTH = 2;

  input rst, clk;

  input [DATA_WIDTH-1:0] in;
  output [DATA_WIDTH-1:0] out;

  logic [DATA_WIDTH-1:0] sync[SYNC_DEPTH];

  assign out = sync[SYNC_DEPTH-1];

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      for (int i = 0; i < SYNC_DEPTH; i++) sync[i] <= 0;
    end else begin
      sync[0] <= in;
      for (int i = 1; i < SYNC_DEPTH; i++) begin
        sync[i] <= sync[i-1];
      end
    end
  end

endmodule
