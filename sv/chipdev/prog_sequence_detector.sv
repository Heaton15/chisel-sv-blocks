module prog_sequence_detector (  /*AUTOARG*/
    // Outputs
    seen,
    // Inputs
    clk,
    resetn,
    init,
    din
);
  input clk;
  input resetn;
  input [4:0] init;
  input din;
  output logic seen;

  logic [4:0] init_r, capture;
  logic [2:0] counter;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      init_r <= 0;
    end else begin
      init_r <= init;
    end
  end

  always_ff @(posedge clk) begin
    if (!resetn) begin
      capture <= 0;
    end else begin
      capture <= {capture[3:0], din};
    end
  end

  always_ff @(posedge clk) begin
    if (!resetn) begin
      counter <= 0;
    end else begin
      if (counter < 3'd5) counter <= counter + 1'b1;
    end
  end

  assign seen = (capture == init_r) && (counter == 3'd5);





endmodule
