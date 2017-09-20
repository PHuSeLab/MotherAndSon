function fiducialSon = processData(ms)

if (ms.processMother)
    %% prepare MOTHER data
    disp('Processing mother data...')
    % for each mother
    for mother = 1:ms.motherCount
        % get all emotional categories
        expr_dir = dirFolders(ms.imgPathMother{mother});
        fprintf('- Mother %d/%d\n', mother, ms.motherCount);
        % consider index 3, to exclude ./ and ../
        data = {};
        % for each emotional category
        for i = 3:numel(expr_dir)
            fprintf('- Learning shape and action for emotion %d/%d\n', i-2, numel(expr_dir)-2);
            lbl = expr_dir(i).name(end);
            % get all frames landmarks
            txtFiles = dir([ms.landmarksPathMother{mother} '/' expr_dir(i).name '/*.txt']);
            fiducial = [];
            if (numel(txtFiles) == 0) % landmarks not present
                imageFiles = dirImages([ms.imgPathMother{mother} '/' expr_dir(i).name]);
                % extract landmarks for each frame
                for j = 1:numel(imageFiles)
                    fprintf('- Landmarks not found. Extracting points with %s method...\n', ms.landmarkModeMother);
                    fullImg = [ms.imgPathMother{mother} '/' expr_dir(i).name '/' imageFiles{j}];
                    imgMother = im2double(imread(fullImg));
                    imgMother = imresize(imgMother, [300, NaN]);
                    landmarkFile = [fullImg(1:end-4) '_' ms.landmarkModeMother '.txt'];
                    annotations = extractFeaturesCoordinates(fullImg, landmarkFile, ms.landmarkModeMother, 0);
                    Xannotations =  annotations(:,1);
                    Yannotations =  annotations(:,2);
                    
                    if ms.normalize
                        Xnorm = normFeatVect(Xannotations');
                        Ynorm = normFeatVect(Yannotations');
                    else
                        Xnorm = Xannotations';
                        Ynorm = Yannotations';
                    end
                    
                    fiducial(:,1,j) = Xnorm;
                    fiducial(:,2,j) = Ynorm;
                end
                disp('- Landmarks extracted.');
            else % if landmarks are present
                for j = 1:numel(txtFiles)
                    % load landmark file
                    landmarkFile = [ms.landmarksPathMother{mother} '/' expr_dir(i).name '/' txtFiles(j).name];
                    if (strcmp(ms.landmarkModeMother, 'CK'))
                        fileID = fopen(landmarkFile, 'r');
                        annotations = fscanf(fileID, '%f');
                        fclose(fileID);
                        Xannotations =  annotations(1:2:end);
                        Yannotations =  annotations(2:2:end);
                    else
                        annotations = dlmread(landmarkFile);
                        Xannotations =  annotations(:,1);
                        Yannotations =  annotations(:,2);
                    end
                    
                    fiducial(:,1,j) = Xannotations';
                    fiducial(:,2,j) = Yannotations';
                end
            end
            % learn action parameters
            learn = 1;
            motherImgs = [ms.imgPathMother{mother} '/' expr_dir(i).name];
            [~, ~, sstActionMultiFrames] = CandideLinearActionSimul(fiducial, ms.landmarkModeMother, learn, [], [], motherImgs, ms.dims);
            data{i-2}.sstAction = sstActionMultiFrames;
            data{i-2}.label = lbl;
        end
        % save mother action parameters and labels
        motherDatafile = [ms.dataPath 'mothers/dataMotherCandide_' ms.motherSession{mother} '_' num2str(ms.dims) 'D.mat'];
        ms.motherData{mother} = motherDatafile;
        save(motherDatafile, 'data');
    end
end

%% prepare SON data
disp('Processing son data...')
fiducialSon = [];

if (strcmp(ms.landmarkSonPath, ''))
    error('ERROR: Please set where to save son landmarks');
else
    % if landmarks are not present
    if (~exist(ms.landmarkSonPath, 'file'))
        fprintf('- Landmarks not found. Extracting points with %s method...\n', ms.landmarkModeSon);
        annotations = extractFeaturesCoordinates(ms.imgSonPath, ms.landmarkSonPath, ms.landmarkModeSon, 1);
        ms.modelGeneration = 1;
        disp('- Landmarks extracted.');
    else % if landmarks are present
        disp('- Landmarks found. Loading points...');
        annotations = dlmread(ms.landmarkSonPath);
        disp('- Landmarks loaded.');
    end
end

Xannotations =  annotations(:,1);
Yannotations =  annotations(:,2);

fiducialSon(:,1) = Xannotations';
fiducialSon(:,2) = Yannotations';
ms.landmarkSon = fiducialSon;
