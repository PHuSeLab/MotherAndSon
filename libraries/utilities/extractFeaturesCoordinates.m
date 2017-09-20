function annotations = extractFeaturesCoordinates(faceImgPath, landmarksFile, method, visualize)

%faceImg = im2double(imread(faceImgPath));
faceImg = imread(faceImgPath);
faceImg = imresize(faceImg, [300, NaN]);

%% Extract facial landmarks
switch (method)
    
    case 'OF'
        if(isunix)
            executable = '"libraries/landmarks extraction/OF/FeatureExtraction"';
        else
            executable = '"libraries/landmarks extraction/OF/x64/Release/FeatureExtraction.exe"';
        end
        
        imwrite(faceImg, 'temp.jpg');
        
        in_img  = 'temp.jpg';
        out_anno = landmarksFile;
        
        % Trained on in the wild and multi-pie data (less accurate CLM model)
        % model = 'model/main_clm_general.txt';
        % Trained on in-the-wild
        %model = 'model/main_clm_wild.txt';
        
        % Trained on in the wild and multi-pie data (more accurate CLNF model)
        model = 'model/main_clnf_general.txt';
        % Trained on in-the-wild
        %model = 'model/main_clnf_wild.txt';
        
        command = executable;
        
        command = cat(2, command, [' -f "' in_img '"']);
        command = cat(2, command, [' -of "' out_anno '"']);
        command = cat(2, command, [' -mloc "', model, '"']);
        command = cat(2, command, ' -no3Dfp -noMparams -noPose -noAUs -noGaze');

        % Demonstrates the multi-hypothesis slow landmark detection (more accurate
        % when dealing with non-frontal faces and less accurate face detections)
        % Comment to skip this functionality
        % command = cat(2, command, ' -wild ');
        
        if(isunix)
            unix(command);
        else
            dos(command);
        end
        
        delete('temp.jpg');
        
        fileID = fopen(out_anno);
        annotations = textscan(fileID, '%f', 'HeaderLines', 1, 'Delimiter',',');
        annotations = [annotations{1}(5:72) annotations{1}(73:140)];
        if visualize
            showPoints(method, faceImg, annotations);
        end
        
    case 'AA'
        % % % Choose Face Detector
        % % % 0: Tree-Based Face Detector (p204);
        % % % 1: Matlab Face Detector (or External Face Detector);
        % % % 2: Use Pre-computed Bounding Boxes
        bbox_method = 1;
        
        % % % Choose Visualize
        % % % 0: Do Not Display Fitting Results;
        % % % 1: Display Fitting Results and Pause of Inspection)
        data.name = 'sonImage';
        data.img = faceImg;
        % Required Only for bbox_method = 2;
        data.bbox = []; % Face Detection Bounding Box [x;y;w;h]
        % Initialization to store the results
        data.points = []; % MAT containing 66 Landmark Locations
        data.pose = []; % POSE information [Pitch;Yaw;Roll]
        clm_model = 'model/DRMF_Model.mat';
        load(clm_model);
        data = DRMF(clm_model, data, bbox_method, visualize);
        
        annotations = data.points;
        
    case 'ZR'
        % Pre-trained model with 1050 parts. Give best performance on localization, but very slow
        load multipie_independent.mat
        % 5 levels for each octave
        model.interval = 5;
        % set up the threshold
        model.thresh = min(-0.65, model.thresh);
        im = faceImg;
        bs = detect(im, model, model.thresh);
        bs = clipboxes(im, bs);
        bs = nms_face(bs,0.3);
        annotations = processPoints(bs);
        if visualize
            showPoints(method, faceImg, annotations);
        end
        
    case 'TC'
        faceDetector = vision.CascadeObjectDetector;
        bboxes = step(faceDetector, faceImg);
        imwrite(faceImg, 'temp.jpg');
        fileID = fopen('temp.txt','w');
        fprintf(fileID, '%s %d %d %d %d', 'temp.jpg', bboxes);
        fclose(fileID);
        main('temp.txt','model.mat','temp_output.txt');
        annotations = dlmread('temp_output.txt', ' ', 1, 0);
        delete('temp*');
        annotations = reshape(annotations(1:end-1),2,68)';
        if visualize
            showPoints(method, faceImg, annotations);
        end
end

dlmwrite(landmarksFile, annotations);

function annotations = processPoints (bs)

if (length(bs) > 1) % if more than one face is present
    bs = bs{1};     % get only the first
end

annotations(:,1) = round(mean([bs.xy(:,1) bs.xy(:,3)], 2));
annotations(:,2) = round(mean([bs.xy(:,2) bs.xy(:,4)], 2));

% bottom lip
annotations(end+1,:) = round(mean([annotations(51,:); annotations(46,:)]));
% nose sx
annotations(end+1,:) = [annotations(3,1) annotations(7,2)];
% nose dx
annotations(end+1,:) = [annotations(5,1) annotations(7,2)];
% eye sx b
annotations(end+1,:) = round(mean([annotations(11,:); annotations(12,:)]));
% eye sx t
annotations(end+1,:) = round(mean([annotations(13,:); annotations(14,:)]));
% eye dx b
annotations(end+1,:) = round(mean([annotations(22,:); annotations(23,:)]));
% eye dx t
annotations(end+1,:) = round(mean([annotations(24,:); annotations(25,:)]));


function showPoints (method, faceImg, annotations )
h = figure;

showNum = 1;

switch(method)
    case {'OF', 'CK', 'AA', 'TC'}
        
        imshow(faceImg);
        hold on;
        plot(annotations(:,1), annotations(:,2) ,'rx');
        
    case 'ZR'
        
        imshow(faceImg);
        hold on;
        % face
        plot(annotations([60:-1:52, 61:68],1),annotations([60:-1:52, 61:68],2),'r-x');
        % nose
        plot(annotations(1:9,1),annotations(1:9,2),'r-x');
        % mouth
        plot(annotations(32:50,1),annotations(32:50,2),'r-x');
        % left eyebrow
        plot(annotations(16:20,1),annotations(16:20,2),'r-x');
        % right eyebrow
        plot(annotations(27:31,1),annotations(27:31,2),'r-x');
        % left eye
        plot(annotations([10,11,72,12,15,14,73,13,10],1),annotations([10,11,72,12,15,14,73,13,10],2),'r-x');
        % right eye
        plot(annotations([21,24,75,25,26,23,74,22,21],1),annotations([21,24,75,25,26,23,74,22,21],2),'r-x');
end

if showNum
    for i = 1:length(annotations)
        text(annotations(i,1), annotations(i,2),num2str(i));
    end
end

hold off;
drawnow;
disp('Press space to continue');
pause;
close(h);