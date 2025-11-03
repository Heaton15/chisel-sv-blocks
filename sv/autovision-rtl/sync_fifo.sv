module sync_fifo #(
    // Depth of the sync fifo
    parameter int DEPTH = 4,

    // Width of the FIFO data bus
    parameter int DATA_SIZE = 16
) (

    input wr_en,
    input [DATA_SIZE-1:0] data_i,
    output full,

    input rd_en,
    output empty,
    output logic [DATA_SIZE-1:0] data_o,
    input clk,
    input rst

);

  localparam DS_BITS = $clog2(DEPTH);

  // Make the counter 1 bit bigger to support the full / empty checking
  logic [$clog2(DEPTH)-1:0] rd_ptr, wr_ptr;

  assign full = (rd_ptr[DS_BITS] ^ wr_ptr[DS_BITS]) && (rd_ptr[DS_BITS-1:0] == wr_ptr[DS_BITS-1:0]);
  assign empty = rd_ptr == wr_ptr;

  wire can_write = wr_en && !full;
  wire can_read = rd_en && !empty;

  // Memory elements (register file, sram, distributed flops)
  logic [DATA_SIZE-1:0] ram[DEPTH];

  initial begin
    for (int i = 0; i < DEPTH; i++) begin
      ram[i] = 0;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      rd_ptr <= 0;
      wr_ptr <= 0;
    end
  end

  // Write side logic
  always_ff @(posedge clk) begin
    if (can_write) begin
      ram[wr_ptr] <= data_i;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end

  always_ff @(posedge clk) begin
    if (can_read) begin
      data_o <= ram[rd_ptr];
      rd_ptr <= rd_ptr + 1'b1;
    end 
  end


endmodule
