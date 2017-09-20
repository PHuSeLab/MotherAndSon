function prepareData(ms)

if (ms.processMother) % process mother(s)
    switch(ms.motherModality)
        case 0
            prepareMCK(ms);
        case 1 % WIP
            prepareMCam(ms);
        case 2
            prepareMImg(ms);
    end
else  % load preprocessed mother(s)
    [filename, pathname] = uigetfile([ms.dataPath 'mothers/*.mat'], ...
        'Select mother(s) data', 'MultiSelect', 'on');
    if isequal(filename,0)
        error('User selected Cancel')
    else
        if iscell(filename)
            ms.motherCount = length(filename);
            for i = 1:ms.motherCount
                ms.motherData{i} = [pathname filename{i}];
                ms.motherSession{i} = filename{i};
            end
        else
            ms.motherData{1} = [pathname filename];
            ms.motherSession{1} = filename;
        end
    end
end

switch(ms.sonModality)
    case 0
        prepareSCK(ms);
    case 1
        prepareSCam(ms);
    case 2
        prepareSImg(ms);
end

if (ms.BW && size(ms.imgSon, 3) == 3)
    ms.imgSon = rgb2gray(ms.imgSon);
end

% Modality mother 0
function prepareMCK(ms)
for i = 1:ms.motherCount
    %ms.imgPathMother{i} = '/media/vcuculo/Data/Datasets/Cohn Kanade/CK+/S022/';
    ms.imgPathMother{i} = uigetdir('',['Choose CK mother ' num2str(i) ' images path']);
    if isequal(ms.imgPathMother(i),0)
        error('User selected Cancel')
    end
    [path,~,~] = fileparts(ms.imgPathMother{i});
    %ms.landmarksPathMother{i} = '/media/vcuculo/Data/Datasets/Cohn Kanade/Landmarks/S022/';    
    ms.landmarksPathMother{i} = uigetdir(path,['Choose CK mother ' num2str(i) ' landmarks path']);
    if isequal(ms.landmarksPathMother{i},0)
        error('User selected Cancel')
    end
    [~,ms.motherSession{i},~] = fileparts(ms.imgPathMother{i});
end

% Modality mother 1 (WIP / don't use)
function prepareMCam(ms)
recordCam(ms);

% Modality mother 2
function prepareMImg(ms)
for i = 1:ms.motherCount
    ms.imgPathMother{i} = uigetdir('',['Choose mother ' num2str(i) ' images path']);
    if isequal(ms.imgPathMother(i),0)
        error('User selected Cancel')
    end
    ms.landmarksPathMother{i} = ms.imgPathMother{i}; % set where to save landmarks
    [~,ms.motherSession{i},~] = fileparts(ms.imgPathMother{i});
end

% Modality son 0
function prepareSCK(ms)
ms.imgSonPath = uigetdir('','Choose CK son images path');
if isequal(ms.imgSonPath,0)
    error('User selected Cancel')
end
ms.imgSon = im2double(imread(getFirstImage(ms.imgSonPath)));
ms.landmarkSonPath = uigetdir(ms.imgSonPath,'Choose CK son landmarks path');
if isequal(ms.landmarkSonPath,0)
    error('User selected Cancel')
end
ms.landmarkSonPath = getFirstLandmark(ms.landmarkSonPath);
[~,ms.sessionSon,~] = fileparts(ms.imgSonPath);
ms.landmarkModeSon = 'CK';

% Modality son 1
function prepareSCam(ms)
saveCamImage(ms);
%ms.modelGeneration = 1; % surely need to recreate the model
ms.imgSonPath = [ms.imagesPath 'Webcam.jpg'];
ms.landmarkSonPath = [ms.landmarksPath 'Webcam_' ms.landmarkModeSon '.txt']; % set where to save landmarks
if (exist(ms.landmarkSonPath,'file'))
    delete(ms.landmarkSonPath); % delete old annotations
end
ms.imgSon = im2double(imread(ms.imgSonPath));
ms.imgSon = imresize(ms.imgSon, [300, NaN]);

% Modality son 2
function prepareSImg(ms)
[filename, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
    '*.*','All Files' },'Choose neutral son image',...
    ms.imagesPath);
if isequal(filename,0)
    error('User selected Cancel')
end
ms.imgSonName = filename;
ms.imgSonPath = fullfile(pathname, filename);
ms.landmarkSonPath = [ms.landmarksPath ms.imgSonName(1:end-4) '_' ms.landmarkModeSon '.txt']; % if not exist, set where to save landmarks
ms.imgSon = im2double(imread(ms.imgSonPath));
ms.imgSon = imresize(ms.imgSon, [300, NaN]);

function recordCam(ms) % TODO
disp('Press space to start recording.');
cam = webcam;
preview(cam);
pause;
i = 1;
while i < 31
    images(end+1) = imresize(snapshot(cam), [300, NaN]);
end
closePreview(cam);
clear('cam');

function saveCamImage(ms)
disp('Press space to save image.');
cam = webcam;
preview(cam);
pause;
img = snapshot(cam);
imwrite(img, [ms.imagesPath 'Webcam.jpg']);
closePreview(cam);
clear('cam');

function firstImage = getFirstImage(sonImagesPath)
exprDir = dir(sonImagesPath);
fullPath = [sonImagesPath '/' exprDir(3).name '/'];
% consider index 3, to exclude ./ and ../
allImages = dir([fullPath '*.jpg']);
firstImage = [fullPath allImages(1).name];

function firstLandmark = getFirstLandmark(sonLandmarksPath)
exprDir = dir(sonLandmarksPath);
fullPath = [sonLandmarksPath '/' exprDir(3).name '/'];
% consider index 3, to exclude ./ and ../
allLandmarks = dir([fullPath '*.txt']);
firstLandmark = [fullPath allLandmarks(1).name];