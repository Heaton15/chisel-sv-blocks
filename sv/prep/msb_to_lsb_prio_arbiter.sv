module msb_to_lsb_prio_arbiter #(

    parameter int unsigned SIZE = 4

) (

    input [SIZE-1:0] req,
    output logic [SIZE-1:0] gnt
);


  assign gnt[SIZE-1] = req[SIZE-1];

  for (genvar i = SIZE - 2; i >= 0; i--) begin : g_msb_to_lsb_arbiter
    always_comb begin
      gnt[i] = ~|req[SIZE-1:i+1] && req[i];
    end
  end
endmodule

module tb;

  parameter int SIZE = 4;
  logic [SIZE-1:0] req;  // To dut of prio_arbiter_msb_to_lsb.v
  logic [SIZE-1:0] gnt;  // From dut of prio_arbiter_msb_to_lsb.v

  logic            clk;
  initial begin
    clk = 0;
    forever begin
      clk = #1ns !clk;
    end
  end

  msb_to_lsb_prio_arbiter #(
    .SIZE(SIZE /* default 4 */)
   ) dut(
    .req(req),
    .gnt(gnt)
  );


  int rnd;
  initial begin
    repeat (100) begin
      rnd = $urandom_range(0, 3);
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



