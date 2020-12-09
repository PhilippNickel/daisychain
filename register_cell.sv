/* chaincell consisting of 3 flip flops to minimize hold violations and buffer output that gets active when update signal is high */
module register_cell
(
  input logic chain_in, /* chain in from before chaincell or controller */
  input logic update,
  input logic clk,
  input logic reset,    
  output logic chain_out, /* chain out to next chaincell */
  output logic bit_out    /* bit to PLL */
);

logic ff_in_q;

logic ff_out_clk;
logic ff_buf_clk;

assign ff_out_clk = ~clk;

assign ff_buf_clk = (!reset) ? clk : update;

dff ff_in (
  .clk(clk),
  .reset(reset),
  .d(chain_in),
  .q(ff_in_q)
  );

dff ff_buf (
  .clk(ff_buf_clk),
  .reset(reset),
  .d(ff_in_q),
  .q(bit_out)
  );

dff ff_out (
  .clk(ff_out_clk),
  .reset(reset),
  .d(ff_in_q),
  .q(chain_out)
  );

endmodule