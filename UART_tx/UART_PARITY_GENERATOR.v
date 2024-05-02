module UART_PARITY_GENERATOR #(parameter WIDTH=8)(
	input CLK,RST ,DATA_VALID,
	input [WIDTH-1:0] P_DATA,
	input PAR_EN,PAR_TYPE,
	input stop_case,
	output reg parity_bit,
	output reg PAR_EN_reg //used with fsm so that if any new PAR_EN comes it doesn't affect the running operation 
);
reg [WIDTH-1:0] P_DATA_reg;
reg  PAR_TYPE_reg;
always @(posedge CLK or negedge RST) begin 
	if(~RST) begin
		P_DATA_reg <= 0;
		PAR_EN_reg<=0;
		PAR_TYPE_reg<=0;
	end else if(stop_case && DATA_VALID)begin
		P_DATA_reg <= P_DATA ;
		PAR_EN_reg<=PAR_EN;
		PAR_TYPE_reg<=PAR_TYPE;
	end
end

always @(posedge CLK or negedge RST) begin 
	if(~RST) begin
		parity_bit <= 0;
	end else if(PAR_EN_reg) begin
		 if(PAR_TYPE_reg) begin
		 	parity_bit <= ~^ P_DATA_reg;
		 end
		 else begin
		 	parity_bit <= ^P_DATA_reg;
		 end
	end
end

endmodule 
