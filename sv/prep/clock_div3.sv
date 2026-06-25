`timescale 1ns / 1ps

module clock_div3 #(
) (
    input  logic clk,
    input  logic rstn,
    output logic clk_out
);

  // DIV3 is the falling edge clock 
  logic [1:0] cntr;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      cntr <= 0;
    end else begin
      if (cntr == 2'd2) cntr <= 0;
      else cntr <= cntr + 1'b1;
    end
  end

  // Negative edge of the clk on the 2nd pulse is the 1/3 point

  // Pulse 1, cntr = 1
  // Pulse 2, cntr = 2
  // on posedge, we drop "posedge" tracker
  // on negedge, we drop "negedge" tracker
  
  logic posedge_div3, negedge_div3;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      posedge_div3 <= 0;
    end else begin
      posedge_div3 <= cntr < 2'd2;
    end
  end

  always_ff @(negedge clk) begin
    if (!rstn) begin
      negedge_div3 <= 0;
    end else begin
      negedge_div3 <= cntr < 2'd2;
    end
  end

  assign clk_out = posedge_div3 | negedge_div3;

endmodule

module tb;


  logic clk, clk_out;
  initial begin
    clk = 0;
    forever clk = #1 !clk;
  end

  clock_div3 clock_div3 (
      .clk    (clk),
      .rstn   (rstn),
      .clk_out(clk_out)
  );
endmodule
