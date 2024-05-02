module register #(parameter IDLE_STATE_VALUE)(
	input CLK,RST,
	input in_comb,
	output reg output_seq
);
always @(posedge CLK or negedge RST) begin : proc_
	if(~RST) begin
		output_seq <= IDLE_STATE_VALUE;
	end else begin
		output_seq <= in_comb;
	end
end
endmodule 
