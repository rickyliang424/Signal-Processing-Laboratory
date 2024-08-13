'''
@Modified by Paul Cho; 10th, Nov, 2020
For NTHU DSP Lab 2021 Autumn
'''
import numpy as np
import soundfile as sf
import matplotlib.pyplot as plt
from scipy.fftpack import dct
from Lab9_functions_student import pre_emphasis, STFT, get_filter_banks
from Lab10_stft2audio_student import griffinlim
from scipy.fftpack import idct
from scipy.linalg import pinv2 as pinv
import random

filename = './audio.wav'
source_signal, sr = sf.read(filename)  # sr:sampling rate
print('Sampling rate = {} Hz.'.format(sr))

# hyper parameters
frame_length = 512                     # Frame length(samples)
frame_step = 128                       # Step length(samples)
emphasis_coeff = 0.95                  # pre-emphasis para
num_bands = 64                         # Filter number = band number
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
# fig, (ax0, ax1) = plt.subplots(1,2,figsize=(10,4))
# fig.suptitle("Original signal vs. Pre-emphasized signal")
# ax0.pcolor(spectrum)
# ax0.set_xlabel('Frame')
# ax0.set_ylabel('Frequency band')
# ax1.pcolor(spectrum_pe)
# ax1.set_xlabel('Frame')
# ax1.set_ylabel('Frequency band')

#%% Part II
# get Mel-scaled filter
fbanks = get_filter_banks(num_bands, num_FFT , sr, freq_min, freq_max)

# (1) Convolve the pre-emphasized signal with the filter
features = np.dot(fbanks, spectrum_pe)

# (2) Convert magnitude to logarithmic scale
features = np.log(features)

# demo 2 MFCC of a random frame
# rd = random.randint(0, features.shape[1])
# plt.figure()
# plt.plot(features[:,rd])
# plt.title('MFCC of a random frame')
# plt.xlabel('Cepstral Coefficient')
# plt.ylabel('Magnitude')

# (3) Perform Discrete Cosine Transform (dct) as a process of information compression to obtain MFCC
MFCC = dct(features.transpose(), norm = 'ortho')[:,:num_bands].transpose()

# (4) Plot the filter banks alongside the MFCC
# fig, (ax0, ax1) = plt.subplots(1,2,figsize=(10,4))
# fig.suptitle("Mel-scaled filter banks and MFCC")
# ax0.plot(np.linspace(freq_min,freq_max,int(num_FFT/2+1))/1000, fbanks.transpose())
# ax0.set_xlabel('Frequency (kHz)')
# ax0.set_ylabel('Mel-scaled filter banks')
# ax1.pcolor(MFCC)
# ax1.set_xlabel('Frame')
# ax1.set_ylabel('MFCC coefficient')

#%% Part III
# (1) Perform inverse DCT on MFCC
inv_DCT = idct(MFCC.transpose(), norm = 'ortho').transpose()
print('Shape after iDCT:', inv_DCT.shape)

# (2) Restore magnitude from logarithmic scale
inv_DCT = np.exp(inv_DCT)

# (3) Invert the fbanks convolution
a = np.transpose(fbanks)
b = np.dot(fbanks, a)
c = pinv(b)
d = np.dot(a, c)
inv_spectrogram = np.dot(d, inv_DCT)
print('Shape after inverse convolution:', inv_spectrogram.shape)

# (4) Synthesize time-domain audio with Griffin-Lim
inv_audio = griffinlim(inv_spectrogram, n_iter=32, hop_length=frame_step, win_length=frame_length)
sf.write('reconstructed.wav', inv_audio, samplerate=int(sr*512/frame_length))

# (5) Get STFT spectrogram of the reconstructed signal
reconstructed_spectrum = STFT(inv_audio, num_frames, num_FFT, frame_step, frame_length, len(inv_audio), verbose=False)

# Scale and plot and compare original and reconstructed signals
absolute_spectrum = spectrum
absolute_spectrum = np.where(absolute_spectrum == 0, np.finfo(float).eps, absolute_spectrum)
absolute_spectrum = np.log(absolute_spectrum)
reconstructed_spectrum = np.where(reconstructed_spectrum == 0, np.finfo(float).eps, reconstructed_spectrum)
reconstructed_spectrum = np.log(reconstructed_spectrum)

#%% Demo 1
fbanks_12 = get_filter_banks(12 , num_FFT , sr, freq_min, freq_max)
fbanks_64 = get_filter_banks(64 , num_FFT , sr, freq_min, freq_max)
features_12 = np.log(np.dot(fbanks_12, spectrum_pe))
features_64 = np.log(np.dot(fbanks_64, spectrum_pe))

rd = random.randint(0, features.shape[1])
fig, (ax0, ax1) = plt.subplots(1,2,figsize=(10,4))
ax0.plot(features_12[:,rd])
ax0.set_title('MFCC of a random frame (12 banks)')
ax0.set_xlabel('Cepstral Coefficient')
ax0.set_ylabel('Magnitude')
ax1.plot(features_64[:,rd])
ax1.set_title('MFCC of a random frame (64 banks)')
ax1.set_xlabel('Cepstral Coefficient')
ax1.set_ylabel('Magnitude')

#%% Demo 2
MFCC_12 = dct(features_12.transpose(), norm = 'ortho')[:,:12].transpose()
MFCC_64 = dct(features_64.transpose(), norm = 'ortho')[:,:64].transpose()

fig, (ax0, ax1) = plt.subplots(1,2,figsize=(10,4))
ax0.pcolor(MFCC_12)
ax0.set_title('12 banks MFCC')
ax0.set_xlabel('Frame')
ax0.set_ylabel('MFCC coefficient')
ax1.pcolor(MFCC_64)
ax1.set_title('64 banks MFCC')
ax1.set_xlabel('Frame')
ax1.set_ylabel('MFCC coefficient')

#%% Demo 3
fig, (ax0, ax1) = plt.subplots(1,2,figsize=(10,4))
fig.suptitle("Original signal vs Reconstructed signal", fontweight='bold')
ax0.pcolor(absolute_spectrum)
ax0.set_xlabel('Frame')
ax0.set_ylabel('Frequency band')
ax1.pcolor(reconstructed_spectrum)
ax1.set_xlabel('Frame')
ax1.set_ylabel('Frequency band')

#%% Demo 4
def Reconstruct_Audio (signal, PE, banks):
    if PE:
        signal = pre_emphasis(signal, coefficient = 0.95)
    
    spectrum = STFT(source_signal, num_frames, num_FFT, frame_step, frame_length, signal_length, verbose=False)
    fbanks = get_filter_banks(banks, num_FFT , sr, freq_min, freq_max)
    features = np.log(np.dot(fbanks, spectrum))
    MFCC = dct(features.transpose(), norm = 'ortho')[:,:num_bands].transpose()
    inv_DCT = np.exp(idct(MFCC.transpose(), norm = 'ortho').transpose())
    a = np.transpose(fbanks)
    b = np.dot(fbanks, a)
    c = pinv(b)
    d = np.dot(a, c)
    inv_spectrogram = np.dot(d, inv_DCT)
    new_audio = griffinlim(inv_spectrogram, n_iter=32, hop_length=frame_step, win_length=frame_length)
    return new_audio

banks_64_wi_pe = Reconstruct_Audio(source_signal, PE=True, banks=64)
banks_64_wo_pe = Reconstruct_Audio(source_signal, PE=False, banks=64)
banks_12_wi_pe = Reconstruct_Audio(source_signal, PE=True, banks=12)
banks_12_wo_pe = Reconstruct_Audio(source_signal, PE=False, banks=12)

sf.write('64_banks_pre-emphasized.wav', banks_64_wi_pe, samplerate=sr)
sf.write('64_banks_NOT_pre-emphasized.wav', banks_64_wo_pe, samplerate=sr)
sf.write('12_banks_pre-emphasized.wav', banks_12_wi_pe, samplerate=sr)
sf.write('12_banks_NOT_pre-emphasized.wav', banks_12_wo_pe, samplerate=sr)
sf.write('Original.wav', source_signal, samplerate=sr)
