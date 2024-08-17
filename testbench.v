`include "Tester.v"
`include "Wrapper.v"
module testbench;

wire [9:0]		TX_code_group;		// From TRANSMISOR of Transmisor.v
wire		RX_DV;			// From RECEPTOR of Receptor.v
wire [9:0]		rx_code_group;	// From SINCRONIZADOR of Sincronizador.v
wire			clock;			// From TESTER of Tester.v
wire			TX_EN;			// From TESTER of Tester.v
wire [7:0]		TXD;
wire			power;			// From TESTER of Tester.v
wire			reset;			// From TESTER of Tester.v
wire			RX_EVEN;		// From SINCRONIZADOR of Sincronizador.v

 // Inicialización para la generación del archivo VCD
  initial begin
	$dumpfile("resultados.vcd");
	$dumpvars(-1, WRAPPER);
  end
  
  

//Instancias
Tester TESTER(/*AUTOINST*/
	      // Outputs
	      .clock			(clock),
	      .reset			(reset),
	      .power			(power),
  		  .TXD				(TXD),
	      .TX_EN			(TX_EN),
	      .RX_EVEN			(RX_EVEN),
	      .rx_code_group		(rx_code_group),
	      .TX_code_group		(TX_code_group),	  
	      .RX_DV			(RX_DV));

Wrapper WRAPPER (/*AUTOINST*/
		 // Outputs
	      .clock			(clock),
	      .reset			(reset),
	      .power			(power),
  		  .TXD				(TXD),
	      .TX_EN			(TX_EN),
	      .RX_EVEN			(RX_EVEN),
	      .rx_code_group		(rx_code_group),
	      .TX_code_group		(TX_code_group),	  
	      .RX_DV			(RX_DV));

endmodule
