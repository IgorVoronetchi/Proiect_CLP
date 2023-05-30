module autoModule #(
    parameter SECUNDE_VERDE = 10
    parameter DIV_FACTOR = 10
)(
    input rst_n,
    input clk,
    input enable,
    input clear,

    output rosu,
    output verde,
    output galben,
    output done

);
//Codare stari(dupa organigrama) FSM(MAS) 
localparam S_IDLE = 0;
localparam S_GALBEN = 1;
localparam S_VERDE = 2;
localparam S_DONE = 3;

//Semnale interne divizor frecventa
wire enable_div_frecv;
wire pulse_1_sec;

//CNT interne
reg[4:0] counter_verde; //de calculat alt numar de biti!!!! 28 sec , 5 biti?
reg[1:0] counter_galben; //2 secunde, folosim 2 biti

//Registrii pentru stare
reg[1:0] stare_curenta;
reg[1:0] stare_viitoare;

//MAS -  calea de control, masina de stare

//partea secventiala
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) stare_curenta <= S_IDLE;
    else stare_curenta <= stare_viitoare;
end

//partea combinationala
always @(*) begin
    case (stare_curenta)
    S_IDLE: if(enable) stare_viitoare <= S_GALBEN;
            else stare_viitoare <= S_IDLE; 
    S_GALBEN: if(counter_galben < 2) stare_viitoare <= S_GALBEN;
              else                        stare_viitoare <= S_VERDE;
    S_VERDE: if(counter_verde < SECUNDE_VERDE) stare_viitoare <= S_VERDE;
             else                            stare_viitoare <= S_DONE;
    S_DONE: if(clear)                        stare_viitoare <= S_IDLE;
    else                                     stare_viitoare <= S_DONE;
        default:                             stare_viitoare <= S_IDLE;
    endcase
end
////////////////////////////////////////////

//Instantiere divizor frecventa
divFrecv#(DIV_FACTOR) DIV_FRECVENTA (
.clk       (clk),
.rst_n     (rst_n),
.enable    (enable_div_frecv),
.clk_div   (pulse_1_sec)
);
////////////////////////////
// Modelare Counter Galben
always @(posedge clk or negedge rst_n) begin  ///always penttru ca avem registru
    if(~rst_n) counter_galben <=0;
    else if ((stare_curenta == S_GALBEN) & pulse_1_sec) counter_galben <= counter_galben + 1;
    else if(stare_curenta == S_IDLE) counter_galben <= 0; //am resetat   
end

///Modelare Counter Verde
always @(posedge clk or negedge rst_n) begin  ///always penttru ca avem registru
    if(~rst_n) counter_verde <=0;
    else if ((stare_curenta == S_VERDE) & pulse_1_sec) counter_verde <= counter_verde + 1;
    else if(stare_curenta == S_IDLE) counter_verde <= 0; //am resetat   
end

///Modelare enable div frecv
assign enable_div_frecv = (stare_curenta == S_GALBEN) | (stare_curenta == S_VERDE);//bug

// modelarea iesirii
assign verde = (stare_curenta == S_VERDE);
assign galben = (stare_curenta == S_GALBEN);
assign rosu = ((stare_curenta == S_DONE) | (stare_curenta== S_IDLE)); 
endmodule