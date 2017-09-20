function [candideAll, sstShape, sstActionMultiFrames, handle] =  CandideLinearActionSimul(fiducial, landmarkMode, learn, sstActionMultiFrames, handle, subjectImg, dims)

% Import CANDIDE-3 model
candideModel = dlmread('candide3.dat');
candideModel = candideModel(:,1:dims);
candideAll = [];

TRI = dlmread('triangles.dat');
TRI = TRI+1;

candideVect = reshape(candideModel',size(candideModel,1)*dims,1);

[facialFeature, map] = mapCandidePts(fiducial, landmarkMode);

if (dims == 3) % add third dimension to fiducial points
    facialFeature(:,3,:) = zeros([size(facialFeature,1) size(facialFeature,3)]);
end

showCandidePts = 1;
processAUVp = 0; % 0 - dont process AUV parameters
                 % 1 - use smoothdata
                 % 2 - use kalman filter


if showCandidePts
    if ~isempty(handle)
        set(0, 'CurrentFigure', handle);
    else
        handle = figure;
        pos = get(gcf, 'pos');
        set(gcf,'units','normalized', 'pos',[pos(1) pos(2) [.5 1]])
    end
end

Ma = buildActionMatrix(dims);
Ms = buildShapeMatrix(dims);

if (dims == 3)
    [Rx, Ry, Rz] = buildRotationMatrices(dims);
elseif (dims == 2)
    R = buildRotationMatrices(dims);
end


% Calculate shape parameters
sstParams = ParamsLSF(map, candideModel, facialFeature(:,:,1), true, false);
scale = sstParams.data(sstParams.indexes.scale);
sstShape = sstParams.data(sstParams.indexes.shape) / scale;

% add Shape
MS = Ms*sstShape;
CSS = candideVect + MS;

if ~learn
    for i = 1:size(sstActionMultiFrames,2)
        
        sstAction = sstActionMultiFrames(:,i);
        
        % add Action
        MA = Ma*sstAction;
        CSSA = CSS + MA;
        
        % add Scale
        CS = CSSA*sstParams.data(sstParams.indexes.scale);
        % add Rotation
        if (dims == 3)
            CR = candideModel*(sstParams.data(sstParams.indexes.rot(1))*Rx + sstParams.data(sstParams.indexes.rot(2))*Ry + sstParams.data(sstParams.indexes.rot(3))*Rz);
        elseif (dims == 2)
            CR = candideModel*(sstParams.data(sstParams.indexes.rot)*R);
        end
        CRres = reshape(CR', [], 1);
        CS4 = CS + CRres;
        % add Traslation
        T = repmat(sstParams.data(sstParams.indexes.t), 113, 1);
        CS5 = CS4 + T;
        
        candideSon = reshape(CS5,dims,[])';
        
        if showCandidePts
            if (dims == 2)
                subplot(2,2,1);triplot(TRI, candideVect(1:dims:end), candideVect(2:dims:end));
                title('starting model - m');
                subplot(2,2,2);triplot(TRI, CSS(1:dims:end), CSS(2:dims:end));
                title('m + shape');
                subplot(2,2,3);triplot(TRI, CSSA(1:dims:end), CSSA(2:dims:end));
                title('m + shape + action');
                subplot(2,2,4);
%               imshow(subjectImg);
%               hold on;
                plot(candideSon(:,1), candideSon(:,2), 'r.');
                triplot(TRI, CS5(1:dims:end), CS5(2:dims:end));
%               hold off;                
                title('RS(m) + shape + action + t');
            elseif (dims == 3)
                subplot(2,2,1);trimesh(TRI, candideVect(1:dims:end), candideVect(2:dims:end), candideVect(3:dims:end));
                title('starting model - m');
                view(-45,80);
                subplot(2,2,2);trimesh(TRI, CSS(1:dims:end), CSS(2:dims:end), CSS(3:dims:end));
                title('m + shape');
                view(-45,80);
                subplot(2,2,3);trimesh(TRI, CSSA(1:dims:end), CSSA(2:dims:end), CSSA(3:dims:end));
                title('m + shape + action');
                view(-45,80);
                subplot(2,2,4);trimesh(TRI, CS5(1:dims:end), CS5(2:dims:end), CS5(3:dims:end));
                title('RS(m) + shape + action + t');
            end
            drawnow;
        end
        
        if dims == 3
            candideAll = cat(3, candideAll, [candideSon(:,1) candideSon(:,2) candideSon(:,3)]);
        else
            candideAll = cat(3, candideAll, [candideSon(:,1) candideSon(:,2)]);
        end
    end
else
    sstActionMultiFrames = [];
    
    candideShape = reshape(CSS,dims,[])';
    
    imagesMother = dirImages(subjectImg);
    
    for i = 1:size(facialFeature,3)

        % Calculate action parameters
        sstParams = ParamsLSF(map, candideShape, facialFeature(:,:,i), false, true);
        sstAction = sstParams.data(sstParams.indexes.action) / sstParams.data(sstParams.indexes.scale);
        
        sstActionMultiFrames = [sstActionMultiFrames, sstAction];
        
        if showCandidePts
            
            % add Action
            MA = Ma*sstAction;
            CSSA = CSS + MA;
            
            % add Scale
            CS = CSSA*sstParams.data(sstParams.indexes.scale);
            % add Rotation
            if (dims == 3)
                CR = candideModel*(sstParams.data(sstParams.indexes.rot(1))*Rx + sstParams.data(sstParams.indexes.rot(2))*Ry + sstParams.data(sstParams.indexes.rot(3))*Rz);
            elseif (dims == 2)
                CR = candideModel*(sstParams.data(sstParams.indexes.rot)*R);
            end
            CRres = reshape(CR', [], 1);
            CS4 = CS + CRres;
            % add Traslation
            T = repmat(sstParams.data(sstParams.indexes.t), 113, 1);
            CS5 = CS4 + T;
            
            if (dims == 2)
                subplot(2,2,1);triplot(TRI, candideVect(1:dims:end), candideVect(2:dims:end));
                title('starting model - m');
                subplot(2,2,2);triplot(TRI, CSS(1:dims:end), CSS(2:dims:end));
                title('m + shape');
                subplot(2,2,3);triplot(TRI, CSSA(1:dims:end), CSSA(2:dims:end));
                title('m + shape + action');
                subplot(2,2,4);
                imshow([subjectImg '/' imagesMother{i}]);
                hold on;
                plot(facialFeature(:,1,i), facialFeature(:,2,i), 'ro');
                triplot(TRI, CS5(1:dims:end), CS5(2:dims:end));
                hold off;
                title('RS(m) + shape + action + t');
            elseif (dims == 3)
                subplot(2,2,1);trimesh(TRI, candideVect(1:dims:end), candideVect(2:dims:end), candideVect(3:dims:end));
                title('starting model - m');
                view(-45,80);
                subplot(2,2,2);trimesh(TRI, CSS(1:dims:end), CSS(2:dims:end), CSS(3:dims:end));
                title('m + shape');
                view(-45,80);
                subplot(2,2,3);trimesh(TRI, CSSA(1:dims:end), CSSA(2:dims:end), CSSA(3:dims:end));
                title('m + shape + action');
                view(-45,80);
                subplot(2,2,4);trimesh(TRI, CS5(1:dims:end), CS5(2:dims:end), CS5(3:dims:end));
                title('RS(m) + shape + action + t');
            end
            drawnow;      
            pause;
        end
    end
    
%     smoothSstActionMultiFrames = smoothdata(sstActionMultiFrames');
%     
%     kalmanSstActionMultiFrames = [];
%     for s = 1:size(sstActionMultiFrames, 1)
%         y = sstActionMultiFrames(s,:);
%         ss = 2; % state size
%         os = 1; % observation size
%         F = [1 0; 0 1];
%         H = [1 0];
%         Q = 0.1*eye(ss);
%         R = 1*eye(os);
%         initx = [y(1) 1]';
%         initV = 10*eye(ss);
%         [xsmooth, ~] = kalman_smoother(y, F, H, Q, R, initx, initV);
%         kalmanSstActionMultiFrames = [kalmanSstActionMultiFrames; xsmooth(1,:)];
%     end
    
%     if (showCandidePts)
%         figure;
%         subplot(3,1,1);plot(sstActionMultiFrames');title('original');
%         subplot(3,1,2);plot(smoothSstActionMultiFrames);title('movmean smooth');
%         subplot(3,1,3);plot(kalmanSstActionMultiFrames');title('kalman smooth');
%         drawnow;
%         pause;
%     end
%     
%     if (processAUVp == 1)
%         sstActionMultiFrames = smoothSstActionMultiFrames;
%     elseif ( processAUVp == 2)
%         sstActionMultiFrames = kalmanSstActionMultiFrames;
%     end

    if ~exist('sstActionMultiFrames', 'var')
        sstActionMultiFrames = [];
    end
end
