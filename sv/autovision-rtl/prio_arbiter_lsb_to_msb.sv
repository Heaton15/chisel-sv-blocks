/* The LSB has the highest priority*/
module prio_arbiter_lsb_to_msb #(
    parameter int SIZE = 4

) (  /*AUTOARG*/
    // Outputs
    output [SIZE-1:0] gnt,
    // Inputs
    input  [SIZE-1:0] req
);

`ifdef comb_arbiter
  logic [SIZE-1:0] higher_prio;

  // The trick here is that the moment a higher_prio bit gets set, all bits above it
  // will become set and will negate to 0 in the gnt assignment
  /* verilator lint_off ALWCOMBORDER */
  always_comb begin
    higher_prio[0] = 1'b0;
    for (int i = 1; i < SIZE; i++) begin
      higher_prio[i] = higher_prio[i-1] | req[i-1];
    end
  end
  /* verilator lint_on ALWCOMBORDER */

  assign gnt[SIZE-1:0] = req[SIZE-1:0] & ~higher_prio[SIZE-1:0];
`else

  assign gnt = req & (~req + 1'b1);
`endif
endmodule
