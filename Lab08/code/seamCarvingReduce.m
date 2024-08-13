function output = seamCarvingReduce(image, newSize)
    % How many seam you need to delete from origin image
    reducesize = newSize;
    output = double(image);
    
    for i = 1:reducesize
        energy = energyRGB(output);
        [SeamIndexArray, seamEnergy] = findOptSeam(energy);
        output = reduceImageByIndexArray(output, SeamIndexArray);
    end
    
    output = uint8(output);
end
