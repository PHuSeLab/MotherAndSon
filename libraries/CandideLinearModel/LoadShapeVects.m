function shape = LoadShapeVects()
    shape={};
    suv_files = dir('libraries/CandideLinearModel/Candide/Data/SUV*');
    for i=1:length(suv_files)
        shape{i} = load([suv_files(i).folder '/' suv_files(i).name]);
    end
end