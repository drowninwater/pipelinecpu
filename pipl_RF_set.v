`include "ctrl_encode_def.v"

module IF_ID(
    input           clk,
    input           rst,
    input           flush,
    input   [31:0] pc_if_id_in,
    input   [31:0] instr_if_id_in,
    output reg [31:0] pc_if_id_out,
    output reg [31:0] instr_if_id_out

);
    always @(posedge clk, posedge rst) begin
    if (rst || flush) begin
        pc_if_id_out <= 32'b0;
        instr_if_id_out <= 32'b0;
    end
    else begin
        pc_if_id_out <= pc_if_id_in;
        instr_if_id_out <= instr_if_id_in;
    end
end

endmodule

module ID_EX(
    input           clk,
    input           rst,
    input           flush,

    //控制信号输入，从ctrl送进来的控制信号,初始时所有信号都传递到ID_EX寄存器里面
    input       RegWrite_id_ex_in,
    input       MemWrite_id_ex_in,
    input       MemRead_id_ex_in,
    input [5:0] EXTOp_id_ex_in,   // control signal to signed extension
    input [4:0] ALUOp_id_ex_in,    // ALU opertion
    input [2:0] NPCOp_id_ex_in,    // next pc operation
    input       ALUSrc_id_ex_in,   // ALU source for A
    input [2:0] DMType_id_ex_in,
    //input [1:0] GPRSel_id_ex_in,   // general purpose register selection
    input [1:0] WDSel_id_ex_in,   // (register) write data selection


    //数据信号输入
    input       [31:0] pc_id_ex_in,
    input       [31:0] instr_id_ex_in,
    input       [31:0] imm_id_ex_in,
    input       [4:0] rd_id_ex_in,
    input       [31:0] rs1_data_id_ex_in,
    input       [31:0] rs2_data_id_ex_in,

    //数据信号输出
    output reg [31:0] pc_id_ex_out,
    output reg [31:0] instr_id_ex_out,
    output reg [31:0] imm_id_ex_out,
    output reg [4:0]  rd_id_ex_out,
    output reg [31:0] rs1_data_id_ex_out,
    output reg [31:0] rs2_data_id_ex_out,

    //控制信号输出
    output reg RegWrite_id_ex_out,
    output reg MemWrite_id_ex_out,
    output reg MemRead_id_ex_out,
    output reg [5:0] EXTOp_id_ex_out,    // control signal to signed extension
    output reg [4:0] ALUOp_id_ex_out,    // ALU opertion
    output reg [2:0] NPCOp_id_ex_out,    // next pc operation
    output    reg   ALUSrc_id_ex_out,   // ALU source for A
    output reg [2:0] DMType_id_ex_out,
    //output reg [1:0] GPRSel_id_ex_out,   // general purpose register selection
    output reg [1:0] WDSel_id_ex_out   // (register) write data selection
);

    always @(posedge clk, posedge rst) begin
    if (rst || flush) begin

        pc_id_ex_out <= 32'b0;
        instr_id_ex_out <= 32'b0;
        imm_id_ex_out <= 32'b0;
        rd_id_ex_out <= 32'b0;
        rs1_data_id_ex_out <= 32'b0;
        rs2_data_id_ex_out <= 32'b0;

        RegWrite_id_ex_out <= 1'b0;
        MemWrite_id_ex_out <= 1'b0;
        MemRead_id_ex_out <= 1'b0;
        EXTOp_id_ex_out <= 5'b0;
        ALUOp_id_ex_out <= 5'b0;
        NPCOp_id_ex_out <= 3'b0;
        ALUSrc_id_ex_out <= 1'b0;
        DMType_id_ex_out <= 3'b0;
        //GPRSel_id_ex_out <= 2'b0;
        WDSel_id_ex_out <= 2'b0;
    end
    else begin
        pc_id_ex_out <= pc_id_ex_in;
        instr_id_ex_out <= instr_id_ex_in;
        imm_id_ex_out <= imm_id_ex_in;
        rd_id_ex_out <= rd_id_ex_in;
        rs1_data_id_ex_out <= rs1_data_id_ex_in;
        rs2_data_id_ex_out <= rs2_data_id_ex_in;

        RegWrite_id_ex_out <= RegWrite_id_ex_in;
        MemWrite_id_ex_out <= MemWrite_id_ex_in;
        MemRead_id_ex_out <= MemRead_id_ex_in;
        EXTOp_id_ex_out <= EXTOp_id_ex_in;
        ALUOp_id_ex_out <= ALUOp_id_ex_in;
        NPCOp_id_ex_out <= NPCOp_id_ex_in;
        ALUSrc_id_ex_out <= ALUSrc_id_ex_in;
        DMType_id_ex_out <= DMType_id_ex_in;
        //GPRSel_id_ex_out <= GPRSel_id_ex_in;
        WDSel_id_ex_out <= WDSel_id_ex_in;
    end
end

endmodule

module EX_MEM(
    input       clk,
    input       rst,
    input       flush,
    //数据信号输入
    input              zero_ex_mem_in,
    input       [31:0] pc_ex_mem_in,
    input       [4:0] rd_ex_mem_in,
    input       [31:0] addsum_ex_mem_in,
    input       [31:0] alu_ex_mem_in,
    input       [31:0] rs2_data_ex_mem_in,
    input       [31:0] imm_ex_mem_in,

    //控制信号输入
    input       RegWrite_ex_mem_in,
    input       MemWrite_ex_mem_in,
    input       MemRead_ex_mem_in,
    input   [2:0] NPCOp_ex_mem_in,
    input   [2:0] DMType_ex_mem_in,
    input   [1:0] WDSel_ex_mem_in,

    //数据信号输出
    output  reg [31:0] pc_ex_mem_out,
    output reg [4:0]  rd_ex_mem_out,
    output reg [31:0] alu_ex_mem_out,
    output reg [31:0] addsum_ex_mem_out,
    output reg [31:0] imm_ex_mem_out,
    output reg [31:0] rs2_data_ex_mem_out,

    //控制信号输出
    output  reg      RegWrite_ex_mem_out,
    output  reg      MemWrite_ex_mem_out,
    output  reg      MemRead_ex_mem_out,
    output   reg [2:0] NPCOp_ex_mem_out,
    output   reg [2:0] DMType_ex_mem_out,
    output reg  [1:0] WDSel_ex_mem_out
);

    always @(posedge clk, posedge rst) begin
    if (rst || flush) begin
        //数据
        pc_ex_mem_out <= 32'b0;
        rd_ex_mem_out <= 5'b0;
        alu_ex_mem_out <= 32'b0;
        addsum_ex_mem_out <= 32'b0;
        imm_ex_mem_out <= 32'b0;
        rs2_data_ex_mem_out <= 32'b0;
        //控制
        RegWrite_ex_mem_out <= 1'b0;
        MemWrite_ex_mem_out <= 1'b0;
        MemRead_ex_mem_out <= 1'b0;
        NPCOp_ex_mem_out <= 3'b0;
        DMType_ex_mem_out <= 3'b0;
        WDSel_ex_mem_out <= 2'b0;

    end
    else begin
        //数据
        pc_ex_mem_out <= pc_ex_mem_in;
        rd_ex_mem_out <= rd_ex_mem_in;
        alu_ex_mem_out <= alu_ex_mem_in;
        addsum_ex_mem_out <= addsum_ex_mem_in;
        imm_ex_mem_out <= imm_ex_mem_in;
        rs2_data_ex_mem_out <= rs2_data_ex_mem_in;

        //控制
        RegWrite_ex_mem_out <= RegWrite_ex_mem_in;
        MemWrite_ex_mem_out <= MemWrite_ex_mem_in;
        MemRead_ex_mem_out <= MemRead_ex_mem_in;
        NPCOp_ex_mem_out <= NPCOp_ex_mem_in;
        DMType_ex_mem_out <= DMType_ex_mem_in;
        WDSel_ex_mem_out <= WDSel_ex_mem_in;
    end
end

endmodule

module MEM_WB(
    input       clk,
    input       rst,
    input       flush,
    //数据输入
    input   [31:0] pc_mem_wb_in,
    input   [31:0] rdata_mem_wb_in,
    input   [31:0] alu_mem_wb_in,
    input   [31:0] imm_mem_wb_in,
    input   [4:0]  rd_mem_wb_in,

    //控制输入
    input       RegWrite_mem_wb_in,
    input   [1:0] WDSel_mem_wb_in,
    input   [2:0]   DMType_mem_wb_in,


    //数据输出
    output  reg [31:0] pc_mem_wb_out,
    output  reg [31:0] rdata_mem_wb_out,
    output  reg [31:0] alu_mem_wb_out,
    output  reg [31:0] imm_mem_wb_out,
    output  reg [4:0] rd_mem_wb_out,

    //控制输出
    output  reg RegWrite_mem_wb_out,
    output  reg [1:0] WDSel_mem_wb_out,
    output   reg [2:0]   DMType_mem_wb_out


);
    always @(posedge clk, posedge rst) begin
        if(rst)begin
          pc_mem_wb_out <= 32'b0;
          rdata_mem_wb_out <= 32'b0;
          alu_mem_wb_out <= 32'b0;
          imm_mem_wb_out <= 32'b0;
          rd_mem_wb_out <= 5'b0;

          RegWrite_mem_wb_out <= 1'b0;
          WDSel_mem_wb_out <= 2'b0;
          DMType_mem_wb_out <= 3'b0;
        end
        else begin
          pc_mem_wb_out <= pc_mem_wb_in;
          rdata_mem_wb_out <= rdata_mem_wb_in;   
          alu_mem_wb_out <= alu_mem_wb_in;
          imm_mem_wb_out <= imm_mem_wb_in;
          rd_mem_wb_out <= rd_mem_wb_in;

          RegWrite_mem_wb_out <= RegWrite_mem_wb_in;
          WDSel_mem_wb_out <= WDSel_mem_wb_in;
          DMType_mem_wb_out <= DMType_mem_wb_in;
        end
    end

endmodule