module UART_SERIALIZER #(parameter WIDTH=8)(
	input CLK,serial_en,RST ,DATA_VALID,
	input [WIDTH-1:0] P_DATA,
	output reg serial_done,
	output reg serial_data ,
	output stop_case
);
reg [2:0] counter;
reg [WIDTH-1:0] P_DATA_reg;

assign stop_case=(counter==0 && !serial_en ) ? 1 : 0; // we included the serial enable to prevent the case of data valid high
													  // for 2 consequent clock cyckes with different types of data
always @(posedge CLK or negedge RST) begin : proc_
	if(~RST) begin
		P_DATA_reg <= 0;
	end else if (stop_case && DATA_VALID )begin
		P_DATA_reg <= P_DATA ;

	end
end
always @(posedge CLK or negedge RST) begin 
	if(~RST) begin
		serial_done <= 0;
		serial_data <=0;
		counter<=0;
	end
	else if(serial_en) begin
		if(counter<7 ) begin
		 	serial_data <=P_DATA_reg[counter];
		 	counter<=counter+1;
		end
		else begin
			serial_data <=P_DATA_reg[counter];
			serial_done<=1;
		end
	end
	else begin
		serial_done<=0;
		counter<=0;
	end
end
endmodule 
