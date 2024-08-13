% shear image according to the shift pixels in both x and y axises
% input1---source image: I
% input2---shift pixel in x axis: sh_x (ex: -0.8)
% input3---shift pixel in y axis: sh_y (ex: 0.2)
% output---shear image: I_shear

function I_shear = shear(I, sh_x, sh_y)

    % RGB channel
    R(:, :) = I(:, :, 1);
    G(:, :) = I(:, :, 2);
    B(:, :) = I(:, :, 3);

    % get height, width, channel of image
    [height, width, channel] = size(I);

    %% create new image
    % step1. record image vertices, and use the transformation matrix to get new vertices.
    matrix = [1 sh_x; sh_y 1];
    vertex = [1 width width 1 ; 1 1 height height];
    vertex_new = matrix * vertex;

    % step2. find min x, min y, max x, max y, use "min()" & "max()" function is ok
    min_x = min(vertex_new(1,:));
    min_y = min(vertex_new(2,:));
    max_x = max(vertex_new(1,:));
    max_y = max(vertex_new(2,:));

    % step3. consider how much to shift the image to the positive axis
    x_shift = 1 - min_x;
    y_shift = 1 - min_y;

    % step4. calculate new width and height, if they are not integer, use
    % "ceil()" & "floor()" to help get the largest width and height.
    width_new = ceil(max_x) - floor(min_x);
    height_new = ceil(max_y) - floor(min_y);

    % step5. initial r, g, b array for the new image
    R_shear = zeros(height_new, width_new);
    G_shear = zeros(height_new, width_new);
    B_shear = zeros(height_new, width_new);

    %% backward warping using bilinear interpolation
    % for each pixel on the shear image, find the correspond r, g, b value 
    % from the source image, and save to R_shear, G_shear, B_shear.
    for y_new = 1 : height_new
        for x_new = 1 : width_new

            % step5. shift the new pixel (y_new, x_new) back, 
            % and reverse the shear transformation to get (y_old, x_old)
            matrix_b = 1 / (1 - sh_x * sh_y) * [1 -sh_x; -sh_y 1];
            coord = matrix_b * [x_new - x_shift ; y_new - y_shift];
            x_old = coord(1);
            y_old = coord(2);

            % step6. use "ceil()" & "floor()" to get interpolation coordinates
            % x1, x2, y1, y2
            x1 = floor(x_old);
            x2 = ceil(x_old);
            y1 = floor(y_old);
            y2 = ceil(y_old);

            % step7. if (y_old, x_old) is inside of the source image, 
            % calculate r, g, b by interpolation.
            % else if (y_old, x_old) is outside of the source image, set
            % r, g, b = 0 (black).
            if (x1 >= 1) && (x1 <= width) && (x2 >= 1) && (x2 <= width) && ...
                (y1 >= 1) && (y1 <= height)&& (y2 >= 1) && (y2 <= height)

                % step8. calculate weight wa, wb, notice that if x1 = x2 or y1 = y2,
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

                % step9. calculate weight w1, w2, w3, w4. 
                w1 = (1 - wa) * (1 - wb);
                w2 = wa * (1 - wb);
                w3 = wa * wb;
                w4 = (1 - wa) * wb;

                % step10. calculate r, g, b with 4 neighbor points and their weights
                r = R(y1,x1)*w1 + R(y1,x2)*w2 + R(y2,x2)*w3 + R(y2,x1)*w4;
                g = G(y1,x1)*w1 + G(y1,x2)*w2 + G(y2,x2)*w3 + G(y2,x1)*w4;
                b = B(y1,x1)*w1 + B(y1,x2)*w2 + B(y2,x2)*w3 + B(y2,x1)*w4;

            else
                r = 0;
                g = 0;
                b = 0;
            end
            R_shear(y_new, x_new) = r;
            G_shear(y_new, x_new) = g;
            B_shear(y_new, x_new) = b;
        end
    end

    % save R_shear, G_shear, B_shear to output image
    I_shear = uint8(zeros(height_new, width_new, channel));
    I_shear(:, :, 1) = R_shear;
    I_shear(:, :, 2) = G_shear;
    I_shear(:, :, 3) = B_shear;

end
