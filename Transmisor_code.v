module Tx_code (power, clock, reset, TXD, tx_even, TX_code_group,TX_OSET_indicate,tx_o_set);
//entradas
input power, clock, reset;
input [7:0] TXD;
input [7:0] tx_o_set;
//salidas
output reg tx_even, TX_OSET_indicate;
output reg [9:0] TX_code_group;

//Variables Internas
reg [4:0] state, next_state;
reg [9:0] next_TX_code_group;
reg next_tx_even; 
reg tx_disparity;
wire tx_even_negado;

// Definición de estados 
// parameter [4:0]  GENERATE_CODE_GROUPS = 5'b00001;
  parameter [4:0]  GENERATE_CODE_GROUPS = 5'b00001;
  parameter [4:0]  SPECIAL_GO = 5'b00010;
  parameter [4:0]  DATA_GO = 5'b00100;
  parameter [4:0]  IDLE_DISPARITY_OK = 5'b01000;
  parameter [4:0]  IDLE_I2B = 5'b10000;

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
  parameter K27_7_10_0 = 10'b1101101000;//K27.7, /S/, negativo
  parameter K27_7_10_1 = 10'b0010010111;//K27.7, /S/, ppositivo
  parameter K23_7_10_0 = 10'b1110101000; //K23.7, /R/, negativo  
  parameter K23_7_10_1 = 10'b0001010111; //K23.7, /R/, positivo
  parameter K29_7_10_0 = 10'b1011101000; //K29.7, /T/, negativo
  parameter K29_7_10_1 = 10'b0100010111; //K29.7, /T/, positivo
  parameter D5_6_10 = 10'b1010010110; //D5.6 
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
    state        <= GENERATE_CODE_GROUPS;
    TX_code_group     <= 9'b00000000;
    tx_even = 0;
    tx_disparity = 0;

  end else begin
    state        <= next_state;
    TX_code_group <= next_TX_code_group;
    tx_even <= next_tx_even;
  end
end

// Lógica de definición del próximo estado y acciones
    always @(*) begin
    next_state = state;
    next_TX_code_group = TX_code_group;
    next_tx_even = tx_even;
        case (state)
            GENERATE_CODE_GROUPS: begin
              if (tx_o_set == K27_7_8 || tx_o_set == K23_7_8 || tx_o_set == K29_7_8) begin
                next_state = SPECIAL_GO;
                next_tx_even = !tx_even;
                if (tx_o_set == K27_7_8) begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K27_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin 
                      next_TX_code_group <= K27_7_10_1;
                      tx_disparity = 1;
                    end
                end
                else if (tx_o_set == K23_7_8)begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K23_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K23_7_10_1;
                      tx_disparity = 1;
                    end
              	end
                else begin 
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K29_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K29_7_10_1;
                      tx_disparity = 1;
                    end
                end	
                
              end else if (tx_o_set == K28_5_8) begin 
              	next_state = IDLE_DISPARITY_OK;	
                if (tx_disparity == 0) begin 
                  next_TX_code_group <= K28_5_10_0;
                  tx_disparity = 1;
                end
                else begin 
                  next_TX_code_group <= K28_5_10_1;
				  tx_disparity = 0;
                end
                next_tx_even = 1;
              end else begin
                next_state = DATA_GO;
                if (tx_disparity == 0) begin
                  	
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                      next_TX_code_group <= D2_0_10_0;
                      tx_disparity = 0;
                  end
                      else if (tx_o_set == D3_0_8) begin 
                        next_TX_code_group <= D3_0_10_0;
                        tx_disparity = 1;
                      end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_0;
                    tx_disparity = 0;
                  end
                    else if (tx_o_set == D5_0_8) begin 
                      next_TX_code_group <= D5_0_10_0;
                      tx_disparity = 1;
                    end
                      else if (tx_o_set == D6_0_8) begin 
                        next_TX_code_group <= D6_0_10_0;
                        tx_disparity = 1;
                      end
                        else if (tx_o_set == D7_0_8) begin 
                          next_TX_code_group <= D7_0_10_0;
                          tx_disparity = 1;
                        end
                  else if (tx_o_set == D8_0_8)begin 
                      next_TX_code_group <= D8_0_10_0;
                      tx_disparity = 0;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_0;
                    tx_disparity = 1;
                  end
                  next_tx_even = !tx_even;
                end
                else begin
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                    next_TX_code_group <= D2_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D3_0_8) begin 
                    next_TX_code_group <= D3_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D5_0_8) begin 
                    next_TX_code_group <= D5_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D6_0_8) begin 
                    next_TX_code_group <= D6_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D7_0_8) begin 
                    next_TX_code_group <= D7_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D8_0_8) begin 
                    next_TX_code_group <= D8_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_1;
                    tx_disparity = 0;
                  end
                  	next_tx_even = !tx_even;
                end
              end
              
            end
          	
            SPECIAL_GO: begin
              if (tx_o_set == K27_7_8 || tx_o_set == K23_7_8 || tx_o_set == K29_7_8) begin
                next_state = SPECIAL_GO;
                next_tx_even = !tx_even;
                if (tx_o_set == K27_7_8) begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K27_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin 
                      next_TX_code_group <= K27_7_10_1;
                      tx_disparity = 1;
                    end
                end
                else if (tx_o_set == K23_7_8)begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K23_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K23_7_10_1;
                      tx_disparity = 1;
                    end
              	end
                else begin 
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K29_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K29_7_10_1;
                      tx_disparity = 1;
                    end
                end	
                
              end else if (tx_o_set == K28_5_8) begin 
              	next_state = IDLE_DISPARITY_OK;	
                if (tx_disparity == 0) begin 
                  next_TX_code_group <= K28_5_10_0;
                  tx_disparity = 1;
                end
                else begin 
                  next_TX_code_group <= K28_5_10_1;
				  tx_disparity = 0;
                end
                next_tx_even = 1;
              end else begin
                next_state = DATA_GO;
                if (tx_disparity == 0) begin
                  	
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                      next_TX_code_group <= D2_0_10_0;
                      tx_disparity = 0;
                  end
                      else if (tx_o_set == D3_0_8) begin 
                        next_TX_code_group <= D3_0_10_0;
                        tx_disparity = 1;
                      end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_0;
                    tx_disparity = 0;
                  end
                    else if (tx_o_set == D5_0_8) begin 
                      next_TX_code_group <= D5_0_10_0;
                      tx_disparity = 1;
                    end
                      else if (tx_o_set == D6_0_8) begin 
                        next_TX_code_group <= D6_0_10_0;
                        tx_disparity = 1;
                      end
                        else if (tx_o_set == D7_0_8) begin 
                          next_TX_code_group <= D7_0_10_0;
                          tx_disparity = 1;
                        end
                  else if (tx_o_set == D8_0_8)begin 
                      next_TX_code_group <= D8_0_10_0;
                      tx_disparity = 0;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_0;
                    tx_disparity = 1;
                  end
                  next_tx_even = !tx_even;
                end
                else begin
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                    next_TX_code_group <= D2_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D3_0_8) begin 
                    next_TX_code_group <= D3_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D5_0_8) begin 
                    next_TX_code_group <= D5_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D6_0_8) begin 
                    next_TX_code_group <= D6_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D7_0_8) begin 
                    next_TX_code_group <= D7_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D8_0_8) begin 
                    next_TX_code_group <= D8_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_1;
                    tx_disparity = 0;
                  end
                  	next_tx_even = !tx_even;
                end
              end
              
            end
          
            DATA_GO: begin
             if (tx_o_set == K27_7_8 || tx_o_set == K23_7_8 || tx_o_set == K29_7_8) begin
                next_state = SPECIAL_GO;
                next_tx_even = !tx_even;
                if (tx_o_set == K27_7_8) begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K27_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin 
                      next_TX_code_group <= K27_7_10_1;
                      tx_disparity = 1;
                    end
                end
                else if (tx_o_set == K23_7_8)begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K23_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K23_7_10_1;
                      tx_disparity = 1;
                    end
              	end
                else begin 
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K29_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K29_7_10_1;
                      tx_disparity = 1;
                    end
                end	
                
              end else if (tx_o_set == K28_5_8) begin 
              	next_state = IDLE_DISPARITY_OK;	
                if (tx_disparity == 0) begin 
                  next_TX_code_group <= K28_5_10_0;
                  tx_disparity = 1;
                end
                else begin 
                  next_TX_code_group <= K28_5_10_1;
				  tx_disparity = 0;
                end
                next_tx_even = 1;
              end else begin
                next_state = DATA_GO;
                if (tx_disparity == 0) begin
                  	
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                      next_TX_code_group <= D2_0_10_0;
                      tx_disparity = 0;
                  end
                      else if (tx_o_set == D3_0_8) begin 
                        next_TX_code_group <= D3_0_10_0;
                        tx_disparity = 1;
                      end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_0;
                    tx_disparity = 0;
                  end
                    else if (tx_o_set == D5_0_8) begin 
                      next_TX_code_group <= D5_0_10_0;
                      tx_disparity = 1;
                    end
                      else if (tx_o_set == D6_0_8) begin 
                        next_TX_code_group <= D6_0_10_0;
                        tx_disparity = 1;
                      end
                        else if (tx_o_set == D7_0_8) begin 
                          next_TX_code_group <= D7_0_10_0;
                          tx_disparity = 1;
                        end
                  else if (tx_o_set == D8_0_8)begin 
                      next_TX_code_group <= D8_0_10_0;
                      tx_disparity = 0;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_0;
                    tx_disparity = 1;
                  end
                  next_tx_even = !tx_even;
                end
                else begin
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                    next_TX_code_group <= D2_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D3_0_8) begin 
                    next_TX_code_group <= D3_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D5_0_8) begin 
                    next_TX_code_group <= D5_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D6_0_8) begin 
                    next_TX_code_group <= D6_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D7_0_8) begin 
                    next_TX_code_group <= D7_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D8_0_8) begin 
                    next_TX_code_group <= D8_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_1;
                    tx_disparity = 0;
                  end
                  	next_tx_even = !tx_even;
                end
              end
              
            end
          
            IDLE_DISPARITY_OK: begin
                // Definir transiciones y acciones para IDLE_DISPARITY_OK
              next_TX_code_group <= D5_6_10;
              next_state = IDLE_I2B;
              next_tx_even <=0;
            end
            IDLE_I2B:begin
              if (tx_o_set == K27_7_8 || tx_o_set == K23_7_8 || tx_o_set == K29_7_8) begin
                next_state = SPECIAL_GO;
                next_tx_even = !tx_even;
                if (tx_o_set == K27_7_8) begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K27_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin 
                      next_TX_code_group <= K27_7_10_1;
                      tx_disparity = 1;
                    end
                end
                else if (tx_o_set == K23_7_8)begin
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K23_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K23_7_10_1;
                      tx_disparity = 1;
                    end
              	end
                else begin 
                  if (tx_disparity == 0) begin 
                    next_TX_code_group <= K29_7_10_0;
                    tx_disparity = 0;
                  end
                	else begin
                      next_TX_code_group <= K29_7_10_1;
                      tx_disparity = 1;
                    end
                end	
                
              end else if (tx_o_set == K28_5_8) begin 
              	next_state = IDLE_DISPARITY_OK;	
                if (tx_disparity == 0) begin 
                  next_TX_code_group <= K28_5_10_0;
                  tx_disparity = 1;
                end
                else begin 
                  next_TX_code_group <= K28_5_10_1;
				  tx_disparity = 0;
                end
                next_tx_even = 1;
              end else begin
                next_state = DATA_GO;
                if (tx_disparity == 0) begin
                  	
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_0;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                      next_TX_code_group <= D2_0_10_0;
                      tx_disparity = 0;
                  end
                      else if (tx_o_set == D3_0_8) begin 
                        next_TX_code_group <= D3_0_10_0;
                        tx_disparity = 1;
                      end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_0;
                    tx_disparity = 0;
                  end
                    else if (tx_o_set == D5_0_8) begin 
                      next_TX_code_group <= D5_0_10_0;
                      tx_disparity = 1;
                    end
                      else if (tx_o_set == D6_0_8) begin 
                        next_TX_code_group <= D6_0_10_0;
                        tx_disparity = 1;
                      end
                        else if (tx_o_set == D7_0_8) begin 
                          next_TX_code_group <= D7_0_10_0;
                          tx_disparity = 1;
                        end
                  else if (tx_o_set == D8_0_8)begin 
                      next_TX_code_group <= D8_0_10_0;
                      tx_disparity = 0;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_0;
                    tx_disparity = 1;
                  end
                  next_tx_even = !tx_even;
                end
                else begin
                  if (tx_o_set == D0_0_8) begin 
                    next_TX_code_group <= D0_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D1_0_8) begin 
                    next_TX_code_group <= D1_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D2_0_8) begin 
                    next_TX_code_group <= D2_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D3_0_8) begin 
                    next_TX_code_group <= D3_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D4_0_8) begin 
                    next_TX_code_group <= D4_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D5_0_8) begin 
                    next_TX_code_group <= D5_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D6_0_8) begin 
                    next_TX_code_group <= D6_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D7_0_8) begin 
                    next_TX_code_group <= D7_0_10_1;
                    tx_disparity = 0;
                  end
                  else if (tx_o_set == D8_0_8) begin 
                    next_TX_code_group <= D8_0_10_1;
                    tx_disparity = 1;
                  end
                  else if (tx_o_set == D9_0_8) begin 
                    next_TX_code_group <= D9_0_10_1;
                    tx_disparity = 0;
                  end
                  	next_tx_even = !tx_even;
                end
              end
              
            end
            default: next_state = GENERATE_CODE_GROUPS; // Estado por defecto
        endcase

    end
endmodule
