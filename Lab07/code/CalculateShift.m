% My Harris detector
% The code calculates
% the Harris Feature/Interest Points (FP or IP) 
% and compute how much the rectangle is shifted between two images

% When you execute the code, the test image file will open
% then the code will print out and display the feature points.
% You can select the number of FPs by changing the variables 

%%%
% corner: significant change in all directions for a sliding window
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
dx = [-1 0 1; -1 0 1; -1 0 1];              % horizontal gradient filter 
dy = dx';                                   % vertical gradient filter
g = fspecial('gaussian', max(1, fix(2 * n_x_sigma*sigma)), sigma); % Gaussien Filter: filter size 2*n_x_sigma*sigma

%% load image
frame1 = imread('../data/img_1.png');
frame2 = imread('../data/img_2.png');

%% Find corners in frame1 and frame2
[I1, r1, c1, count1] = FindCorners(frame1, dx, dy, g, threshold, r, alpha);
[I2, r2, c2, count2] = FindCorners(frame2, dx, dy, g, threshold, r, alpha);

%% Display the detected corners in frame1
% To show these two images, please refer to the MyHarrisCornerDetector.m
figure();
imagesc(uint8(I1));
hold on;
plot(c1, r1, 'or', 'MarkerSize', 5, 'LineWidth', 1);

%% Display the detected corners in frame2
figure();
imagesc(uint8(I2));
hold on;
plot(c2, r2, 'or', 'MarkerSize', 5, 'LineWidth', 1);

%% Calculate shift
center1 = [(r1(1)+r1(4))/2 (c1(1)+c1(4))/2];
center2 = [(r2(1)+r2(4))/2 (c2(1)+c2(4))/2];
shift_row = center2(1) - center1(1);
shift_col = center2(2) - center1(2);

% Show how much the rectangle is shifted between two images
fprintf("Row shifted: %d \n", shift_row);
fprintf("Col shifted: %d \n", shift_col);

return;
