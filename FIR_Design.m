%LPF FIR filter example using Hamming window
%Input signals are 16-bit fixed-point numbers
%Filter coefficients are 16-bit fixed-point numbers 

%% 
%Filter design
close all;
clear all;
clc;
%Filter requirements
f1=10e3;                                        %Passband frequency
f2=15e3;                                        %Stopband frequency
Adb=40;                                         %Stopband attenuation in dB
fs=192e3;                                       %Sampling frequency
delta_f=f2-f1;                                  %Transition band

N=(Adb*fs)/(22*delta_f);                        %Calculation of the required number of coefficients (filter length)
FIR_filter=fir1(round(N),f1/(fs/2), 'low');     %Calculating filter coefficients in double percision. Cutoff in Hz = normalized cutoff * 0.5 * fs. 
FIR_filter_fixed=fi(FIR_filter,1,16,15);        %Convert to 16-bit signed fixed point with 15-bit fractional part. Note: this is not binary fixed-point, it is decimal fixed-point
%Fixed-point verification using: https://github.com/chummersone/chummersone.github.io
FIR_filter_fixed_verification=[-0.000640869140625,-0.000762939453125,-0.000823974609375,-0.000823974609375,-0.000732421875,-0.000518798828125,-0.000091552734375,0.00048828125,0.00128173828125,0.002166748046875,0.0030517578125,0.003814697265625,0.004241943359375,0.004119873046875,0.00335693359375,0.001800537109375,-0.000518798828125,-0.003509521484375,-0.006927490234375,-0.0103759765625,-0.013397216796875,-0.015411376953125,-0.015869140625,-0.014251708984375,-0.010162353515625,-0.003448486328125,0.00592041015625,0.017669677734375,0.03125,0.0458984375,0.06072998046875,0.074737548828125,0.0869140625,0.096343994140625,0.102325439453125,0.1043701171875,0.102325439453125,0.096343994140625,0.0869140625,0.074737548828125,0.06072998046875,0.0458984375,0.03125,0.017669677734375,0.00592041015625,-0.003448486328125,-0.010162353515625,-0.014251708984375,-0.015869140625,-0.015411376953125,-0.013397216796875,-0.0103759765625,-0.006927490234375,-0.003509521484375,-0.000518798828125,0.001800537109375,0.00335693359375,0.004119873046875,0.004241943359375,0.003814697265625,0.0030517578125,0.002166748046875,0.00128173828125,0.00048828125,-0.000091552734375,-0.000518798828125,-0.000732421875,-0.000823974609375,-0.000823974609375,-0.000762939453125,-0.000640869140625];

figure (1)
[h,w]=freqz(FIR_filter,1,512,fs);               %Double precision. Plot the frequency response ih Hz (remove the 'fs' to plot in normalized freuqency units)
[h_fixed,w_fixed]=freqz(double(FIR_filter_fixed),1,512,fs);       %16-bit fixed-point. Plot the frequency response ih Hz (remove the 'fs' to plot in normalized freuqency units)
subplot(2,1,1)
plot(w,20*log10(abs(h)),'r')
hold on 
plot(w_fixed,20*log10(abs(h_fixed)),'b')
title('Magnitude')
legend('64-bit floating point','16-bit fixed point')
grid on
subplot(2,1,2)
plot(w,unwrap(angle(h)),'r')
title('Phase')
hold on
plot(w_fixed,unwrap(angle(h_fixed)),'b')
grid on

%Plot the filter coefficients
figure (2)
stem(FIR_filter,'r');
hold on
stem(FIR_filter_fixed,'b');
title('Filter coefficients')                    
legend('64-bit floating point','16-bit fixed point')
grid on;

%%
%Filtering operation
x = sin(2*pi*[1:1000]*5000/fs) +  sin(2*pi*[1:1000]*2000/fs) + sin(2*pi*[1:1000]*15000/fs)  + sin(2*pi*[1:1000]*18000/fs);  %time domain signal comprising four sinusoid signals
x_fixed=fi(x,1,16,13);                                        %Convert the input signal to 16-bit fixed point representation

xf = filter(FIR_filter,1,double(x_fixed));                                  %Full precision filtered signal
xf_fixed = filter(FIR_filter_fixed,1,x_fixed);                %Filtered signal 

%Plotting time domain signals (input signal (x) and the filtered signal (xf))
figure (3)

subplot (2,1,1)
plot (x_fixed,'b')
legend('16-bit fixed point input signal')
title('Input signal')
grid on

subplot(2,1,2)
plot(xf,'r')                %16-bit input signal and double precision coefficients
hold on
plot (xf_fixed,'b')         %16-bit input signal and 8-bit coefficients
legend('Double precision coefficients','16-bit coefficients')
title('Filtered Signal with 16-bit FIR filter coefficients')
xlabel('time')
ylabel('amplitude')
grid on

%Plotting frequency domain signals
sig_fixed = 20*log10(abs(fftshift(fft(double(x_fixed),4096))));

figure (4)
subplot(2,1,1)
plot((-0.5:1/4096:0.5-1/4096)*fs,sig_fixed,'color','b')  %Plot between -0.5fs to 0.5fs the spectrum of the original signal
hold on
plot((-0.5:1/4096:0.5-1/4096)*fs,20*log10(abs(fftshift(fft(FIR_filter,4096)))),'color','r') %Plot between -0.5fs to 0.5fs the spectrum of the filter
hold on
plot((-0.5:1/4096:0.5-1/4096)*fs,20*log10(abs(fftshift(fft(double(FIR_filter_fixed),4096)))),'color','g') %Plot between -0.5fs to 0.5fs the spectrum of the filter
hold off
axis([0 20000 -60 60])
title('Input signal')
grid on
legend('16-bit fixed point input signal', 'Double precision coefficients','16-bit coefficients')

subplot(2,1,2)
plot((-0.5:1/4096:0.5-1/4096)*fs,20*log10(abs(fftshift(fft(xf,4096)))),'color','r')
hold on
plot((-0.5:1/4096:0.5-1/4096)*fs,20*log10(abs(fftshift(fft(double(xf_fixed),4096)))),'g')
axis([0 20000 -60 60])
title('Filtered signal')
xlabel('Hz')
ylabel('dB')
grid on

%%
%Extracting the FIR filter coefficients 
FIR_filter
FIR_filter_fixed
FIR_filter_fixed_verification
%Converting to binary representation (1 integer and 15 fraction bits)
binary_FIR_filter_fixed=strsplit(bin(FIR_filter_fixed))
%Converting the input signal to binary represrntation (3 integer bits and 13 fractional bits)
binary_x_fixed=strsplit(bin(x_fixed))

%Extracting to text files
writecell(reshape(binary_FIR_filter_fixed,71,[]),'filter_coefficients.txt');
writecell(reshape(binary_x_fixed,1000,[]),'input_signal.txt');