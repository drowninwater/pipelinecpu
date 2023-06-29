`include "ctrl_encode_def.v"

// module dm(pc,clk, DMWr, addr, din, dout);
//    input [31:0] pc;  
//    input          clk;
//    input          DMWr;
//    input  [31:0]   addr;
//    input  [31:0]  din;
//    output [31:0]  dout;
     
//    reg [31:0] dmem[1024:0];
   
//    always @(posedge clk)
//       if (DMWr) begin
//          dmem[addr[8:2]] <= din;
//         //$display("dmem[0x%8X] = 0x%8X,", addr << 2, din); 
//         //$display("pc = %h: dataaddr = %h, memdata = %h", pc,{addr [31:2],2'b00}, din);
//       end
   
//    assign dout = dmem[addr[8:2]];
    
// endmodule    

module dm(
    input       clk,
    input   [3:0] wea,
    input   [3:0] DMType,
    input   [31:0] addr_in,
    input   [31:0] data_in,
    output reg [31:0] data_out
);

    reg [7:0] dmem[1023:0];
    always @(posedge clk) begin
         
            
        
    end
    


endmodule