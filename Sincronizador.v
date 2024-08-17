module Sincronizador (
  input wire clk,       // Señal de reloj
  input wire reset,     // Señal de reinicio
  input wire [9:0] rx_code_group_in, // Entrada rx_code_group
  output reg [9:0] rx_code_group_out,
  output reg RX_EVEN,
  output reg sync_status
);

  // Definición de los estados
  parameter LOSS_OF_SYNC = 4'b0000;
  parameter COMMA_DETECT_1 = 4'b0001;
  parameter ACQUIRE_SYNC_1 = 4'b0010;
  parameter COMMA_DETECT_2 = 4'b0011;
  parameter ACQUIRE_SYNC_2 = 4'b0100;
  parameter COMMA_DETECT_3 = 4'b0101;
  parameter SYNC_ACQUIRED = 4'b0110;
  parameter ERROR_DETECT = 4'b0111;


  // Definición de la reg variable para almacenar el estado actual
  reg [3:0] current_state, next_state;
  
  parameter k285_pos = 10'b1100000101;
  parameter K285_neg = 10'b0011111010;
  
  parameter D56 = 10'b1010010110;
  		
 			 
  parameter k297_pos = 10'b1011101000;
  parameter k297_neg = 10'b0100010111;
  
  parameter k277_pos = 10'b1101101000;
  parameter k277_neg = 10'b0010010111;

  parameter k237_pos = 10'b1110101000;
  parameter k237_neg = 10'b0001010111;

  parameter D00 = 10'b0110001011; 
  parameter D01 = 10'b1001110100;
  parameter D10 = 10'b0111010100;
  parameter D11 = 10'b1000101011;
  parameter D20 = 10'b0100101011;
  parameter D21 = 10'b1011010100;
  parameter D30 = 10'b1100011011;
  parameter D31 = 10'b1100010100;
  parameter D40 = 10'b0010101011;
  parameter D41 = 10'b1101010100;
  parameter D50 = 10'b1010010100;
  parameter D51 = 10'b1010011011;
  parameter D60 = 10'b0110010100;
  parameter D61 = 10'b0110011011;
  parameter D70 = 10'b0001110100;
  parameter D71 = 10'b1110001011;
  parameter D80 = 10'b0001101011;
  parameter D81 = 10'b1110010100;
  parameter D90 = 10'b1001010100;
  parameter D91 = 10'b1001011011;

  // Inicialización del estado actual
  always @(posedge clk) begin
    if (reset) begin
      current_state <= LOSS_OF_SYNC;
    end
    else begin
    	current_state <= next_state;
    end
  end

  // Definición de la lógica de transición y salida
  always @(rx_code_group_in) begin
    // Lógica de transición de estados
    case (current_state)
      LOSS_OF_SYNC:
      	begin
      		sync_status <= 0;
      		RX_EVEN <= 0;
      		rx_code_group_out <= 10'b0000000000;
      		if (rx_code_group_in == k285_pos || rx_code_group_in == K285_neg) begin
      			next_state <= COMMA_DETECT_1; 
    		end
      	end	
      COMMA_DETECT_1:
       begin
      		RX_EVEN <= 1;
      		if (rx_code_group_in == D56) begin
      			next_state <= ACQUIRE_SYNC_1; 
    		end
    		else next_state <= LOSS_OF_SYNC; 
      	end	
      
      ACQUIRE_SYNC_1: 
        begin
      		
      		RX_EVEN <= !RX_EVEN;
      		if (rx_code_group_in == k285_pos || rx_code_group_in == K285_neg) begin
      			next_state <= COMMA_DETECT_2; 
    		end
    		else next_state <= LOSS_OF_SYNC; 

        end	
      COMMA_DETECT_2: 
       begin
      		RX_EVEN <= 1;
      		if (rx_code_group_in == D56) begin
      			next_state <= ACQUIRE_SYNC_2; 
    		end
    		else next_state <= LOSS_OF_SYNC; 
      	end	
      
      ACQUIRE_SYNC_2: 
        begin
		RX_EVEN <= !RX_EVEN;
      		if (rx_code_group_in == k285_pos || rx_code_group_in == K285_neg) begin
      			next_state <= COMMA_DETECT_3; 
    		end
    		else next_state <= LOSS_OF_SYNC; 

        end		

      COMMA_DETECT_3:
        begin
      		
      		RX_EVEN <= 1;
      		if (rx_code_group_in == D56) begin
      			next_state <= SYNC_ACQUIRED; 
    		end
    		else next_state <= LOSS_OF_SYNC; 
      	end	

      SYNC_ACQUIRED: 
      	begin 
      		RX_EVEN <= !RX_EVEN;
      		if (rx_code_group_in == k297_pos || rx_code_group_in == k297_neg) begin
      			next_state <= LOSS_OF_SYNC;
      		end
      		else if (rx_code_group_in == D00 || rx_code_group_in == D01 || rx_code_group_in == D10 || rx_code_group_in == D11
      		|| rx_code_group_in == D20 || rx_code_group_in == D21 || rx_code_group_in == D30 || rx_code_group_in == D31
      		|| rx_code_group_in == D40 || rx_code_group_in == D41 || rx_code_group_in == D50 || rx_code_group_in == D51
      		|| rx_code_group_in == D60 || rx_code_group_in == D61 || rx_code_group_in == D70 || rx_code_group_in == D71
      		|| rx_code_group_in == D80 || rx_code_group_in == D81 || rx_code_group_in == D90 || rx_code_group_in == D91
      		|| rx_code_group_in == k285_pos || rx_code_group_in == K285_neg || rx_code_group_in == D56) begin
      			sync_status <= 1;
      			rx_code_group_out <= rx_code_group_in;
      		end
      		
      		else begin
      			sync_status <= 1;
      			rx_code_group_out <= rx_code_group_in;
      			next_state <= ERROR_DETECT;
      		end 
      	end
      
      ERROR_DETECT: 
      	begin 
      		RX_EVEN <= !RX_EVEN;
      		if (rx_code_group_in == k297_pos || rx_code_group_in == k297_neg) begin
      			next_state <= LOSS_OF_SYNC;
      		end
      		
    		else if (rx_code_group_in == D00 || rx_code_group_in == D01 || rx_code_group_in == D10 || rx_code_group_in == D11
      		|| rx_code_group_in == D20 || rx_code_group_in == D21 || rx_code_group_in == D30 || rx_code_group_in == D31
      		|| rx_code_group_in == D40 || rx_code_group_in == D41 || rx_code_group_in == D50 || rx_code_group_in == D51
      		|| rx_code_group_in == D60 || rx_code_group_in == D61 || rx_code_group_in == D70 || rx_code_group_in == D71
      		|| rx_code_group_in == D80 || rx_code_group_in == D81 || rx_code_group_in == D90 || rx_code_group_in == D91
              || rx_code_group_in == k285_pos || rx_code_group_in == K285_neg || rx_code_group_in == D56) begin
      			sync_status <= 1;
      			rx_code_group_out <= rx_code_group_in;
      		end
      		
      		else next_state <= LOSS_OF_SYNC;
      	end
      
      
    endcase


  end
  

endmodule
