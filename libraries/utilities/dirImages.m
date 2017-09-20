function listOfImageNames = dirImages( folder )
listOfImageNames = {};
imageFiles = dir([folder '/*.*']);
for index = 1:length(imageFiles)
    baseFileName = imageFiles(index).name;
    [~, ~, extension] = fileparts(baseFileName);
    extension = upper(extension);
    switch lower(extension)
        case {'.png', '.bmp', '.jpg', '.tif'}
            % Allow only PNG, TIF, JPG, or BMP images
            listOfImageNames = [listOfImageNames baseFileName];
        otherwise
    end
end

