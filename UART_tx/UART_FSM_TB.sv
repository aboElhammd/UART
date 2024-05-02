module UART_FSM_TB ();
	typedef enum logic [2:0] {IDLE,START,PARITY,SERIALIZNG,STOP} e_states;
	parameter CLOCK_PERIOD=4;
	/*------------------------------------------------------------------------------
	--variables declarations  
	------------------------------------------------------------------------------*/
	logic CLK_tb;
	logic DATA_VALID_tb;
	logic PAR_EN_tb;
	logic RST_tb;
	logic SERIAL_DONE_tb;
	logic [1:0] MUX_SEL_tb;
	logic SERIAL_EN_tb;
	e_states cs_tb;
	
	UART_FSM DUT (
	 .CLK(CLK_tb),
	 .DATA_VALID(DATA_VALID_tb),
	 .PAR_EN(PAR_EN_tb),
	 .RST(RST_tb),
	 .SERIAL_DONE(SERIAL_DONE_tb),
	 .MUX_SEL(MUX_SEL_tb),
	 .SERIAL_EN(SERIAL_EN_tb)
	);
	/*------------------------------------------------------------------------------
	--  clock generation
	------------------------------------------------------------------------------*/
	always #2 CLK_tb=~CLK_tb;
	/*------------------------------------------------------------------------------
	--reset task  
	------------------------------------------------------------------------------*/
	task reset();
		@(negedge CLK_tb);
		RST_tb=0;
		#CLOCK_PERIOD RST_tb=1;
	endtask : reset
	/*------------------------------------------------------------------------------
	--initializing task  
	------------------------------------------------------------------------------*/
	task initialize();
		 CLK_tb=0;
		 DATA_VALID_tb=0;
		 PAR_EN_tb=0;
		 RST_tb=1;
		 SERIAL_DONE_tb=0;
	endtask : initialize
	/*------------------------------------------------------------------------------
	--  stimulus generation
	------------------------------------------------------------------------------*/
	initial begin
		initialize;
		reset();
		for (int i = 0; i < 10; i++) begin
			@(negedge CLK_tb) DATA_VALID_tb=1;

			PAR_EN_tb=$random();
			#CLOCK_PERIOD DATA_VALID_tb=0;
			SERIAL_DONE_tb=0;
			repeat(7) # CLOCK_PERIOD;
			@(posedge CLK_tb) SERIAL_DONE_tb=1; 
		end
		$stop;
	end
	/*------------------------------------------------------------------------------
	--  
	------------------------------------------------------------------------------*/
	always @(*)begin
		case (DUT.cs)
			0:cs_tb=IDLE;
			1:cs_tb=START;
			3:cs_tb=SERIALIZNG;
			2:cs_tb=PARITY;
			6:cs_tb=STOP;
		endcase
	end
endmodule : UART_FSM_TB
