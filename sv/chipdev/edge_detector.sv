module edge_detector (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    clk,
    resetn,
    din
);

  typedef enum logic {
    IDLE,
    PULSE
  } state_e;

  input clk, resetn, din;
  output dout;

  state_e state, next_state;

  always_ff @(posedge clk) begin
    if (~resetn) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    next_state = state;
    case (state)
      IDLE:  next_state = (din == 1'b1) ? PULSE : IDLE;
      PULSE: next_state = IDLE;
    endcase
  end

  assign dout = (state == PULSE);

endmodule
