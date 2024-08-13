function res = energyRGB(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sum up the enery for each channel 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dx = [-1 0 1; -1 0 1; -1 0 1];
dy = dx';
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);
res_R = abs(imfilter(R, dx)) + abs(imfilter(R, dy));
res_G = abs(imfilter(G, dx)) + abs(imfilter(G, dy));
res_B = abs(imfilter(B, dx)) + abs(imfilter(B, dy));
res = res_R + res_G + res_B;
end

function res = energyGray(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returns energy of all pixelels
% e = |dI/dx| + |dI/dy|
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dx = [-1 0 1; -1 0 1; -1 0 1];
dy = dx';
Ix = imfilter(I, dx);
Iy = imfilter(I, dy);
res = abs(Ix) + abs(Iy);
end
