// You send 64 bits on the input. The output is broken up into 2 32-bit chunks.
// Size is indicative of how many bits need to be sent.
// So if size_in=40, size_out will be 32 for beat 1 and 8 for beat 2. 

`timescale 1ns / 1ps
module nvidia_handshake #(

) (

    // Upstream Channel
    input clk,
    input rstn,
    input [63:0] upstream_data,
    input upstream_valid,
    output logic upstream_ready,
    input [2:0] upstream_id_bits,
    input [5:0] upstream_size,

    // Downstream Channel
    output logic [31:0] downstream_data,
    output downstream_valid,
    input downstream_ready,
    output [2:0] downstream_id_bits,
    output logic [4:0] downstream_size
);

  // Size Information
  // upstream_size = 32 == 64'h00010000
  // upstream_size = 64 == 64'h00000000

  // TBD: Do we even need IDs for this?
  assign downstream_id_bits = upstream_id_bits;

  // This module must send 1-2 beats based on the size_in indicator
  // If size <32, send 1 beat
  // If size >=32, send 2 beats. Beat 2 must only be the remaining bits of data_in

  typedef enum logic {
    BEAT1 = 1'b0,
    BEAT2 = 1'b1
  } states;

  states state, next_state;

  always_ff @(posedge clk) begin
    if (!rstn) state <= BEAT1;
    else state <= next_state;
  end

  assign upstream_ready   = downstream_ready && state != BEAT2;
  assign downstream_valid = upstream_valid || state == BEAT2;

  wire upstream_fire = upstream_valid && upstream_ready;
  wire downstream_fire = downstream_valid && downstream_ready;

  // If we have a second beat, we need to register the bottom 32 bits for the 2nd transaction
  // since upstream_data is can now change post handshake!
  logic [31:0] upstream_data_reg;
  logic [5:0] upstream_size_reg;

  // 0 to 31 will indicate 32 bits
  wire has_second_beat = upstream_size > 'd31;

  always_comb begin
    next_state = state;
    unique case (state)
      BEAT1: begin
        if (upstream_fire && has_second_beat) begin
          next_state = BEAT2;
        end
      end
      BEAT2: begin
        if (downstream_fire) next_state = BEAT1;
      end
    endcase
  end

  // Upstream Logic
  always_ff @(posedge clk) begin
    if (!rstn) begin
      upstream_data_reg <= '0;
      upstream_size_reg <= '0;
    end else begin
      if (upstream_fire && state == BEAT1) begin
        upstream_data_reg <= upstream_data[63:32];
        upstream_size_reg <= upstream_size;
      end
    end
  end

  // Downstream logic
  always_ff @(posedge clk) begin
    if (!rstn) begin
      downstream_data <= '0;
    end else begin
      if (downstream_fire) begin
        unique case (state)
          BEAT1: begin
            downstream_data <= upstream_data[31:0];
            downstream_size <= has_second_beat ? 'd31 : upstream_size[4:0];
          end
          BEAT2: begin
            downstream_data <= upstream_data_reg;
            downstream_size <= upstream_size_reg - 'd32;
          end
        endcase
      end
    end
  end
endmodule

module tb;

  logic clk, rstn;

  logic [63:0] upstream_data;
  logic upstream_valid;
  logic upstream_ready;
  logic [2:0] upstream_id_bits;
  logic [5:0] upstream_size;
  logic [31:0] downstream_data;
  logic downstream_valid, downstream_ready;
  logic [2:0] downstream_id_bits;
  logic [4:0] downstream_size;

  wire upstream_fire = upstream_ready && upstream_valid;
  wire downstream_fire = downstream_ready && downstream_valid;

  initial begin
    $dumpfile("waves.fst");
    $dumpvars(0, "tb");
  end

  initial begin
    clk = 0;
    forever #1 clk = !clk;
  end

  function automatic logic [63:0] rand_data();
    return {$urandom(), $urandom()};
  endfunction

  task automatic reset();
    rstn = 0;
    upstream_data = 0;
    upstream_valid = 0;
    upstream_id_bits = 0;
    upstream_size = 0;
    downstream_ready = 0;
    repeat (20) @(posedge clk);
    rstn = 1;
    @(posedge clk);
  endtask

  // Send a transaction on the upstream interface
  task automatic upstream_send(input logic [63:0] data, input logic [5:0] size,
                               input logic [2:0] id = 0);
    @(posedge clk);
    upstream_data = #0.1ns data;
    upstream_size = #0.1ns size;
    upstream_id_bits = #0.1ns id;
    upstream_valid = #0.1ns 1'b1;

    @(posedge clk);
    while (!upstream_ready) @(posedge clk);

    upstream_valid = #0.1ns 1'b0;
    $display("[%0t] TX: data=%h size=%0d id=%0d", $time, data, size, id);
  endtask

  // Receive a transaction on the downstream interface
  task automatic downstream_receive(output logic [31:0] data, output logic [4:0] size,
                                    output logic [2:0] id);
    @(posedge clk);
    downstream_ready = #0.1ns 1'b1;

    @(posedge clk);
    while (!downstream_valid) @(posedge clk);

    data = downstream_data;
    size = downstream_size;
    id = downstream_id_bits;
    downstream_ready = #0.1ns 1'b0;
    $display("[%0t] RX: data=%h size=%0d id=%0d", $time, data, size, id);
  endtask

  // Continuously accept downstream transactions with random delays
  task automatic downstream_sink();
    logic [31:0] rx_data;
    logic [4:0] rx_size;
    logic [2:0] rx_id;
    int delay;

    forever begin
      delay = $urandom_range(0, 3);
      repeat (delay) @(posedge clk);
      downstream_receive(rx_data, rx_size, rx_id);
    end
  endtask

  int tx_count = 0;

  initial begin
    reset();

    fork
      downstream_sink();
    join_none

    // Test various transaction sizes
    upstream_send(64'hDEAD_BEEF_CAFE_BABE, 6'd63);  // Full 64 bits -> 2 beats (32 + 31)
    tx_count++;

    upstream_send(64'hAAAA_BBBB_CCCC_DDDD, 6'd32);  // 33 bits -> 2 beats (32 + 0)
    tx_count++;

    upstream_send(64'h0000_0000_1234_5678, 6'd31);  // 32 bits -> 1 beat
    tx_count++;

    upstream_send(64'h0000_0000_0000_ABCD, 6'd15);  // 16 bits -> 1 beat
    tx_count++;

    upstream_send(64'hFEED_FACE_DEAD_C0DE, 6'd50);  // 51 bits -> 2 beats (32 + 18)
    tx_count++;

    upstream_send(64'h0000_0000_0000_00FF, 6'd7);  // 8 bits -> 1 beat
    tx_count++;

    upstream_send(64'h1111_2222_3333_4444, 6'd40);  // 41 bits -> 2 beats (32 + 8)
    tx_count++;

    upstream_send(64'h0000_0000_FFFF_FFFF, 6'd31);  // 32 bits -> 1 beat
    tx_count++;

    upstream_send(64'h9999_8888_7777_6666, 6'd63);  // Full 64 bits -> 2 beats
    tx_count++;

    upstream_send(64'h0000_0000_0000_0001, 6'd0);  // 1 bit -> 1 beat
    tx_count++;

    repeat (50) @(posedge clk);
    $display("Test complete: %0d transactions sent", tx_count);
    $finish;
  end

  nvidia_handshake nvidia_handshake (
      .clk               (clk),
      .rstn              (rstn),
      .upstream_data     (upstream_data),
      .upstream_valid    (upstream_valid),
      .upstream_ready    (upstream_ready),
      .upstream_id_bits  (upstream_id_bits),
      .upstream_size     (upstream_size),
      .downstream_data   (downstream_data),
      .downstream_valid  (downstream_valid),
      .downstream_ready  (downstream_ready),
      .downstream_id_bits(downstream_id_bits),
      .downstream_size   (downstream_size)
  );
endmodule
