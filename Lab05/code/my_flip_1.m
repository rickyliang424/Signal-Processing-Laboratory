clear; clc;

I = imread('../data/image.jpg');
imshow(I);

%%
I1 = flip(I, 0);
imshow(I1);
% imwrite(I1, '../results/flip_image_new_0.jpg');

function I_flip = flip(I, type)
    R = I(:, :, 1);
    G = I(:, :, 2);
    B = I(:, :, 3);
    [height, width, channel] = size(I);

    %%% horizontal flipping
    if type == 0
        x_shift = width + 1;
        y_shift = 0;
        matrix = [-1 0 x_shift ; 0 1 y_shift];
        I_flip = uint8(zeros(height, width, channel));
        for y_old = 1:height
            for x_old = 1:width
                new = matrix * [x_old ; y_old ; 1];
                x_new = new(1);
                y_new = new(2);
                I_flip(y_new, x_new, 1) = R(y_old, x_old);
                I_flip(y_new, x_new, 2) = G(y_old, x_old);
                I_flip(y_new, x_new, 3) = B(y_old, x_old);
            end
        end
    end

    %%% vertical flipping
    if type == 1
        x_shift = 0;
        y_shift = height + 1;
        matrix = [1 0 x_shift ; 0 -1 y_shift];
        I_flip = uint8(zeros(height, width, channel));
        for y_old = 1:height
            for x_old = 1:width
                new = matrix * [x_old ; y_old ; 1];
                x_new = new(1);
                y_new = new(2);
                I_flip(y_new, x_new, 1) = R(y_old, x_old);
                I_flip(y_new, x_new, 2) = G(y_old, x_old);
                I_flip(y_new, x_new, 3) = B(y_old, x_old);
            end
        end
    end

    %%% horizontal + vertical flipping
    if type == 2
        x_shift = width + 1;
        y_shift = height + 1;
        matrix = [-1 0 x_shift ; 0 -1 y_shift];
        I_flip = uint8(zeros(height, width, channel));
        for y_old = 1:height
            for x_old = 1:width
                new = matrix * [x_old ; y_old ; 1];
                x_new = new(1);
                y_new = new(2);
                I_flip(y_new, x_new, 1) = R(y_old, x_old);
                I_flip(y_new, x_new, 2) = G(y_old, x_old);
                I_flip(y_new, x_new, 3) = B(y_old, x_old);
            end
        end
    end
end
