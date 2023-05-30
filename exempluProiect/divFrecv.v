module divFrecv #(
    parameter DIV_FACTOR = 10
)(
    input clk,
    input rst_n,
    input enable,

    output clk_div
);
    reg[31:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) cnt <= 0;
        else if(enable)
        begin 
            if(cnt <= DIV_FACTOR) cnt <= cnt +1;
            else cnt <=0;
        end
        
    end

assign clk_div = (cnt ==DIV_FACTOR);//
endmodule