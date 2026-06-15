// ============================================================
// TOP MODULE - Robot Móvil con FPGA DE10-Lite (CORREGIDO)
// ============================================================

module top_module (
    // ===== ENTRADAS DEL SISTEMA =====
    input  wire        MAX10_CLK1_50,
    input  wire [1:0]  KEY,
    input  wire [9:0]  SW,
    
    // ===== DISPLAYS 7-SEGMENTOS =====
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5,
    
    // ===== LEDs =====
    output wire [9:0]  LEDR,
    
    // ===== UART: COMUNICACIÓN CON ARDUINO =====
    input  wire        UART_RX_PIN,
    output wire        UART_TX_PIN
);

    // ===== SEÑALES INTERNAS =====
    wire        clk;
    wire        rst_n;
    wire [7:0]  rx_data;
    wire        rx_ready;
    wire        tx_busy;
    wire [7:0]  comando;
    wire        enviar_cmd;
    wire [2:0]  estado;
    reg  [7:0]  distancia_reg;
    
    // ===== ASIGNACIONES =====
    assign clk   = MAX10_CLK1_50;
    assign rst_n = KEY[0];
    
    // ===== GUARDAR ÚLTIMA DISTANCIA =====
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            distancia_reg <= 8'd200;
        else if (rx_ready)
            distancia_reg <= rx_data;
    end
    
    // ===== INSTANCIAR MÓDULOS =====
    
    // 1. UART Receiver
    uart_rx u_rx (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx        (UART_RX_PIN),
        .data_out  (rx_data),
        .data_ready(rx_ready)
    );
    
    // 2. UART Transmitter
    uart_tx u_tx (
        .clk     (clk),
        .rst_n   (rst_n),
        .data_in (comando),
        .send    (enviar_cmd),
        .tx      (UART_TX_PIN),
        .busy    (tx_busy)
    );
    
    // 3. FSM Principal
    fsm_robot u_fsm (
        .clk          (clk),
        .rst_n        (rst_n),
        .distancia    (distancia_reg),
        .dato_nuevo   (rx_ready),
        .comando      (comando),
        .enviar_cmd   (enviar_cmd),
        .estado_actual(estado)
    );
    
    // 4. Display 7-Segmentos
    seven_seg_display u_display (
        .estado   (estado),
        .distancia(distancia_reg),
        .HEX0     (HEX0),
        .HEX1     (HEX1),
        .HEX2     (HEX2),
        .HEX3     (HEX3),
        .HEX4     (HEX4),
        .HEX5     (HEX5)
    );
    
    // ===== LEDs: Barra de distancia =====
    assign LEDR[0] = (distancia_reg < 8'd10);
    assign LEDR[1] = (distancia_reg < 8'd20);
    assign LEDR[2] = (distancia_reg < 8'd30);
    assign LEDR[3] = (distancia_reg < 8'd50);
    assign LEDR[4] = (distancia_reg < 8'd70);
    assign LEDR[5] = (distancia_reg < 8'd90);
    assign LEDR[6] = (distancia_reg < 8'd110);
    assign LEDR[7] = (distancia_reg < 8'd130);
    assign LEDR[8] = (distancia_reg < 8'd150);
    assign LEDR[9] = rx_ready;

endmodule
