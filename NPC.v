`include "ctrl_encode_def.v"

module NPC(PC, NPCOp, IMM, ALU_out, NPC);

    input       [31:0] PC;
    input       [2:0]  NPCOp;
    input       [31:0] IMM;    //jump instr's imm will be extended to 31 bits
    input       [31:0] ALU_out;
    output reg  [31:0] NPC;

    wire       [31:0] PC_plus4;
    assign PC_plus4 = PC + 4;

    always @(*)begin
      case (NPCOp)
        `NPC_PLUS4: NPC <= PC_plus4; 
        `NPC_BRANCH: NPC <= PC + IMM;
        `NPC_JUMP:   NPC <= PC + IMM;
        `NPC_JALR:   NPC <= ALU_out;
        default: NPC <= PC_plus4;
      endcase
    end
endmodule