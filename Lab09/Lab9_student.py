'''
@Modified by Paul Cho; 10th, Nov, 2020
For NTHU DSP Lab 2021 Autumn
'''
import numpy as np
import soundfile as sf
import matplotlib.pyplot as plt
from scipy.fftpack import dct
from Lab9_functions_student import pre_emphasis, STFT, get_filter_banks

filename = './audio.wav'
source_signal, sr = sf.read(filename)  # sr:sampling rate
print('Sampling rate = {} Hz.'.format(sr))

# hyper parameters
frame_length = 512                     # Frame length(samples)
frame_step = 256                       # Step length(samples)
emphasis_coeff = 0.95                  # pre-emphasis para
num_bands = 12                         # Filter number = band number
num_FFT = frame_length                 # FFT freq-quantization
freq_min = 0
freq_max = int(0.5 * sr)
signal_length = len(source_signal)     # Signal length

# number of frames it takes to cover the entirety of the signal
num_frames = 1 + int(np.ceil((1.0 * signal_length - frame_length) / frame_step))

#%% Part I
# (1) Perform STFT on the source signal to obtain one spectrogram
spectrum = STFT(source_signal, num_frames, num_FFT, frame_step, frame_length, signal_length, verbose=False)

# (2) Pre-emphasize the source signal with pre_emphasis()
signal_pe = pre_emphasis(source_signal, coefficient = 0.95)

# (3) Perform STFT on the pre-emphasized signal to obtain the second spectrogram
spectrum_pe = STFT(signal_pe, num_frames, num_FFT, frame_step, frame_length, signal_length, verbose=False)

# (4) Plot the two spectrograms together to observe the effect of pre-emphasis
fig, (ax0, ax1) = plt.subplots(1,2,figsize=(10,4))
fig.suptitle("Original signal vs. Pre-emphasized signal")
ax0.pcolor(spectrum)
ax0.set_xlabel('Frame')
ax0.set_ylabel('Frequency band')
ax1.pcolor(spectrum_pe)
ax1.set_xlabel('Frame')
ax1.set_ylabel('Frequency band')

#%% Part II
# get Mel-scaled filter
fbanks = get_filter_banks(num_bands, num_FFT , sr, freq_min, freq_max)

# (1) Convolve the pre-emphasized signal with the filter
features = np.dot(fbanks, spectrum_pe)

# (2) Convert magnitude to logarithmic scale
features = np.log(features)

# demo 2 MFCC of a random frame
import random
rd = random.randint(0, features.shape[1])
plt.figure()
plt.plot(features[:,rd])
plt.title('MFCC of a random frame')
plt.xlabel('Cepstral Coefficient')
plt.ylabel('Magnitude')

# (3) Perform Discrete Cosine Transform (dct) as a process of information compression to obtain MFCC
MFCC = dct(features.transpose(), norm = 'ortho')[:,:num_bands].transpose()

# (4) Plot the filter banks alongside the MFCC
fig, (ax0, ax1) = plt.subplots(1,2,figsize=(10,4))
fig.suptitle("Mel-scaled filter banks and MFCC")
ax0.plot(np.linspace(freq_min,freq_max,int(num_FFT/2+1))/1000, fbanks.transpose())
ax0.set_xlabel('Frequency (kHz)')
ax0.set_ylabel('Mel-scaled filter banks')
ax1.pcolor(MFCC)
ax1.set_xlabel('Frame')
ax1.set_ylabel('MFCC coefficient')

#%% Question 2
frame = 100
for i in [5, 10, 15, 20]:
    fbanks = get_filter_banks(i, num_FFT , sr, freq_min, freq_max)
    features = np.log(np.dot(fbanks, spectrum_pe))
    
    plt.figure()
    plt.plot(features[:,frame])
    plt.title('MFCC of a random frame (number of coeff. = ' + str(i) + ')')
    plt.xlabel('Cepstral Coefficient')
    plt.ylabel('Magnitude')
    
    MFCC = dct(features.transpose(), norm = 'ortho')[:,:num_bands].transpose()
    plt.figure()
    plt.pcolor(MFCC)
    plt.title('MFCC Heatmap (number of coeff. = ' + str(i) + ')')
    plt.xlabel('Frame')
    plt.ylabel('MFCC coefficient')

#%% Bonus 1
# Plot the spectrograms in different coefficient
for i in [0.65, 0.95, 0.99]:
    # Pre-emphasize the source signal
    signal_pe = pre_emphasis(source_signal, coefficient = i)
    # Perform STFT on the pre-emphasized signal to obtain spectrogram
    spectrum_pe = STFT(signal_pe, num_frames, num_FFT, frame_step, frame_length, signal_length, verbose=False)
    # Plot the spectrogram
    plt.figure()
    plt.pcolor(spectrum_pe)
    plt.xlabel('Frame')
    plt.ylabel('Frequency band')
    plt.title('Spectrogram (coefficient = ' + str(i) + ')')
