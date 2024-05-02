module UART_FSM  (
	input CLK,
	input DATA_VALID,
	input PAR_EN_reg,
	input RST,
	input serial_done,
	output reg[1:0]  mux_sel,
	output reg serial_en,
	output reg BUSY
);
/*------------------------------------------------------------------------------
--varaibles declarations  
------------------------------------------------------------------------------*/
parameter IDLE=3'b000;
parameter START=3'b001;
parameter SERIALIZING_DATA=3'b011;
parameter PARITY_GENERATION=3'b010;
parameter STOP=3'b110;
reg[2:0] cs,ns;
/*------------------------------------------------------------------------------
-- next state transition 
------------------------------------------------------------------------------*/
always @(posedge CLK or negedge RST) begin : proc_
	if(~RST) begin
		cs<= 0;
	end else begin
		cs <=ns ;
	end
end
/*------------------------------------------------------------------------------
--next state logic   
------------------------------------------------------------------------------*/
always @(*) begin 
	case (cs)
		IDLE:
			begin
				if(DATA_VALID) 
					ns=START;
				else 
					ns=IDLE;
			end	
		START: 
			begin
				ns=SERIALIZING_DATA;
			end
		SERIALIZING_DATA:  
			begin
				if(serial_done)begin
					if(PAR_EN_reg)
						ns=	PARITY_GENERATION;
					else 
						ns=STOP;
				end 
				else 
					ns=SERIALIZING_DATA;						
			end
		PARITY_GENERATION:ns=STOP;		
		STOP: ns= IDLE ;
			// begin
			// 	if(DATA_VALID)
			// 		ns=START;
			// 	else 
			// 		ns=IDLE;
			// end
	endcase
end
/*------------------------------------------------------------------------------
--output logic   
------------------------------------------------------------------------------*/
always @(*) begin 
	case (cs)
		IDLE:begin
			mux_sel=2'b11;
			serial_en=0;
			BUSY=0;
		end
		START:
			begin
				BUSY=1;
				mux_sel=2'b00;
				serial_en=1;
			end
		SERIALIZING_DATA:
			begin
				BUSY=1;
				serial_en=1;
				mux_sel=2'b01;
			end
		PARITY_GENERATION: 
			begin
			 	mux_sel=2'b10;
			 	serial_en=0;
			end
		STOP: begin
			BUSY=1 ;
			serial_en=0;
			mux_sel=2'b11;
		end

	endcase
end
endmodule : UART_FSM
