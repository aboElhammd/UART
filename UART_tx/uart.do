vlib work
vlog UART_FSM.v UART_SERIALIZER.v UART_PARITY_GENERATOR.v MUX.v register.v UART_TOP.v UART_TB.sv
vsim -voptargs=+acc work.UART_TB
add wave * 
run -all