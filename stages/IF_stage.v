

module IF_stage(
    input       clk,
    input       rst,
    input       stall,
    input       flush,
    input   [31:0] pc_if_st_in,
    input   [31:0] instr_if_st_in,

    output  reg [31:0] pc_if_st_out,
    output  reg [31:0] instr_if_st_out

);

    always @(posedge clk, posedge rst) begin
        if (rst || flush) begin
            pc_if_st_out <= 32'b0;
            instr_if_st_out <= 32'b0;
        end
        else begin
            if (!(stall === 1'b1)) begin // 处理停顿
                pc_if_st_out <= pc_if_st_in;
                instr_if_st_out <= instr_if_st_in;
            end
        end
    end

endmodule