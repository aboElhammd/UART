module MUX (
	input in_1,in_2,in_3,in_4,
	input [1:0] mux_sel,
	output reg TX_OUT_comb
);

always @(*) begin 
	case (mux_sel)
		0:TX_OUT_comb=in_1;
		1:TX_OUT_comb=in_2;
		2:TX_OUT_comb=in_3;
		3:TX_OUT_comb=in_4;		
	endcase
end
endmodule : MUX
