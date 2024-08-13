%
%   Matlab script - FFT Example
%                                   Edited by Meng-Lin Li, 10/05/2007
%

% Generate sampled consine
fc = 5; % in MHz
fs = 100; % in MHz
Ncycle = 20; % number of cycles of sampled cosine
dt = 1/fs;  % time resolution
t_axis = (0:dt:Ncycle/fc);  % time axis
sampled_cos = cos(2*pi*fc*t_axis);  % sampled cosine ,time domain
Npoint = length(sampled_cos);   % number of points in sampled cosine

% Fourier transform
df = fs/Npoint; % frequency resolution
f_axis = (0:1:(Npoint-1))*df;   % frequency axis
SAMPLED_COS = fft(sampled_cos); % spectrum of sampled cosine, freqeuncy domain, complex
mag_SAMPLED_COS = abs(SAMPLED_COS);   % magnitude
pha_SAMPLED_COS = angle(SAMPLED_COS); % phase

figure
subplot(2,1,1)
plot(t_axis, sampled_cos);
hold
stem(t_axis, sampled_cos,'r');
xlabel('Time (\mus)');
title('Sampled cosine (time domain)');

subplot(2,1,2)
plot(f_axis, mag_SAMPLED_COS);
xlabel('Frequency (MHz)');
title('Spectrum of 5 MHz cosine (frequency domain)')
set(gca,'Xtick',[0 5 10 20 30 40 50 60 70 80 90 95 100]);
print -djpeg fft_example.jpg
