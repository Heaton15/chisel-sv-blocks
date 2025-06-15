module multi_bit_fifo (  /*AUTOARG*/
    // Outputs
    dout,
    full,
    empty,
    // Inputs
    clk,
    resetn,
    din,
    wr
);
  parameter int DATA_WIDTH = 8;

  input clk, resetn;
  input [DATA_WIDTH-1:0] din;
  input wr;
  output logic [DATA_WIDTH-1:0] dout;
  output logic full;
  output logic empty;

  logic [DATA_WIDTH-1:0] mem[2];
  logic ptr, mux_sel, mux_sel_r;

  typedef enum logic [1:0] {
    EMPTY,
    INTERMEDIATE,
    FULL
  } state_e;

  state_e state, next_state;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      dout <= 0;
      ptr <= 0;
      state <= EMPTY;
      mux_sel_r <= 0;
      foreach (mem[i]) begin
        mem[i] <= 0;
      end
    end else begin
      state <= next_state;
      mux_sel_r <= mux_sel;
      if (wr) begin
        mem[ptr] <= din;
        ptr <= ptr + 1'b1;
      end
    end
  end

  // Manages the full / empty flags
  always_comb begin
    next_state = state;
    mux_sel = mux_sel_r;
    empty = 0;
    full = 0;
    case (state)
      EMPTY: begin
        if (wr) next_state = INTERMEDIATE;
        empty = 1'b1;
      end
      INTERMEDIATE: begin
        if (wr) next_state = FULL;
      end
      FULL: begin
        if (wr) mux_sel = !mux_sel_r;
        full = 1'b1;
      end
      default: begin
        empty = 1;
        full = 0;
        mux_sel = 0;
      end
    endcase
  end

  assign dout = mux_sel_r ? mem[1] : mem[0];




endmodule
