function output = Q5_seamCarvingInsert(image, newSize)
    image = double(image);
    insertsize = newSize;
    
    energy = energyRGB(image);
    [SeamIndexArray, seamEnergy] = findOptSeam(energy);

    for i = 1:insertsize
        image = enlargeImageByIndexArray(image, SeamIndexArray);
    end

    output = uint8(image);
end
