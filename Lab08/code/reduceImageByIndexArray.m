function imageReduced = reduceImageByIndexArray(image, seamIndexArray)
    [height, width, channel] = size(image);
    indexsize = length(seamIndexArray);
    imageReduced = zeros(height, width-1, channel);
    for i = 1:channel
        for j = 1:indexsize
            delete = seamIndexArray(j);
            if delete == 1
                imageReduced(j,:,i) = image(j,delete+1:end,i);
            elseif delete == width
                imageReduced(j,:,i) = image(j,1:delete-1,i);
            else
                imageReduced(j,:,i) = [image(j,1:delete-1,i), image(j,delete+1:end,i)];
            end
        end
    end
end
