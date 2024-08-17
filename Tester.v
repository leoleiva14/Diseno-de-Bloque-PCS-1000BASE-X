module Tester(power, clock, reset,TXD, TX_EN, RX_EVEN, RX_DV, rx_code_group, TX_code_group);


input wire [9:0]		TX_code_group;		// From TRANSMISOR of Transmisor.v
input wire		RX_DV;			// From RECEPTOR of Receptor.v
output reg [9:0]		rx_code_group;	// From SINCRONIZADOR of Sincronizador.v
output reg			clock;			// From TESTER of Tester.v
output reg			TX_EN;			// From TESTER of Tester.v
output reg			power;			// From TESTER of Tester.v
output reg [7:0] TXD;  				// From TESTER of Tester.v
output reg			reset;			// From TESTER of Tester.v
input wire			RX_EVEN;		// From SINCRONIZADOR of Sincronizador.v


initial begin
    // Inicialización de las señales
    clock = 0;
  	reset = 0;
  	power = 0;
  	TX_EN = 0;
  	TXD = 0;
    rx_code_group = 10'b0000000000;
    
  	#20 reset = 1;
  	power = 1;
  	
    // Ciclo de reset
    #10 reset = 0;
    #65 TX_EN = 1; // Se prueba el paso a START_OF_PACKET
  
    #20 TXD = 8'h01; //Se prueba la tranmisión del dato: D1_0_8 
    
    #10 TXD = 8'h02; //Se prueba la tranmisión del dato: D2_0_8 
    
    #10 TXD = 8'h03; //Se prueba la tranmisión del dato: D3_0_8 
    
    #10 TXD = 8'h04; //Se prueba la tranmisión del dato: D4_0_8 
    
    #10 TXD = 8'h05; //Se prueba la tranmisión del dato: D5_0_8 

    #10 TXD = 8'h06; //Se prueba la tranmisión del dato: D2_0_8 
    
    #10 TXD = 8'h07; //Se prueba la tranmisión del dato: D3_0_8 
    
    #10 TXD = 8'h08; //Se prueba la tranmisión del dato: D4_0_8 
    
    #10 TXD = 8'h09; //Se prueba la tranmisión del dato: D5_0_8
  
    #10 TXD = 8'h00; //Se prueba la tranmisión del dato: D5_0_8   
  
  
    #75 TX_EN = 0; // Se prueba la transición a END_OF_PACKET_T (envia (/T/), 

    // después debería pasar a END_OF_PACKET_R, envía /R/

    // por último debería volver a a enviar IDLES

    // Finalizar simulación
    #100 $finish;
end
always begin
    #5 clock = !clock;
end
endmodule
