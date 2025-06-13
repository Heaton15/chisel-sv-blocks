module flip_flop_array (  /*AUTOARG*/
    // Outputs
    dout,
    error,
    // Inputs
    din,
    addr,
    wr,
    rd,
    clk,
    resetn
);


  // 1RW register file using multi-dimensional array of FFs
  // 8 entries, 8 bit word
  // error =1 when wr && rd. Set dout to zero in output

  input [7:0] din;
  input [2:0] addr;
  input wr;
  input rd;
  input clk;
  input resetn;
  output logic [7:0] dout;
  output logic error;

  localparam int DEPTH = 8;

  logic [7:0] mem[DEPTH];

  logic [DEPTH-1:0] err_mask;  // is set when a write is done

  always_ff @(posedge clk) begin
    if (!resetn) begin
      dout <= 0;
      err_mask <= 0;
    end else begin
      if (wr && rd) begin
        dout  <= 0;
        error <= 1;
      end else if (wr) begin
        mem[addr] <= din;
        err_mask[addr] <= 1'b1;
      end else if (rd) begin
        if (err_mask[addr] != 1'b1) begin
          error <= 1;
          dout  <= 0;
        end else begin
          dout <= mem[addr];
        end
      end
    end
  end

endmodule
