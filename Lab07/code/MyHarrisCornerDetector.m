% My Harris detector
% The code calculates
% the Harris Feature/Interest Points (FP or IP) 

% When you execute the code, the test image file will open
% then the code will print out and display the feature points.
% You can select the number of FPs by changing the variables 

%%%
% corner : significant change in all direction for a sliding window
%%%

clear; clc;

%%
% parameters
% corner response related
sigma = 2;
n_x_sigma = 6;
alpha = 0.04;

% maximum suppression related
threshold = 20;     % should be between 0 and 1000
r = 6;              % k for calculate Rv

%%
% filter kernels
dx = [-1 0 1; -1 0 1; -1 0 1];      % horizontal gradient filter 
dy = dx';                           % vertical gradient filter
g = fspecial('gaussian', max(1, fix(2 * n_x_sigma*sigma)), sigma); % Gaussien Filter: filter size 2*n_x_sigma*sigma

%% load 'Im.jpg'
frame = imread('../data/Im.jpg');

%% Call FindCorners function
[I, r1, c1, count1] = FindCorners(frame, dx, dy, g, threshold, r, alpha);

%% Display
figure;
imagesc(uint8(I));
hold on;
plot(c1, r1, 'or', 'MarkerSize', 5, 'LineWidth', 1);
return;
