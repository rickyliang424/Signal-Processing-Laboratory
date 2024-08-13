%% grayscale 
% 1. matrix: [a,b,c] = [a b c]
%    matrix: [a;b;c] = [a b c]'
%
% 2. zeros: create an array of 0
% zeros(3) = [ 0 0 0 
%              0 0 0 
%              0 0 0 ]
% zeros(2,5) = [ 0 0 0 0 0
%                0 0 0 0 0 ]
% data type of zeros() is preset "double".
% show the result on command window to help yourself understand 

%% data type
% 1. data type of RGB channel is preset "uint8", range 0-255
% assume that Y = R+G+B; if R+G+B > 255, Y will be assigned the maximum 255,
% so we need to calculate in data type "double": 
%               Y = double(R) + double(G) + double(B);
%
% 2. data type and data range for imshow(I)
% uint8: 0-255:   Y = uint8((double(R) + double(G) + double(B)) / 3);
%                    => turn back to uint8
% double: 0-1     Y = ((double(R) + double(G) + double(B)) / 3) / 255;
%                    => scale 0-255 to 0-1

%% function
% input---source image: I
% output---grayscale image: I_gray
function I_gray = grayscale(I)

    % RGB channel
    R = I(:, :, 1);
    G = I(:, :, 2);
    B = I(:, :, 3);

    % get height, width, channel of the image
    [height, width, channel] = size(I);

    % initial the intensity array Y using zeros()
    Y = zeros(height, width);

    % weight of RGB channel
    matrix = [0.299 0.587 0.114];

    % implement the grayscale convertion
    for i = 1:height
        for j = 1:width
            Y(i,j) = matrix * double(transpose([R(i,j) G(i,j) B(i,j)]));
        end
    end
    Y = uint8(Y);

    % save intensity Y to output image
    I_gray(:, :, 1) = Y;
    I_gray(:, :, 2) = Y;
    I_gray(:, :, 3) = Y;

end
