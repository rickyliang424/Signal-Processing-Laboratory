clear; clc;

I = imread('../data/image.jpg');
imshow(I);

%%
I1 = rotation(I, pi/6);
imshow(I1);
% imwrite(I1, '../results/rotated_image_fw.jpg');

function I_rot = rotation(I, radius)
    % RGB channel
    R(:, :) = I(:, :, 1);
    G(:, :) = I(:, :, 2);
    B(:, :) = I(:, :, 3);

    % get height, width, channel of image
    [height, width, channel] = size(I);

    % step1. record image vertices, and use rotation matrix to get new vertices.
    matrix = [cos(radius) -sin(radius) ; sin(radius) cos(radius)];
    vertex = [1 width width 1 ; 1 1 height height];
    vertex_new = matrix * vertex;

    % step2. find min x, min y, max x, max y
    min_x = min(vertex_new(1,:));
    min_y = min(vertex_new(2,:));
    max_x = max(vertex_new(1,:));
    max_y = max(vertex_new(2,:));

    % step3. consider how much to shift the image to the positive axis
    x_shift = 1 - min_x;
    y_shift = 1 - min_y;

    % step4. calculate new width and height
    width_new = ceil(max_x) - floor(min_x);
    height_new = ceil(max_y) - floor(min_y);

    % step5. initial r, g, b array for the new image
    R_rot = zeros(height_new, width_new);
    G_rot = zeros(height_new, width_new);
    B_rot = zeros(height_new, width_new);
    
    % forward warping.
    for y_old = 1:height
        for x_old = 1:width
            new = matrix * [x_old ; y_old];
            x_new = round(new(1) + x_shift);
            y_new = round(new(2) + y_shift);
            R_rot(y_new, x_new) = R(y_old, x_old);
            G_rot(y_new, x_new) = G(y_old, x_old);
            B_rot(y_new, x_new) = B(y_old, x_old);
        end
    end

    % save R_rot, G_rot, B_rot to output image
    I_rot = uint8(zeros(height_new, width_new, channel));
    I_rot(:, :, 1) = R_rot;
    I_rot(:, :, 2) = G_rot;
    I_rot(:, :, 3) = B_rot;
end
