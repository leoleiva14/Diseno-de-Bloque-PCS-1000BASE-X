PCS:	Receptor.v Sincronizador.v Transmisor.v Transmisor_code.v Transmisor_oset.v Wrapper.v Tester.v testbench.v
	iverilog -o salida testbench.v 
	vvp salida
	gtkwave resultados.vcd

