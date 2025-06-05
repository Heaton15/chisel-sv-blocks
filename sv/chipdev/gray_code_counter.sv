module gray_code_counter (  /*AUTOARG*/
    // Outputs
    out,
    // Inputs
    clk,
    resetn
);

  parameter int DATA_WIDTH = 8;

  input clk, resetn;
  output [DATA_WIDTH-1:0] out;

  logic [DATA_WIDTH-1:0] cnt;


  // Convert from binary to gray
  assign out = bin2gray(cnt);

  // standard DATA_WIDTH counter size
  always_ff @(posedge clk) begin
    if (~resetn) begin
      cnt <= 0;
    end else begin
      cnt <= cnt + 1;
    end
  end
endmodule

function automatic logic [DATA_WIDTH-1:0] bin2gray(logic [DATA_WIDTH-1:0] binary);
  return binary ^ (binary >> 1);
endfunction
