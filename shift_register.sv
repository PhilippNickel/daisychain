

`include "includes.svh"
/* shift register consisting of `DATA_LEN register_cells with data in and data out port */
module shift_register
(
        input logic data_in,
        input logic clk,
        input logic update,
        input logic reset,
        input logic enable,
        output logic data_out,
        output logic [`DATA_LEN - 1 : 0]bit_out
);

logic cells_out[`DATA_LEN - 1 : 0];

generate
    genvar i;
    for (i = `DATA_LEN - 1; i >= 0; i--) begin : chain_generate
        /* beginning of the chain */
        if (i == `DATA_LEN - 1) begin : chain_begin
            register_cell cell_reg(
                .chain_in(data_in),
                .update(update),
                .clk(clk),
					 .enable(enable),
                .reset(reset),
                .chain_out(cells_out[i]),
                .bit_out(bit_out[i])
            );
        end
        /* end of the chain */
        else if (i == 0) begin : chain_end
            register_cell cell_reg(
                .chain_in(cells_out[i+1]),
                .update(update),
                .clk(clk),
					 .enable(enable),
                .reset(reset),
                .chain_out(data_out),
                .bit_out(bit_out[i])
            );
        end
        /* middle cells */
        else begin : chain_middle
            register_cell cell_reg(
                .chain_in(cells_out[i+1]),
                .update(update),
                .clk(clk),
					 .enable(enable),
                .reset(reset),
                .chain_out(cells_out[i]),
                .bit_out(bit_out[i])
            );
            end    
        end
endgenerate
endmodule