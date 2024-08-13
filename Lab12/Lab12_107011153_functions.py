import numpy as np
import matplotlib.pyplot as plt
import itertools

def pre_emphasis(signal, coefficient=0.95):
    signal_pe = np.append(signal[0], signal[1:] - coefficient * signal[:-1])
    return signal_pe

def STFT(signal, num_FFT, frame_step, frame_length, verbose=False):
    num_frames = 1 + int(np.ceil((1.0 * len(signal) - frame_length) / frame_step))
    padding_length = int((num_frames - 1) * frame_step + frame_length)
    padding_zeros = np.zeros((padding_length - len(signal)))
    padded_signal = np.concatenate((signal, padding_zeros))

    ## split into frames
    indices1 = np.tile(np.arange(0,frame_length), (num_frames,1))
    indices2 = np.tile(np.arange(0,num_frames*frame_step,frame_step), (frame_length,1)).T
    indices = np.array(indices1 + indices2, dtype=np.int32)
    ## slice signal into frames
    frames = padded_signal[indices]
    ## apply window to the signal
    frames = frames * np.hamming(frame_length)
    ## FFT
    complex_spectrum = np.fft.rfft(frames, num_FFT).T
    absolute_spectrum = np.abs(complex_spectrum)
    
    if verbose:
        print('Signal length : {} samples.' .format(len(signal)))
        print('Frame length : {} samples.' .format(frame_length))
        print('Frame step  : {} samples.' .format(frame_step))
        print('Number of frames: {}.' .format(len(frames)))
        print('Shape after FFT: {}.' .format(absolute_spectrum.shape))
    return absolute_spectrum

def get_filter_banks(num_filters, num_FFT, sample_rate, freq_min, freq_max):
    ## num_filters: filter numbers
    ## num_FFT: number of FFT quantization values
    ## freq_min: the lowest frequency that mel frequency include
    ## freq_max: the Highest frequency that mel frequency include
    
    # convert from hz scale to mel scale
    low_mel = 2595 * np.log10(1 + freq_min / 700)  ## Hz to mel
    high_mel = 2595 * np.log10(1 + freq_max / 700)  ## Hz to mel
    
    # define freq-axis
    mel_freq_axis = np.linspace(low_mel, high_mel, num_filters + 2)
    hz_freq_axis = 700 * (10 ** (mel_freq_axis / 2595) - 1)  ## mel to Hz
    
    # Mel triangle bank design (Triangular band-pass filter banks)
    bins = np.floor((num_FFT + 1) * hz_freq_axis / sample_rate)
    fbanks = np.zeros((num_filters, int(num_FFT / 2 + 1)))
    
    for i in range(fbanks.shape[0]):
        a = int(bins[i+0])
        b = int(bins[i+1])
        c = int(bins[i+2])
        fbanks[i,a:b+1] = np.linspace(0,1,b-a+1)
        fbanks[i,b:c+1] = np.linspace(1,0,c-b+1)
    return fbanks

def plot_confusion_matrix(cm, classes, normalize=False, cmap=plt.cm.Blues):
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        title = 'Normalized confusion matrix'
    else:
        title = 'Confusion matrix'

    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=90)
    plt.yticks(tick_marks, classes)

    fmt = '.2f' if normalize else 'd'
    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, format(cm[i, j], fmt),
                 horizontalalignment = "center",
                 color = "white" if cm[i,j] > thresh else "black")

    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.show()
    return
