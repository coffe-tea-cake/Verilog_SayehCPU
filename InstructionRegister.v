module InstrunctionRegister (in, IRload, clk, out);
input [15:0] in;
input IRload, clk;
output [15:0] out;
reg [15:0] out;
always @(negedge clk) if (IRload == 1) out <= in;
endmodule
