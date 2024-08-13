
1.easy mid hard分別是三種不同難度的檔案，每個資料夾有5筆ECG的raw data
2.用matlab匯入.mat檔，.mat檔即為ECG raw data
3.寫code抓出R peak
4.同檔名的txt檔為R peak的正確資訊，比對後分別列出true positive(TP)、false negative(FN)、false positive(FP) 


True positive(TP)   有抓到R，實際上也有R
False negative(FN)  沒抓到R，實際上有R
False positive(FP)  有抓到R，實際上沒有R