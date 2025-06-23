`timescale 1ns / 1ns
module prio_arbiter_msb_to_lsb (  /*AUTOARG*/
    // Outputs
    gnt,
    // Inputs
    req
);
  parameter int SIZE = 4;

  input [SIZE-1:0] req;
  output [SIZE-1:0] gnt;


  assign gnt[SIZE-1] = req[SIZE-1];
  for (genvar i = SIZE - 2; i >= 0; i--) begin : g_msb_to_lsb_arbiter
    assign gnt[i] = ~|gnt[SIZE-1:i+1] & req[i];
  end
endmodule


module tb;

  localparam int SIZE = 4;

  /*AUTOREGINPUT*/
  // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
  logic [SIZE-1:0] req;  // To dut of prio_arbiter_msb_to_lsb.v
  // End of automatics
  /*AUTOLOGIC*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [SIZE-1:0] gnt;  // From dut of prio_arbiter_msb_to_lsb.v
  // End of automatics

  logic clk;
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
    stimulus(3, 4'b1000);
    stimulus(3, 4'b1000);
    stimulus(3, 4'b1000);
    stimulus(3, 4'b1000);
    $finish;
  end

  task automatic stimulus(input int index, input logic [SIZE-1:0] expected);
    req = generate_req(index);
    @(posedge clk);
    $display("req: %b, expected(%b) == gnt(%b)", req[SIZE-1:0], expected[SIZE-1:0], gnt[SIZE-1:0]);
  endtask


  function automatic logic [SIZE-1:0] generate_req(input int index);
    logic [63:0] rnd;
    rnd = {$urandom, $urandom};
    return rnd[SIZE-1:0] | (1 << index);
  endfunction

endmodule



