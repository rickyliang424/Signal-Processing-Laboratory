function imageEnlarged = enlargeImageByIndexArray(image, seamIndexArray)
    [height, width, channel] = size(image);
    indexsize = length(seamIndexArray);
    imageEnlarged = zeros(height, width+1, channel);
    for i = 1:channel
        for j = 1:indexsize
            add = seamIndexArray(j);
            if add == 1
                insert = mean([image(j,add,i), image(j,add+1,i)]);
            elseif add == width
                insert = mean([image(j,add-1,i), image(j,add,i)]);
            else
                insert = mean([image(j,add-1,i), image(j,add,i), image(j,add+1,i)]);
            end
            imageEnlarged(j,:,i) = [image(j,1:add,i), insert, image(j,add+1:end,i)];
        end
    end
end
