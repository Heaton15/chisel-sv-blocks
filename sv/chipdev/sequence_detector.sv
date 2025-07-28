module sequence_detector (  /*AUTOARG*/
    // Outputs
    dout,
    // Inputs
    clk,
    resetn,
    din
);
  input clk, resetn, din;
  output logic dout;

  typedef enum logic [2:0] {
    S0,
    S1,
    S10,
    S101,
    S1010
  } state_e;

  state_e state, next_state;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      state <= S0;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    next_state = state;
    case (state)
      S0: next_state = din == 1'b1 ? S1 : S0;
      S1: next_state = din == 1'b0 ? S10 : S1;
      S10: next_state = din == 1'b1 ? S101 : S0;
      S101: next_state = din == 1'b0 ? S1010 : S1;
      S1010: next_state = din == 1'b1 ? S101 : S0;
      default: next_state = state;
    endcase
  end

  assign dout = state == S1010;

endmodule
