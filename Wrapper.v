
`include "Receptor.v"
`include "Transmisor.v"
`include "Sincronizador.v"
module Wrapper(power, clock, reset, TXD, TX_EN, RX_EVEN, RX_DV, rx_code_group, TX_code_group);
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)


output [9:0]	TX_code_group;		// From TRANSMISOR of Transmisor.v
wire [7:0]		RXD;			// From RECEPTOR of Receptor.v
output 			RX_DV;			// From RECEPTOR of Receptor.v
wire [9:0]		rx_code_group_out;	// From SINCRONIZADOR of Sincronizador.v
input wire [9:0]		rx_code_group;	// From SINCRONIZADOR of Sincronizador.v

wire 			sync_status;
input wire			clock;			// From TESTER of Tester.v
input wire			TX_EN;			// From TESTER of Tester.v
input wire			power;			// From TESTER of Tester.v
input wire [7:0]		TXD;

input wire			reset;			// From TESTER of Tester.v
output  			RX_EVEN;		// From SINCRONIZADOR of Sincronizador.v

    // Instancias de los módulos
    Transmisor TRANSMISOR (/*AUTOINST*/
			   // Outputs
			   .TX_code_group	(TX_code_group),
			   // Inputs
			   .power		(power),
			   .clock		(clock),
			   .reset		(reset),
			   .TX_EN		(TX_EN),
      		   .TXD			(TXD[7:0]));

    Receptor RECEPTOR (/*AUTOINST*/
		       // Outputs
		       .RXD		(RXD[7:0]),
		       .RX_DV		(RX_DV),
		       // Inputs
		       .CLK		(clock),
		       .SUDI		(rx_code_group_out[9:0]),
		       .sync_status	(sync_status),
		       .RESET		(reset));

    Sincronizador SINCRONIZADOR (/*AUTOINST*/
				 // Outputs
				 .rx_code_group_out	(rx_code_group_out[9:0]),
				 .RX_EVEN		(RX_EVEN),
				 .sync_status			(sync_status),
				 // Inputs
				 .clk			(clock),
				 .reset			(reset),
				 .rx_code_group_in	(TX_code_group));

endmodule
