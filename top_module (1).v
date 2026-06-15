// ============================================================
// TOP MODULE - Robot Móvil con FPGA DE10-Lite
// ============================================================
// Conecta todos los módulos:
//   - UART RX (recibe distancia del Arduino)
//   - UART TX (envía comandos al Arduino)
//   - FSM (decide qué hacer)
//   - 7-Seg Display (muestra estado y distancia)
//   - LEDs (indicadores visuales)
// ============================================================

module top_module (
    // ===== ENTRADAS DEL SISTEMA =====
    input  wire        MAX10_CLK1_50,   // Reloj 50MHz de la DE10-Lite
    input  wire [1:0]  KEY,             // 2 botones (activo bajo)
    input  wire [9:0]  SW,              // 10 switches
    
    // ===== SALIDAS: DISPLAYS 7-SEGMENTOS =====
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5,
    
    // ===== SALIDAS: LEDs =====
    output wire [9:0]  LEDR,
    
    // ===== GPIO: COMUNICACIÓN CON ARDUINO =====
    input  wire [35:0] GPIO,            // GPIO entrada
    output wire [35:0] GPIO_OUT         // GPIO salida
);

    // ===== SEÑALES INTERNAS =====
    wire        clk;
    wire        rst_n;
    
    // UART
    wire [7:0]  rx_data;        // Dato recibido (distancia)
    wire        rx_ready;       // Pulso: dato listo
    wire        tx_busy;        // TX ocupado
    
    // FSM
    wire [7:0]  comando;        // Comando de la FSM
    wire        enviar_cmd;     // Pulso: enviar comando
    wire [2:0]  estado;         // Estado actual de la FSM
    
    // Registro de distancia
    reg  [7:0]  distancia_reg;
    
    // ===== ASIGNACIONES =====
    assign clk   = MAX10_CLK1_50;   // Reloj principal
    assign rst_n = KEY[0];           // KEY[0] = Reset (presionar para reset)
    
    // GPIO: Arduino conectado en GPIO[0] (RX) y GPIO[1] (TX)
    wire uart_rx_pin;
    assign uart_rx_pin = GPIO[0];   // FPGA recibe del Arduino por GPIO[0]
    
    // Para GPIO_OUT, solo usamos el bit 1 para TX
    // Los demás bits los dejamos en alta impedancia
    wire uart_tx_pin;
    
    // ===== GUARDAR ÚLTIMA DISTANCIA =====
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            distancia_reg <= 8'd200;  // Default: sin obstáculo
        else if (rx_ready)
            distancia_reg <= rx_data;
    end
    
    // ===== INSTANCIAR MÓDULOS =====
    
    // 1. UART Receiver (recibe datos del Arduino)
    uart_rx u_rx (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx        (uart_rx_pin),
        .data_out  (rx_data),
        .data_ready(rx_ready)
    );
    
    // 2. UART Transmitter (envía comandos al Arduino)
    uart_tx u_tx (
        .clk     (clk),
        .rst_n   (rst_n),
        .data_in (comando),
        .send    (enviar_cmd),
        .tx      (uart_tx_pin),
        .busy    (tx_busy)
    );
    
    // 3. FSM Principal (cerebro del robot)
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
    
    // ===== LEDs: Mostrar distancia como barra =====
    // LED[0] = obstáculo muy cerca
    // LED[1-8] = barra de distancia
    // LED[9] = estado de comunicación
    
    assign LEDR[0] = (distancia_reg < 10);   // Muy cerca
    assign LEDR[1] = (distancia_reg < 20);   // Obstáculo
    assign LEDR[2] = (distancia_reg < 30);
    assign LEDR[3] = (distancia_reg < 50);
    assign LEDR[4] = (distancia_reg < 70);
    assign LEDR[5] = (distancia_reg < 90);
    assign LEDR[6] = (distancia_reg < 110);
    assign LEDR[7] = (distancia_reg < 130);
    assign LEDR[8] = (distancia_reg < 150);
    assign LEDR[9] = rx_ready;  // Parpadea cuando recibe datos
    
    // ===== GPIO OUTPUT =====
    // Solo GPIO[1] se usa para TX, los demás en 0
    genvar i;
    generate
        for (i = 0; i < 36; i = i + 1) begin : gpio_out_gen
            if (i == 1)
                assign GPIO_OUT[i] = uart_tx_pin;
            else
                assign GPIO_OUT[i] = 1'b0;
        end
    endgenerate

endmodule
