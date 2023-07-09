`include "ctrl_encode_def.v"
`include "pipl_RF_set.v"
`include "PC.v"
`include "RF.v"
`include "ctrl.v"
`include "EXT.v"
`include "alu.v"
`include "NPC.v"

module SCPU(
    input   INT,                 // not used signal
    input   MIO_ready,           // not used signal
    output  CPU_MIO,             // not used signal

    input   clk,                 // clock
    input   reset,               // reset


    input   [31:0]   inst_in,    // instruction
    output  [31:0]   PC_out,     // PC address

   
    output  mem_w,               // output: memory write signal
    input   [31:0]  Data_in,     // data from data memory
    output  [31:0]  Addr_out,    // ALU output
    output  [31:0]  Data_out,    // data to data memory
    output  [2:0]   dm_ctrl
);

//*************************************************************
//IF stage includes PC module and IF_ID_f
    wire flush;
    wire [31:0] PC;
    wire [31:0] NPC;
    wire [2:0] NPCOp;
    wire stall;
    assign stall  = 1'b0;
    assign flush = 1'b0;

//实例化PC
    PC U_PC(
        //input
        .clk(clk), .rst(reset),
        .stall(stall), .NPCOp(NPCOp_a),
        .NPC(NPC), 
        //output
        .PC(PC)
    );
   assign PC_out = PC; //不能 <= ?

    wire    [31:0] pc_if_id_out;
    wire    [31:0] instr_if_id_out;

//实例化IF_ID流水线寄存器
    IF_ID U_IF_ID(
        //input
        .clk(clk), .rst(reset), .flush(flush),
        .pc_if_id_in(PC), .instr_if_id_in(inst_in),
        //output
        .pc_if_id_out(pc_if_id_out), .instr_if_id_out(instr_if_id_out)
    );
    //**************************************************************
    //ID stage : RF, ctrl, EXT， 冒险检测及处理

    //实例化RF
    wire    [4:0] rs1,rs2,rd;
    wire    [31:0] rb_data; // 写回寄存器的数据   line 297 给rb_data赋值
    wire    [31:0] RD1,RD2; //读出寄存器的数据 
    RF U_RF(
        //input
        .clk(clk), 
        .rst(reset), 
        .RFWr(RegWrite_mem_wb_out),
        .pc(PC),
        .A1(rs1), 
        .A2(rs2), 
        .A3(rd_mem_wb_out),
        .WD(rb_data), 
        //output
        .RD1(RD1), 
        .RD2(RD2)
    );


//实例化ctrl
    wire [4:0]  iimm_shamt;
    wire [11:0] iimm,simm,bimm;
    wire [19:0] uimm,jimm;

    wire    [6:0] Op;
    wire    [6:0] Funct7;
    wire    [2:0] Funct3;
    wire        Zero;
    wire        MemWrite;
    wire        RegWrite;
    wire        MemRead;
    wire    [5:0] EXTOp;
    wire    [4:0] ALUOp;
    //wire    [2:0] NPCOp;
    wire        ALUSrc;
    wire    [2:0] DMType;
    wire    [1:0] WDSel;

        // 处理指令
    assign iimm_shamt=instr_if_id_out[24:20];
    assign iimm=instr_if_id_out[31:20];
    assign simm={instr_if_id_out[31:25],instr_if_id_out[11:7]};
    assign bimm={instr_if_id_out[31],instr_if_id_out[7],instr_if_id_out[30:25],instr_if_id_out[11:8]};
    assign uimm=instr_if_id_out[31:12];
    assign jimm={instr_if_id_out[31],instr_if_id_out[19:12],instr_if_id_out[20],instr_if_id_out[30:21]};
   
    assign Op = instr_if_id_out[6:0];       // instruction
    assign Funct7 = instr_if_id_out[31:25]; // funct7
    assign Funct3 = instr_if_id_out[14:12]; // funct3F
    assign rs1 = instr_if_id_out[19:15];    // rs1
    assign rs2 = instr_if_id_out[24:20];    // rs2
    assign rd = instr_if_id_out[11:7];    // rd

    //冒险检测
    // wire stall_a; 
    // assign stall_a = (MemRead) & ((rd_ex_mem_out == rs1) | (rd_ex_mem_out == rs2));
    // assign stall = stall_a;


    ctrl U_ctrl(
        //input
        .Op(Op),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .Zero(Zero),
        //output
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .EXTOp(EXTOp),
        .ALUOp(ALUOp),
        .NPCOp(NPCOp),
        .ALUSrc(ALUSrc),
        .DMType(DMType),
        .WDSel(WDSel)
    );

    //实例化立即数生成模块
    wire [31:0] immout;
    EXT U_EXT(
        //input
        .iimm_shamt(iimm_shamt),
        .iimm(iimm),
        .simm(simm),
        .bimm(bimm),
        .uimm(uimm),
        .jimm(jimm),
        .EXTOp(EXTOp),
        //output
        .immout(immout)
    );


    //实例化ID_EX寄存器
    wire [31:0] pc_id_ex_out;
    wire [31:0] instr_id_ex_out;
    wire [31:0] imm_id_ex_out;
    wire [4:0]  rd_id_ex_out;
    wire [31:0] rs1_data_id_ex_out;
    wire [31:0] rs2_data_id_ex_out;

    wire RegWrite_id_ex_out;
    wire MemWrite_id_ex_out;
    wire    MemRead_id_ex_out;
   wire [5:0] EXTOp_id_ex_out;
   wire [4:0] ALUOp_id_ex_out;
   wire [2:0] NPCOp_id_ex_out;
   wire       ALUSrc_id_ex_out;
   wire [2:0] DMType_id_ex_out;
   wire [1:0] WDSel_id_ex_out;

    ID_EX U_ID_EX(
        //input
        .clk(clk),
        .rst(reset),
        .flush(flush),
        .RegWrite_id_ex_in(RegWrite),
        .MemWrite_id_ex_in(MemWrite),
        .MemRead_id_ex_in(MemRead),
        .EXTOp_id_ex_in(EXTOp),
        .ALUOp_id_ex_in(ALUOp),
        .NPCOp_id_ex_in(NPCOp),
        .ALUSrc_id_ex_in(ALUSrc),
        .DMType_id_ex_in(DMType),
        .WDSel_id_ex_in(WDSel),

        .pc_id_ex_in(pc_if_id_out),
        .instr_id_ex_in(instr_if_id_out),
        .imm_id_ex_in(immout),
        .rd_id_ex_in(rd),
        .rs1_data_id_ex_in(RD1),
        .rs2_data_id_ex_in(RD2),
        
        //output
        .pc_id_ex_out(pc_id_ex_out),
        .instr_id_ex_out(instr_id_ex_out),
        .imm_id_ex_out(imm_id_ex_out),
        .rd_id_ex_out(rd_id_ex_out),
        .rs1_data_id_ex_out(rs1_data_id_ex_out),
        .rs2_data_id_ex_out(rs2_data_id_ex_out),

        .RegWrite_id_ex_out(RegWrite_id_ex_out),
        .MemWrite_id_ex_out(MemWrite_id_ex_out),
        .MemRead_id_ex_out(MemRead_id_ex_out),
        .EXTOp_id_ex_out(EXTOp_id_ex_out),
        .ALUOp_id_ex_out(ALUOp_id_ex_out),
        .NPCOp_id_ex_out(NPCOp_id_ex_out), //*
        .ALUSrc_id_ex_out(ALUSrc_id_ex_out),
        .DMType_id_ex_out(DMType_id_ex_out),
        .WDSel_id_ex_out(WDSel_id_ex_out)
    );



//**********************************************************************
//Ex stage : adder, ALU, 处理跳转产生flush
    //EX数据冒险
    reg fwa,fwb;
    always @(*) begin
        if (RegWrite_mem_wb_out & (rd_mem_wb_out) & (rd_mem_wb_out == rs1))begin
            fwa = 2'b10;
        end 
        else begin
            fwa = 2'b00;
        end
        if(RegWrite_mem_wb_out & (rd_mem_wb_out) & (rd_mem_wb_out == rs1))begin
           fwb = 2'b10;
        end
        else begin
            fwb = 2'b00;
        end
    end
    //MEM数据冒险
    




   // wire [31:0] rs1_data_tmp,rs2_data_tmp;
   wire [31:0] rs2_imm_tmp;
   assign rs2_imm_tmp = (ALUSrc_id_ex_out)? imm_id_ex_out : rs2_data_id_ex_out;

    //实例化ALU
    // wire Zero;
    wire    [31:0] alu_out;
    alu U_ALU(
        //input
        .A(rs1_data_id_ex_out),
        .B(rs2_imm_tmp),
        .ALUOp(ALUOp_id_ex_out),
        //.pc_alu_in(pc_id_ex_out),
        .pc_alu_in(pc_id_ex_out),
        //output
        .C(alu_out),
        .Zero(Zero)
    );
    //处理branch指令
    reg [2:0] NPCOp_a;
    always @(*) begin
        NPCOp_a[0] <= NPCOp_id_ex_out[0] & Zero;
        NPCOp_a[1] <= NPCOp_id_ex_out[1];
        NPCOp_a[2] <= NPCOp_id_ex_out[2];

    end

    //实例化NPC
    NPC U_NPC(
        //input
        .PC(pc_id_ex_out),
        .NPCOp(NPCOp_a),
        .IMM(imm_id_ex_out),
        .ALU_out(alu_out),
        //output
        .NPC(NPC)
    );
    //产生flush信号处理跳转
    wire flush_a;
    assign flush_a = (NPCOp_id_ex_out[0] & Zero) | NPCOp_id_ex_out[1] | NPCOp_id_ex_out[2];
    assign flush = flush_a;
    
    //实例化EX_MEM寄存器
    wire [31:0] pc_ex_mem_out;
    wire [4:0]  rd_ex_mem_out;
    wire [31:0] alu_ex_mem_out;
    wire [31:0] addsum_ex_mem_out;
    wire [31:0] imm_ex_mem_out;
    wire [31:0] rs2_data_ex_mem_out;

    //控制信号输出
    wire      RegWrite_ex_mem_out;
    wire      MemWrite_ex_mem_out;
    wire [2:0] NPCOp_ex_mem_out;
    wire [2:0] DMType_ex_mem_out;
    wire  [1:0] WDSel_ex_mem_out;


    EX_MEM U_EX_MEM(
        //input
        .clk(clk),
        .rst(reset),
        .flush(flush),
        .zero_ex_mem_in(Zero),
        .pc_ex_mem_in(pc_id_ex_out),
        .rd_ex_mem_in(rd_id_ex_out),
        .addsum_ex_mem_in(NPC),
        .alu_ex_mem_in(alu_out),
        .rs2_data_ex_mem_in(rs2_data_id_ex_out),
        .imm_ex_mem_in(imm_id_ex_out),
        .RegWrite_ex_mem_in(RegWrite_id_ex_out),
        .MemWrite_ex_mem_in(MemWrite_id_ex_out),
        .NPCOp_ex_mem_in(NPCOp_id_ex_out),
        .DMType_ex_mem_in(DMType_id_ex_out),
        .WDSel_ex_mem_in(WDSel_id_ex_out),
        //output
        .pc_ex_mem_out(pc_ex_mem_out),
        .rd_ex_mem_out(rd_ex_mem_out),
        .alu_ex_mem_out(alu_ex_mem_out),
        .addsum_ex_mem_out(addsum_ex_mem_out),
        .imm_ex_mem_out(imm_ex_mem_out),
        .rs2_data_ex_mem_out(rs2_data_ex_mem_out),
        .RegWrite_ex_mem_out(RegWrite_ex_mem_out),
        .MemWrite_ex_mem_out(MemWrite_ex_mem_out),
        .NPCOp_ex_mem_out(NPCOp_ex_mem_out),
        .DMType_ex_mem_out(DMType_ex_mem_out),
        .WDSel_ex_mem_out(WDSel_ex_mem_out)
    );

    assign Data_out = rs2_data_ex_mem_out;
    assign mem_w = MemWrite_ex_mem_out;
    assign dm_ctrl = DMType_ex_mem_out;
    //给Addr_out赋值
    assign Addr_out = alu_ex_mem_out;





    //******************************************************************
    //MEM stage : 给rb_data赋值，
    wire [31:0] rb_data_in;
    wire [31:0] rb_data_pc;
    
    wire     [31:0] pc_mem_wb_out;
    wire [31:0] rdata_mem_wb_out;
    wire [31:0] alu_mem_wb_out;
    wire [31:0] imm_mem_wb_out;
    wire [4:0] rd_mem_wb_out;

    //控制输出
    wire RegWrite_mem_wb_out;
    wire  [1:0] WDSel_mem_wb_out;
    wire  [2:0] DMType_mem_wb_out;
    wire [31:0] Data_in_a;

    reg  [31:0] Data_in_new;
    always @(*) begin
        case (DMType_ex_mem_out)
            `dm_word : Data_in_new <= Data_in;
            `dm_halfword : Data_in_new <= {{16{Data_in[15]}},Data_in[15:0]}; 
            `dm_halfword_unsigned : Data_in_new <= {{16'b0},Data_in[15:0]}; 
            `dm_byte : Data_in_new <= {{24{Data_in[7]}},Data_in[7:0]}; 
            `dm_byte_unsigned : Data_in_new <= {24'b0,Data_in[7:0]}; 
            default: Data_in_new <= 31'b0;
        endcase
    end
    

    //实例化MEM_WB 寄存器
    MEM_WB U_MEM_WB(
        //input
        .clk(clk),
        .rst(reset),
        .flush(flush),
        .pc_mem_wb_in(pc_ex_mem_out),
        .rdata_mem_wb_in(Data_in_new),
        .alu_mem_wb_in(alu_ex_mem_out),
        .imm_mem_wb_in(imm_ex_mem_out),
        .rd_mem_wb_in(rd_ex_mem_out),
        .RegWrite_mem_wb_in(RegWrite_ex_mem_out),
        .WDSel_mem_wb_in(WDSel_ex_mem_out),
        .DMType_mem_wb_in(DMType_ex_mem_out),
        //output
        .pc_mem_wb_out(pc_mem_wb_out),
        .rdata_mem_wb_out(rdata_mem_wb_out),
        .alu_mem_wb_out(alu_mem_wb_out),
        .imm_mem_wb_out(imm_mem_wb_out),
        .rd_mem_wb_out(rd_mem_wb_out),
        .RegWrite_mem_wb_out(RegWrite_mem_wb_out),
        .WDSel_mem_wb_out(WDSel_mem_wb_out),
        .DMType_mem_wb_out(DMType_mem_wb_out)
    );


       
    assign rb_data_pc = (WDSel_mem_wb_out == `WDSel_FromPC) ? pc_mem_wb_out+4 : alu_mem_wb_out;
    assign rb_data_in = rdata_mem_wb_out;
    assign  rb_data =  (WDSel_mem_wb_out == `WDSel_FromMEM) ? rb_data_in : rb_data_pc;
    







endmodule
