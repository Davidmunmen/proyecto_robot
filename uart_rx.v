// ============================================================
// UART RECEIVER - Recibe datos del Arduino
// ============================================================
// Velocidad: 9600 baud
// Reloj DE10-Lite: 50 MHz
// 50,000,000 / 9600 = 5208 ciclos por bit

module uart_rx (
    input  wire       clk,        // Reloj 50MHz
    input  wire       rst_n,      // Reset activo bajo
    input  wire       rx,         // Pin RX (viene del Arduino)
    output reg  [7:0] data_out,   // Byte recibido
    output reg        data_ready  // Pulso: dato listo para leer
);

    // Constantes
    parameter CLKS_PER_BIT = 5208;  // 50MHz / 9600 baud
    
    // Estados
    parameter IDLE    = 3'd0;
    parameter START   = 3'd1;
    parameter DATA    = 3'd2;
    parameter STOP    = 3'd3;
    parameter CLEANUP = 3'd4;
    
    reg [2:0]  state;
    reg [12:0] clk_count;    // Contador de ciclos de reloj
    reg [2:0]  bit_index;    // Qué bit estamos recibiendo (0-7)
    reg [7:0]  rx_byte;      // Byte que vamos construyendo
    
    // Sincronizar la entrada RX (evitar metaestabilidad)
    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
    
    // Máquina de estados para recibir
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            clk_count  <= 0;
            bit_index  <= 0;
            data_ready <= 0;
            data_out   <= 0;
            rx_byte    <= 0;
        end else begin
            case (state)
                
                // IDLE: Esperando que empiece un byte
                IDLE: begin
                    data_ready <= 0;
                    clk_count  <= 0;
                    bit_index  <= 0;
                    if (rx_sync2 == 0)      // Start bit detectado (LOW)
                        state <= START;
                end
                
                // START: Verificar que sí es un start bit
                START: begin
                    if (clk_count == CLKS_PER_BIT / 2) begin
                        if (rx_sync2 == 0) begin
                            clk_count <= 0;     // Centrarse en el medio del bit
                            state     <= DATA;
                        end else begin
                            state <= IDLE;      // Falsa alarma
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                // DATA: Recibir los 8 bits de datos
                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        rx_byte[bit_index] <= rx_sync2;  // Guardar bit
                        
                        if (bit_index == 7) begin
                            bit_index <= 0;
                            state     <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                // STOP: Esperar el stop bit
                STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        data_ready <= 1;        // ¡Dato listo!
                        data_out   <= rx_byte;  // Copiar a la salida
                        clk_count  <= 0;
                        state      <= CLEANUP;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                // CLEANUP: Un ciclo para que data_ready sea un pulso
                CLEANUP: begin
                    data_ready <= 0;
                    state      <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
