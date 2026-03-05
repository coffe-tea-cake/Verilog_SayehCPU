`timescale 1ns/1ps

// Section 8.3 (SAYEH-style) controller skeleton completion.
// This is a compact educational implementation:
// 1) Multi-cycle fetch/decode/execute FSM
// 2) ALU/register/memory/jump/branch classes
// 3) Easy-to-extend opcode decode and control signal generation
module controller (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       mem_ready,
    input  wire [3:0] opcode,
    input  wire [2:0] func,
    input  wire       zf,
    input  wire       cf,

    output reg        ir_load,
    output reg        pc_inc,
    output reg        pc_load,
    output reg        rf_we,
    output reg        mar_load,
    output reg        mdr_load,
    output reg        mem_read,
    output reg        mem_write,
    output reg [2:0]  alu_op,
    output reg        alu_src_imm,
    output reg        wb_sel_mem,
    output reg        wb_sel_alu
);

    // Opcode groups (4-bit major opcode)
    localparam OP_ALU  = 4'h0; // register/immediate ALU (func decides operation)
    localparam OP_LD   = 4'h1; // load
    localparam OP_ST   = 4'h2; // store
    localparam OP_JMP  = 4'h3; // unconditional jump
    localparam OP_BR   = 4'h4; // conditional branch (func decides condition)
    localparam OP_NOP  = 4'hF;

    // ALU micro-ops
    localparam ALU_ADD = 3'd0;
    localparam ALU_SUB = 3'd1;
    localparam ALU_AND = 3'd2;
    localparam ALU_OR  = 3'd3;
    localparam ALU_XOR = 3'd4;
    localparam ALU_INC = 3'd5;
    localparam ALU_DEC = 3'd6;
    localparam ALU_MOV = 3'd7;

    // FSM states
    localparam S_RESET  = 4'd0;
    localparam S_FETCH1 = 4'd1;
    localparam S_FETCH2 = 4'd2;
    localparam S_DECODE = 4'd3;
    localparam S_EX_ALU = 4'd4;
    localparam S_EX_LD1 = 4'd5;
    localparam S_EX_LD2 = 4'd6;
    localparam S_EX_ST1 = 4'd7;
    localparam S_EX_ST2 = 4'd8;
    localparam S_EX_JMP = 4'd9;
    localparam S_EX_BR  = 4'd10;

    reg [3:0] state, next_state;

    // Sequential state register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_RESET;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_RESET:  next_state = S_FETCH1;

            S_FETCH1: next_state = mem_ready ? S_FETCH2 : S_FETCH1;
            S_FETCH2: next_state = S_DECODE;

            S_DECODE: begin
                case (opcode)
                    OP_ALU: next_state = S_EX_ALU;
                    OP_LD : next_state = S_EX_LD1;
                    OP_ST : next_state = S_EX_ST1;
                    OP_JMP: next_state = S_EX_JMP;
                    OP_BR : next_state = S_EX_BR;
                    default:next_state = S_FETCH1; // NOP/unknown
                endcase
            end

            S_EX_ALU: next_state = S_FETCH1;

            S_EX_LD1: next_state = mem_ready ? S_EX_LD2 : S_EX_LD1;
            S_EX_LD2: next_state = S_FETCH1;

            S_EX_ST1: next_state = mem_ready ? S_EX_ST2 : S_EX_ST1;
            S_EX_ST2: next_state = S_FETCH1;

            S_EX_JMP: next_state = S_FETCH1;
            S_EX_BR : next_state = S_FETCH1;

            default:  next_state = S_FETCH1;
        endcase
    end

    // ALU function decode (used in ALU execute state)
    always @(*) begin
        case (func)
            3'b000: alu_op = ALU_ADD;
            3'b001: alu_op = ALU_SUB;
            3'b010: alu_op = ALU_AND;
            3'b011: alu_op = ALU_OR;
            3'b100: alu_op = ALU_XOR;
            3'b101: alu_op = ALU_INC;
            3'b110: alu_op = ALU_DEC;
            default:alu_op = ALU_MOV;
        endcase
    end

    // Output/control decode
    always @(*) begin
        // Safe defaults
        ir_load     = 1'b0;
        pc_inc      = 1'b0;
        pc_load     = 1'b0;
        rf_we       = 1'b0;
        mar_load    = 1'b0;
        mdr_load    = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        alu_src_imm = 1'b0;
        wb_sel_mem  = 1'b0;
        wb_sel_alu  = 1'b0;

        case (state)
            S_RESET: begin
                // Rely on datapath reset values; start fetch at next cycle.
            end

            // Instruction fetch: MAR <- PC, start read.
            S_FETCH1: begin
                mar_load = 1'b1;
                mem_read = 1'b1;
            end

            // Instruction register <= memory, PC++
            S_FETCH2: begin
                ir_load = 1'b1;
                pc_inc  = 1'b1;
            end

            S_EX_ALU: begin
                // ALU result write-back to register file.
                rf_we      = 1'b1;
                wb_sel_alu = 1'b1;
                // Example convention: func[2] indicates immediate form.
                alu_src_imm = func[2];
            end

            // Load effective address/read
            S_EX_LD1: begin
                mar_load = 1'b1;
                mem_read = 1'b1;
            end

            // Complete load: MDR -> RF
            S_EX_LD2: begin
                mdr_load   = 1'b1;
                rf_we      = 1'b1;
                wb_sel_mem = 1'b1;
            end

            // Store effective address/write begin
            S_EX_ST1: begin
                mar_load  = 1'b1;
                mem_write = 1'b1;
            end

            // Keep write strobed one more beat for slow memory models.
            S_EX_ST2: begin
                mem_write = 1'b1;
            end

            S_EX_JMP: begin
                pc_load = 1'b1;
            end

            S_EX_BR: begin
                // Branch condition encoded in func[1:0]
                // 00: if Z=1, 01: if Z=0, 10: if C=1, 11: if C=0
                case (func[1:0])
                    2'b00: pc_load = zf;
                    2'b01: pc_load = ~zf;
                    2'b10: pc_load = cf;
                    2'b11: pc_load = ~cf;
                endcase
            end

            default: begin
                // keep defaults
            end
        endcase
    end

endmodule