module median_calc #(
    parameter int unsigned DATA_WIDTH = 16
) (

    input  [DATA_WIDTH-1:0] a,
    b,
    c,
    output [DATA_WIDTH-1:0] z
);
  // Return the median (middle number) of the 3 signals
  assign z = a > b ? 
            (b > c ? b : (c > a ? a : c)) : 
            (a > c ? a : (c > b ? b : c));
endmodule

module tb;

  localparam DATA_WIDTH = 32;
  logic [DATA_WIDTH-1:0] z;

  median_calc #(
      .DATA_WIDTH(DATA_WIDTH)
  ) median_calc (
      .a('d1),
      .b('d3),
      .c('d2),
      .z(z)
  );
  initial begin
    #1;
    $display("z: %d", z);
    $finish;
  end
endmodule
