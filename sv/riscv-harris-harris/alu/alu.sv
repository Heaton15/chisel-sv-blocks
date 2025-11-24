package alu_package;
  parameter int INSTR_WIDTH = 4;

  typedef enum logic [INSTR_WIDTH-1:0] {
    ADD = 'b0000,
    SUB = 'b0001,
    AND = 'b0010,
    OR  = 'b0011
  } alu_e;

  typedef struct packed {
    logic N;  // Negative ALU Result
    logic Z;  // Zero ALU Result
    logic C;  // Carry-Out from ALU
    logic V;  // Overflow in ALU
  } alu_flags;


endpackage

module alu
  import alu_package::*;
#(
    parameter int N = 16
) (

    input signed [N-1:0] a,
    b,
    input alu_e alu_inst,

    output signed [N:0] z,
    output alu_flags flags
);


  always_comb begin
    flags.N = z[N-1];
    flags.Z = |z == '0;
    flags.V = 1'b0;
    if (alu_inst inside {ADD, SUB}) flags.C = z[N] == 1'b1;
    if (z[N-1] ^ z[N-1]) begin
      if ((alu_inst inside {ADD} && a[N-1] == b[N-1]) || (alu_inst inside {SUB} && a[N-1] ^ b[N-1]))
        flags.V = 1'b1;
    end else flags.C = 0;
  end


  always_comb begin
    case (alu_inst)
      ADD: begin
        z = a + b;
      end
      SUB: begin
        z = a - b;
      end
      AND: begin
        z = {1'b0, a & b};
      end
      OR: begin
        z = {1'b0, a | b};
      end
      default: begin
        z = 0;
      end
    endcase
  end
endmodule
