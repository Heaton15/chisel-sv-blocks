module prefix_adder #(
    parameter int DATA_SIZE = 16
) (

    input [DATA_SIZE-1:0] a,
    b,

    output logic [DATA_SIZE-1:0] s,
    output cout

);


  localparam K_TREE_DEPTH = $clog2(DATA_SIZE);


  // DATA_SIZE+1 entries to account for the -1 index
  logic [DATA_SIZE:0] P, G;

  // Stage 1: Pre-compute the P / G values for the adder
  assign P = {a | b, 1'b0};
  assign G = {a & b, 1'b0};

  // Stage 2: Create the K-Tree
  logic [DATA_SIZE-1:0] P1, P2, P3, P4;
  logic [DATA_SIZE-1:0] G1, G2, G3, G4;

  // k = 0;
  always_comb begin
    for (int i = 0; i < 16; i += 2) begin
      for (int j = 0; j < 2; j++) begin
        if (j == 0) begin
          P1[i+j] = P[i+j];
          G1[i+j] = G[i+j];
        end else begin
          P1[i+j] = P[i+j] && P[i];
          G1[i+j] = G[i+j] || (P[i+j] && G[i]);
        end
      end
    end
  end

  // k = 1
  always_comb begin
    for (int i = 0; i < 16; i += 4) begin
      for (int j = 0; j < 4; j++) begin
        if (j < 2) begin
          P2[i+j] = P1[i+j];
          G2[i+j] = G1[i+j];
        end else begin
          P2[i+j] = P1[i+j] && P1[i+1];
          G2[i+j] = G1[i+j] || (P1[i+j] && G1[i+1]);
        end
      end
    end
  end

  // k = 2
  always_comb begin
    for (int i = 0; i < 16; i += 8) begin
      for (int j = 0; j < 8; j++) begin
        if (j < 4) begin
          P3[i+j] = P2[i+j];
          G3[i+j] = G2[i+j];
        end else begin
          P3[i+j] = P2[i+j] && P2[i+3];
          G3[i+j] = G2[i+j] || (P2[i+j] && G2[i+3]);
        end
      end
    end
  end

  // k = 3
  always_comb begin
    for (int i = 0; i < 16; i += 16) begin
      for (int j = 0; j < 16; j++) begin
        if (j < 8) begin
          P4[i+j] = P3[i+j];
          G4[i+j] = G3[i+j];
        end else begin
          P4[i+j] = P3[i+j] && P3[i+7];
          G4[i+j] = G3[i+j] || (P3[i+j] && G3[i+7]);
        end
      end
    end
  end

  // Stage 3: Compute sums
  always_comb begin
    for (int i = 0; i < DATA_SIZE; i++) begin
      s[i] = a[i] ^ b[i] ^ G4[i];
    end
  end

  // We compute cout by determining if the S15 value generates a carry or if it propagates 
  // one from the G14:-1 stage.
  assign cout = G[16] || (P[16] && (G4[15]));

endmodule
