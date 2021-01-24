source /cad/env/cadence_path.XCELIUM1909

xrun \
	-F tb.f \
	-F dut.f \
	-uvm \
	-uvmhome /cad/XCELIUM1909/tools/methodology/UVM/CDNS-1.2/sv \
	+UVM_TESTNAME=wp_alu_example_test \
	"$@"

#	-clean\
