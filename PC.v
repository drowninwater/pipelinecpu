`include "ctrl_encode_def.v"

module PC( clk, rst, stall, NPCOp, NPC, PC );

  input              clk;
  input              rst;
  input              stall;
  input        [2:0] NPCOp;
  input       [31:0] NPC;
  output reg  [31:0] PC;

  wire [31:0] PC_PLUS4;
  assign PC_PLUS4 = PC+4;

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h00000000;
    else begin 
      if(stall == 1'b1)
        PC <= PC;
      else if(NPCOp == 3'b000)
        PC <= PC_PLUS4;
      else PC <= NPC;
    end
    
endmodule