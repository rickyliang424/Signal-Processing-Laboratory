% input1---source image: I
% input2---flip direction: type (0: horizontal, 1: vertical, 2: both)
% output---flipped image: I_flip

function I_flip = my_flip(I, type)

    % RGB channel
    R = I(:, :, 1);
    G = I(:, :, 2);
    B = I(:, :, 3);

    % get height, width, channel of image
    [height, width, channel] = size(I);

    %%  horizontal flipping
    if type == 0
        % initial r, g, b array for flipped image using zeros()
        R_flip = zeros(height, width);
        G_flip = zeros(height, width);
        B_flip = zeros(height, width);

        % assign pixels from R, G, B to R_flip, G_flip, B_flip
        for i = 1:height
            for j = 1:width
                R_flip(i,j) = R(i,abs(j-width-1));
                G_flip(i,j) = G(i,abs(j-width-1));
                B_flip(i,j) = B(i,abs(j-width-1));
            end
        end

        % save R_flip, G_flip, B_flip to output image
        I_flip = uint8(zeros(height, width, channel));
        I_flip(:, :, 1) = R_flip;
        I_flip(:, :, 2) = G_flip;
        I_flip(:, :, 3) = B_flip;
    end

    %% vertical flipping
    if type == 1
        % initial r, g, b array for flipped image using zeros()
        R_flip = zeros(height, width);
        G_flip = zeros(height, width);
        B_flip = zeros(height, width);

        % assign pixels from R, G, B to R_flip, G_flip, B_flip
        for i = 1:height
            for j = 1:width
                R_flip(i,j) = R(abs(i-height-1),j);
                G_flip(i,j) = G(abs(i-height-1),j);
                B_flip(i,j) = B(abs(i-height-1),j);
            end
        end

        % save R_flip, G_flip, B_flip to output image
        I_flip = uint8(zeros(height, width, channel));
        I_flip(:, :, 1) = R_flip;
        I_flip(:, :, 2) = G_flip;
        I_flip(:, :, 3) = B_flip;
    end

    %%  horizontal + vertical flipping
    if type == 2
        % initial r, g, b array for flipped image using zeros()
        R_flip = zeros(height, width);
        G_flip = zeros(height, width);
        B_flip = zeros(height, width);

        % assign pixels from R, G, B to R_flip, G_flip, B_flip
        for i = 1:height
            for j = 1:width
                R_flip(i,j) = R(abs(i-height-1),abs(j-width-1));
                G_flip(i,j) = G(abs(i-height-1),abs(j-width-1));
                B_flip(i,j) = B(abs(i-height-1),abs(j-width-1));
            end
        end

        % save R_flip, G_flip, B_flip to output image
        I_flip = uint8(zeros(height, width, channel));
        I_flip(:, :, 1) = R_flip;
        I_flip(:, :, 2) = G_flip;
        I_flip(:, :, 3) = B_flip;
    end

end
