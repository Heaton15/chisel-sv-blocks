module fizzbuzz (  /*AUTOARG*/
    // Outputs
    fizz,
    buzz,
    fizzbuzz,
    // Inputs
    clk,
    resetn
);

  parameter int FIZZ = 3;
  parameter int BUZZ = 5;
  parameter int MAX_CYCLES = 100;

  input clk, resetn;
  output logic fizz, buzz, fizzbuzz;

  logic [$clog2(MAX_CYCLES)-1:0] counter;

  always_ff @(posedge clk) begin
    if (!resetn || counter >= MAX_CYCLES - 1) begin
      counter <= 0;
    end else begin
      counter <= counter + 1'b1;
    end
  end

  assign fizz = (counter == 0) ? 1 : counter % FIZZ == 0 ? 1 : 0;
  assign buzz = (counter == 0) ? 1 : counter % BUZZ == 0 ? 1 : 0;
  assign fizzbuzz = fizz && buzz;

endmodule
