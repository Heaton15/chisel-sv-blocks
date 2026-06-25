module factorial #(
    parameter int unsigned DATA_WIDTH = 64
) (

    input clk,
    rstn,

    input [DATA_WIDTH-1:0] factorial_num,
    input start,

    output logic [DATA_WIDTH-1:0] factorial_result,
    output logic done
);

  // n = 5
  // 1 * 2 * 3 * 4 * 5 ... N

  // Assert start to trigger a computation
  // Wait until done is asserted to read out the output data
  // Reset our FSMs when we finish a computation

  typedef enum logic [1:0] {
    IDLE,
    COMPUTE,
    DONE
  } states;

  states state, next_state;

  logic [DATA_WIDTH-1:0] product;
  logic [DATA_WIDTH-1:0] counter;

  always_ff @(posedge clk) begin
    if (!rstn) state <= IDLE;
    else state <= next_state;
  end

  always_comb begin
    next_state = state;
    unique case (state)
      IDLE: begin
        if (start) next_state = COMPUTE;
      end
      COMPUTE: begin
        if (counter <= 'd1) next_state = DONE;
      end
      DONE: begin
        next_state = IDLE;
      end
    endcase
  end

  wire is_idle = state == IDLE;
  wire is_compute = state == COMPUTE;
  wire is_done = state == DONE;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      product <= 1;
      counter <= 0;
    end else begin
      if (is_idle) begin
        counter <= factorial_num;
      end else if (is_compute) begin
        product <= product * counter;
        counter <= counter - 1'b1;
      end else if (is_done) begin
        done <= 1;
        factorial_result <= product;
      end
    end
  end
endmodule

module tb;

  localparam DATA_WIDTH = 64;

  logic clk, rstn;

  wire [DATA_WIDTH-1:0] factorial_num = 6;
  logic [DATA_WIDTH-1:0] factorial_result;

  initial begin
    clk = 0;
    forever clk = #1 !clk;
  end

  logic start, done;

  initial begin
    rstn = 0;
    repeat (20) @(posedge clk);
    rstn = 1;
    @(posedge clk);
    start = 1;
    wait (done);
    $display("result: %d", factorial_result);
    $finish;
  end

  factorial #(
      .DATA_WIDTH()
  ) factorial (
      .clk             (clk),
      .rstn            (rstn),
      .factorial_num   (factorial_num),
      .start           (start),
      .factorial_result(factorial_result),
      .done            (done)
  );
endmodule
