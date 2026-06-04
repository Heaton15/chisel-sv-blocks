module register_controller #(

    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter unsigned BASE_ADDR = 'h8000,
    parameter unsigned NUM_REG = 4

) (
    input  clk,
    input  rstn,
    output error,

    input [ADDR_WIDTH-1:0] addr,
    input wr_en,
    input rd_en,
    input logic [DATA_WIDTH-1:0] wdata_i,
    output logic [DATA_WIDTH-1:0] rdata_o

);

  localparam ADDR_CSR0 = 'h0;
  localparam ADDR_CSR1 = 'h8;
  localparam ADDR_CSR2 = 'h10;
  localparam ADDR_CSR3 = 'h18;

  logic [63:0] registers[NUM_REG];
  logic [DATA_WIDTH-1:0] rdata;
  wire [ADDR_WIDTH-1:0] decoded_addr = addr - BASE_ADDR;

  wire is_csr0 = ADDR_CSR0 == decoded_addr;  // WO
  wire is_csr1 = ADDR_CSR1 == decoded_addr;  // RW
  wire is_csr2 = ADDR_CSR2 == decoded_addr;  // RO
  wire is_csr3 = ADDR_CSR3 == decoded_addr;  // RW

  // Error if any addr decoding fails
  wire addr_error = !(is_csr0 || is_csr1 || is_csr2 || is_csr3);
  assign error = addr_error;

  logic write_allowed, read_allowed;

  // Indicates if a register is WO, RO, RW
  always_comb begin
    write_allowed = 1'b1;
    read_allowed  = 1'b1;
    unique case (decoded_addr)
      ADDR_CSR0: begin
        read_allowed = 1'b0;
      end
      ADDR_CSR2: begin
        write_allowed = 1'b0;
      end
    endcase
  end

  always_comb begin
    rdata = '0;
    if (rd_en && read_allowed) begin
      unique case (decoded_addr)
        ADDR_CSR0: rdata = registers[0];
        ADDR_CSR1: rdata = registers[1];
        ADDR_CSR2: rdata = registers[2];
        ADDR_CSR3: rdata = registers[3];
      endcase
    end
  end

  always_ff @(posedge clk) begin
    if (!rstn) begin
      rdata_o <= '0;
    end else begin
      if (rd_en) rdata_o <= rdata;
    end
  end

  always_ff @(posedge clk) begin
    if (!rstn) begin
      for (int unsigned i = 0; i < NUM_REG; i++) registers[i] <= '0;
    end else begin
      if (wr_en && write_allowed) begin
        unique case (decoded_addr)
          ADDR_CSR0: registers[0] <= wdata_i;
          ADDR_CSR1: registers[1] <= wdata_i;
          ADDR_CSR2: registers[2] <= wdata_i;
          ADDR_CSR3: registers[3] <= wdata_i;
        endcase
      end
    end
  end
endmodule
