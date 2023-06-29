`include "D:\Inclass\B_II\computer_organization\pipeline_cpu\ImmGen.v"

module ID(
    input       clk,
    input       rst,
    input   [31:0] pc_id_st_in,
    input   [31:0] instr_id_st_in,

    //output
	output [6:0] opcode_id_out,
	output [2:0] func3_id_out,
	output [6:0] func7_id_o,
    output  [4:0] rs1_id_o,
    output  [4:0] rs2_id_o,
    output  [4:0] rd_id_o;
    output [31:0] imme_id_o,
    output      ALUsrc_id_out,
    output  [4:0] ALUOp_id_out
);
//分析指令格式并从ctrl中提取EXTOp信号
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;      // funct7
    wire [2:0]  Funct3;      // funct3

    wire        RegWrite_a;
    wire        MemWrite_a; 

    wire [5:0]  EXTOp_a;       // 立即数提取信号
    wire [4:0]  ALUOp_a;
    wire [2:0]  NPCOp_a;
    wire        ALUSrc_a; // ALU 输入值 B 的来源
    wire [2:0]  DMType_a;     
    wire [1:0]  GPRSel_a;      // general purbiase register selection (unused)

    assign Op = instr_id_st_in[6:0];       // instruction
    assign Funct7 = instr_id_st_in[31:25]; // funct7
    assign Funct3 = instr_id_st_in[14:12]; // funct3
    assign rs1_id_o <= instr_if_st_in[19:15];
    assign rs2_id_o <= instr_if_st_in[24:20];
    assign rd_id_o <= instr_if_st_in[11:7];

    ctrl U_ctrl(
        // input
        .Op(Op), .Funct7(Funct7), .Funct3(Funct3),
        // output
        .RegWrite(RegWrite_a), .MemWrite(MemWrite_a),
        .EXTOp(EXTOp), .ALUOp(ALUOp_a), .NPCOp(NPCOp_a), 
        .ALUSrc(ALUSrc_a), .GPRSel(GPRSel_a), .WDSel(WDSel_a), .DMType(DMType_a),
        .type(type_a)
    );
// .use_rs1(use_rs1), .use_rs2(use_rs2)


//分析指令中的立即数，为EXT模块传数据,并提取
    wire [4:0]  iimm_shamt;
    wire [11:0] iimm,simm,bimm;
    wire [19:0] uimm,jimm;
    wire [5:0]  EXTOp;       // 立即数提取信号
    wire [31:0] immout_a;

    assign iimm_shamt=instr_id_st_in[24:20];
    assign iimm=instr_id_st_in[31:20];
    assign simm={instr_id_st_in[31:25],instr_id_st_in[11:7]};
    assign bimm={instr_id_st_in[31],instr_id_st_in[7],instr_id_st_in[30:25],instr_id_st_in[11:8]};
    assign uimm=instr_id_st_in[31:12];
    assign jimm={instr_id_st_in[31],instr_id_st_in[19:12],instr_id_st_in[20],instr_id_st_in[30:21]};

    ImmGen U_EXT(
    .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
    .uimm(uimm), .jimm(jimm),
    .EXTOp(EXTOp), .immout(immout_a)
    );

    always @(posedge clk or negedge rstn) begin
        if(rst) begin
          ALUOp <= 32'b0;
          //
          pc_if_st_out <= 32'b0;
          imme_id_o <= 32'b0;
          NPCOp <= 32'b0;

          //
          MemWrite <= 1'b0;
          ALUsrc_id_out <= 1'b0;
          DMType <= 3'b0;
          
          //
          RegWrite <= 1'b0;
          WDSel <= 2'b0;
        end
        else begin
            ALUOp <= ALUOp_a;

            pc_if_st_out <= pc_if_st_in;
            imme_id_o <= immout_a;
            //NPCOp <= (stall === 1'b1) ? 3'b0 : NPCOp_a;
            NPCOp <= NPCOp_a;
            ALUsrc_id_out <= ALUSrc_a;

            //MemWrite <= (stall === 1'b1) ? 1'b0 : MemWrite_w;
            MemWrite <= MemWrite_a;
            DMType <= DMType_a;

            // RegWrite <= (stall === 1'b1) ? 1'b0 : RegWrite_w;
            RegWrite <= RegWrite_a;
            WDSel <= WDSel_a;
        end
    end

endmodule