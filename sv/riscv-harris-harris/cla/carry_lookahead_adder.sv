// Uses the G (generate) / P (propagate) logic for blocks
// N-bit adders are partitined into k-bit blocks

// tD = tpg + tpg_block + ((N/k) - 1))t_and_or + k*tFA

// Generate  (G): If a current stage generates it's own carry from A*B
// Propagate (P): If the Cin(A+B) computation passes a carry through

// G = A*B
// P = A + B
// Cout = G + P*Ci-1

// In a k block implementation, the G, P, Cout logic expands to the block level with G because the implementation of all
// stages
// For N=32, k=4 (8, 4-bit blocks)
// G_3:0 = G3 + P3(G2 + P2 (G1 + P1G0))

// Notice how G3 = A3*B3 and that the remaining logic is just the recursive Cout = G + P*Ci-1 solution

module carry_lookahead_adder #(
    parameter int N = 32,
    parameter int BLOCK_SIZE = 4
) (
    output cout,
    output [N-1:0] s,
    input [N-1:0] a,
    b
);

  localparam int NUM_CLA = N / BLOCK_SIZE;

  logic [NUM_CLA-1:0] cout_int;
  assign cout = cout_int[NUM_CLA-1];

  for (genvar i = 0; i < NUM_CLA; i++) begin : g_cla_block
    cla_block #(
        .BLOCK_SIZE(BLOCK_SIZE)
    ) cla_block (
        .a   (a[i*BLOCK_SIZE +: BLOCK_SIZE]),
        .b   (b[i*BLOCK_SIZE +: BLOCK_SIZE]),
        .cin (i == 0 ? 0 : cout_int[i-1]),
        .cout(cout_int[i]),
        .s   (s[i*BLOCK_SIZE+: BLOCK_SIZE])
    );
  end


endmodule

module cla_block #(
    parameter int BLOCK_SIZE = 4
) (

    input [BLOCK_SIZE-1:0] a,
    input [BLOCK_SIZE-1:0] b,
    input cin,

    output cout,
    output [BLOCK_SIZE-1:0] s
);

  logic [BLOCK_SIZE-1:0] cout_int;

  // This is full_adder implementation of a 4 bit RCA
  for (genvar i = 0; i < BLOCK_SIZE; i++) begin : g_rca
    full_adder #() u_fa (
        .a   (a[i]),
        .b   (b[i]),
        .cin (i == 0 ? cin : cout_int[i-1]),
        .z   (s[i]),
        .cout(cout_int[i])
    );
  end


  //This logic implementats the carry lookahead portion
  logic [BLOCK_SIZE-1:0] P, G;
  logic P_block, G_block;

  always_comb begin
    for (int i = 0; i < BLOCK_SIZE; i++) begin
      P[i] = a[i] || b[i];
      G[i] = a[i] && b[i];
    end
  end

  assign P_block = &P;
  assign G_block = pg_compute(P, G);
  assign cout = G_block || (cin && P_block);

  function automatic logic pg_compute(logic [BLOCK_SIZE-1:0] P, logic [BLOCK_SIZE-1:0] G);
    logic result;
    result = G[0];
    for (int i = 1; i < BLOCK_SIZE; i++) begin
      result = G[i] || (P[i] && result);
    end
    return result;
  endfunction
endmodule
