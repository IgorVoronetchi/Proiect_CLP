module pietoni_Module #(
    parameter SECUNDE_VERDE_INTERMITENT = 6, 
    parameter SECUNDE_VERDE = 12, 
    parameter DIV_FACTOR_SEC = 10
) (
    input clk,
    input rst_n,
    input enable,
    input clear,

    output rosu,
    output verde,
    output done 
);
    
localparam S_IDLE = 0;
localparam S_VERDE = 1 ;
localparam S_VERDE_INTERMITENT = 2 ;
//localparam S_ROSU = 3 ;
localparam S_DONE = 3 ;

//Semnale interne divizor frecventa
wire enable_div_frecv;
wire pulse_1_sec;

//Registrii pentru stare
reg[1:0] stare_curenta;
reg[1:0] stare_viitoare;

//Countere verde verde intermitent
reg[3:0] counter_verde; // 12 sec, 4 biti
reg[2:0] counter_verde_intermitent;//6 sec, 3 biti


//partea secventiala
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) stare_curenta <= S_IDLE;
    else stare_curenta <= stare_viitoare;
end

//partea combinationala
always @(*) begin
    case (stare_curenta)
    S_IDLE: if(enable)                                                 stare_viitoare <= S_VERDE;
            else                                                       stare_viitoare <= S_IDLE; 
    S_VERDE: if(counter_verde < 12)                                    stare_viitoare <= S_VERDE;
              else                                                     stare_viitoare <= S_VERDE_INTERMITENT;
    S_VERDE_INTERMITENT: if(counter_verde_intermitent < SECUNDE_VERDE_INTERMITENT) stare_viitoare <= S_VERDE_INTERMITENT;
             else                                                      stare_viitoare <= S_DONE;
    S_DONE: if(clear)                                                  stare_viitoare <= S_IDLE;                     
    else                                                               stare_viitoare <= S_DONE;
        default:                                                       stare_viitoare <= S_IDLE;                            
    endcase
end


// Modelare COUNTER Verde
always @(posedge clk or negedge rst_n) begin  
    if(~rst_n) counter_verde <=0;
    else if ((stare_curenta == S_VERDE) & pulse_1_sec) counter_verde <= verde + 1;
    else if(stare_curenta == S_IDLE) counter_verde <= 0; //am resetat   
end

///Modelare Counter Verde-intermitent
always @(posedge clk or negedge rst_n) begin  
    if(~rst_n) counter_verde_intermitent <=0;
    else if ((stare_curenta == S_VERDE_INTERMITENT) & pulse_1_sec) counter_verde_intermitent <= counter_verde_intermitent + 1;
    else if(stare_curenta == S_IDLE) counter_verde_intermitent <= 0; //am resetat   
end

///Modelare enable div frecv
assign enable_div_frecv = (stare_curenta == S_VERDE_INTERMITENT) | (stare_curenta == S_VERDE);//bug

// modelarea iesirii
assign verde = (stare_curenta == S_VERDE);
assign verde_intermitent = (stare_curenta == S_VERDE_INTERMITENT);
assign rosu = ((stare_curenta == S_DONE) | (stare_curenta== S_IDLE)); 



//Instantiere divizor frecventa
divFrecv #(DIV_FACTOR_SEC) DIV_FRECVENTA (
.clk       (clk),
.rst_n     (rst_n),
.enable    (enable_div_frecv),
.clk_div   (pulse_1_sec)
);

endmodule