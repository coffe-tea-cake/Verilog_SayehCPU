
module RegisterFile (
    input  wire [15:0] Databus,
    input  wire        clk,
    input  wire [2:0]  Laddr,
    input  wire [2:0]  Raddr,
    input  wire [2:0]  WPout,
    input  wire        RFLwrite,
    input  wire        RFHwrite,
    output wire [15:0] Left,
    output wire [15:0] Right
);
    // 8 windows x 8 registers = 64 physical registers.
    reg [15:0] rf [0:63];

    wire [5:0] left_index  = {WPout, Laddr};
    wire [5:0] right_index = {WPout, Raddr};

    // Falling-edge update to align with SAYEH data register timing.
    always @(negedge clk) begin
        if (RFLwrite)
            rf[left_index][7:0] <= Databus[7:0];
        if (RFHwrite)
            rf[left_index][15:8] <= Databus[15:8];
    end

    assign Left  = rf[left_index];
    assign Right = rf[right_index];
endmodule
