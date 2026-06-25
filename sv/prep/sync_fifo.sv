module sync_fifo #(
    parameter int SIZE  = 4,
    parameter int DEPTH = 16
) (


    input clk,
    input rstn,


    input [SIZE-1:0] upstream_data,
    input upstream_valid,
    output upstream_ready,

    output logic [SIZE-1:0] downstream_data,
    output downstream_valid,
    input downstream_ready

);

  localparam PTR_SIZE = $clog2(DEPTH);

  // Behavioral memory queue
  logic [SIZE-1:0] mem[DEPTH];

  // Track where we are in the memory
  logic [PTR_SIZE:0] wptr;
  logic [PTR_SIZE:0] rptr;

  wire full = (wptr[PTR_SIZE] ^ rptr[PTR_SIZE]) && (wptr[PTR_SIZE-1:0] == rptr[PTR_SIZE-1:0]);
  wire empty = wptr == rptr;

  assign upstream_ready   = !full;
  assign downstream_valid = !empty;

  wire upstream_fire = upstream_ready && upstream_valid;
  wire downstream_fire = downstream_ready && downstream_valid;

  // Upstream Channel
  always_ff @(posedge clk) begin
    if (~rstn) begin
      wptr <= '0;
      for (int i = 0; i < DEPTH; i++) begin
        mem[i] <= '0;
      end
    end else begin
      if (upstream_fire) begin
        mem[wptr] <= upstream_data;
        wptr <= wptr + 1'b1;
      end
    end
  end

  // Downstream Channel
  always_ff @(posedge clk) begin
    if (!rstn) begin
      rptr <= '0;
    end else begin
      if (downstream_fire) begin
        downstream_data <= mem[rptr];
        rptr <= rptr + 1'b1;
      end
    end
  end

endmodule
