//
module FIR_stage(rst,clk,i_sig,o_sig,delayed_sig,coefficient);
//Parameters
parameter DATA_WIDTH=16;
parameter COEFFICIENT_WIDTH=16;
//Input signals
input logic clk;
input logic rst;
input logic signed [DATA_WIDTH-1:0] i_sig;
input logic signed [COEFFICIENT_WIDTH-1:0] coefficient;
//Output signals
output logic signed [COEFFICIENT_WIDTH+DATA_WIDTH-1:0] o_sig;
output logic signed [DATA_WIDTH-1:0] delayed_sig;
//HDL code
always @(posedge clk or negedge rst)
	if (!rst) begin
		o_sig<='0;
		delayed_sig<='0;
	end
	else begin
		delayed_sig<=i_sig;
		o_sig<=i_sig*coefficient;
	end
endmodule

//FIR filter
module FIR(rst,clk,i_sig,o_sig,coefficeints);

//Parameters
parameter FILTER_LENGTH=1;
parameter DATA_WIDTH=16;
parameter COEFFICIENT_WIDTH=16;

//Inputs
input logic rst;
input logic clk;
input logic signed [DATA_WIDTH-1:0] i_sig;
input logic signed [COEFFICIENT_WIDTH-1:0] coefficeints [FILTER_LENGTH-1:0];

//Internal signals
logic signed [COEFFICIENT_WIDTH+DATA_WIDTH-1:0] stage_out [FILTER_LENGTH-1:0];
logic signed [DATA_WIDTH-1:0] delayed_sig [FILTER_LENGTH-1:0];
logic signed [COEFFICIENT_WIDTH+DATA_WIDTH-1:0] sum_tmp;
int j;
//Outputs
output logic signed [COEFFICIENT_WIDTH+DATA_WIDTH-1:0] o_sig;
//HDL code
		
genvar i;

generate
	for (i=0; i<FILTER_LENGTH; i=i+1) begin : koko
		if (i==0)
			FIR_stage #(.DATA_WIDTH(DATA_WIDTH),.COEFFICIENT_WIDTH(COEFFICIENT_WIDTH)) u0 (.rst(rst),.clk(clk),.i_sig(i_sig),.o_sig(stage_out[0]),.delayed_sig(delayed_sig[0]),.coefficient(coefficeints[0]));
		else
			FIR_stage #(.DATA_WIDTH(DATA_WIDTH),.COEFFICIENT_WIDTH(COEFFICIENT_WIDTH)) u0 (.rst(rst),.clk(clk),.i_sig(delayed_sig[i-1]),.o_sig(stage_out[i]),.delayed_sig(delayed_sig[i]),.coefficient(coefficeints[i]));
	end
endgenerate
		
always @(*)	begin
	sum_tmp=0;
	for (j=0; j<FILTER_LENGTH; j++)
		sum_tmp=sum_tmp+stage_out[j];
end

assign o_sig=sum_tmp;

endmodule
