
function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.
% Your function should work for color images. Simply filter each color
% channel independently.
% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambigious which pixel in the filter is the center
% pixel.
% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.
% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% output = imfilter(image, filter);
    
    [I_height, I_width, channel] = size(image);
    [F_height, F_width] = size(filter);
    
    height = I_height + F_height - 1;
    width = I_width + F_width - 1;
    h_begin = 1 + (F_height - 1) / 2;
    w_begin = 1 + (F_width - 1) / 2;
    h_end = height - (F_height - 1) / 2;
    w_end = width - (F_width - 1) / 2;
    
    R = zeros(height, width);
    G = zeros(height, width);
    B = zeros(height, width);
    R(h_begin:h_end, w_begin:w_end) = image(:, :, 1);
    G(h_begin:h_end, w_begin:w_end) = image(:, :, 2);
    B(h_begin:h_end, w_begin:w_end) = image(:, :, 3);
    out_R = zeros(height, width);
    out_G = zeros(height, width);
    out_B = zeros(height, width);
    
%     out_Y = zeros(height, width);
%     matrix = [0.299 0.587 0.114];
%     Y = zeros(height, width);
%     for i = 1:height
%         for j = 1:width
%             Y(i,j) = matrix * double(transpose([R(i,j) G(i,j) B(i,j)]));
%         end
%     end
    
    for i = h_begin:h_end
        for j = w_begin:w_end
            for m = 1:F_height
                for n = 1:F_width
                    out_R(i,j) = out_R(i,j) + R(i+m-(F_height+1)/2,j+n-(F_width+1)/2) * filter(m,n);
                    out_G(i,j) = out_G(i,j) + G(i+m-(F_height+1)/2,j+n-(F_width+1)/2) * filter(m,n);
                    out_B(i,j) = out_B(i,j) + B(i+m-(F_height+1)/2,j+n-(F_width+1)/2) * filter(m,n);
%                     out_Y(i,j) = out_Y(i,j) + Y(i+m-(F_height+1)/2,j+n-(F_width+1)/2) * filter(m,n);
                end
            end
        end
    end
    
    output = single(zeros(I_height, I_width, channel));
    output(:,:,1) = out_R(h_begin:h_end, w_begin:w_end);
    output(:,:,2) = out_G(h_begin:h_end, w_begin:w_end);
    output(:,:,3) = out_B(h_begin:h_end, w_begin:w_end);
%     output(:,:,:) = cat(3, out_Y, out_Y, out_Y);
end
