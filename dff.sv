/* d-Flip-Flop with synchronous low reset */
module dff (
    input  logic clk,
    input  logic d,
    input  logic reset,
    output logic q
);

  always @(posedge clk) begin
    if (!reset) begin
      q <= 0;
    end
    else begin
      q <= d;
    end
  end
endmodule
