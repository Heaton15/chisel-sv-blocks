module toggle_sync #(

) (
    input clk_a,
    rstn_a,
    input signal_a,

    input  clk_b,
    rstn_b,
    output signal_b
);

  // On the clk a side, we are turning the pulse into a toggle bit that we sync across
  logic toggle_a, toggle_b;
  always_ff @(posedge clk_a) begin
    if (!rstn_a) begin
      toggle_a <= 0;
    end else begin
      if (signal_a) begin
        toggle_a <= ~toggle_a;
      end
    end
  end

  sync_2ff sync_2ff (
    .clk (clk_b),
    .rstn(rstn_b),
    .in  (toggle_a),
    .out (toggle_b)
  );

  // This signal can be turned into a pulse by checking the last state and current state

  logic last_toggle_b;
  always_ff @(posedge clk_b) begin
    if (!rstn_b) begin
      last_toggle_b <= 0;
    end else begin
      last_toggle_b <= toggle_b;
    end
  end

  assign signal_b = toggle_b ^ last_toggle_b;
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
