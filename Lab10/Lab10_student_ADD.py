'''PART I Copy paste to the top import section:'''
############ADD THESE#################
from Lab10_stft2audio_student import griffinlim
from scipy.fftpack import idct
from scipy.linalg import pinv2 as pinv
############ADD ABOVE#################
'''PART I ENDS HERE.'''



'''PART II Copy paste to the very bottom after all your previous code (where you have the MFCC obtained):'''
############ADD THESE#################
'''
(1) Perform inverse DCT on MFCC (already done for you)
(2) Restore magnitude from logarithmic scale (i.e. use exponential)
(3) Invert the fbanks convolution
(4) Synthesize time-domain audio with Griffin-Lim
(5) Get STFT spectrogram of the reconstructed signal and compare it side by side with the original signal's STFT spectrogram
    (please convert magnitudes to logarithmic scale to better present the changes)
'''

# inverse DCT (done for you)
inv_DCT = idct(MFCC, norm = 'ortho')
print('Shape after iDCT:', inv_DCT.shape)

# mag scale restoration:
###################
# YOUR CODE HERE
###################

# inverse convoluation against fbanks (mind the shapes of your matrices):
###################
# YOUR CODE HERE
###################
print('Shape after inverse convolution:', inv_spectrogram.shape)


# signal restoration to time domain (You only have to finish griffinlim() in 'stft2audio_student.py'):
inv_audio = griffinlim(inv_spectrogram, n_iter=32, hop_length=frame_step, win_length=frame_length)
sf.write('reconstructed.wav', inv_audio, samplerate=int(sr*512/frame_length))
reconstructed_spectrum = STFT(inv_audio, num_frames, num_FFT, frame_step, frame_length, len(inv_audio), verbose=False)

# scale and plot and compare original and reconstructed signals
# scale (done for you):
absolute_spectrum = np.where(absolute_spectrum == 0, np.finfo(float).eps, absolute_spectrum)
absolute_spectrum = np.log(absolute_spectrum)
reconstructed_spectrum = np.where(reconstructed_spectrum == 0, np.finfo(float).eps, reconstructed_spectrum)
reconstructed_spectrum = np.log(reconstructed_spectrum)

#plot:
###################
# YOUR CODE HERE
###################

############ADD ABOVE#################
'''PART II ENDS  HERE.'''