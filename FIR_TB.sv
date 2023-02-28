`timescale 1ns/100ps
//FIR TB
module FIR_TB();

//Parameter declarations
parameter CLK_PERIOD = 20;                                                     //Clock period
parameter DATA_WIDTH=16;                                                       //Input signal data width
parameter COEFFICIENT_WIDTH=16;                                                //Coefficients' width
parameter FILTER_LENGTH=71;                                                    //Filter length (number of taps)

//Internal signals declarations
logic rst;                                                                     //TB reset signal (active high logic)
logic rst_fir;                                                                 //FIR filter rst signal (active high logic)
logic clk;                                                                     //Clock signal

int fd;                                                                        //Holds signal file open descriptor
int count_rd;                                                                  //Counter used during txt read operation
logic signed [DATA_WIDTH-1:0] data_in;                                         //A single entry of the input time-domain signal
logic signed [COEFFICIENT_WIDTH-1:0] coeddicient_in;                           //A single entry of the FIR filter coefficients

logic signed [DATA_WIDTH-1:0] mem_input_signal [$];                            //Queue holding the input signal read from the .txt file
logic signed [COEFFICIENT_WIDTH-1:0] filter_coefficients [FILTER_LENGTH-1:0];  //2D array to store the coefficients read from the .txt. file

logic signed [COEFFICIENT_WIDTH+DATA_WIDTH-1:0] o_sig;                         //FIR filter output
logic [DATA_WIDTH-1:0] i_sig_tmp;                                              //Holds the input to the filter - updated on a cycle-by-cycle basis

//FIR filter module instantiation
FIR #(.DATA_WIDTH(DATA_WIDTH),.COEFFICIENT_WIDTH(COEFFICIENT_WIDTH),.FILTER_LENGTH(FILTER_LENGTH)) FIR(.rst(rst_fir),.clk(clk),.i_sig(i_sig_tmp),.o_sig(o_sig), .coefficeints(filter_coefficients));

//Initial blocks
initial begin
rst=0;
rst_fir=0;
clk=0;
count_rd=0;
#1000
rst=1;
#1000
//Reading input signal, x(t), from a text file located in the simulation workng directory
fd=$fopen("input_signal.txt","r");
if (fd) $display("Input signal file opened succefully : %0d", fd);
else $display("Input signal was not succefully opened : %0d", fd);
//Saving the input signal in a 2-D queue named 'mem_input_signal'
while(!$feof(fd)) begin
$fscanf(fd,"%b",data_in);
mem_input_signal.push_front(data_in);
#CLK_PERIOD;
end
$fclose(fd);

#1
count_rd=0;

//Reading FIR filter coefficients from a text file located in the simulation workng directory
fd=$fopen("filter_coefficients.txt","r");
if (fd) $display("Input signal file opened succefully : %0d", fd);
else $display("Input signal was not succefully opened : %0d", fd);
//Saving the FIR filter coefficients 'filter_coefficients'
while(!$feof(fd)) begin
$fscanf(fd,"%b",coeddicient_in);
filter_coefficients[count_rd]=coeddicient_in;
count_rd=count_rd+1;
#CLK_PERIOD;
end
$fclose(fd);

repeat (600) @(posedge clk);
rst_fir=1;                      //Enable FIR filter
repeat (1200) @(posedge clk);
rst_fir=0;                      //Disable FIR filter

end

//HDL code
//Upon filter activation, load instantaneous input signal value from the queue
always @(posedge clk or negedge rst_fir)
  if (!rst_fir)
    i_sig_tmp<='0;
  else if (mem_input_signal.size()>0)
    i_sig_tmp<=mem_input_signal.pop_back();
  else i_sig_tmp<='0;

//Clock generation
always
begin
#(CLK_PERIOD/2);
clk=~clk;
end

endmodule
