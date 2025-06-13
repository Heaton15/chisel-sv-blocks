module ripple_carry_adder (  /*AUTOARG*/
    // Outputs
    sum,
    cout_int,
    // Inputs
    a,
    b
);
  parameter int DATA_WIDTH = 8;

  input [DATA_WIDTH-1:0] a;
  input [DATA_WIDTH-1:0] b;
  output logic [DATA_WIDTH-0:0] sum;
  output logic [DATA_WIDTH-1:0] cout_int;

  generate
    for (genvar i = 0; i < DATA_WIDTH; i++) begin : g_adder
      full_adder adder_inst (
          // Outputs
          .sum (sum[i]),
          .cout(cout_int[i]),
          // Inputs
          .a   (a[i]),
          .b   (b[i]),
          .cin (i == 0 ? 0 : cout_int[i-1])
      );
    end
  endgenerate

  assign sum[DATA_WIDTH] = cout_int[DATA_WIDTH-1];

endmodule

module full_adder (  /*AUTOARG*/
    // Outputs
    sum,
    cout,
    // Inputs
    a,
    b,
    cin
);

  input a, b, cin;
  output logic sum, cout;

  assign sum  = cin ^ a ^ b;
  assign cout = a & b || cin & b || cin & a;


endmodule

