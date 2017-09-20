clear; close all;
%addpath(genpath('.'));

ms = MotherSon;

%% CONFIGURATION
%% 0. Set default paths
ms.dataPath = 'Data/mat/';
ms.imagesPath = 'Data/images/';
ms.landmarksPath = 'Data/landmarks/';

%% 1. Choose processes to run
ms.processMother = 0;   % learn mother parameters
ms.modelGeneration = 1; % learn mother action latent space
ms.dims = 2;            % work with 2D/3D models

%% 2. Set Mother parameters
ms.motherCount = 1;            % total number of mothers
ms.landmarkModeMother = 'CK';  % CK, ZR, AA, TC
ms.motherModality = 0;         % 0 - use a CK dataset's session
                               % 1 - use webcam input (WIP / don't use)
                               % 2 - use an existing set of images

%% 3. Set Son parameters
ms.BW = 0;                  % Handle son images in BW (1) or RGB (0)
ms.landmarkModeSon = 'OF';  % OF, CK, ZR, AA, TC
ms.sonModality = 2;         % 0 - use a CK dataset's session
                            % 1 - use webcam input
                            % 2 - use an existing image

%% EXECUTION
% prepare mother and son images and landmarks
ms.prepareData;
% shows a description of the experiment
ms.printDescription;
% starts processing data
ms.processData;
% generates the son latent space based on mother actions
if (ms.modelGeneration)
    ms.genLatentSpaceMotherSon;
end
% shows the latent space and the new generated face expression 
ms.displayLatentSpaceMotherSon;