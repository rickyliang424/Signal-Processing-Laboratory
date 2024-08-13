# -*- coding: utf-8 -*-
"""
Created on Fri Dec 31 13:51:44 2021
@author: Ricky
"""
import os
import librosa
import numpy as np
import pandas as pd
from glob import glob
from scipy.fftpack import dct
from sklearn.svm import SVC
from sklearn.model_selection import KFold
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.preprocessing import StandardScaler
from Lab12_107011153_functions import pre_emphasis, STFT, get_filter_banks, plot_confusion_matrix

DataPath = './Baby_Data'
FeaPath  = './Features/MFCC'

#%% Functions
def MFCC_feat(file):
    ## set parameters
    num_FFT = 256                           ## FFT freq-quantization
    frame_step = num_FFT // 2               ## Step length (samples)
    frame_length = num_FFT                  ## Frame length (samples)
    num_bands = 20                          ## Filter number = band number
    
    ## get MFCC
    signal, fs = librosa.load(file, sr=None)
    signal_pe = pre_emphasis(signal, coefficient=0.95)
    spectrum = STFT(signal_pe, num_FFT, frame_step, frame_length, verbose=False)
    fbanks = get_filter_banks(num_bands, num_FFT, fs, freq_min=0, freq_max=int(0.5*fs))
    mfcc = np.log(np.dot(fbanks, spectrum))
    MFCC = dct(mfcc.T, norm='ortho').T
    
    ## extract features
    mean = np.mean(MFCC, axis=1)
    std = np.std(MFCC, axis=1)
    features = np.concatenate((mean, std), axis=0)
    return features

def cross_val(cv_num, C, kernel, degree, train_data, train_target):
    Kf = KFold(n_splits=cv_num, shuffle=True, random_state=0)
    accuracy = []
    for cvIdx, (trainIdx, devIdx) in enumerate(Kf.split(range(len(train_data)))):
        ## split training and validation data
        X_train = train_data[trainIdx,:]
        X_valid = train_data[devIdx,:]
        y_train = train_target[trainIdx]
        y_valid = train_target[devIdx]
        
        ## normalize data
        sc = StandardScaler()
        sc.fit(X_train)
        X_train_std = sc.transform(X_train)
        X_valid_std = sc.transform(X_valid)
        
        ## train SVM model and predict results
        svm = SVC(C=C, kernel=kernel, degree=degree).fit(X_train_std, y_train)
        pred = svm.predict(X_valid_std)
        accuracy.append(accuracy_score(y_valid, pred))
    return round(np.mean(accuracy), 4)

#%% Loading training and test data
train_path = sorted(glob(os.path.join(DataPath, 'wav_train', 'train*.wav')))
test_path = sorted(glob(os.path.join(DataPath, 'wav_dev', 'dev*.wav')))

## use MFCC_feat to get features
train_data = [MFCC_feat(path) for path in train_path]
test_data = [MFCC_feat(path) for path in test_path]

#%% Reading labels
labels = pd.read_csv(os.path.join(DataPath, 'label_raw_train.csv'))
name2label = dict((row['file_name'], row['label']) for idx, row in labels.iterrows())
train_label = [name2label[os.path.basename(path)] for path in train_path]

#%% Try different parameters
X_train = np.vstack(train_data)
y_train = np.array(train_label)

## record results from different SVM models
trainhist = []
for C in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
    for kernel in ['linear', 'poly', 'rbf', 'sigmoid']:
        if kernel == 'poly':
            for degree in [2, 3, 4, 5]:
                trainhist.append([C, kernel, degree, cross_val(5, C, kernel, degree, X_train, y_train)])
        else:
            trainhist.append([C, kernel, cross_val(5, C, kernel, 3, X_train, y_train)])
trainhist.sort(reverse = True, key = lambda x: x[-1])

#%% Model training and prediction
choose = 0

## train the best SVM model
sc = StandardScaler()
sc.fit(X_train)
X_train_std = sc.transform(X_train)
svm = SVC(C=trainhist[choose][0], kernel=trainhist[choose][1]).fit(X_train_std, y_train)

## predict testing data
X_test = np.vstack(test_data)
X_test_std = sc.transform(X_test)
y_predict = svm.predict(X_test_std)

#%% Saving results into csv
results = pd.DataFrame({'file_name':[os.path.basename(f) for f in test_path], 'Predicted':y_predict})
results.to_csv('Lab12_107011153_results.csv', index=False)

#%% Plot confusion matrix
classNames = ['Crying', 'Canonical', 'Non-canonical', 'Laughing', 'Junk']

def plot_CM(cv_num, X_data, Y_data):
    accuracy = []
    cm = np.zeros((len(classNames), len(classNames)))
    Kf = KFold(n_splits=cv_num, shuffle=True, random_state=0)
    for cvIdx, (trainIdx, devIdx) in enumerate(Kf.split(range(len(X_data)))):
        ## split training and validation data
        X_train = X_data[trainIdx,:]
        X_valid = X_data[devIdx,:]
        y_train = Y_data[trainIdx]
        y_valid = Y_data[devIdx]
        
        ## normalize data
        sc = StandardScaler()
        sc.fit(X_train)
        X_train_std = sc.transform(X_train)
        X_valid_std = sc.transform(X_valid)
        
        ## train SVM model and predict results
        svm = SVC(C=2, kernel='rbf').fit(X_train_std, y_train)
        pred = svm.predict(X_valid_std)
        accuracy.append(accuracy_score(y_valid, pred))
        cm = cm + confusion_matrix(y_valid, pred)
    
    print('Accuracy = ', round(np.mean(accuracy),4))
    plot_confusion_matrix(cm, classNames, normalize=True)
    return

plot_CM(5, X_train, y_train)

#%% Plot spectrogram
# import matplotlib.pyplot as plt
# train_path = sorted(glob(os.path.join(DataPath, 'wav_train', 'train*.wav')))
# labels = pd.read_csv(os.path.join(DataPath, 'label_raw_train.csv'))
# for i in [0, 2, 1, 7, 4, 75, 5, 6, 23, 24, 25, 27]:
#     file = train_path[i]
#     signal, fs = librosa.load(file, sr=None)
#     signal_pe = pre_emphasis(signal, coefficient=0.95)
#     num_FFT = 256
#     frame_step = num_FFT // 2
#     frame_length = num_FFT
#     num_bands = 20
#     spectrum = STFT(signal_pe, num_FFT, frame_step, frame_length, verbose=False)
#     fbanks = get_filter_banks(num_bands, num_FFT, fs, freq_min=0, freq_max=int(0.5*fs))
#     mfcc = np.log(np.dot(fbanks, spectrum))
#     MFCC = dct(mfcc.T, norm='ortho').T
#     plt.figure()
#     plt.pcolor(MFCC)
#     plt.colorbar(format='%+2.0f dB')
#     plt.title(labels['label'][i])

#%% Note
# num_bands = 10
# trainhist_10 = \
# [[2, 'rbf', 0.6739],
#  [3, 'rbf', 0.6737],
#  [0.9, 'rbf', 0.6727],
#  [1, 'rbf', 0.6727],
#  [0.8, 'rbf', 0.6712],
#  [0.7, 'rbf', 0.6707],
#  [0.6, 'rbf', 0.6692],
#  [0.5, 'rbf', 0.6682],
#  [4, 'rbf', 0.6682],
#  [6, 'rbf', 0.6672]]

# num_bands = 16
# trainhist_16 = \
# [[2, 'rbf', 0.6975],
#  [3, 'rbf', 0.6929],
#  [1, 'rbf', 0.6907],
#  [4, 'rbf', 0.6887],
#  [0.7, 'rbf', 0.6879],
#  [0.9, 'rbf', 0.6872],
#  [0.8, 'rbf', 0.6857],
#  [0.6, 'rbf', 0.6854],
#  [5, 'rbf', 0.6844],
#  [0.5, 'rbf', 0.6834]]

# num_bands = 20
# trainhist_20 = \
# [[2, 'rbf', 0.7215],
#  [3, 'rbf', 0.721],
#  [0.8, 'rbf', 0.7187],
#  [1, 'rbf', 0.7187],
#  [0.9, 'rbf', 0.7175],
#  [0.7, 'rbf', 0.7172],
#  [0.6, 'rbf', 0.7157],
#  [4, 'rbf', 0.715],
#  [0.5, 'rbf', 0.713],
#  [0.4, 'rbf', 0.7112]]

# num_bands = 25
# trainhist_25 = \
# [[2, 'rbf', 0.718],
#  [1, 'rbf', 0.7142],
#  [0.9, 'rbf', 0.7132],
#  [0.8, 'rbf', 0.7112],
#  [3, 'rbf', 0.7112],
#  [0.6, 'rbf', 0.7105],
#  [0.7, 'rbf', 0.7102],
#  [4, 'rbf', 0.7077],
#  [0.5, 'rbf', 0.7065],
#  [5, 'rbf', 0.7035]]

# num_bands = 32
# trainhist_32 = \
# [[2, 'rbf', 0.712],
#  [3, 'rbf', 0.7085],
#  [0.6, 'rbf', 0.7077],
#  [0.7, 'rbf', 0.7072],
#  [0.9, 'rbf', 0.7072],
#  [0.8, 'rbf', 0.707],
#  [1, 'rbf', 0.707],
#  [4, 'rbf', 0.704],
#  [0.5, 'rbf', 0.7035],
#  [5, 'rbf', 0.7015]]

# num_bands = 40
# trainhist_40 = \
# [[4, 'rbf', 0.7095],
#  [1, 'rbf', 0.7092],
#  [3, 'rbf', 0.7085],
#  [2, 'rbf', 0.7082],
#  [8, 'rbf', 0.708],
#  [5, 'rbf', 0.7077],
#  [7, 'rbf', 0.7072],
#  [6, 'rbf', 0.7067],
#  [0.9, 'rbf', 0.7062],
#  [9, 'rbf', 0.7062]]
