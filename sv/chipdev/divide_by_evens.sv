module divide_by_evens (  /*AUTOARG*/
    // Outputs
    div2,
    div4,
    div6,
    // Inputs
    clk,
    resetn
);
  input clk, resetn;
  output logic div2, div4, div6;


  logic div2_cnt;
  logic [1:0] div4_cnt;
  logic [2:0] div6_cnt;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      div2_cnt <= 0;
      div4_cnt <= 0;
      div6_cnt <= 0;
    end else begin
      div2_cnt <= div2_cnt + 1'b1;
      div4_cnt <= div4_cnt + 1'b1;

      if (div6_cnt == 3'b101) div6_cnt <= 0;
      else div6_cnt <= div6_cnt + 1'b1;
    end
  end

  assign div2 = (div2_cnt == 1);
  assign div4 = (div4_cnt == 1) || (div4_cnt == 2);
  assign div6 = (div6_cnt == 1) || (div6_cnt == 2) || (div6_cnt == 3);
endmodule
