

`include "includes.svh"
/* shift register consisting of `DATA_LEN register_cells with data in and data out port */
module shift_register
(
        input data_in,
        input clk,
        input update,
        input reset,
        input enable,
        output logic data_out,
        output logic [`DATA_LEN - 1 : 0]bit_out
);

logic cells_out[`DATA_LEN - 1 : 0];
wire clk_and_en;

assign clk_and_en = clk & enable;

generate
    genvar i;
    for (i = `DATA_LEN - 1; i >= 0; i--) begin : chain_begin
        /* beginning of the chain */
        if (i == `DATA_LEN - 1) begin
            register_cell cell_reg(
                .chain_in(data_in),
                .update(update),
                .clk(clk_and_en),
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
                .clk(clk_and_en),
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
                .clk(clk_and_en),
                .reset(reset),
                .chain_out(cells_out[i]),
                .bit_out(bit_out[i])
            );
            end
            
        end
endgenerate
endmodule