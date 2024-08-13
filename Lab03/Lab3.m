close all; clear; clc;
%% Load ECG data
% This raw ECG did not go through the analog notch filter
data = load('ECG_signal.mat');
ECG = data.ECG;
fs = data.fs;
Npoint = length(ECG);

% calculate t_axis and f_axis
dt = 1 / fs;  % time resolution
t_axis = (0 : dt : 1/fs*(Npoint - 1));
df = fs / Npoint;  % frequency resolution
f_axis = (0:1:(Npoint-1))*df - fs/2;  % frequency axis (shifted)

% plot signal and its frequency spectrum
figure();
subplot(2,1,1);
plot(t_axis, ECG);
xlabel('Time (sec)');
ylabel('Quantized value');
title("Raw ECG Signal");
subplot(2,1,2);
plot(f_axis, abs(fftshift(fft(ECG))));
title('Frequency spectrum');

%% (1) Design a digital filter to remove the 60Hz power noise
% filter design
% https://www.mathworks.com/help/signal/filter-design.html
% Hint: you may use moving average filter or fir1() or anything else
% In the report, please describe how you design this filter
% filtering
B1 = fir1(100, 56/fs*2, 'low');
% fvtool(B1);
% ECG_1 = filter(B1, 1, ECG);
ECG_1 = filter(B1, 1, [ECG zeros(1,200)]);

% Plot the filtered signal and its frequency spectrum
Npoint_1 = length(ECG_1);
dt_1 = 1 / fs;
t_axis_1 = (0 : dt_1 : 1/fs*(Npoint_1 - 1));
df_1 = fs / Npoint_1;
f_axis_1 = (0:1:(Npoint_1-1))*df_1 - fs/2;

figure();
subplot(2,1,1);
plot(t_axis_1, ECG_1);
title("filtered ECG Signal");
subplot(2,1,2);
plot(f_axis_1, abs(fftshift(fft(ECG_1))));
title('Frequency spectrum');

%% (2) Design a digital filter to remove baseline wander noise
% filter design or somehow remove the baseline wander noise
% Hint: you may use high-pass filters or (original signal - low passed signal)
B2 = fir1(200, 1/fs*2, 'high');
% fvtool(B2);
% ECG_2 = filter(B2, 1, ECG_1);
ECG_2 = filter(B2, 1, [ECG_1 zeros(1,200)]);

% plot the filtered signal
Npoint_2 = length(ECG_2);
dt_2 = 1 / fs;
t_axis_2 = (0 : dt_2 : 1/fs*(Npoint_2 - 1));
df_2 = fs / Npoint_2;
f_axis_2 = (0:1:(Npoint_2-1))*df_2 - fs/2;

figure();
subplot(2,1,1);
plot(t_axis_2, ECG_2);
title("filtered ECG Signal");
subplot(2,1,2);
plot(f_axis_2, abs(fftshift(fft(ECG_2))));
title('Frequency spectrum');

%% (3) Utilizing the ADC dynamic range in 8-bit
% the code should be written in Arduino
