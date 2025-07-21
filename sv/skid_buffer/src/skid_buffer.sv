/* A skid-buffer should allow the receiver to de-assert for 1 cycle and not lose throughput */
interface ready_valid_if #(
    parameter int DATA_WIDTH
) ();

  logic valid;
  logic ready;
  logic [DATA_WIDTH-1:0] data;

  modport o(output valid, output data, input ready);
  modport i(input valid, input data, output ready);

endinterface

module skid_buffer #(
    parameter int DATA_WIDTH = 64
) (
    ready_valid_if.i enqueue,
    ready_valid_if.o dequeue,
    /*AUTOARG*/
   // Inputs
   clk, rstn
   );

  input clk, rstn;
  logic [DATA_WIDTH-1:0] skid_buf_r;
  logic bypass;

endmodule

/* This module is a 1 deep synchronous queue */
module sync_fifo_1d (  /*AUTOARG*/
   // Outputs
   full, empty, dout,
   // Inputs
   rstn, clk, wr_en, rd_en, din
   );

  parameter int DATA_WIDTH = 64;
  // The size of the data bus

  input rstn, clk, wr_en, rd_en;
  input [DATA_WIDTH-1:0] din;

  output full, empty;
  output [DATA_WIDTH-1:0] dout;

  logic [DATA_WIDTH-1:0] queue;
  logic is_queued;

  assign full  = is_queued;
  assign empty = !is_queued;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      queue <= 0;
      is_queued <= 0;
    end else begin
      if (wr_en && empty) begin
        is_queued <= 1;
        queue <= din;
      end
      if (rd_en && full) begin
        is_queued <= 0;
        dout <= queue;
      end
    end
  end
endmodule

module tb;
endmodule
