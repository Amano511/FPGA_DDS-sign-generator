module key_debounce (
    input wire clk,           // 系统时钟，如 50MHz
    input wire rst_n,         // 异步复位
    input wire key_in,        // 原始按键输入（低有效）
    output reg key_neg_edge   // 输出：下降沿脉冲，1个周期宽
);

    reg key_sync_0, key_sync_1;
    reg [19:0] cnt;           // 20ms @ 50MHz = 1_000_000个周期
    reg key_flag;
    wire stable_low;

    // 1. 两级同步（避免亚稳态）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_sync_0 <= 1'b1;
            key_sync_1 <= 1'b1;
        end else begin
            key_sync_0 <= key_in;
            key_sync_1 <= key_sync_0;
        end
    end

    // 2. 判断是否稳定为低（按下）
    assign stable_low = (cnt == 20'd1_000_000);  // 约 20ms

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 20'd0;
            key_flag <= 1'b0;
        end else if (key_sync_1 == 1'b0) begin  // 检测到低电平
            if (cnt < 20'd1_000_000)
                cnt <= cnt + 1'b1;
            else
                key_flag <= 1'b1;  // 表示已稳定按下
        end else begin
            cnt <= 20'd0;
            key_flag <= 1'b0;
        end
    end

    // 3. 边沿检测（按下时产生一个脉冲）
    reg key_flag_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            key_flag_d <= 1'b0;
        else
            key_flag_d <= key_flag;
    end

    always @(*) begin
        key_neg_edge = (key_flag && !key_flag_d);
    end

endmodule
