module rotate_left #(
    parameter unsigned SIZE = 4,
    parameter unsigned SHAMT_SIZE = $clog2(SIZE)
) (
    input [SIZE-1:0] data_i,
    input [SHAMT_SIZE-1:0] shift_by,
    output [SIZE-1:0] result_by_shift_o,
    output [SIZE-1:0] result_by_borders_o
);

  wire [SHAMT_SIZE:0] ofst = $bits(shift_by)'(SIZE) - shift_by;

  // Shift left / right and then OR them.
  assign result_by_shift_o = (data_i << shift_by) | (data_i >> ($bits(shift_by)'(SIZE) - shift_by));

  // Part-Select index the rotate
  assign result_by_borders_o = {data_i, data_i}[ofst +: SIZE];
endmodule

module tb;

  parameter int SIZE = 4;
  parameter int SHAMT_SIZE = $clog2(SIZE);

  logic [SIZE-1:0] data_i;
  logic [SHAMT_SIZE-1:0] shamt_i;
  logic [SIZE-1:0] result_by_shift_o;
  logic [SIZE-1:0] result_by_borders_o;

  rotate_left #(
      .SIZE      (SIZE),
      .SHAMT_SIZE(SHAMT_SIZE)
  ) dut (
      .data_i             (data_i),
      .shift_by           (shamt_i),
      .result_by_shift_o  (result_by_shift_o),
      .result_by_borders_o(result_by_borders_o)
  );

  assign data_i  = 'b1101;
  assign shamt_i = 1;

  initial $display("data_i: %b", data_i);
  initial $display("shift_by: %d", shamt_i);
  initial begin
    #10;
    $display("result_by_shift_o: %b", result_by_shift_o);
  end

  initial begin
    #10;
    $display("result_by_borders_o: %b", result_by_borders_o);
  end
endmodule
