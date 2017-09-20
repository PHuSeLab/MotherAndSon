function displayLatentSpaceMotherSon(ms)
close all;
addpath(genpath('.'));
dims = ms.dims;
candideModel = dlmread('candide3.dat');

TRI = dlmread('triangles.dat');
TRI = TRI+1;

% load model
[filename, pathname] = uigetfile([ms.dataPath 'models/*.mat'], ...
    'Select trained model');
if isequal(filename,0)
    error('User selected Cancel')
else
    load([pathname '/' filename]);
end
lblsCK = [];
for i=1:length(lbls)
    lblsCK = [lblsCK, {lbls(i)}];
end
lbls = lblsCK;

fiducialSon = ms.landmarkSon;

[facialFeature_son, map] = mapCandidePts(fiducialSon, ms.landmarkModeSon);

if (dims == 3) % add third dimension to fiducial points
    facialFeature_son(:,3,:) = zeros([size(facialFeature_son,1) size(facialFeature_son,3)]);
end

candideModel = candideModel(:,1:dims);
candideVect = reshape(candideModel',size(candideModel,1)*dims,1);

Ms = buildShapeMatrix(dims);

if (dims == 3)
    [Rx, Ry, Rz] = buildRotationMatrices(dims);
elseif (dims == 2)
    R = buildRotationMatrices(dims);
end

%% Calculate observer (son) shape parameters
sstParams = ParamsLSF(map, candideModel, facialFeature_son(:,:,1), true, false);

sstShape = sstParams.data(sstParams.indexes.shape) / sstParams.data(sstParams.indexes.scale);

% add Shape
MS = Ms*sstShape;
CSS = candideVect + MS;
% add Scale
CS = CSS*sstParams.data(sstParams.indexes.scale);
% add Rotation
if (dims == 3)
    CR = candideModel*(sstParams.data(sstParams.indexes.rot(1))*Rx + sstParams.data(sstParams.indexes.rot(2))*Ry + sstParams.data(sstParams.indexes.rot(3))*Rz);
elseif (dims == 2)
    CR = candideModel*(sstParams.data(sstParams.indexes.rot)*R);
end
CRres = reshape(CR', [], 1);
CS4 = CS + CRres;
% add Traslation
if (dims == 3)
    T = repmat(sstParams.data(sstParams.indexes.t), 113, 1);
elseif (dims == 2)
    T = repmat(sstParams.data(sstParams.indexes.t), 113, 1);
end
CS5 = CS4 + T;

candideShape_son = reshape(CS5,dims,[])';

lvmVisualiseMotherSon(model, lbls, ['landmarks' 'VisualiseExprSONgen'], ['landmarks' 'ModifyExprSONgen'], LengthTrainSeq, TRI, candideShape_son, ms);