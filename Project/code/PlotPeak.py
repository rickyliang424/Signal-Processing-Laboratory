# -*- coding: utf-8 -*-
"""
Created on Mon Dec 27 17:04:26 2021
@author: Ricky
"""
import librosa
import librosa.display
import numpy as np
from scipy.fft import fft
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter, freqz

def addnoise(signal, SNR):
    reqSNR = 10**(SNR/10)
    pow_s = np.mean(signal**2)
    pow_n = pow_s / reqSNR
    RMS_n = np.sqrt(pow_n)
    noise = np.random.normal(0, RMS_n, len(signal))  # rand, randn
    AWGN = signal + noise
    return AWGN

## load audio file
file = "Voice_water3.wav"
path = 'C:/Users/Ricky/OneDrive/大四上 課程/數位訊號處理實驗/Final Project/' + file
data, fs = librosa.load(path, sr=None)
data = addnoise(data, SNR=80)

#%% ###########################################################################
## Try it directly on the spectrogram
def plot_spectrogram(x, fs, n_fft, plot=False):
    spectrum = np.abs(librosa.stft(x, n_fft=n_fft))
    y = librosa.amplitude_to_db(spectrum, ref=np.min)
    if plot == True:
        plt.figure()
        librosa.display.specshow(y, sr=fs, x_axis='frames', y_axis='log')
        plt.colorbar(format='%+2.0f dB')
        plt.title('Power Spectrogram')
    return y

def filtering(x, fs, cutoff, btype, order, plot=False):
    nyq = 0.5 * fs
    if type(cutoff) == list:
        normal_cutoff = np.ndarray.tolist(np.array(cutoff) / nyq)
    else:
        normal_cutoff = cutoff / nyq
    b, a = butter(N=order, Wn=normal_cutoff, btype=btype)
    y = lfilter(b, a, x)
    w, h = freqz(b, a)
    if plot == True:
        f = (fs * 0.5 / np.pi) * w
        plt.figure()
        plt.plot(f, abs(h))
        plt.plot([0, 0.5*fs], [np.sqrt(0.5), np.sqrt(0.5)], '--', label='-3dB')
        plt.xlim([0, 1000])
        plt.xlabel('Frequency (Hz)')
        plt.ylabel('Gain')
        plt.legend(loc='best')
        plt.grid()
    return y

def thresholding(x, fs, plot=False):
    th = np.tile((np.mean(x,axis=0) + np.std(x,axis=0) * 2), (x.shape[0], 1))
    y = np.array(x - th)
    y[y<=0] = 0
    if plot == True:
        plt.figure()
        librosa.display.specshow(y, sr=fs, x_axis='frames', y_axis='log')
        plt.colorbar(format='%+2.0f dB')
        plt.title('Power Spectrogram')
    return y

def find_peak(x, fs, plot=False):
    x_data = []
    y_data = []
    freq_step = round(0.5*fs / x.shape[0])
    for frame in range(x.shape[1]):
        peak = np.argmax(x[:,frame])
        x_data.append(frame)
        y_data.append( 0 if (peak*freq_step == 0) else np.log2(peak*freq_step))
    if plot == True:
        plt.figure()
        plt.scatter(x_data, y_data, s=1)
        plt.xlabel('frames')
        plt.ylabel('frequency (Hz)')
        plt.ylim([5,15])
        plt.yticks(np.arange(6,15), ([str(2**i) for i in range(6,15)]))
        plt.grid()
    y = np.array([x_data,y_data])
    return y

D = plot_spectrogram(data, fs, n_fft=8192, plot=True)
x = filtering(data, fs, 150, btype='high', order=5, plot=False)
D = plot_spectrogram(x, fs, n_fft=8192, plot=True)
D = thresholding(D, fs, plot=True)
p = find_peak(D, fs, plot=True)

#%% ###########################################################################
## Predict the peak from each frame
n_fft = 8192
win_length = n_fft
hop_length = win_length // 4
## simulate the real data input
seq = []
for i in range(len(data)):
    if (i+1) % hop_length == 0:
        begin = i+1-hop_length
        if (begin+n_fft) <= len(data):
            seq.append(data[begin:begin+n_fft])

## parameters setting and initialize
base_u = 800  ## 基頻上限
base_d = 250  ## 基頻下限
delta_u = 20  ## 取峰值的範圍(往上)
delta_d = 5  ## 取峰值的範圍(往上)
delta_p = 5  ## 兩次峰值之間的差距
wait = 5  ## 峰值連續幾次在基頻範圍則開始預測
f = np.arange(n_fft) / n_fft * fs  ## 0~fs Hz
base_range = np.where((f >= base_d) & (f <= base_u))[0]  ## 基頻範圍
detect = 0  ## 峰值在基頻範圍內
old_peak = 0  ## 前一frame的峰值
x_data, y_data = [], []

## record peaks
for i in range(len(seq)):
    ## Fourier transform
    X = librosa.amplitude_to_db(np.abs(fft(seq[i])), ref=np.min)
    ## thresholding
    th = (np.mean(X) + np.std(X) * 1)
    X = np.array(X - th)
    X[X<=0] = 0
    ## find peak
    if detect < wait:
        peak = np.argmax(X[base_range[0]:base_range[-1]]) + base_range[0]
        if (peak-old_peak>=-delta_p) & (peak-old_peak<=delta_p):
            detect = detect + 1
        else:
            detect = 0
    else:
        peak = np.argmax(X[(old_peak-delta_d):(old_peak+delta_u)]) + old_peak - delta_d
    ## record data
    x_data.append(i)
    y_data.append(np.log2(f[peak]))
    old_peak = peak

## plot prediction
plt.figure()
plt.scatter(x_data, y_data, s=2)
plt.xlabel('frames')
plt.ylabel('frequency (Hz)')
plt.title('Predicted frequency peaks')
plt.ylim([5,15])
plt.yticks(np.arange(6,15), ([str(2**i) for i in range(6,15)]))  ## log scale
plt.grid()

#%% ###########################################################################
## Real time plot
plt.figure()
x, y = [], []
stop = 0
for i in range(len(x_data)):
    ## get new data and plot
    x.append(x_data[i])
    y.append(y_data[i])
    plt.scatter(x, y, s=5)
    plt.title("Real-Time Plot")
    plt.xlabel("frames")
    plt.ylabel("frequency (Hz)")
    plt.grid()
    ## set axis
    plt.xlim([0,x_data[i]+2])
    y_max = int(np.ceil(np.max(y))) + 2
    y_min = int(np.floor(np.min(y))) - 1
    plt.yticks(np.arange(y_min,y_max), ([str(2**i) for i in range(y_min,y_max)]))
    ## add text
    freq = int(2**y_data[i])  ## current frequency
    rest = round((331+0.6*20)/freq/4*100, 1)  ## current remaining water level
    text = 'freq=' + str(freq) + 'Hz\n' + 'rest=' + str(rest) + 'cm'
    plt.text(x_data[i], y_min+1, text, fontsize=20, 
              verticalalignment='top', horizontalalignment='right')
    ## add stop line
    if (stop == 0) & (freq >= 1200):
        line = x_data[i]
        stop = 1
    if stop == 1:
        plt.axvline(x=line, linestyle='--', color='red', linewidth='2')
        plt.text(line, y_max-1, 'stop', fontsize=15, 
                  verticalalignment='top', horizontalalignment='center')
    ## show figure
    plt.pause(0.02)
    plt.show()

#%% ###########################################################################
## Compare the ideal, actual and predicted line
depth = 0.225  ## bottle depth (m)
stop = 0.04  ## how much is left to stop (m)
temp = 20  ## room temperature
rate = (depth - stop) / len(y_data)  ## water level rise rate
frame = np.linspace(0,len(y_data)-1,len(y_data))  ## frames
x = depth - frame * rate  ## remaining water level
y = (331 + 0.6 * temp)/(4 * x)  ## ideal frequency

plt.figure()
plt.plot(frame, np.log2(y), 'k', label='ideal')
plt.scatter(p[0,:], p[1,:], s=2, c='b', label='actual')
plt.scatter(x_data, y_data, s=1, c='r', label='predict')
plt.xlabel('frame')
plt.ylabel('frequency (Hz)')
plt.title('Peak per frame')
plt.ylim([5,15])
plt.yticks(np.arange(6,15), ([str(2**i) for i in range(6,15)]))
plt.legend()
plt.grid()

#%% ###########################################################################
## Note
# 基頻範圍：約200Hz~450Hz
# 基頻(最低頻率)：(331+0.6*20)/(4*0.3) = 286 Hz
# 離瓶口約5cm(最低頻率)：(331+0.6*20)/(4*0.05) = 1715 Hz
# 離瓶口(20C)：[5cm, 4cm, 3cm, 2cm, 1cm] => [1715, 2144, 2858, 4288, 8575]
# 溫度(5cm)：[0, 10, 20, 30, 40] => [1655, 1685, 1715, 1745, 1775]
# 瓶子高23.5cm, 22cm
