module UART_TOP #(parameter WIDTH=8)(
	input CLK,RST,
	input PAR_TYPE,PAR_EN,
	input [WIDTH-1:0] P_DATA,
	input DATA_VALID,
	output TX_OUT,BUSY
);
/*------------------------------------------------------------------------------
--internal signals declarations  
------------------------------------------------------------------------------*/
wire serial_en,serial_done,serail_data;
wire [1:0] mux_sel;
wire parity_bit;
wire TX_OUT_comb,busy_comb;
wire stop_case;
wire PAR_EN_reg;
parameter START_BIT=0;
parameter STOP_BIT=1;
/*------------------------------------------------------------------------------
-- FSM instansiation  
------------------------------------------------------------------------------*/
UART_FSM  FSM(
	 .CLK(CLK),
	 .DATA_VALID(DATA_VALID),
	 .PAR_EN_reg(PAR_EN_reg),
	 .RST(RST),
	 .serial_done(serial_done) ,
	 .mux_sel(mux_sel),
	.serial_en  (serial_en),
	 .BUSY(busy_comb)
);
/*------------------------------------------------------------------------------
--serailizer instanstiation  
------------------------------------------------------------------------------*/
UART_SERIALIZER #(.WIDTH(WIDTH)) SERILIZER(
	 	.CLK(CLK),
	 	.serial_en(serial_en),
	 	.RST(RST) ,
	  .P_DATA(P_DATA),
	  .serial_done(serial_done),
	  .serial_data(serial_data) ,
	  .stop_case  (stop_case) ,
	  .DATA_VALID(DATA_VALID)
);
/*------------------------------------------------------------------------------
-- parity block instansiation  
------------------------------------------------------------------------------*/
UART_PARITY_GENERATOR #(.WIDTH(8)) PARITY_GENERATOR(
	 .CLK(CLK),
	 .RST(RST),
	 .P_DATA(P_DATA),
	 .PAR_EN(PAR_EN),
	 .PAR_TYPE(PAR_TYPE),
	 .parity_bit(parity_bit),
	 .stop_case(stop_case),
	 .DATA_VALID(DATA_VALID),
	.PAR_EN_reg(PAR_EN_reg)
);
/*------------------------------------------------------------------------------
-- mux instantiations  
------------------------------------------------------------------------------*/
 MUX UART_MUX(
	 .in_1(START_BIT),.in_2(serial_data),.in_3(parity_bit),.in_4(STOP_BIT),
	  .mux_sel(mux_sel),
	 .TX_OUT_comb(TX_OUT_comb)
);
 /*------------------------------------------------------------------------------
 -- registering outputs  
 ------------------------------------------------------------------------------*/
  register #(.IDLE_STATE_VALUE(0))BUSY_SIGNAL(
	 .CLK(CLK),
	 .RST(RST),
	 .in_comb(busy_comb),
		.output_seq(BUSY)
	);
  register #(.IDLE_STATE_VALUE(1)) TX_SIGNAL(
	.CLK(CLK),
	.RST(RST),
	.in_comb(TX_OUT_comb),
	.output_seq(TX_OUT)
	);
endmodule 