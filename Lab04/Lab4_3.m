%% load data
clear; clc;
mat = load('C:/Users/Ricky/Desktop/MATLAB/DSP_Lab/MIT_BIH/hard/203m.mat');
txt = fopen('C:/Users/Ricky/Desktop/MATLAB/DSP_Lab/MIT_BIH/hard/203.txt');
txt = textscan(txt, '%{m:ss.SSS}D %*[^\n]');

ECG = mat.val(1,:);
fs = 360;
Time = (0:1:(length(ECG)-1))/fs;
GT = 60*minute(txt{1,1}) + second(txt{1,1});

%% plot the first 10 sec
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

%% preprocessing
ma = [2 0 0 0 0 0 -2];
% figure();
% plot((0:1E4-1)*fs/1E4, abs(fft(ma,1E4)));
% xticks([0*60 1*60 2*60 3*60 4*60 5*60 6*60]);
% xlim([0 fs]);

ECG_p = zeros(1,length(ECG));
for i = (length(ma)+1):length(ECG_p)
    for j = 1:length(ma)
        ECG_p(i) = ECG_p(i) + ma(j)*ECG(i-j+1);
    end
end
figure();
subplot(2,1,1);
plot(time, ECG_p);
title("Time Domain");
xlim([0 10]);
subplot(2,1,2);
plot(freq, abs(fftshift(fft(ECG_p))));
title('Frequency Domain');
ylim([0 1E6]);

%% find peaks
[~, locs] = findpeaks(ECG_p,'minpeakheight',400);
range = 18;
peaks = zeros(1, length(locs));
result = zeros(length(locs), 1);
for i = 1:length(locs)
    a = locs(i) - range/2;
    b = locs(i) + range/2;
    [~, index] = max(ECG(a:b));
    peaks(i) = locs(i) - range/2 + index - 1;
    result(i+1) = Time(peaks(i));
end
% figure();
% plot(time, ECG_p);
% hold on;
% plot(time(locs(:)), ECG_p(locs(:)), 'o');
% title("Processed data");
% xlim([0 100]);
figure();
plot(time, ECG);
hold on;
plot(time(peaks), ECG(peaks), 'o');
title("Raw data");
xlim([0 100]);

%%
TP = 0;
FN = 0;
FP = 0;
fn = [];
fp = [];
GT = round(GT, 3);
result = round(result, 3);
for i = 1:length(GT)
    dist = abs(GT(i) - result(i+FP));
    if dist < 0.01
        TP = TP + 1;
    elseif dist < 0.05
        FN = FN + 1;
        fn(end+1) = i;
    else
        FP = FP + 1;
        fp(end+1) = i;
    end
end
