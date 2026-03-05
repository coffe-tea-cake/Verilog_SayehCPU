
module StatusRegister (
    input  wire SRCin,
    input  wire SRZin,
    input  wire SRload,
    input  wire clk,
    input  wire Cset,
    input  wire Creset,
    input  wire Zset,
    input  wire Zreset,
    output reg  SRCout,
    output reg  SRZout
);
    always @(negedge clk) begin
        if (SRload) begin
            SRCout <= SRCin;
            SRZout <= SRZin;
        end else begin
            if (Cset)
                SRCout <= 1'b1;
            else if (Creset)
                SRCout <= 1'b0;

            if (Zset)
                SRZout <= 1'b1;
            else if (Zreset)
                SRZout <= 1'b0;
        end
    end
endmodule