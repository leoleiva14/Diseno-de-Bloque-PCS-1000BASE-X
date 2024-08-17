// Code your design here
module Tx_oset (power, clock, reset, tx_o_set, tx_even, TX_OSET_indicate, transmitting,TX_EN,TXD);
//entradas
input power, clock, reset, TX_OSET_indicate, tx_even,TX_EN;
input [7:0] TXD;
//salidas
output reg transmitting;
output reg [7:0] tx_o_set;

//Variables Internas
reg [5:0] state, next_state;
reg [7:0] next_tx_o_set;
reg next_transmitting;

// Definición de estados 
  parameter [5:0]  XMIT_DATA = 6'b000001;
  parameter [5:0]  START_OF_PACKET = 6'b000010;
  parameter [5:0]  TX_PACKET = 6'b000100;
  parameter [5:0]  TX_DATA = 6'b001000;
  parameter [5:0]  END_OF_PACKET_NOEXT = 6'b010000;
  parameter [5:0]  EPD2_NOEXT = 6'b100000;

// Para decoder:
  parameter K28_5_8 = 8'hbc;  //I
  parameter D5_6_8 = 8'hc5;  //I
  parameter K27_7_8 = 8'hfb; //S
  parameter K23_7_8 = 8'hf7; //R
  parameter K29_7_8 = 8'hfd; //T
// Resto de Datos
  parameter D0_0_8 = 8'h00; //000 00000
  parameter D1_0_8 = 8'h01; //000 00001
  parameter D2_0_8 = 8'h02; //000 00010
  parameter D3_0_8 = 8'h03; //000 00011
  parameter D4_0_8 = 8'h04; //000 00100
  parameter D5_0_8 = 8'h05; //000 00101
  parameter D6_0_8 = 8'h06; //000 00110
  parameter D7_0_8 = 8'h07; //000 00111
  parameter D8_0_8 = 8'h08; //000 01000
  parameter D9_0_8 = 8'h09; //000 01001
//10 bits, 0- and 1+
  parameter K28_5_10_0 = 10'b0011111010; //K28.5, negativo
  parameter K28_5_10_1 = 10'b1100000101; //K28.5, positivo
  parameter D5_6_10_0 = 10'b1010010110; //D5.6, negativo
  parameter D5_6_10_1 = 10'b1010010110; //D5.6, positivo
  parameter K27_7_10_0 = 10'b1101101000;//K27.7, /S/, negativo
  parameter K27_7_10_1 = 10'b0010010111;//K27.7, /S/, ppositivo
  parameter K23_7_10_0 = 10'b1110101000; //K23.7, /R/, negativo  
  parameter K23_7_10_1 = 10'b0001010111; //K23.7, /R/, positivo
  parameter K29_7_10_0 = 10'b1011101000; //K29.7, /T/, negativo
  parameter K29_7_10_1 = 10'b0100010111; //K29.7, /T/, positivo
// Resto de Datos
  parameter D0_0_10_0 = 10'b1001110100; //D0.0, negativo
  parameter D0_0_10_1 = 10'b0110001011; //D0.0, positivo
  parameter D1_0_10_0 = 10'b0111010100; //D1.0, negativo
  parameter D1_0_10_1 = 10'b1000101011; //D1.0, positivo
  parameter D2_0_10_0 = 10'b1011010100; //D2.0, negativo
  parameter D2_0_10_1 = 10'b0100101011; //D2.0, positivo
  parameter D3_0_10_0 = 10'b1100011011; //D3.0, negativo
  parameter D3_0_10_1 = 10'b1100010100; //D3.0, positivo
  parameter D4_0_10_0 = 10'b1101010100; //D4.0, negativo
  parameter D4_0_10_1 = 10'b0010101011; //D4.0, positivo
  parameter D5_0_10_0 = 10'b1010011011; //D5.0, negativo
  parameter D5_0_10_1 = 10'b1010010100; //D5.0, positivo
  parameter D6_0_10_0 = 10'b0110011011; //D6.0, negativo
  parameter D6_0_10_1 = 10'b0110010100; //D6.0, positivo
  parameter D7_0_10_0 = 10'b1110001011; //D7.0, negativo
  parameter D7_0_10_1 = 10'b0001110100; //D7.0, positivo
  parameter D8_0_10_0 = 10'b1110010100; //D8.0, negativo
  parameter D8_0_10_1 = 10'b0001101011; //D8.0, positivo
  parameter D9_0_10_0 = 10'b1001011011; //D9.0, negativo
  parameter D9_0_10_1 = 10'b1001010100; //D9.0, positivo
  
//flipflop para maquina de estados
  always @ (negedge clock)  begin
    if (reset & power) begin
    state        <= XMIT_DATA;
    tx_o_set     <= K28_5_8;
    transmitting <= 0;

  end else begin
    state        <= next_state;
    tx_o_set <= next_tx_o_set;
    transmitting <= next_transmitting;
  end
end

// Lógica de definición del próximo estado y acciones
    always @(*) begin
    next_state = state;
    next_tx_o_set = tx_o_set;
    next_transmitting = transmitting;
        case (state)
            XMIT_DATA: begin
                // Definir transiciones y acciones para XMIT_DATA
              if (tx_o_set == K28_5_8 )next_tx_o_set = D5_6_8;
              else next_tx_o_set = K28_5_8;
              if (TX_EN == 0)
                next_state = XMIT_DATA; // Ejemplo de transición
              	
              else begin
                next_state = START_OF_PACKET;
              	next_tx_o_set = K27_7_8;
              end
              	
            end
            START_OF_PACKET: begin
                // Definir transiciones y acciones para START_OF_PACKET
              	next_transmitting = 1;
              	next_tx_o_set = TXD;
              	next_state = TX_PACKET;
            end
            TX_PACKET: begin
              if (TX_EN == 0) begin
                	next_state = END_OF_PACKET_NOEXT; // Ejemplo de transición
              		next_tx_o_set = K29_7_8;
              end
              	else begin
                	next_state = TX_DATA;
              		next_tx_o_set = TXD;
                end
            end
            TX_DATA: begin
                // Definir transiciones y acciones para TX_DATA
              	
              if (TX_EN == 0) begin
                	next_state = END_OF_PACKET_NOEXT; // Ejemplo de transición
              		next_tx_o_set = K29_7_8;
              end
              	else begin 
                	next_state = TX_DATA;
              		next_tx_o_set = TXD;
                end
            end
            END_OF_PACKET_NOEXT: begin
                // Definir transiciones y acciones para END_OF_PACKET_NOEXT
              if (tx_even == 0) next_transmitting <= 0;
              next_tx_o_set = K23_7_8;
              next_state = EPD2_NOEXT;
            end
            EPD2_NOEXT: begin
                // Definir transiciones y acciones para EPD2_NOEXT
              	next_transmitting <= 0;
              	next_tx_o_set = K28_5_8;
                next_state = XMIT_DATA;
            end
            default: next_state = XMIT_DATA; // Estado por defecto
        endcase
    end
endmodule
