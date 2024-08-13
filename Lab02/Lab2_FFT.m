
% fs = 800;  % in Hz
dt = 1/fs;  % time resolution
t_axis = (0:dt:dt*(N_data-1));  % time axis
Npoint = length(disbuff);   % number of points in sampled cosine

df = fs/Npoint;  % frequency resolution
f_axis = (0:1:(Npoint-1))*df;  % frequency axis
DISBUFF = fft(disbuff);  % spectrum of sampled cosine, freqeuncy domain, complex
mag_DISBUFF = abs(DISBUFF);  % magnitude
pha_DISBUFF = angle(DISBUFF);  % phase

figure
subplot(2,1,1)
plot(t_axis, disbuff);
hold
% stem(t_axis, disbuff,'r');
xlabel('Time (sec)');
title('Sampled data (time domain)');

subplot(2,1,2)
plot(f_axis-(fs/2), fftshift(mag_DISBUFF));
xlabel('Frequency (Hz)');
title('Spectrum of sampled data (frequency domain)')
% print -djpeg fft_example.jpg
