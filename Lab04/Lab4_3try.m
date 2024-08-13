clear; clc;

load 'C:/Users/Ricky/Desktop/MATLAB/DSP_Lab/MIT_BIH/easy/117m.mat';
ECG = val(1,:);
fs = 360;
Npoint = length(ECG);
dt = 1 / fs;
time = (0:1:(Npoint-1))*dt;
df = fs / Npoint;
freq = (0:1:(Npoint-1))*df - fs/2;

figure();
subplot(2,1,1);
plot(time, ECG);
title("Time Domain");
xlim([0 10]);
subplot(2,1,2);
plot(freq, abs(fftshift(fft(ECG))));
title('Frequency Domain');
ylim([0 1E6]);

%%
ma1 = [2 zeros(1, 7 -2) -2];
ma2 = [1/2 0 1/2];
ma3 = [1/2 0 0 1/2];
ma4 = [1/2 0 0 0 1/2];
ma5 = [1/2 0 0 0 0 1/2];
ma6 = [1/2 0 0 0 0 0 1/2];
figure();
plot((0:1E4-1)*fs/1E4, abs(fft(ma1,1E4)), '--'); hold on;
plot((0:1E4-1)*fs/1E4, abs(fft(ma2,1E4)), '--'); hold on;
plot((0:1E4-1)*fs/1E4, abs(fft(ma3,1E4)), '--'); hold on;
plot((0:1E4-1)*fs/1E4, abs(fft(ma4,1E4)), '--'); hold on;
plot((0:1E4-1)*fs/1E4, abs(fft(ma5,1E4)), '--'); hold on;
plot((0:1E4-1)*fs/1E4, abs(fft(ma6,1E4)), '--'); hold on;
plot((0:1E4-1)*fs/1E4, abs(fft(ma1,1E4)) .* abs(fft(ma2,1E4)) .* abs(fft(ma3,1E4)) .* abs(fft(ma4,1E4)) .* abs(fft(ma5,1E4)) .* abs(fft(ma6,1E4)), 'k-', 'LineWidth', 1);
xticks([0*60 1*60 2*60 3*60 4*60 5*60 6*60]);
xlim([0 fs]);

%%
ma = conv(ma1, ma2);
ma = conv(ma , ma3);
ma = conv(ma , ma4);
ma = conv(ma , ma5);
ma = conv(ma , ma6);
figure();
subplot(2,1,1);
plot(ma, 'o');
subplot(2,1,2);
plot((0:1E4-1)*fs/1E4, abs(fft(ma,1E4)));
xticks([0*60 1*60 2*60 3*60 4*60 5*60 6*60]);
xlim([0 fs]);

%%
ECG_t = zeros(1,length(ECG));
for i = (length(ma)+1):length(ECG_t)
    for j = 1:length(ma)
        ECG_t(i) = ECG_t(i) + ma(j)*ECG(i-j+1);
    end
end
figure();
subplot(2,1,1);
plot(time, ECG_t);
title("Time Domain");
xlim([0 10]);
subplot(2,1,2);
plot(freq, abs(fftshift(fft(ECG_t))));
title('Frequency Domain');
