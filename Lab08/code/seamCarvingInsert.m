function output = seamCarvingInsert(image, newSize)
    % How many seam you need to insert from origin image
    insertsize = newSize;
    [height, width, channel] = size(image);
    image = double(image);
    
    % Duplicate image
    image_duplicate = image;
    
    % Create a container to record the seam index
    RecordSeam = zeros(height, insertsize);
    
    % Use a for loop to delete each seam
    % with your "energyRGB", "findOptSeam", "reduceImageByIndexArray"
    for i = 1:1:insertsize
        % Perform seam carving
        energy = energyRGB(image_duplicate);
        [SeamIndexArray, seamEnergy] = findOptSeam(energy);
        image_duplicate = reduceImageByIndexArray(image_duplicate, SeamIndexArray);
        
        % Record the seam index
        RecordSeam(:,i) = SeamIndexArray;
    end

    % Use a for loop to add each seam
    % with your "enlargeImageByIndexArray"
    for i = insertsize:-1:1
        % Get s_i from record
        Si = RecordSeam(:,i);
        
        % Enlarge image
        image = enlargeImageByIndexArray(image, Si);
        
        % Update affected seam index
        for m = 1:size(RecordSeam, 1)
            for n = 1:size(RecordSeam, 2)
                if RecordSeam(m,n) >= Si(m)
                    RecordSeam(m,n) = RecordSeam(m,n) + 1;
                end
            end
        end
    end

    output = uint8(image);
end
