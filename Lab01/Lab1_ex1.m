%
%   Matlab script - FFT Example
%                                   Edited by Meng-Lin Li, 10/05/2007
%

% Generate sampled consine
fc = 5; % in MHz
fs = 100; % in MHz
Ncycle = 5; % number of cycles of sampled cosine
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
plot(t_axis, sampled_cos,'linewidth',2);
hold
stem(t_axis, sampled_cos,'r','linewidth',2);
axis([0.2 0.8 -1 1]);   % to zoom in
set(gca,'fontsize',14);
set(gca,'linewidth',2);
set(gca,'box','off');
xlabel('Time (\mus)');
title('Sampled cosine (time domain)');
legend('Original cosine','Sampled cosine','0');	% new !!!!!
legend('boxoff')

subplot(2,1,2)
plot(f_axis, mag_SAMPLED_COS,'linewidth',2);
set(gca,'fontsize',14);
set(gca,'linewidth',2);
set(gca,'box','off');
xlabel('Frequency (MHz)');
title('Spectrum of 5 MHz cosine (frequency domain)')
set(gca,'Xtick',[0 5 10 20 30 40 50 60 70 80 90 95 100]);   % set(gca,'Ytick', [ ]); set(gca,'XtickLabel',[...]);
print -djpeg fft_example.jpg % or print -dtiff fft_example.tif

% Image
Test = randn(101,101);
x_axis = 0:0.5:50;
y_axis = 0:0.25:25;
figure
imagesc(x_axis,y_axis,Test) % vs. imagesc(x_axis, y_axis, Test, [-2 2]);
set(gca,'fontsize',14);
set(gca,'linewidth',2);
set(gca,'box','off');
colorbar
colormap(gray);
xlabel('Test X');
ylabel('Test Y');
axis([10 40 10 20])
set(gca,'Xtick',[10:10:40]);
set(gca,'XtickLabel',['a';'b';'c';'d']);
set(gca,'Ytick',[12:2:18])
set(gca,'YtickLabel',[50 80 10 20]);
