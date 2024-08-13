clc; clear all;
fclose('all');

serialobj = instrfind;
if ~isempty(serialobj)
    delete(serialobj)
end
clc; clear all; close all;
s1 = serial('COM5');  % define serial port
s1.BaudRate = 250000;  % define baud rate

fs = 300;  % sample rate
N_data = fs * 10;
disbuff = nan(1, N_data);

fopen(s1);
clear data;
N_point = N_data + fs * 0.2;
time = [1:N_data]/fs;
figure
h_plot = plot(nan, nan);
hold off 
tic
for i = 1:N_point 
    data = fscanf(s1);  % read sensor
    y(i) = str2double(data);
    if y(i)>1000
        y(i) = y(i-1);
    end
    if y(i)<40
        y(i) = y(i-1);
    end
    if isnan(y(i))
        y(i) = y(i-1);
    end

    if i<=N_data
    disbuff(i) = y(i);
    else
    disbuff = [disbuff(2:end) y(i)];
    end

    if i>1
    set(h_plot,'xdata',time,'ydata',disbuff)
    title('Waveform');
    xlabel('Time (s)');
    ylabel('Quantization value');
    drawnow;
    end
end
toc
% close the serial port
fclose(s1);
