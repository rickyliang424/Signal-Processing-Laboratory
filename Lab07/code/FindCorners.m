
function [I, row, col, count] = FindCorners(frame, dx, dy, g, threshold, r, alpha)
    %%% Input
    % frame: image read from source
    % dx: horizontal gradient filter
    % dy: vertical gradient filter
    % g: Gaussian filter (filter size: 2*n_x_sigma*sigma)
    % threshold: threshold for finding local maximum (0 ~ 1000)
    % r: k for calculate Rv
    %%% Output
    % I: double type converted from "frame"
    % row, col: the detected corners' locations
    % count: the number of interest points, which avoid the image's edge

    %% Convert frame to double type
    I = double(frame);
    figure;
    imagesc(frame);
    [ymax, xmax, ~] = size(I);

    %%%%%%%%%%%%%%%%%%%%%%%%%%% Interest Points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%
    %%% get image gradient

    % Grayscale
    R = I(:, :, 1);
    G = I(:, :, 2);
    B = I(:, :, 3);
    Ig = 0.299*R + 0.587*G + 0.144*B;
    
    % calculate Ix
    Ix = imfilter(Ig, dx);
    
    % calcualte Iy
    Iy = imfilter(Ig, dy);
    
    %%% get all components of second moment matrix M = [[Ix2 Ixy];[Iyx Iy2]];
    %%% note Ix2 Ixy Iy2 are all Gaussian smoothed

    % calculate Ix2 
    Ix2 = imfilter(Ix.*Ix, g);
    
    % calculate Iy2
    Iy2 = imfilter(Iy.*Iy, g);
    
    % calculate Ixy
    Ixy = imfilter(Ix.*Iy, g);
    
    %% visualize Ixy
    figure;
    imagesc(Ixy);

    %-------------------------- Demo Check Point -----------------------------%

    %%
    %%% get corner response function R = det(M)-alpha*trace(M)^2

    % calculate R
    R = zeros(ymax, xmax);
    for i = 1:ymax
        for j = 1:xmax
            M = [Ix2(i,j) , Ixy(i,j) ; Ixy(i,j) , Iy2(i,j)];
            R(i,j) = det(M) - alpha * trace(M) ^ 2;
        end
    end
    
    %% make max R value to be 1000
    R = (1000 / max(max(R))) * R; % be aware of if max(R) is 0 or not
    
    %% using B = ordfilt2(A,order,domain) to implment a maxfilter
    sze = 2*r + 1; % domain width
    
    %%% find local maximum and get RBinary.
    % calculate MX
    MX = ordfilt2(R, sze^2, ones(sze,sze));
    
    % calculate RBinary
    RBinary = (MX > threshold) & (MX == R);
    
    %% get location of corner points not along image's edges
    offe = r-1;
    count = sum(sum(RBinary(offe:size(RBinary, 1) - offe, offe:size(RBinary,2) - offe))); % How many interest points, avoid the image's edge   
    R = R*0;
    R(offe:size(RBinary, 1) - offe, offe:size(RBinary, 2) - offe) = RBinary(offe:size(RBinary, 1) - offe, offe:size(RBinary, 2) - offe);
    [row,col] = find(R);

end
