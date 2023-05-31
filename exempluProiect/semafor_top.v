module semafor_top (
    input clk,
    input rst_n,
    input service_btn,

    output verde_sud,
    output galben_sub,
    output rosu_sud,

    output verde_est,
    output galben_est,
    output rosu_est,

    output verde_vest,
    output galben_vest,
    output rosu_vest,

    output verde_nord,
    output galben_nord,
    output rosu_nord,

    output verde_pietoni,
    output rosu_pietoni

);
    
localparam DIV_FACTOR = 10000000;

//parametrii proiect
localparam SECUNDE_VERDE_SUD                 = 28;
localparam SECUNDE_VERDE_EST                 = 25;
localparam SECUNDE_VERDE_VEST                = 25;
localparam SECUNDE_VERDE_NORD                = 23;
localparam SECUNDE_VERDE_PIETONI             = 12;
localparam SECUNDE_VERDE_INTERMITENT_PIETONI = 6;

wire service_btn_debounce;

drv_btn DEBOUNCE(
    .clk (clk),
    .rst_n (rst_n),
    .data_i(service_btn),
    .data_o(service_btn_debounce)
);

pietoni_Module #(
    .SECUNDE_VERDE_INTERMITENT(SECUNDE_VERDE_INTERMITENT_PIETONI),
    .SECUNDE_VERDE(SECUNDE_VERDE_PIETONI),
    .DIV_FACTOR_SEC(DIV_FACTOR))
    MODUL_PIETONI(
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable_pietoni),
        .clear(clear_pietoni),
        .done(done_pietoni),
        .rosu(rosu_pietoni),
        .verde(verde_pietoni)

    );


    general_FSM #(DIV_FACTOR) GENERAL_FSM(
        .clk(clk),
        .rst_n(rst_n),
        .service_btn(service_btn_debounce),
        .done_nord(done_nord),
        .done_est(done_est),
        .done_sud(done_sud),
        .done_vest(done_vest),
        .done_pietoni(done_pietoni),
        .enable_nord(enable_nord),
        .enable_sud(enable_sud),
        .enable_vest(enable_vest),
        .enable_est(enable_est),
        .enable_pietoni(enable_pietoni),
        .enable_service(enable_service),
        .clear_est(clear_est),
        .clear_vest(clear_vest),
        .clear_nord(clear_nord),
        .clear_sud(clear_sud),
        .clear_pietoni(clear_pietoni)

    );
   autoModule #(SECUNDE_VERDE_SUD,DIV_FACTOR) MODUL_SUD(
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable_sud),
        .clear(clear_sud),
        .done(done_sud),
        .rosu(rosu_sud),
        .verde(verde_sud),
        .galben(galben_sud)
    );
     autoModule #(SECUNDE_VERDE_EST,DIV_FACTOR) MODUL_EST(
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable_est),
        .clear(clear_est),
        .done(done_est),
        .rosu(rosu_est),
        .verde(verde_est),
        .galben(galben_est)
    );
     autoModule #(SECUNDE_VERDE_VEST,DIV_FACTOR) MODUL_VEST(
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable_vest),
        .clear(clear_vest),
        .done(done_vest),
        .rosu(rosu_vest),
        .verde(verde_vest),
        .galben(galben_vest)
    );
     autoModule #(SECUNDE_VERDE_NORD,DIV_FACTOR) MODUL_NORD(
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable_nord),
        .clear(clear_nord),
        .done(done_nord),
        .rosu(rosu_nord),
        .verde(verde_nord),
        .galben(galben_nord)
    );
endmodule