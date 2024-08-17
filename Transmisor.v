`include "Transmisor_oset.v"
`include "Transmisor_code.v"

module Transmisor (power, clock, reset, TXD, TX_EN,TX_code_group);
//entradas
input power,clock,reset,TX_EN;
input [7:0] TXD;
output [9:0] TX_code_group;

wire [7:0] tx_o_set;
wire tx_even;
wire TX_OSET_indicate;
wire transmitting;

Tx_oset oset(
  .power(power),
  .clock(clock),
  .reset(reset),
  .tx_o_set(tx_o_set),
  .tx_even(tx_even),
  .TX_OSET_indicate(TX_OSET_indicate),
  .transmitting(transmitting),
  .TX_EN(TX_EN),
  .TXD(TXD)
);

Tx_code code(
  .power(power),
  .clock(clock),
  .reset(reset),
  .tx_o_set(tx_o_set),
  .tx_even(tx_even),
  .TX_OSET_indicate(TX_OSET_indicate),
  .TX_code_group(TX_code_group),
  .TXD(TXD)
);

endmodule
