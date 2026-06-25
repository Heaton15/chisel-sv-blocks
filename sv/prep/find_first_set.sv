module find_first_set (
    input  logic [31:0] data_i,
    output logic [4:0]  index_o,
    output logic        valid_o
);

    always_comb begin
        valid_o = |data_i;
        index_o = 5'd0;

        for (int i = 31; i >= 0; i--) begin
            if (data_i[i]) begin
                index_o = 5'(i);
            end
        end
    end

endmodule
