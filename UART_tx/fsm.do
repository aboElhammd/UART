vlib work 
vlog UART_FSM.v UART_FSM_TB.sv
vsim -voptargs=+acc work.UART_FSM_TB
add wave * 
run -all