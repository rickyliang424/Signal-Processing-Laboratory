close all; clear; clc;

data = load('ECG_signal.mat');
ECG = data.ECG;
fs = data.fs;
Npoint = length(ECG);
dt = 1 / fs;  % time resolution
t_axis = (0 : dt : 1/fs*(Npoint - 1));
% df = fs / Npoint;  % frequency resolution
% f_axis = (0:1:(Npoint-1))*df - fs/2;  % frequency axis (shifted)

figure();
% subplot(2,1,1);
plot(t_axis, ECG);
xlabel('Time (sec)');
ylabel('Quantized value');
title("Raw ECG Signal");
% subplot(2,1,2);
% plot(f_axis, abs(fftshift(fft(ECG))));
% title('Frequency spectrum');

%% Slope calculation
% a = 1;
% b = [2 1 -1 -2];
% ECG_1 = filter(b, a, ECG);

n = 1;
ECG_1 = zeros(1,length(ECG));
for i = (3*n+1):length(ECG)
    ECG_1(i) = 2*ECG(i) + ECG(i-n) - ECG(i-2*n) - 2*ECG(i-3*n);
end

Npoint_1 = length(ECG_1);
dt_1 = 1 / fs;
t_axis_1 = (0 : dt_1 : 1/fs*(Npoint_1 - 1));
figure();
plot(t_axis_1, ECG_1);

%% 60Hz filtering
% ma = ones(1,3)/3;
% figure();
% plot((0:511)*fs/512, abs(fft(ma,512)));
% xlabel('Hz');
% ECG_2_1 = conv(ECG_1, ma, 'same');
% ECG_2 = conv(ECG_2_1, ma, 'same');

n = 1;
ECG_2_1 = zeros(1,length(ECG_1));
for i = (2*n+1):length(ECG_1)
    ECG_2_1(i) = 1/3*ECG_1(i) + 1/3*ECG_1(i-n) + 1/3*ECG_1(i-2*n);
end
ECG_2 = zeros(1,length(ECG_2_1));
for i = (2*n+1):length(ECG_2_1)
    ECG_2(i) = 1/3*ECG_2_1(i) + 1/3*ECG_2_1(i-n) + 1/3*ECG_2_1(i-2*n);
end

Npoint_2 = length(ECG_2);
dt_2 = 1 / fs;
t_axis_2 = (0 : dt_2 : 1/fs*(Npoint_2 - 1));
% df_2 = fs / Npoint_2;
% f_axis_2 = (0:1:(Npoint_2-1))*df_2 - fs/2;

figure();
% subplot(2,1,1);
plot(t_axis_2, ECG_2);
% title("filtered ECG Signal");
% subplot(2,1,2);
% plot(f_axis_2, abs(fftshift(fft(ECG_2))));
% title('Frequency spectrum');

%% Squaring
ECG_3 = ECG_2 .^ 2;

Npoint_3 = length(ECG_3);
dt_3 = 1 / fs;
t_axis_3 = (0 : dt_3 : 1/fs*(Npoint_3 - 1));
figure();
plot(t_axis_3, ECG_3);

%% Flattening
% df_3 = fs / Npoint_3;
% f_axis_3 = (0:1:(Npoint_3-1))*df_3 - fs/2;
% figure();
% plot(f_axis_3, abs(fftshift(fft(ECG_3))));
% title('Frequency spectrum');

% ma = 1 * ones(1,8)/8;
% figure();
% plot((0:999)*200/1000, abs(fft(ma,1000)));
% xlabel('Hz');

ECG_4 = zeros(1,length(ECG_3));
for i = (8+1):length(ECG_3)
    ECG_4(i) = 1/8*ECG_3(i) + 1/8*ECG_3(i-1) + 1/8*ECG_3(i-2) + 1/8*ECG_3(i-3) + ...
        1/8*ECG_3(i-4) + 1/8*ECG_3(i-5) + 1/8*ECG_3(i-6) + 1/8*ECG_3(i-7) + 1/8*ECG_3(i-8);
end
Npoint_4 = length(ECG_4);
dt_4 = 1 / fs;
t_axis_4 = (0 : dt_4 : 1/fs*(Npoint_4 - 1));
figure();
plot(t_axis_4, ECG_4);

% b = fir1(100, 20/fs*2, 'low');
% % fvtool(b);
% ECG_4 = filter(b, 1, ECG_3);
% 
% Npoint_4 = length(ECG_4);
% dt_4 = 1 / fs;
% t_axis_4 = (0 : dt_4 : 1/fs*(Npoint_4 - 1));
% figure();
% plot(t_axis_4, ECG_4);

%% Thresholding
x_axis = t_axis_4;
data = ECG_4;
[y,x] = findpeaks(data,'minpeakheight',10E4);
peaks_x = x_axis(x(:));
peaks_y = data(x(:));

figure();
plot(t_axis_4, ECG_4);
hold on;
plot(peaks_x, peaks_y, 'o');
xlabel('Time (sec)');
ylabel('Quantized value');

%% Result
range = 20;
peaks = zeros(1, length(x));
for i = 1:length(x)
    a = x(i) - range/2;
    b = x(i) + range/2;
    [mx, index] = max(ECG(a:b));
    peaks(i) = x(i) - range/2 + index - 1;
end

figure();
plot(t_axis, ECG);
hold on;
plot(t_axis(peaks(:)), ECG(peaks(:)), 'o');
xlabel('Time (sec)');
ylabel('Quantized value');
