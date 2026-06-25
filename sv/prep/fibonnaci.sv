module fibonnaci #(
    parameter int unsigned DATA_WIDTH = 16
) (

    input clk,
    rstn,
    output logic [DATA_WIDTH-1:0] out

);

  // First 2 values are 0,1
  // Everything after that is the sum of the previous 2 values
  //
  // 0, 1, 1, 2, 3, 5...

  logic [DATA_WIDTH-1:0] last_out;
  always_ff @(posedge clk) begin
    if (!rstn) begin
      out <= 0;
      last_out <= 1;
    end else begin
      out <= last_out + out;
      last_out <= out;
    end
  end
endmodule

module tb;

  localparam DATA_WIDTH = 16;
  logic [DATA_WIDTH-1:0] out;

  logic clk, rstn;
  initial begin
    clk = 0;
    forever clk = #1 !clk;
  end

  initial begin
    rstn = 0;
    repeat (10) @(posedge clk);
    rstn = 1;
    repeat (20) begin
      @(posedge clk);
      $display("out: %d", out);
    end
    $finish;
  end


  fibonnaci #(
      .DATA_WIDTH(DATA_WIDTH)
  ) fibonnaci (
      .clk (clk),
      .rstn(rstn),
      .out (out)
  );
endmodule
