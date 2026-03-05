
module WindowPointer (
    input  wire [2:0] IRout,
    input  wire       clk,
    input  wire       WPreset,
    input  wire       WPadd,
    output reg  [2:0] WPout
);
    always @(negedge clk) begin
        if (WPreset)
            WPout <= 3'b000;
        else if (WPadd)
            WPout <= WPout + IRout;
    end
endmodule