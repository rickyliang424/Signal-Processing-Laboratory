close all; clear; clc;

image1 = im2single(imread('../data/tiger_pooh.jpg'));
image2 = im2single(imread('../data/obama_xi.jpg'));
[height1, width1, ~] = size(image1);
[height2, width2, ~] = size(image2);

top1 = 10;
bottom1 = 320;
left1 = 100;
right1 = 440;

top2 = 10;
bottom2 = 360;
left2 = 20;
right2 = 400;

figure(1); imshow(image1);
xline(left1, '-.r', 'left = '+string(left1), 'LineWidth', 2);
xline(right1, '-.r', 'right = '+string(right1), 'LineWidth', 2);
yline(top1, '-.r', 'top = '+string(top1), 'LineWidth', 2);
yline(bottom1, '-.r', 'bottom = '+string(bottom1), 'LineWidth', 2);
xticks((0:round(width1/20):width1));
yticks((0:round(height1/20):height1));
set(gca, 'XAxisLocation', 'top');
axis on;

figure(2); imshow(image2);
xline(left2, '-.r', 'left = '+string(left2), 'LineWidth', 2);
xline(right2, '-.r', 'right = '+string(right2), 'LineWidth', 2);
yline(top2, '-.r', 'top = '+string(top2), 'LineWidth', 2);
yline(bottom2, '-.r', 'bottom = '+string(bottom2), 'LineWidth', 2);
xticks((0:round(width2/20):width2));
yticks((0:round(height2/20):height2));
set(gca, 'XAxisLocation', 'top');
axis on;

imwrite(image1, 'Q4_image1.jpg', 'quality', 95);
imwrite(image2, 'Q4_image2.jpg', 'quality', 95);

%% 
area1 = abs(top1 - bottom1) * abs(left1 - right1);
area2 = abs(top2 - bottom2) * abs(left2 - right2);

if (area1 > area2)
    image2 = imresize(image2, sqrt(area1/area2));
    top2 = floor(top2 * sqrt(area1/area2));
    bottom2 = ceil(bottom2 * sqrt(area1/area2));
    left2 = floor(left2 * sqrt(area1/area2));
    right2 = ceil(right2 * sqrt(area1/area2));
end
if (area2 > area1)
    image1 = imresize(image1, sqrt(area2/area1));
    top1 = floor(top1 * sqrt(area2/area1));
    bottom1 = ceil(bottom1 * sqrt(area2/area1));
    left1 = floor(left1 * sqrt(area2/area1));
    right1 = ceil(right1 * sqrt(area2/area1));
end

if (abs(top1 - bottom1) > abs(top2 - bottom2))
    new_height = abs(top1 - bottom1);
else
    new_height = abs(top2 - bottom2);
end
if (abs(left1 - right1) > abs(left2 - right2))
    new_width = abs(left1 - right1);
else
    new_width = abs(left2 - right2);
end

more = 5;
middle1 = [round((left1+right1)/2) round((top1+bottom1)/2)];
middle2 = [round((left2+right2)/2) round((top2+bottom2)/2)];
new_top1 = floor(middle1(2) - new_height/2 - more);
new_bottom1 = ceil(middle1(2) + new_height/2 + more);
new_left1 = floor(middle1(1) - new_width/2 - more);
new_right1 = ceil(middle1(1) + new_width/2 + more);
new_top2 = floor(middle2(2) - new_height/2 - more);
new_bottom2 = ceil(middle2(2) + new_height/2 + more);
new_left2 = floor(middle2(1) - new_width/2 - more);
new_right2 = ceil(middle2(1) + new_width/2 + more);

new_image1 = image1(new_top1:new_bottom1, new_left1:new_right1, :);
new_image2 = image2(new_top2:new_bottom2, new_left2:new_right2, :);
figure(1); imshow(new_image1);
figure(2); imshow(new_image2);

imwrite(new_image1, 'Q4_new_image1.jpg', 'quality', 95);
imwrite(new_image2, 'Q4_new_image2.jpg', 'quality', 95);

%% 
cutoff_freq = 3;
filter = fspecial('Gaussian', cutoff_freq*4+1, cutoff_freq);

tic
low_freq = my_imfilter(new_image1, filter);
high_freq = new_image2 - my_imfilter(new_image2, filter);
toc

figure(3); imshow(low_freq);
figure(4); imshow(high_freq + 0.5);
hybrid = low_freq + high_freq;
vis = vis_hybrid_image(hybrid);
figure(5); imshow(vis);

imwrite(low_freq, 'Q4_low_freq.jpg', 'quality', 95);
imwrite(high_freq, 'Q4_high_freq.jpg', 'quality', 95);
imwrite(hybrid, 'Q4_hrbrid.jpg', 'quality', 95);
imwrite(vis, 'Q4_hybrid_scales.jpg', 'quality', 95);
