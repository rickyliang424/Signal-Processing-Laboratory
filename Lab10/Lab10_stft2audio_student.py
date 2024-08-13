import numpy as np
from librosa import stft, istft
import random as rd

def griffinlim(S, n_iter=64, hop_length=None, win_length=None, window="hann", center=True, dtype=None,
    length=None, pad_mode="reflect", momentum=0.99):

    # Infer n_fft from the spectrogram shape
    n_fft = 2 * (S.shape[0] - 1)

    # using complex64 will keep the result to minimal necessary precision
    angles = np.empty(S.shape, dtype=np.complex64)

    # randomly initialize the phase (simply use j as imaginary unit. e.g. A = 2j + 2):
    ###################
    for m in range(angles.shape[0]):
        for n in range(angles.shape[1]):
            a = rd.uniform(-1,1)
            b = np.sqrt(1 - a**2)
            angles[m,n] = (a + 1j*b)
    
    ###################

    # And initialize the previous iterate to 0
    rebuilt = 0.0

    for _ in range(n_iter):
        # Store the previous iterate
        tprev = rebuilt

        # Invert with our current estimate of the phases
        inverse = istft(S * angles, hop_length=hop_length, win_length=win_length, window=window,
            center=center, dtype=dtype, length=length,)

        # Rebuild the spectrogram
        rebuilt = stft(inverse, n_fft=n_fft, hop_length=hop_length, win_length=win_length, window=window,
            center=center,pad_mode=pad_mode,)

        # Update our phase estimates
        # Momentum must be between 0 and 1 (0.99 is advised)
        angles[:] = rebuilt - (momentum / (1 + momentum)) * tprev
        angles[:] /= np.abs(angles) + 1e-16

    # Return the final phase estimates:
    ###################
    inv_audio = istft(S * angles, hop_length=hop_length, win_length=win_length, window=window,
            center=center, dtype=dtype, length=length,)
    
    return inv_audio
    ###################
