
// Move a data bus between clock domains
// The enqueue side is a ready valid interface
// The dequeue side is a valid only interface
module handshake_sync #(

    parameter int unsigned DATA_WIDTH = 32

) (

    // Clk A
    input clk_a,
    rstn_a,
    input [DATA_WIDTH-1:0] upstream_data,
    input upstream_valid,
    output upstream_ready,

    // Clk B
    input clk_b,
    rstn_b,
    output logic [DATA_WIDTH-1:0] downstream_data,
    output downstream_valid
);


  // valid / ready @ enqueue side
  // valid only @ dequeue side (can miss the dequeue if we don't read from the synchronizer when valid is asserted)
  //  - This is because req / ack signals toggle to create state. req can de-assert after ack assertion which will drop dequeue valid


  logic req_a, req_b;
  logic ack_a, ack_b;


  // Enqueue 
  wire upstream_fire = upstream_valid && upstream_ready;
  assign upstream_ready = req_a == ack_a;

  wire downstream_fire = downstream_valid;
  assign downstream_valid = req_b != ack_b;

  // de-asserts upstream_ready when we handshake data in. Now we wait for ack;
  logic [DATA_WIDTH-1:0] upstream_data_reg;
  always_ff @(posedge clk_a) begin
    if (!rstn_a) begin
      req_a <= 0;
      upstream_data_reg <= 0;
    end else begin
      if (upstream_fire) begin
        req_a <= !req_a;
        upstream_data_reg <= upstream_data;
      end
    end
  end


  //output [DATA_WIDTH-1:0] downstream_data,
  //output downstream_valid
  // Dequeue
  always_ff @(posedge clk_b) begin
    if (!rstn_b) begin
      ack_b <= 0;
      downstream_data <= 0;
    end else begin
      if (downstream_valid) begin
        ack_b <= !ack_b;
        downstream_data <= upstream_data_reg;
      end
    end
  end

  sync_2ff sync_2ff_a_sync (
    .clk (clk_a),
    .rstn(rstn_a),
    .in  (ack_b),
    .out (ack_a)
  );

  sync_2ff sync_2ff_b_sync (
    .clk (clk_b),
    .rstn(rstn_b),
    .in  (req_a),
    .out (req_b)
  );

endmodule

module sync_2ff #(
) (
    input  clk,
    rstn,
    input  in,
    output out
);

  logic reg1, reg2;
  always_ff @(posedge clk) begin
    if (!rstn) begin
      reg1 <= 0;
      reg2 <= 0;
    end else begin
      reg1 <= in;
      reg2 <= reg1;
    end
  end
  assign out = reg2;
endmodule
