function [optSeamIndexArray, seamEnergy] = findOptSeam(energy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Following paper by Avidan and Shamir `07
% Finds optimal seam by the given energy of an image
% Returns mask with 0 mean a pixel is in the seam
% You only need to implement vertical seam. For
% horizontal case, just using the same function by 
% giving energy for the transpose image I'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Find M for vertical seams
    % Add one element of padding in vertical dimension 
    % to avoid handling border elements
    M = padarray(energy, [0 1], realmax('double'));
    sz = size(M);

    % For all rows starting from second row, fill in the minimum 
    % energy for all possible seam for each (i,j) in M, which
    % M[i, j] = e[i, j] + min(M[i - 1, j - 1], M[i - 1, j], M[i - 1, j + 1]).
    for i = 2:sz(1)
        for j = 2:(sz(2)-1)
            M(i,j) = energy(i,j-1) + min([M(i-1,j-1), M(i-1,j), M(i-1,j+1)]);
        end
    end
    
    % Find the minimum element in the last raw of M
    [val, idx] = min(M(sz(1), :));
    seamEnergy = val;
    fprintf('Optimal energy: %f\n',seamEnergy);

    % Initial for optimal seam mask
    energy_sz = size(energy);
    optSeamIndexArray = zeros(energy_sz(1), 1, 'uint32');

    % Traverse back the path of seam with minimum energy
    % and update optimal seam index array
    optSeamIndexArray(energy_sz(1)) = idx - 1;
    for i = 1:(energy_sz(1)-1)
        row = energy_sz(1) - i;
        col = optSeamIndexArray(row+1) + 1;
        [~, minidx] = min([M(row,col-1), M(row,col), M(row,col+1)]);
        optSeamIndexArray(row) = col - 2 + minidx - 1;
    end
    
end
