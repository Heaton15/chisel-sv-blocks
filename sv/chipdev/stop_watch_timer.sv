module stop_watch_timer (  /*AUTOARG*/
    // Outputs
    count,
    // Inputs
    clk,
    reset,
    start,
    stop
);
  parameter int DATA_WIDTH = 16;
  parameter int MAX = 99;
  input clk, reset, start, stop;
  output logic [DATA_WIDTH-1:0] count;

  // MAX is where we overflow at
  // reset -> stop -> start (priority)

  logic cnt_en;

  always_ff @(posedge clk) begin
    if (reset) begin
      cnt_en <= 0;
    end else if (stop) begin
      cnt_en <= 0;
    end else if (start) begin
      cnt_en <= 1;
      count  <= count + 1;
    end else if (cnt_en) begin
      if (count == MAX) count <= 0;
      else count <= count + 1;
    end
  end
endmodule
