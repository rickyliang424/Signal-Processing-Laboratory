% resize image with input scale 
% input1---source image: I
% input2---resize scale
% output---resized image 

function I_res = resize(I, scale)

    % RGB channel
    R(:, :) = double(I(:, :, 1));
    G(:, :) = double(I(:, :, 2));
    B(:, :) = double(I(:, :, 3));

    % get height, width, channel of image
    [height, width, channel] = size(I);

    %% create new image
    % step1. calculate new width and height, if they are not integer, use
    % "ceil()" & "floor()" to help get the largest width and height.
    shift = 1 - 1 * scale;
    height_new = floor(height * scale) - floor(1 * scale);
    width_new  = floor(width * scale) - floor(1 * scale);

    % step2. initial r, g, b array for the new image
    R_res = zeros(height_new, width_new);
    G_res = zeros(height_new, width_new);
    B_res = zeros(height_new, width_new);

    %% backward warping using bilinear interpolation
    % for each pixel on the resized image, find the correspond r, g, b value 
    % from the source image, and save to R_res, G_res, B_res.
    for y_new = 1 : height_new
        for x_new = 1 : width_new

            % step3. scale the new pixel (y_new, x_new) back to get (y_old, x_old)
            y_old = (y_new - shift) / scale;
            x_old = (x_new - shift) / scale;

            % step4. use "ceil()" & "floor()" to get interpolation coordinates
            % x1, x2, y1, y2
            x1 = floor(x_old);
            x2 = ceil(x_old);
            y1 = floor(y_old);
            y2 = ceil(y_old);

            % step5. if (y_old, x_old) is inside of the source image, 
            % calculate r, g, b by interpolation.
            % else if (y_old, x_old) is outside of the source image, set
            % r, g, b = 0(black).
            if (x1 >= 1) && (x1 <= width) && (x2 >= 1) && (x2 <= width) && ...
                (y1 >= 1) && (y1 <= height)&& (y2 >= 1) && (y2 <= height)
                % step6. calculate weight wa, wb, notice that if x1 = x2 or y1 = y2,
                % function "wa = ()/(x1-x2)" will be fail. 
                % at this situation, you need to assign a value to wa directly.
                if (x1 == x2) && (y1 ~= y2)
                    wa = 0;
                    wb = (y_old - y1) / (y2 - y1);
                    
                elseif (x1 ~= x2) && (y1 == y2)
                    wa = (x_old - x1) / (x2 - x1);
                    wb = 0;
                    
                elseif (x1 == x2) && (y1 == y2)
                    wa = 0;
                    wb = 0;
                    
                else
                    wa = (x_old - x1) / (x2 - x1);
                    wb = (y_old - y1) / (y2 - y1);
                end

                % step7. calculate weight w1, w2, w3, w4. 
                w1 = (1 - wa) * (1 - wb);
                w2 = wa * (1 - wb);
                w3 = wa * wb;
                w4 = (1 - wa) * wb;

                % step8. calculate r, g, b with 4 neighbor points and their weights
                r = R(y1,x1)*w1 + R(y1,x2)*w2 + R(y2,x2)*w3 + R(y2,x1)*w4;
                g = G(y1,x1)*w1 + G(y1,x2)*w2 + G(y2,x2)*w3 + G(y2,x1)*w4;
                b = B(y1,x1)*w1 + B(y1,x2)*w2 + B(y2,x2)*w3 + B(y2,x1)*w4;

            else
                r = 0;
                g = 0;
                b = 0;
            end
            R_res(y_new, x_new) = r;
            G_res(y_new, x_new) = g;
            B_res(y_new, x_new) = b;
        end
    end

    % save R_rot, G_rot, B_rot to output image
    I_res = uint8(zeros(height_new, width_new, channel));
    I_res(:, :, 1) = R_res;
    I_res(:, :, 2) = G_res;
    I_res(:, :, 3) = B_res;
end
