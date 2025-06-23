/* The LSB has the highest priority*/
module prio_arbiter_lsb_to_msb (  /*AUTOARG*/
    // Outputs
    gnt,
    // Inputs
    req
);

  parameter int SIZE = 4;

  input [SIZE-1:0] req;
  output [SIZE-1:0] gnt;



  logic [SIZE-1:0] higher_prio;

  // The trick here is that the moment a bit a higher_prio bit gets set, all bits above it
  // will become set and will negate to 0 in the gnt assignment
  always_comb begin
    higher_prio[0] = 1'b0;
    for (int i = 1; i < SIZE; i++) begin
      higher_prio[i] = higher_prio[i-1] | req[i-1];
    end
  end

  assign gnt[SIZE-1:0] = req[SIZE-1:0] & ~higher_prio[SIZE-1:0];



endmodule
