module general_FSM #(
    parameter DIV_FACTOR = 10)
    (
    input clk,
    input rst_n,
    input service_btn,
    input enable,
    
    output done_sud,
    output done_est,
    output done_vest,
    output done_nord,
    output done_pietoni,
    
    input clear_nord,
    input clear_vest,
    input clear_est,
    input clear_sud,
    input clear_pietoni,

    output enable_sud,
    output enable_est,
    output enable_vest,
    output enable_nord,
    output enable_pietoni,
    output enable_service

);

//codare stari
localparam S_IDLE = 3'b000 ;
localparam S_SUD = 3'b001 ;
localparam S_EST = 3'b010 ;
localparam S_VEST = 3'b011 ;
localparam S_NORD = 3'b100;
localparam S_PIETONI = 3'b101;
localparam S_SERVICE = 3'b110;
localparam S_ALL_RED = 3'b111;

////Registrii pentru stare
reg[1:0] stare_curenta;
reg[1:0] stare_viitoare;

//counter stare to stare

reg[4:0] cnt;
 

//partea secventiala
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) stare_curenta <= S_IDLE;
    else stare_curenta <= stare_viitoare;
end

//Semnale interne divizor frecventa
wire enable_div_frecv;
wire pulse_1_sec;

//partea combinationala

always @(*) begin
    case (stare_curenta)
      S_IDLE :if(enable_sud)    begin             stare_viitoare <= S_SUD;    
                                             //done_sud = 1;
      end   
             else stare_viitoare <= S_IDLE;              

      S_SUD : if(done_sud && enable_sud)     begin  stare_viitoare <= S_PIETONI;
                                              // done_pietoni = 1; 
      end
              else                             stare_viitoare <= S_SUD;

      S_PIETONI : if(done_pietoni && done_sud && enable_pietoni) begin stare_viitoare <= S_EST;
                                                                 //done_est = 1;
      end
              else                                               stare_viitoare <= S_PIETONI;

      S_EST : if(done_est && enable_est)     begin  stare_viitoare <= S_PIETONI;
                                               //done_pietoni <= 1;
      end
               else                            stare_viitoare <= S_EST;

      S_PIETONI: if(done_pietoni && done_est && enable_pietoni) begin stare_viitoare <= S_VEST;
                                                              //   done_vest = 1;
      end
                 else                                            stare_viitoare <= S_PIETONI;  

      S_VEST : if(done_vest && enable_vest) begin   stare_viitoare <= S_PIETONI;
                                             //  done_pietoni = 1;
      end
                else                           stare_viitoare <= S_VEST;

      S_PIETONI :if(done_pietoni && done_vest && enable_pietoni) begin stare_viitoare <= S_NORD;
                                                               //  done_nord = 1;
      end
                else                                             stare_viitoare <= S_PIETONI;

      S_NORD :if(done_nord && enable_nord)  begin   stare_viitoare <= S_PIETONI;
                                            //   done_pietoni = 1;
      end
                else                           stare_viitoare <= S_NORD;
//?
      S_PIETONI:if(done_pietoni && done_nord && enable_pietoni) begin stare_viitoare <= S_SERVICE;
                                                              //   done_pietoni = 1;
      end
                else                                             stare_viitoare <= S_PIETONI;

      S_SERVICE: if(done_pietoni && enable_service)     begin         stare_viitoare <= S_ALL_RED;
                                                                   //   service_btn = 1;
                                                                //  done_pietoni = 1;
      end
                else if(service_btn == 0)                       stare_viitoare <= S_IDLE;
                else                                            stare_viitoare <= S_SERVICE;

      S_ALL_RED: if(done_pietoni && service_btn)                stare_viitoare <= S_SERVICE;
                else                                            stare_viitoare <= S_ALL_RED;                   
       
               
        default: stare_viitoare <= S_IDLE;
    endcase
     
    
end

 always @(posedge clk or rst_n) begin
    if(~rst_n)  cnt <= 0;
    else if(stare_curenta == S_ALL_RED && pulse_1_sec) cnt <= cnt + 1;
    else if(stare_curenta == S_IDLE) cnt <= 0;
end

//
assign done_sud = (stare_curenta == S_SUD);
assign done_est = (stare_curenta == S_EST);
assign done_vest = (stare_curenta == S_VEST);
assign done_nord = (stare_curenta == S_NORD);
assign done_pietoni = (stare_curenta == S_PIETONI);

//
assign enable_nord = (stare_curenta == S_NORD);
assign enable_sud  = (stare_curenta == S_SUD);
assign enable_est  = (stare_curenta == S_EST);
assign enable_vest = (stare_curenta == S_VEST);
assign enable_pietoni = (stare_curenta == S_PIETONI);
assign enable_service = (stare_curenta == S_SERVICE);

assign clear_est = ((stare_curenta == S_EST) & ~enable_est) | (stare_curenta == S_IDLE);
assign clear_vest = ((stare_curenta == S_VEST) & ~enable_vest) | (stare_curenta == S_IDLE);
assign clear_nord = ((stare_curenta == S_NORD) & ~enable_nord) | (stare_curenta == S_IDLE);
assign clear_sud =((stare_curenta == S_SUD) & ~enable_sud) | (stare_curenta == S_IDLE);
assign clear_pietoni = ((stare_curenta == S_PIETONI) & ~enable_pietoni) | (stare_curenta == S_IDLE);



assign  enable_div_frecv = (stare_curenta == S_ALL_RED);


//Instantiere divizor frecventa
divFrecv #(DIV_FACTOR) DIV_FRECVENTA(
.clk       (clk),
.rst_n     (rst_n),
.enable    (enable_div_frecv),
.clk_div   (pulse_1_sec)
);

endmodule