module AddressLogic (
    input [15:0] PCside, Rside,
    input [7:0] Iside,
    input ResetPC, PCplusI, PCplus1, RplusI,
    Rplus0,
    output reg [15:0] ALout
);

always @(*) begin
    case ({ResetPC, PCplusI, PCplus1, RplusI, Rplus0})
        5'b10000: ALout = 0;
        5'b01000: ALout = PCside + Iside;
        5'b00100: ALout = PCside + 1;
        5'b00010: ALout = Rside + Iside;
        5'b00001: ALout = Rside;
        default:  ALout = PCside;
    endcase
end

endmodule
