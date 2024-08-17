module Receptor(
    input wire CLK, // Señal de reloj
    input wire [9:0] SUDI, // Entrada de datos serie (10 bits)
    input wire sync_status, // Estado de sincronización
    input wire RESET, // Señal de reinicio
    output reg [7:0] RXD, // Salida de datos (8 bits)
    output reg RX_DV // Señal de dato válido
);
// Definiendo estados para la máquina de estados finitos
localparam WAIT_FOR_K = 6'b000001; // Esperar señal K
localparam RX_K = 6'b000010; // Recibir señal K
localparam IDLE_D = 6'b000100; // Estado inactivo
localparam START_OF_PACKET = 6'b001000; // Comienzo de paquete
localparam RECEIVE = 6'b010000; // Recibir datos
localparam TRI_RRI = 6'b100000; // Estado TRI_RRI

// Definición de constantes para verdadero y falso
localparam FALSE = 1'b0;
localparam TRUE = 1'b1;

// Registros para el estado actual, próximo estado y contadores
reg [5:0] estado, prox_estado;
reg [1:0] contador, contador_proximo;


// Bloque que se ejecuta en cada flanco negativo del reloj
always @(negedge CLK) begin
    if (RESET || ~sync_status) begin // Si RESET está activo o sync_status es falso
        estado <= WAIT_FOR_K; // Reinicia al estado WAIT_FOR_K
        contador <= 2'b00; // Reinicia el contador
    end else begin // Si no, actualiza estado y contador
        estado <= prox_estado;
        contador <= contador_proximo;
    end
end

// Bloque para manejar la lógica de la máquina de estados
always @(*) begin
    prox_estado = estado; // Mantener el estado actual por defecto
    RX_DV = FALSE; // Inicializa RX_DV a falso
    contador_proximo = contador; // Inicializa el contador próximo

    case (estado)
      // Si recibe señal K y sync_status es verdadero, cambia al estado RX_K
        WAIT_FOR_K: begin
            RX_DV = FALSE;
            if (((SUDI == 10'b1100000101) || (SUDI == 10'b0011111010)) && (sync_status == TRUE)) begin
                prox_estado = RX_K; //TRI_RRI;
                 
            end
        end
        TRI_RRI: begin
         // Lógica para el estado TRI_RRI
            RX_DV = FALSE;
            prox_estado = RX_K;
        end
        RX_K: begin
        // Lógica para el estado RX_K
            RX_DV = FALSE;
            if ((SUDI == 10'b011011_0101) || (SUDI == 10'b100100_0101) || (SUDI == 10'b101001_0110) || (SUDI == 10'b101001_0110)) begin
                prox_estado = IDLE_D;
            end
        end
        IDLE_D: begin
        // Lógica para el estado inactivo
            RX_DV = FALSE;
            if ((SUDI == 10'b0011111010) || (SUDI == 10'b1100000101)) begin
                prox_estado = RX_K;
            end else if ((SUDI == 10'b0010010111) || (SUDI == 10'b1101101000)) begin
                prox_estado = START_OF_PACKET;
            end
        end
        START_OF_PACKET: begin
        // Lógica para el inicio de un paquete
            RX_DV = TRUE;
            RXD = 8'b01010101;
            prox_estado = RECEIVE;
        end
        RECEIVE:begin
         // Lógica para recibir datos

            RX_DV = TRUE;
            
            if ((SUDI == 10'b011000_1011) || (SUDI == 10'b100111_0100))
                RXD = 8'b000_00000;
            else if ((SUDI == 10'b100010_1011) || (SUDI == 10'b011101_0100))
                RXD = 8'b000_00001;
            else if ((SUDI == 10'b010010_1011) || (SUDI == 10'b101101_0100))
                RXD = 8'b000_00010;
            else if ((SUDI == 10'b110001_0100) || (SUDI == 10'b110001_1011))
                RXD = 8'b000_00011;
            else if ((SUDI == 10'b001010_1011) || (SUDI == 10'b110101_0100))
                RXD = 8'b000_00100;
            else if ((SUDI == 10'b101001_0100) || (SUDI == 10'b101001_1011))
                RXD = 8'b000_00101;
            else if ((SUDI == 10'b011001_0100) || (SUDI == 10'b011001_1011))
                RXD = 8'b000_00110;
            else if ((SUDI == 10'b000111_0100) || (SUDI == 10'b111000_1011))
                RXD = 8'b000_00111;
            else if ((SUDI == 10'b000110_1011) || (SUDI == 10'b111001_0100))
                RXD = 8'b000_01000;
            else if ((SUDI == 10'b100101_0100) || (SUDI == 10'b100101_1011))
                RXD = 8'b000_01001;
            else if ((SUDI == 10'b101110_1000) || (SUDI == 10'b010001_0111))
                contador_proximo = 2'b01;
            else if (((SUDI == 10'b111010_1000 ) || (SUDI == 10'b000101_0111 )) && (contador_proximo == 2'b01))
                contador_proximo = 2'b10;
            else if (((SUDI == 10'b001111_1010) || (SUDI == 10'b110000_0101)) && (contador_proximo == 2'b10)) begin
                prox_estado = TRI_RRI;
                contador_proximo = 2'b00;
                
            end

        end
        
    endcase
end

endmodule