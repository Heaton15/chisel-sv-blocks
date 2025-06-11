module fibonacci (  /*AUTOARG*/
    // Outputs
    out,
    // Inputs
    clk,
    resetn
);

  parameter int DATA_WIDTH = 32;

  input clk, resetn;
  output logic [DATA_WIDTH-1:0] out;

  logic [DATA_WIDTH-1:0] out_d1;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      out <= 1;
      out_d1 <= 0;
    end else begin
      out <= out + out_d1;
      out_d1 <= out;
    end
  end
endmodule
