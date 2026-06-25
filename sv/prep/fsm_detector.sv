module fsm_detector #(
) (

    input  clk,
    rstn,
    input  single_bit,
    output is_detected
);

  typedef enum logic [2:0] {
    IDLE = 3'b000,
    ONE = 3'b001,
    ONE_ONE = 3'b010,
    ONE_ONE_ZERO = 3'b011,
    ONE_ONE_ZERO_ONE = 3'b100,
    ONE_ONE_ZERO_ONE_ONE = 3'b101
  } states;


  states state, next_state;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      state <= IDLE;  // We've seen nothing
    end else begin
      state <= next_state;
    end
  end


  // Run through the matching sequences

  assign is_detected = state == ONE_ONE_ZERO_ONE_ONE;

  // 5'b11011
  always_comb begin
    next_state = state;
    unique case (state)
      IDLE: begin
        if (single_bit == 1'b1) next_state = ONE;
      end
      ONE: begin
        if (single_bit == 1'b1) next_state = ONE_ONE;
        else next_state = IDLE;
      end
      ONE_ONE: begin
        if (single_bit == 1'b0) next_state = ONE_ONE_ZERO;
      end
      ONE_ONE_ZERO: begin
        if (single_bit == 1'b1) next_state = ONE_ONE_ZERO_ONE;
        else next_state = IDLE;
      end
      ONE_ONE_ZERO_ONE: begin
        if (single_bit == 1'b1) next_state = ONE_ONE_ZERO_ONE_ONE;
        else next_state = IDLE;
      end
      ONE_ONE_ZERO_ONE_ONE: begin
        if (single_bit == 1'b1) next_state = ONE_ONE;
        else next_state = ONE_ONE_ZERO;
      end
    endcase
  end



endmodule
