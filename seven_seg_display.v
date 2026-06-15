// ============================================================
// DISPLAY 7-SEGMENTOS - Muestra estado y distancia
// ============================================================
// La DE10-Lite tiene 6 displays de 7 segmentos (HEX0 a HEX5)
// Cada display tiene 7 bits (a-g), activo bajo (0 = encendido)
//
// HEX5 HEX4 = Estado del robot (texto)
// HEX3       = Separador
// HEX2 HEX1 HEX0 = Distancia en cm

module seven_seg_display (
    input  wire [2:0]  estado,      // Estado de la FSM (0-5)
    input  wire [7:0]  distancia,   // Distancia en cm (0-200)
    output wire [6:0]  HEX0,        // Display 0 (unidades distancia)
    output wire [6:0]  HEX1,        // Display 1 (decenas distancia)
    output wire [6:0]  HEX2,        // Display 2 (centenas distancia)
    output wire [6:0]  HEX3,        // Display 3 (separador)
    output wire [6:0]  HEX4,        // Display 4 (estado letra 2)
    output wire [6:0]  HEX5         // Display 5 (estado letra 1)
);

    // ===== CONVERTIR DISTANCIA A DÍGITOS =====
    wire [3:0] centenas, decenas, unidades;
    
    assign centenas = distancia / 100;
    assign decenas  = (distancia % 100) / 10;
    assign unidades = distancia % 10;
    
    // ===== DECODIFICADOR DE DÍGITOS (0-9) =====
    // Segmentos: gfedcba, activo bajo (0 = ON)
    //
    //   aaa
    //  f   b
    //   ggg
    //  e   c
    //   ddd
    
    function [6:0] digit_to_7seg;
        input [3:0] digit;
        case (digit)
            4'd0: digit_to_7seg = 7'b1000000;  // 0
            4'd1: digit_to_7seg = 7'b1111001;  // 1
            4'd2: digit_to_7seg = 7'b0100100;  // 2
            4'd3: digit_to_7seg = 7'b0110000;  // 3
            4'd4: digit_to_7seg = 7'b0011001;  // 4
            4'd5: digit_to_7seg = 7'b0010010;  // 5
            4'd6: digit_to_7seg = 7'b0000010;  // 6
            4'd7: digit_to_7seg = 7'b1111000;  // 7
            4'd8: digit_to_7seg = 7'b0000000;  // 8
            4'd9: digit_to_7seg = 7'b0010000;  // 9
            default: digit_to_7seg = 7'b1111111; // Apagado
        endcase
    endfunction
    
    // Asignar displays de distancia
    assign HEX0 = digit_to_7seg(unidades);
    assign HEX1 = digit_to_7seg(decenas);
    assign HEX2 = digit_to_7seg(centenas);
    
    // Separador (guión)
    assign HEX3 = 7'b0111111;  // Solo segmento g encendido = guión
    
    // ===== MOSTRAR ESTADO EN HEX5 y HEX4 =====
    // IDLE=Id, BUSCAR=bU, SEGUIR=go, ESQUIVAR=EV, ATASCADO=At, META=dn
    
    reg [6:0] estado_hex5, estado_hex4;
    
    always @(*) begin
        case (estado)
            3'd0: begin  // IDLE
                estado_hex5 = 7'b1111001;  // I
                estado_hex4 = 7'b0100001;  // d
            end
            3'd1: begin  // BUSCAR
                estado_hex5 = 7'b0000011;  // b
                estado_hex4 = 7'b1000001;  // U
            end
            3'd2: begin  // SEGUIR
                estado_hex5 = 7'b0010000;  // g (como 9)
                estado_hex4 = 7'b1000000;  // o (como 0)
            end
            3'd3: begin  // ESQUIVAR
                estado_hex5 = 7'b0000110;  // E
                estado_hex4 = 7'b1000001;  // V (como U)
            end
            3'd4: begin  // ATASCADO
                estado_hex5 = 7'b0001000;  // A
                estado_hex4 = 7'b0000111;  // t
            end
            3'd5: begin  // META
                estado_hex5 = 7'b0100001;  // d
                estado_hex4 = 7'b0101011;  // n
            end
            default: begin
                estado_hex5 = 7'b1111111;  // Apagado
                estado_hex4 = 7'b1111111;  // Apagado
            end
        endcase
    end
    
    assign HEX5 = estado_hex5;
    assign HEX4 = estado_hex4;

endmodule
