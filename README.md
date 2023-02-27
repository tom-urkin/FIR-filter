# Finite Impulse Reponse (FIR) Filter

> SystemVerilog FIR filter  

SystemVerilog implementation of __generalized FIR filter module__


## Get Started

The source files  are located at the repository root:

- [FIR filter Matlab script](./FIR_Design.m)
- [FIR filter](./FIR.sv)
- [FIR filter coefficients](./filter_coefficients.txt)
- [Input signal](./input_signal.txt)
- [FIR filter TB](./FIR_TB.sv)

##
This repository containts a SystemVerilog implementation of a parametrized finite impulse reponse (FIR) filter as well as a Matlab script for coefficient selection and input data pre-processing. Theoretical background can be found in [XXX](https://www.pololu.com/file/0J435/UM10204.pdf).

##Matlab script
The filter coefficients are obtained from the attached Matlab script which also converts the floating point representation of the built-in 'fir1' function into a user-defined fixed-point representation. In addition, the input signal to be filtered undergoes similar convertion to fixed-point representation.These are exported to two text files ('filter_coefficients' and 'input_signal') which are then imported to the TB.
The coefficeints in this example are derived to satisfy:
	1.Passband frequency of 10kHz
	2.Stopband frequency of 15kHz
	3.Stopband attenuation in dB
	4.Sampling frequency of 192kHz
	
**Frequency response of the FIR filter for floating-point and 16-bit fixed point representation:**
	![M_Fig_1](./docs/M_Fig_1.jpg)  


## Testbench

The testbench comprises five tests covering key scenarios of multi-controller (3) multi-target (2) I2C systems.

1.	Communication between controller '1' and target '1'. Write data from controller to target (3 data frames).
	Here the data sent from the controller to the peripheral unit is 24-bit long (3 data frames, 110010101111000110101111). 
	The target unit is 'target_1' (addr_1=7'b1000111) which is configured to execute byte-level clock streching.
	
	**Communication between controller '1' and target '1':**
		![tst1_wave](./docs/tst1_wave.jpg)  
		
2.	Communication between controller '2' and target '2'. Write data from controller to target (2 data frames).
	Here the data sent from the controller to the peripheral unit is 16-bit long (2 data frames, 0011010111001111). 
	The target unit is 'target_2' (addr_1=7'b1001111) which is configured to execute byte-level clock streching.
	
	**Communication between controller '2' and target '2':**
		![tst2](./docs/tst2_wave.jpg)  

3.	Communication between controller '3' and an unkown target (address mismatch - terminated after the acknoledgement bit)
	Here the address of the target device (7'b1111110) does not match to any existing devices on the line. 
	
	**Communication between controller '3' and unkown target device:**
		![tst3](./docs/tst3_wave.jpg)  

4.	Communication between controller '1' and target '2'. Read data from target to controller (2 bytes are read)
	Note: Clock strectching is carried only when data is transferred from the controller to the target.
	
	**Communication between controller '1' and target '2':**
		![tst4](./docs/tst4_wave.jpg)  
		
5.	Communication between controller '1' and target '1'. Read data from target to controller (1 byte is read)
	Note: Clock strectching is carried only when data is transferred from the controller to the target.
	
	**Communication between controller '1' and target '1':**
		![tst5](./docs/tst5_wave.jpg)  

6.	Clock synchronization and arbitration verification
	The two controllers try to control the I2C lines. The timing specifiaction of the two are deliberately different to verify the clock synchronization logic (please see the I2C protocal manual for detailed explanation). Controller '1' is the 'winner' of the arbritration procedure (after the 4th address bit).
	
	**Clock synchronization and arbitration verification: controller '1' wins the arbritration proccess:**
		![tst6](./docs/tst6_wave.jpg)  

## FPGA - DS3231 RTC Interface
A real-time-clock (RTC) IC is programmed via I2C protocol. Here, the controller module described above is realized on an altera Cyclone V FPGA while the RTC IC acts as the target device (target address 7'b1101000). 
The datasheet of the DS3231 RTC IC can be found in the following [link](https://www.analog.com/media/en/technical-documentation/data-sheets/DS3231.pdf).

1.	Setting the time and date
	The written data is : 8'h2e,8'h42,8'h45,8'h03,8'h07,8'h01,8'h72 to registers 00h->06h. This sets the time and data to: 05:42:34 Tuesday, January 7th in year 72.
	
	**Setting the time and date:**
		![experimental_setting_time_and_date](./docs/experimental_setting_time_and_date.jpg)  

	**Zoom in on the DS3231 address and first sent byte sent:**
		![experimental_setting_time_and_date_zoom_in](./docs/experimental_setting_time_and_date_zoom_in.jpg)  

2.	Setting the control register
	The control register is located on address 0Eh. For the purppose of visual verificatoin brought here, the command written,18h, to the control register resuls in a 8kHz squarewave on the SQW pin.
	
	**Setting the control register:**
		![Setting_control_register](./docs/Setting_control_register.jpg)  

3.	Read data from the RTC IC to the controller module in the FPGA
	The first 7 bytes indicate the current time and date while the last two are the control and status registers.
	The read data indicates the current time is: 05:43:20 Tuesday, January 7th in year 72
	
	**Read_data:**
		![Read_data](./docs/Read_data.jpg) 		
		
	**The read data can also be observed via the signaltap on the FPGA for verification purposes as follows:**
		![SignalTap](./docs/SignalTap.JPG)		
		
## Support

I will be happy to answer any questions.  
Approach me here using GitHub Issues or at tom.urkin@gmail.com