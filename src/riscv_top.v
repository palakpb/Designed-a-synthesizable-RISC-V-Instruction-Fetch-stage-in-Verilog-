`timescale 1ns / 1ps
module riscv_top (
    input clk,
    input reset
);

assign stall = 1'b0;

// ======================
// PROGRAM COUNTER (PC)
// ======================
reg  [31:0] pc;
wire [31:0] pc_next;
wire        pc_write;
wire        stall;

assign stall    = 1'b0;     
assign pc_next  = pc + 4;

assign pc_write = ~stall;
always @(posedge clk) begin
    if (reset)
        pc <= 32'b0;
    else if (pc_write)
        pc <= pc_next;
end

 

// ================================
// INSTRUCTION MEMORY
// ================================

reg [31:0] instr_mem [0:255];
reg [31:0] instr;   // MAKE IT reg, not wire

integer i;

initial begin
    // initialize whole memory (IMPORTANT)
    for (i = 0; i < 256; i = i + 1)
        instr_mem[i] = 32'h00000013; // NOP

    // program
    instr_mem[0] = 32'h00000013; // NOP
    instr_mem[1] = 32'h00000013; // NOP
end

always @(*) begin
    if (reset)
        instr = 32'h00000013;   // NOP during reset
    else
        instr = instr_mem[pc >> 2]; // 🔥 THIS IS THE KEY
end



    // ======================
    // IF / ID PIPELINE REGISTER
    // ======================
    reg [31:0] if_id_instr;

    always @(posedge clk) begin
        if (reset)
            if_id_instr <= 32'b0;
        else if (~stall)
            if_id_instr <= instr;
    end


    // ======================
    // CONTROL UNIT
    // ======================
    wire regwrite, memread, memwrite, alusrc;
    wire [6:0] opcode;

    assign opcode = if_id_instr[6:0];

    reg regwrite_r, memread_r, memwrite_r, alusrc_r;

    always @(*) begin
        regwrite_r = 0;
        memread_r  = 0;
        memwrite_r = 0;
        alusrc_r   = 0;

        case (opcode)
            7'b0110011: regwrite_r = 1;   // R-type
            7'b0000011: begin             // LW
                regwrite_r = 1;
                memread_r  = 1;
                alusrc_r   = 1;
            end
            7'b0100011: begin             // SW
                memwrite_r = 1;
                alusrc_r   = 1;
            end
        endcase
    end

    assign regwrite = regwrite_r;
    assign memread  = memread_r;
    assign memwrite = memwrite_r;
    assign alusrc   = alusrc_r;


    // ======================
    // REGISTER FILE
    // ======================
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] wd;

    assign wd = 32'b0;   // writeback skipped for now

    regfile RF (
        .clk(clk),
        .reset(reset),
        .we(regwrite),
        .rs1(if_id_instr[19:15]),
        .rs2(if_id_instr[24:20]),
        .rd (if_id_instr[11:7]),
        .wd (wd),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );


    // ======================
    // ID / EX PIPELINE REG
    // ======================
    reg [31:0] id_ex_rs1, id_ex_rs2;

    always @(posedge clk) begin
        id_ex_rs1 <= rs1_data;
        id_ex_rs2 <= rs2_data;
    end


    // ======================
    // ALU
    // ======================
    wire [31:0] alu_out;

    alu ALU (
        .a(id_ex_rs1),
        .b(id_ex_rs2),
        .y(alu_out)
    );


    // ======================
    // DATA MEMORY
    // ======================
    reg [31:0] data_mem [0:255];
    reg [31:0] mem_data;

    always @(posedge clk) begin
        if (memwrite)
            data_mem[alu_out[9:2]] <= id_ex_rs2;
    end

    always @(*) begin
        if (memread)
            mem_data = data_mem[alu_out[9:2]];
        else
            mem_data = 32'b0;
    end


    // ======================
    // HAZARD UNIT (DUMMY SAFE)
    // ======================
    wire id_ex_memread;
    wire [4:0] id_ex_rd;

    assign id_ex_memread = 1'b0;
    assign id_ex_rd      = 5'd0;

    hazard_unit HU (
        .id_ex_memread(id_ex_memread),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_instr[19:15]),
        .if_id_rs2(if_id_instr[24:20]),
        .stall(stall)
    );

endmodule
