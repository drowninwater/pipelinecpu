// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
// Date        : Tue Jun 20 11:12:44 2023
// Host        : LAPTOP-E4IJ843E running 64-bit major release  (build 9200)
// Command     : write_verilog -mode synth_stub C:/Users/user/Desktop/projects/edf_file/dm_controller.v
// Design      : dm_controller
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.

`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100
module dm_controller(mem_w, Addr_in, Data_write, dm_ctrl, 
  Data_read_from_dm, Data_read, Data_write_to_dm, wea_mem)
/* synthesis syn_black_box black_box_pad_pin="mem_w,Addr_in[31:0],Data_write[31:0],dm_ctrl[2:0],Data_read_from_dm[31:0],Data_read[31:0],Data_write_to_dm[31:0],wea_mem[3:0]" */;
  input mem_w;
  input [31:0]Addr_in;
  input [31:0]Data_write;
  input [2:0]dm_ctrl;
  input [31:0]Data_read_from_dm;
  output reg [31:0]Data_read;
  output reg [31:0]Data_write_to_dm;
  output reg [3:0]wea_mem;
  
  always@(*)
  //write
    if(mem_w == 1'b1)begin 
        case(dm_ctrl)
            `dm_word:begin
                wea_mem <= 4'b1111;
                Data_write_to_dm <= Data_write;
              end
              
             `dm_halfword:begin 
                if(Addr_in[1] == 1'b0)begin   //write the lower halfword
                    wea_mem <= 4'b0011;
                    Data_write_to_dm[15:0] <= Data_write[15:0];   
                end
                if(Addr_in[1] == 1'b1)begin 
                    wea_mem <= 4'b1100;
                    Data_write_to_dm[31:16] <= Data_write[15:0];
                end
             end
             
             `dm_halfword_unsigned:begin 
                 if(Addr_in[1] == 1'b0)begin   //write the lower halfword
                    wea_mem <= 4'b0011;
                    Data_write_to_dm <= Data_write[15:0];   
                end
                if(Addr_in[1] == 1'b1)begin   //write the higher halfword
                    wea_mem <= 4'b1100;
                    Data_write_to_dm <= Data_write[31:16];
                end
             end
             
             `dm_byte:begin 
                if(Addr_in[1:0] == 2'b00)begin 
                    wea_mem <= 4'b0001;
                    Data_write_to_dm[7:0] <= Data_write[7:0];
                end
                if(Addr_in[1:0] == 2'b01)begin 
                    wea_mem <= 4'b0010;
                    Data_write_to_dm[15:8] <= Data_write[7:0];
                end
                if(Addr_in[1:0] == 2'b10)begin 
                    wea_mem <= 4'b0100;
                    Data_write_to_dm[23:16] <= Data_write[7:0];
                end
                if(Addr_in[1:0] == 2'b11)begin 
                    wea_mem <= 4'b1000;
                    Data_write_to_dm[31:24] <= Data_write[7:0];
                end
             end
    endcase
end
//read
//  input [31:0]Data_read_from_dm;
  //output reg [31:0]Data_read

    else if(mem_w == 1'b0)begin 
        case(dm_ctrl) 
            `dm_word:begin 
                Data_read <= Data_read_from_dm;
            end
            
            `dm_halfword:begin 
                if(Addr_in[1] == 1'b0)begin   //read the lower halfword
                    Data_read <= {{16{Data_read_from_dm[15]}},{Data_read_from_dm[15:0]}};   
                end
                if(Addr_in[1] == 1'b1)begin 
                    Data_read <= {{16{Data_read_from_dm[31]}},{Data_read_from_dm[31:16]}}; //read higher halfword
                end
            end
            
            `dm_halfword_unsigned:begin 
                 if(Addr_in[1] == 1'b0)begin   //read the lower halfword
                    Data_read <= {16'b0,{Data_read_from_dm[15:0]}};   
                end
                if(Addr_in[1] == 1'b1)begin   //read higher halfword
                    Data_read <= {16'b0,{Data_read_from_dm[31:16]}};
                end
            end
            
            `dm_byte:begin 
                case(Addr_in[1:0])
                    4'b0001:begin 
                        Data_read <= {{24{Data_read_from_dm[7]}},{Data_read_from_dm[7:0]}}; 
                    end
                    4'b0010:begin 
                        Data_read <= {{24{Data_read_from_dm[15]}},{Data_read_from_dm[15:8]}};
                    end
                    4'b0100:begin 
                        Data_read <= {{24{Data_read_from_dm[23]}},{Data_read_from_dm[23:16]}};
                    end
                    4'b1000:begin 
                        Data_read <= {{24{Data_read_from_dm[31]}},{Data_read_from_dm[31:24]}};
                    end
                endcase
            end
            
            `dm_byte_unsigned:begin 
                case(Addr_in[1:0]) 
                    4'b0001:begin 
                        Data_read <= {24'b0,{Data_read_from_dm[7:0]}};
                    end
                    4'b0010:begin 
                        Data_read <= {24'b0,{Data_read_from_dm[15:8]}};
                    end
                    4'b0100:begin 
                        Data_read <= {24'b0,{Data_read_from_dm[23:16]}};
                    end
                    4'b1000:begin 
                        Data_read <= {24'b0,{Data_read_from_dm[31:24]}};
                    end
                endcase
                
            end
        endcase
    end
 
endmodule
