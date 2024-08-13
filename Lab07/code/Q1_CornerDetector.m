clear; clc;

% filename = "Stata_Center";  threshold = 10;  r = 20;
filename = "Milwaukee_Art_Museum";  threshold = 200;  r = 10;

frame = imread('../data/' + filename + '.jpg');
sigma = 2;
n_x_sigma = 6;
alpha = 0.04;
dx = [-1 0 1; -1 0 1; -1 0 1];
dy = dx';
filter_size = 2 * n_x_sigma * sigma;
g = fspecial('gaussian', max(1, fix(filter_size)), sigma);

%%
[I, r1, c1, count1] = FindCorners(frame, dx, dy, g, threshold, r, alpha);
figure();
imagesc(uint8(I));
hold on;
plot(c1, r1, 'or', 'MarkerSize', 5, 'LineWidth', 1);
