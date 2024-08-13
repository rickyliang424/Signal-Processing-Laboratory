#%%
import os
import librosa
import numpy as np
import pandas as pd
from glob import glob
from sklearn.metrics import confusion_matrix, accuracy_score
from sklearn.model_selection import KFold
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from Lab11_107011153_functions import plot_confusion_matrix

RANDSEED = 0  # setup random seed
CVFOLD = 5  # number of folds of cross validation
classNames = ['Dog bark', 'Rain', 'Sea waves', 'Baby cry',
              'Clock tick', 'Person sneeze', 'Helicopter', 'Chainsaw',
              'Rooster', 'Fire crackling']

#%%
## Load data
labels = pd.read_csv('../data/label.csv')
nameToLabel = dict((row['filename'], row['label']) for idx, row in labels.iterrows())
trainFiles = sorted(glob('../data/Train/*/*.ogg'))
testFiles = sorted(glob('../data/Test/*/*.ogg'))
trainLabel = np.array([nameToLabel[os.path.basename(p)] for p in trainFiles])
testLabel = np.array([nameToLabel[os.path.basename(p)] for p in testFiles])

## define feature extraction function
def feat_extraction(path):
    '''
    Input: path for a single file
    Output: 1D feature vector
    '''
    ## Read file using librosa
    x, fs = librosa.load(path, sr=None)
    
    ## Use librosa to calculate MFCC
    MFCC = librosa.feature.mfcc(x, sr=fs, n_mfcc=20)
    
    ## Aggregate the 2D MFCC along time axis to 1D feature vector (ex: mean, std ...)
    mean = np.mean(MFCC, axis=1).reshape((1,20))
    stdev = np.std(MFCC, axis=1).reshape((1,20))
    features = np.concatenate((mean, stdev), axis=1)
    
    return features

## Calculate MFCC features
trainFeat = np.vstack([feat_extraction(p) for p in trainFiles])
testFeat = np.vstack([feat_extraction(p) for p in testFiles])

#%%
## Use KFold to perform cross validation
X = trainFeat
y = trainLabel
Kf = KFold(n_splits=CVFOLD, shuffle=True, random_state=RANDSEED)
sc = StandardScaler()

svmfitlist = []
for cvIdx, (trainIdx, devIdx) in enumerate(Kf.split(range(len(X)))):
    ## Prepare training and test data
    X_train = X[trainIdx,:]
    X_test = X[devIdx,:]
    y_train = y[trainIdx]
    y_test = y[devIdx]
    
    ## Normalize training and testing data
    sc.fit(X_train)
    X_train_std = sc.transform(X_train)
    X_test_std = sc.transform(X_test)
    
    ## Train the best model and predict the testing data
    svm = SVC(C=10).fit(X_train_std, y_train)
    pred = svm.predict(X_test_std)
    
    ## Record SVM training data as model parameter
    svmfitlist.append([X_train, y_train])
    
    ## Calculate accuracy and plot confusion matrix
    accuracy = accuracy_score(y_test, pred)
    cm = confusion_matrix(y_test, pred)
    plot_confusion_matrix(cm , classNames)
    print('Accuracy = ', round(accuracy,4))

#%%
## Prepare training and test data
best = 1
X_train = svmfitlist[best][0]
y_train = svmfitlist[best][1]
X_test = np.vstack(testFeat)
y_test = np.array(testLabel)
sc.fit(X_train)
X_train_std = sc.transform(X_train)
X_test_std = sc.transform(X_test)

## Train the best model and predict the testing data
svm = SVC(C=10).fit(X_train_std, y_train)
pred = svm.predict(X_test_std)

## Calculate accuracy and plot confusion matrix
accuracy = accuracy_score(y_test, pred)
cm = confusion_matrix(y_test, pred)
plot_confusion_matrix(cm , classNames)
print('Accuracy = ',  round(accuracy,4))
