
module ProgramCounter ( 
input [15:0] in, input enable, clk, output reg [15:0] out);
always @ (negedge clk) if (enable) out = in;
endmodule
