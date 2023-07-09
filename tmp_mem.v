module MEM(
    input   clk,
    input   rst,
    input [31:0]    raw_Data_in,
    input [2:0] dm_ctrl,
    input [1:0] bias,

    input   RegWrite_in,
    input [4:0] rd_in,
    input [1:0] WDSel_in,
    input [31:0]    WD_in,

    output reg  RegWrite,
    output reg [4:0]    rd,
    output reg [31:0]   WD
    );

    reg [31:0] dtmp;
    reg [31:0] WD_w;
    reg [31:0] Data_in;

    always @(*) begin
        dtmp <= raw_Data_in;

        case (dm_ctrl)
            `dm_word: begin
                Data_in <= dtmp;
            end
            
            `dm_halfword: begin
                Data_in <= {{16{dtmp[15]}}, dtmp[15:0]};
            end

            `dm_byte: begin
                Data_in <= {{24{dtmp[7]}}, dtmp[7:0]};
            end

            `dm_halfword_unsigned: begin
                Data_in <= {16'b0, dtmp[15:0]};
            end

            `dm_byte_unsigned: begin
                Data_in <= {24'b0, dtmp[7:0]};
            end
            default Data_in <= 32'b0;
        endcase

        WD_w <= (WDSel_in == `WDSel_FromMEM) ? Data_in : WD_in;
    end
    
    always @(posedge clk) begin
        RegWrite <= RegWrite_in;
        rd <= rd_in;
        WD <= WD_w;
    end
endmodule
