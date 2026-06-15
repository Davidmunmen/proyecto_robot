// ============================================================
// UART TRANSMITTER - Envía comandos al Arduino
// ============================================================
// Velocidad: 9600 baud
// Reloj DE10-Lite: 50 MHz

module uart_tx (
    input  wire       clk,        // Reloj 50MHz
    input  wire       rst_n,      // Reset activo bajo
    input  wire [7:0] data_in,    // Byte a enviar
    input  wire       send,       // Pulso: empezar a enviar
    output reg        tx,         // Pin TX (va al Arduino)
    output reg        busy        // 1 = transmitiendo
);

    parameter CLKS_PER_BIT = 5208;  // 50MHz / 9600 baud
    
    // Estados
    parameter IDLE  = 3'd0;
    parameter START = 3'd1;
    parameter DATA  = 3'd2;
    parameter STOP  = 3'd3;
    
    reg [2:0]  state;
    reg [12:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  tx_byte;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            tx        <= 1;       // UART idle = HIGH
            busy      <= 0;
            clk_count <= 0;
            bit_index <= 0;
            tx_byte   <= 0;
        end else begin
            case (state)
                
                // IDLE: Esperando datos para enviar
                IDLE: begin
                    tx   <= 1;     // Línea en alto (idle)
                    busy <= 0;
                    if (send) begin
                        tx_byte   <= data_in;
                        busy      <= 1;
                        state     <= START;
                        clk_count <= 0;
                    end
                end
                
                // START: Enviar start bit (LOW)
                START: begin
                    tx <= 0;  // Start bit = LOW
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state     <= DATA;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                // DATA: Enviar los 8 bits
                DATA: begin
                    tx <= tx_byte[bit_index];
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                // STOP: Enviar stop bit (HIGH)
                STOP: begin
                    tx <= 1;  // Stop bit = HIGH
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state     <= IDLE;
                        busy      <= 0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
