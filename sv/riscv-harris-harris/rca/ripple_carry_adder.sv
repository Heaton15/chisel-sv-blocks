module ripple_carry_adder #(
    parameter int N = 4
) (

    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] z,
    output cout
);

  // RCA is built off of full_adder instances

  logic [N-1:0] cout_int;
  assign cout = cout_int[N-1];

  for (genvar i = 0; i < N; i++) begin : g_full_adders
    full_adder #() fa_inst (
        // Outputs
        .z   (z[i]),
        .cout(cout_int[i]),
        // Inputs
        .a   (a[i]),
        .b   (b[i]),
        .cin (i == 0 ? 0 : cout_int[i-1])
    );
  end

endmodule
