`timescale 1ns / 1ns

/*
* A nifty MSB to LSB trick is the following:
  1. Inverse req
  2. Reverse Req
  3. Add 1'b1
  4. Reverse again for result
  5. gnt = req & result
*/
module prio_arbiter_msb_to_lsb #(

    parameter int SIZE = 4
) (  /*AUTOARG*/
    // Outputs
    output logic [SIZE-1:0] gnt,
    // Inputs
    input [SIZE-1:0] req
);


`ifdef comb_arbiter

  for (genvar i = SIZE - 2; i >= 0; i--) begin : g_msb_to_lsb
    always_comb begin
      gnt[SIZE-1] = req[SIZE-1];
      gnt[i] = ~|gnt[SIZE-1:i+1] & req[i];
    end
  end

`else


  wire  [SIZE-1:0] inverse = ~req;
  logic [SIZE-1:0] reverse;

  always_comb begin
    reverse = 0;
    for (int i = 0; i < SIZE; i++) begin
      reverse[i] = inverse[SIZE-1-i];
    end
  end

  wire  [SIZE-1:0] add = reverse + 1'b1;

  logic [SIZE-1:0] reverse2;

  always_comb begin
    reverse2 = 0;
    for (int i = 0; i < SIZE; i++) begin
      reverse2[i] = add[SIZE-1-i];
    end
  end

  assign gnt = req & reverse2;
`endif



endmodule


module tb;

  parameter int SIZE = 4;

  /* verilator lint_off UNOPTFLAT */

  /*AUTOREGINPUT*/
  // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
  logic [SIZE-1:0] req;  // To dut of prio_arbiter_msb_to_lsb.v
  // End of automatics
  /*AUTOLOGIC*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [SIZE-1:0] gnt;  // From dut of prio_arbiter_msb_to_lsb.v
  // End of automatics

  /* verilator lint_on UNOPTFLAT */

  logic            clk;
  initial begin
    clk = 0;
    forever begin
      clk = #1ns !clk;
    end
  end

  prio_arbiter_msb_to_lsb #(  /*AUTOINSTPARAM*/
      // Parameters
      .SIZE(SIZE)
  ) dut (  /*AUTOINST*/
      // Outputs
      .gnt(gnt[SIZE-1:0]),
      // Inputs
      .req(req[SIZE-1:0])
  );

  initial begin
    repeat (100) begin
      int rnd = $urandom_range(0, 3);
      stimulus(rnd, 4'b0000 | 1 << rnd);
    end
    $display("*** PASSED ***");
    $finish;
  end

  task automatic stimulus(input int index, input logic [SIZE-1:0] expected);
    req = generate_req(index);
    @(posedge clk);
    if (expected[SIZE-1:0] != gnt[SIZE-1:0]) begin
      $display("*** FAILED *** expected(%b) != gnt(%b)", expected, gnt);
      $fatal();
    end

    $display("req: %b, expected(%b) == gnt(%b)", req[SIZE-1:0], expected[SIZE-1:0], gnt);
  endtask


  function automatic logic [SIZE-1:0] generate_req(input int index);
    logic [63:0] rnd;
    rnd = {$urandom, $urandom};
    return (rnd[SIZE-1:0] >> SIZE - 1 - index) | 1 << index;
  endfunction

endmodule



