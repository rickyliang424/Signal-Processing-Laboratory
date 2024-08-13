# -*- coding: utf-8 -*-
"""
Created on Sat Jan 15 12:31:17 2022
@author: Ricky
"""
import pyaudio
import librosa
import numpy as np
from scipy.fft import fft
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter

def butter_lowpass_filter(data, cutoff, fs, order):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low')
    y = lfilter(b, a, data)
    return y

def findF0(data, n_fft, fs, detect, old_peak, stop):
    ## define parameters
    base_u = 800  ## 基頻上限
    base_d = 250  ## 基頻下限
    delta_u = 15  ## 取峰值的範圍(往上)
    delta_d = 5  ## 取峰值的範圍(往下)
    delta_p = 5  ## 兩次峰值之間的差距
    delta_s = 10  ## 取峰值的範圍(after stopping)
    wait = 8  ## 連續幾次才開始找峰值
    f = np.arange(n_fft) / n_fft * fs  ## 0~fs Hz
    base_range = np.where((f >= base_d) & (f <= base_u))[0]  ## 基頻範圍
    
    ## process data
    X = librosa.amplitude_to_db(np.abs(fft(data)), ref=np.min)  ## Fourier transform
    # X = butter_lowpass_filter(data=X, cutoff=250, fs=fs, order=5)  ## Filtering
    # delay = 25  ## delay of the filter
    # X = X[delay:]
    # X = np.array(X - (np.mean(X) + np.std(X) * 1))  ## Thresholding
    # X[X<=0] = 0
    
    ## find peak
    if detect < wait:
        peak = np.argmax(X[base_range[0]:base_range[-1]]) + base_range[0]
        if (peak-old_peak>=-delta_p) & (peak-old_peak<=delta_p):
            detect = detect + 1
        else:
            detect = 0
    else:
        peak = np.argmax(X[(old_peak-delta_d):(old_peak+delta_u)]) + old_peak - delta_d
    
    ## after stopping
    if stop == 1:
        peak = np.argmax(X[(old_peak-delta_s):(old_peak+delta_s)]) + old_peak - delta_s
        if peak <= base_u:
            detect = 0
            stop = 0
    
    ## record result
    old_peak = peak
    F0 = np.log2(f[peak])  ## log scale
    
    return F0, detect, old_peak, stop

def plot(y_data, y_new, stop, line):
    ## get new data and plot
    y_data.append(y_new)
    x_data = len(y_data)
    
    ## plot
    buffer = 300  ## display buffer
    if len(y_data) > buffer:
        y_data.pop(0)
    plt.figure()
    plt.plot(y_data, '.', markersize=5)
    plt.title("Real-Time Plot")
    plt.xlabel("frames")
    plt.ylabel("frequency (Hz)")
    plt.grid()
    
    ## set axis
    plt.xlim([0, x_data+2])
    y_max = int(np.ceil(np.max(y_data))) + 2
    y_min = int(np.floor(np.min(y_data))) - 1
    plt.yticks(np.arange(y_min,y_max), ([str(2**i) for i in range(y_min,y_max)]))
    
    ## add text
    temp = 20  ## temperature
    freq = int(2**y_new)
    rest = round((331+0.6*temp) / freq / 4 *100, 1)
    text = 'freq=' + str(freq) + 'Hz\n' + 'rest=' + str(rest) + 'cm'
    plt.text(x_data, y_min+1, text, fontsize=20, 
             verticalalignment='top', horizontalalignment='right')
    
    ## add stop line
    if stop == 1:
        plt.axvline(x=line, linestyle='--', color='red', linewidth='2')
        plt.text(line, y_max-1, 'stop', fontsize=15, 
                 verticalalignment='top', horizontalalignment='center')
    elif freq >= 1100:
        line = x_data
        plt.axvline(x=line, linestyle='--', color='red', linewidth='2')
        plt.text(line, y_max-1, 'stop', fontsize=15, 
                 verticalalignment='top', horizontalalignment='center')
        stop = 1
    else:
        if x_data >= buffer:
            line = line - 1
        if line > 0:
            plt.axvline(x=line, linestyle='--', color='red', linewidth='2')
            plt.text(line, y_max-1, 'stop', fontsize=15, 
                     verticalalignment='top', horizontalalignment='center')
    plt.show()
    return y_data, stop, line

class SpectrumAnalyzer:
    ## initialization
    fs = 48000  ## sampling rate
    n_fft = 8192  ## length of the windowed signal
    data = []
    detect = 0
    old_peak = 0
    stop = 0
    line = 0
    y_data = []

    def __init__(self):
        self.pa = pyaudio.PyAudio()
        self.stream = self.pa.open(format=pyaudio.paFloat32, 
                                   channels=1, 
                                   rate=self.fs, 
                                   input=True, 
                                   frames_per_buffer=self.n_fft)
        self.loop()  ## Main loop
        
    def loop(self):
        try:
            while True:
                self.data = self.audioinput()
                self.plotpeak()
        except KeyboardInterrupt:
            print("End...")
        
    def audioinput(self):
        ret = self.stream.read(self.n_fft)
        ret = np.frombuffer(ret, np.float32)
        return ret
    
    def plotpeak(self):
        F0, self.detect, self.old_peak, self.stop = findF0(self.data, 
                                                           n_fft=self.n_fft, 
                                                           fs=self.fs, 
                                                           detect=self.detect, 
                                                           old_peak=self.old_peak, 
                                                           stop=self.stop)
        self.y_data, self.stop, self.line = plot(self.y_data, 
                                                 F0, 
                                                 self.stop, 
                                                 self.line,)
        
if __name__ == "__main__":
    SpectrumAnalyzer()
