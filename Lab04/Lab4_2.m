fclose('all'); clear all; clc;

serialobj = instrfind;
if ~isempty(serialobj)
    delete(serialobj);
end
clc; clear all; close all;
s1 = serial('COM5');  % define serial port
s1.BaudRate = 250000;  % define baud rate

fs = 180;  % sample rate
disdata = fs * 3;
disbuff = nan(1, disdata);

fopen(s1);
clear data;
totdata = disdata + fs * 17;
time = [1:disdata]/fs;
figure();

tic
% profile on
for i = 1:totdata 
    data = fscanf(s1);  % read sensor
    y(i) = str2double(data);  % string to double
    
    % Check input valid
    if i >= 2
        y(i) = Checkvalid(y(i), y(i-1));
    else
        y(i) = 0;
    end
    
    % Data preprocessing
    if i >= 8
        ECG = Preprocess(y(end-7:end));
    else
        ECG = 0;
    end
    
    % Make disbuff changable
    if i <= disdata
        disbuff(i) = ECG;
    else
        disbuff = [disbuff(2:end) ECG];
    end
    
    % Display waveform
    if mod(i,20) == 0
        [py, px] = Findpeaks(time, disbuff);
        plot(time, disbuff, 'k-', px, py, 'bo');
        rate = HeartRate(px);
        title("Average Heart Rate:" + rate);
        xlabel('Time (s)');
        ylabel('Quantization value');
        drawnow;
    end
end
% profile viewer
toc
fclose(s1);  % close the serial port
% save('myECG', 'disbuff', 'fs');

function data = Checkvalid(new, old)
    if new > 1000
        data = old;
    elseif new < 40
        data = old;
    elseif isnan(new)
        data = old;
    else
        data = new;
    end
end

function data = Preprocess(X)
    % Slope calculation
    for i = 4:length(X)
        X_1(i-3) = 2*X(i) + X(i-1) - X(i-2) - 2*X(i-3);
    end
    % 60Hz filtering
    for i = 3:length(X_1)
        X_2(i-2) = 1/3*X_1(i) + 1/3*X_1(i-1) + 1/3*X_1(i-2);
    end
    for i = 3:length(X_2)
        data(i-2) = 1/3*X_2(i) + 1/3*X_2(i-1) + 1/3*X_2(i-2);
    end
end

function [peaks_y, peaks_x] = Findpeaks(time, data)
    [~, locs] = findpeaks(data,'minpeakheight',200);
    peaks_x = time(locs(:));
    peaks_y = data(locs(:));
end

function rate = HeartRate(px)
    diff = zeros(1, length(px)-1);
    for i = 2:length(px)
        diff(i-1) = px(i) - px(i-1);
    end
    rate = 60 ./ mean(diff);
end
