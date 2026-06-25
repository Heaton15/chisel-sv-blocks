module clock_gate (
    input  logic in,   // clock input
    input  logic en,   // enable
    output logic out   // gated clock output
);

    logic en_latch;

    always_latch begin
        if (!in)
            en_latch = en;
    end

    assign out = in & en_latch;

endmodule
