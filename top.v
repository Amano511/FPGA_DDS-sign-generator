module top  
    (
    input sys_clk,//可以自行更改
    input rst_n,
    input key1_plus_1kHz,
    input key2_minus_1kHz,
    input key3_change_wave,
    output [7:0] ad9708_data,
    output  ad9708_clk
    );
    wire [31:0] Fword_1kHz;
    assign Fword_1kHz = 32'd85899;
    reg [31:0] Fword;
    reg [1:0]wave_change_index;
    
    dds_model DDS_sin_1kHz
    (   
    .dac_clk(sys_clk),                     // DAC 时钟，如 50MHz
    .rst_n(rst_n),                   // 异步复位
    .Fword(Fword),            // 频率控制字
    .dac_data(ad9708_data),      // 输出波形数据
    .ad9708_clk(ad9708_clk),          //DA clock
    .wave_change_index(wave_change_index)
    ); 
    
    
    /******按键切换功能*******/
    wire key1_edge, key2_edge, key3_edge;
    key_debounce u_key1 (
    .clk(sys_clk),
    .rst_n(rst_n),
    .key_in(key1_plus_1kHz),
    .key_neg_edge(key1_edge)
    );
    key_debounce u_key2 (
    .clk(sys_clk),
    .rst_n(rst_n),
    .key_in(key2_minus_1kHz),
    .key_neg_edge(key2_edge)
    );
    key_debounce u_key3 (
    .clk(sys_clk),
    .rst_n(rst_n),
    .key_in(key3_change_wave),
    .key_neg_edge(key3_edge)
    );

    /******时序功能****/
    always @(posedge sys_clk or negedge rst_n) 
    begin
        if (!rst_n) begin
            Fword <= 32'd85899;  // 默认1kHz
            wave_change_index <= 2'd0; //默认输出正弦波
        end
        else begin
            if (key1_edge)
                Fword <= Fword + 32'd85899;
            else if (key2_edge)
                Fword <= Fword - 32'd85899;
            else if (key3_edge) begin
                case (wave_change_index)
                    2'd0 : wave_change_index <= 2'd1;
                    2'd1 : wave_change_index <= 2'd2;
                    2'd2 : wave_change_index <= 2'd0;
                    default : wave_change_index <= 2'd0;
                endcase
            end
        end
    end
endmodule
