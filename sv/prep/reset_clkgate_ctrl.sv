module reset_clkgate_ctrl (
    input  logic clk,              // ungated clock
    input  logic arst_n,           // async reset from CSR (active low)
    output logic core_clk,         // gated clock output
    output logic core_srst         // synchronized reset for core
);

    // Synchronize async reset to clk domain
    logic srst_sync1, srst_sync2;

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            srst_sync1 <= 1'b1;
            srst_sync2 <= 1'b1;
        end else begin
            srst_sync1 <= 1'b0;
            srst_sync2 <= srst_sync1;
        end
    end

    wire srst = srst_sync2;

    // 2-bit counter to keep clock enabled during reset
    logic [1:0] rst_count;
    logic       force_clk_en;

    always_ff @(posedge clk) begin
        if (srst) begin
            rst_count <= 2'b00;  // reset counter
        end else if (rst_count != 2'b11) begin
            rst_count <= rst_count + 1'b1;  // count up
        end
    end

    // Force clock enabled while counter is active
    assign force_clk_en = (rst_count != 2'b11);

    // Clock gate enable: force on during reset, otherwise use normal enable
    logic clk_gate_en;
    assign clk_gate_en = force_clk_en;
    assign core_srst = srst;
    // srst = 1'b1

    // Instantiate clock gate
    clock_gate u_clock_gate (
        .in  (clk),
        .en  (clk_gate_en),
        .out (core_clk)
    );

    // running state
    // srst = 0;

    // assert the reset 
    // srst = 1;


    // Downstream Accelerator
    // clk pulses 2 more times
    

    // srst = 0;
    // clk goes trasparent 


endmodule
