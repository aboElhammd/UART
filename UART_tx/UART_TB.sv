module UART_TB ();
/*------------------------------------------------------------------------------
--parameters declarations   
------------------------------------------------------------------------------*/
parameter WIDTH=8;
parameter CLOCK_PERIOD=10;
parameter HALF_CLOCK_PERIOD=5;
/*------------------------------------------------------------------------------
-- signals declarations  
------------------------------------------------------------------------------*/
	typedef enum logic [2:0] {IDLE,START,SERILIZING,PARITY,STOP} e_states;
 	logic CLK_tb,RST_tb;
	logic PAR_TYPE_tb,PAR_EN_tb;
	logic [WIDTH-1:0] P_DATA_tb;
	logic [WIDTH-1:0]P_DATA_reg;
	logic PAR_TYPE_reg,PAR_EN_reg;
	logic DATA_VALID_tb;
	logic TX_OUT_tb,BUSY_tb;
	logic [WIDTH-1:0]recieved_bits;
	e_states currect_state;
	int interrupt_cycle;
	int error_count ,correct_count;
/*------------------------------------------------------------------------------
--clock generation  
------------------------------------------------------------------------------*/
always #HALF_CLOCK_PERIOD CLK_tb=~CLK_tb;
/*------------------------------------------------------------------------------
--initiliazing task   
------------------------------------------------------------------------------*/
task initialize();
	 CLK_tb=0;RST_tb=1;
	 PAR_TYPE_tb=0;PAR_EN_tb=0;
	 P_DATA_tb=0;
	 DATA_VALID_tb=0;
endtask : initialize
/*------------------------------------------------------------------------------
-- reset task   
------------------------------------------------------------------------------*/
task reset();
	@(negedge CLK_tb) 
	RST_tb=0;
	#CLOCK_PERIOD 
	RST_tb=1;	
endtask : reset
/*------------------------------------------------------------------------------
--stimulus generation   
------------------------------------------------------------------------------*/
task generate_stimulus ();
	@(negedge CLK_tb)
	 PAR_TYPE_tb=$random();
	 PAR_EN_tb=$random();
	 P_DATA_tb=$random();
	 DATA_VALID_tb=1;
	 #CLOCK_PERIOD DATA_VALID_tb=0;
endtask : generate_stimulus
/*------------------------------------------------------------------------------
-- check result task  
------------------------------------------------------------------------------*/
task check_result(int test_case_id);
	
	logic parity_bit;
	//storing the data bits
	@(negedge TX_OUT_tb)
	#CLOCK_PERIOD;
	for (int i = 0; i < WIDTH; i++) begin
		@(negedge CLK_tb)
		recieved_bits[i]=TX_OUT_tb;
	end
	if(PAR_EN_reg) begin
		#CLOCK_PERIOD;
		parity_bit=TX_OUT_tb;
		if(PAR_TYPE_reg) begin
			if(recieved_bits==P_DATA_reg && parity_bit==(~^recieved_bits)) begin
				correct_count++;
			end
			else begin
				$display("test casse %0d failed at time %0t recieved_bits = %0h and TX_OUT = %0h", test_case_id,$time(), recieved_bits , P_DATA_reg);
				$display("parity bit = %0b and correct answer is %0b and par_en =%0b",parity_bit ,~^recieved_bits , PAR_EN_reg);
				error_count++;
			end
		end
		else begin
			if(recieved_bits==P_DATA_reg && parity_bit==(^recieved_bits)) begin
				correct_count++;
			end
			else begin
				$display("test casse %0d failed at time %0t recieved_bits = %0h and TX_OUT = %0h", test_case_id,$time(), recieved_bits , P_DATA_reg);
				$display("parity bit = %0b and correct answer is %0b and par_en =%0b ",parity_bit , ^recieved_bits, PAR_EN_reg);
				error_count ++;
			end
		end
	end
	else begin
		if(recieved_bits==P_DATA_reg) begin
			correct_count++;
		end
		else begin
			$display("test casse %0d failed at time %0t recieved_bits = %0h and TX_OUT = %0h", test_case_id,$time(), recieved_bits , P_DATA_reg);
			error_count++;
		end
	end
endtask : check_result
/*------------------------------------------------------------------------------
-- interrupt task  
------------------------------------------------------------------------------*/
task interrupt(int i);
	repeat(i) #CLOCK_PERIOD;
	DATA_VALID_tb=1;
	P_DATA_tb=$random();
	PAR_TYPE_tb=$random();
	PAR_EN_tb=$random();
	#CLOCK_PERIOD;
	DATA_VALID_tb=0;
endtask : interrupt
/*------------------------------------------------------------------------------
--applying stimulus block   
------------------------------------------------------------------------------*/ 
initial begin
	initialize();
	reset();
	//single operations without any change in the DATA_VALID and P_DATA in the middle of the operation
	for (int i = 0; i < 200; i++) begin
		generate_stimulus();
		P_DATA_reg=P_DATA_tb;
	 	PAR_TYPE_reg=PAR_TYPE_tb;
	 	PAR_EN_reg=PAR_EN_tb;
	 	check_result(i);
	 	#CLOCK_PERIOD;
	end
	//doing operations after each other without returning to the idle state 
	// for (int i = 0; i < 100; i++) begin
	// 	generate_stimulus();
	// 	P_DATA_reg=P_DATA_tb;
	//  	PAR_TYPE_reg=PAR_TYPE_tb;
	//  	PAR_EN_reg=PAR_EN_tb;
	//  	check_result(i+100);
	// end
	//interrupt the operations with data valid high and new data on P_DATA and new parity options 
	// to make sure that no operation will affect the working one 
	for (int i = 0; i < 100; i++) begin
		generate_stimulus();
		P_DATA_reg=P_DATA_tb;
	 	PAR_TYPE_reg=PAR_TYPE_tb;
	 	PAR_EN_reg=PAR_EN_tb;
	 	
	 	interrupt_cycle=$urandom_range(0,8);
	 	//we can't make it 9 as 9 will make repeated statr from the interrupt and the next loop would get the interrupt stimulus instead
	 	// of stimulus from generate stimulus task 
	 	fork
	 		begin
	 			check_result(i+200);
	 		end
	 		begin
	 			interrupt(interrupt_cycle);
	 		end
	 	join
	 	#CLOCK_PERIOD;
	end
	$display("total correct counts %0d total error counts %0d",correct_count, error_count);
	$stop();
end
/*------------------------------------------------------------------------------
-- DUT instantiation 
------------------------------------------------------------------------------*/
UART_TOP #( .WIDTH(8)) DUT(
	 .CLK(CLK_tb),.RST(RST_tb),
	 .PAR_TYPE(PAR_TYPE_tb),.PAR_EN(PAR_EN_tb),
	  .P_DATA(P_DATA_tb),
	 .DATA_VALID(DATA_VALID_tb),
	 .TX_OUT(TX_OUT_tb),.BUSY(BUSY_tb)
);
/*------------------------------------------------------------------------------
--showing states in testbench  
------------------------------------------------------------------------------*/
always @(*) begin
	case (DUT.FSM.cs)
		0:currect_state=IDLE;
		1:currect_state=START;
		3:currect_state=SERILIZING;
		2:currect_state=PARITY;
		6:currect_state=STOP;
	endcase
end
endmodule : UART_TB
