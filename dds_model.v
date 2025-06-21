module dds_model
    (   
    input  dac_clk,                     // DAC 时钟，如 50MHz
    input  rst_n,                   // 异步复位
    input [31:0] Fword,            // 频率控制字
    input [1:0]wave_change_index,  //波形变换变量，0=正弦，1=方波,2=三角波
    output  reg [7:0] dac_data,      // 输出波形数据
    output  ad9708_clk              //DA clock
    );

    wire [8:0]        rom_addr;                //rom address
    reg [31:0]       phase_acc;
    
    
    assign ad9708_clk = dac_clk;
    assign rom_addr = phase_acc[31:23]; // 512点ROM
    
    
    always @(posedge dac_clk or negedge rst_n) begin
        if (!rst_n)
            phase_acc <= 32'd0;
        else begin
            phase_acc <= phase_acc + Fword;
        end        
    end
    
    always @(posedge dac_clk) begin
        case (wave_change_index)
            2'd0 : dac_data <= sin_data;
            2'd1 : dac_data <= squ_data;
            2'd2 : dac_data <= tri_data;
            default : dac_data <= 8'b0;
        endcase
    end

   
    wire [7:0] sin_data,squ_data,tri_data;
    
    
    da_rom da_rom_m0 //正弦波
    (
    .clka                           (ad9708_clk               ),  
    .ena                            (1'b1                     ),     
    .addra                          (rom_addr                 ), 
    .douta                          (sin_data                 )  
    );
    
    da_rom_duty50 da_rom_m1 //方波
    (
    .clka                           (ad9708_clk               ),  
    .ena                            (1'b1                     ),     
    .addra                          (rom_addr                 ), 
    .douta                          (squ_data                 )  
    );
    
    da_rom_tri da_rom_m2 //三角波
    (
    .clka                           (ad9708_clk               ),  
    .ena                            (1'b1                     ),     
    .addra                          (rom_addr                 ), 
    .douta                          (tri_data                 )  
    );

endmodule


