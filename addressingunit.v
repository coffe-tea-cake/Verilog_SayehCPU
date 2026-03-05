
module AddressingUnit (
    input [15:0] Rside,
    input [7:0] Iside,
    output [15:0] Address,
    input clk,
    input ResetPC,
    input PCplusI,
    input PCplus1,
    input RplusI,
    input Rplus0,
    input PCenable
);

wire [15:0] PCout;



ProgramCounter PC (
    Address,
    PCenable,
    clk,
    PCout
);

AddressLogic AL (
    PCout,
    Rside,
    Iside,
    Address,
    ResetPC,
    PCplusI,
    PCplus1,
    RplusI,
    Rplus0
);
endmodule

