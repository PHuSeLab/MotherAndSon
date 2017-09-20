function sst = ParamsLSF(map,candide,fiducial, doShape, doAction )

dims = size(candide, 2);
candide = candide(map(:,2), :);


indexes = {};

A = [];

if doAction
       
    action = LoadActionVects();
        
    % prepare action part
    for i=1:length(map) % for each fiducial point
        a = [];
        for j=1:length(action) % for each action unit
            [~, index] = ismember(map(i,2)-1,action{j}(:,1));
            if (index>0)
                a = [a, action{j}(index,2:dims+1)']; % adding this Unit Vector
            else
                a = [a, zeros(dims,1)];
            end
        end
        
        A=[A;a];
    end
        
end


S = [];

if doShape    
    shape = LoadShapeVects();
        
    % prepare shape part
    for i=1:length(map) % for each fiducial point
        s = [];
        for j=1:length(shape) % for each shape unit
            [~, index] = ismember(map(i,2)-1,shape{j}(:,1));
            if (index>0)
                s = [s, shape{j}(index,2:dims+1)']; %adding this Unit Vector
            else
                s = [s, zeros(dims,1)];
            end
        end
        
        S = [S;s];
    end
    
end
    
% scale part
candideVect = reshape(candide',size(candide,1)*dims,1);

% prepare rotation part
if (dims == 3)
    [Rx, Ry, Rz] = buildRotationMatrices(dims);

    Rxm = candide*Rx;
    Rym = candide*Ry;
    Rzm = candide*Rz;

    Rxm = reshape(Rxm',size(Rxm,1)*dims,1);
    Rym = reshape(Rym',size(Rym,1)*dims,1);
    Rzm = reshape(Rzm',size(Rzm,1)*dims,1);

    R = [Rxm, Rym, Rzm];
elseif (dims == 2)
    Rxy = buildRotationMatrices(dims);

    Rm = candide*Rxy;

    Rm = reshape(Rm',size(Rm,1)*dims,1);

    R = Rm;
end

% prepare traslation part
T = repmat(eye(dims), size(candide, 1), 1);

% prepare indexes
indexes.scale  = 1;
curIdx = indexes.scale + 1;
indexes.action = curIdx:size(A,2)+curIdx-1;
curIdx = size(A,2) + curIdx;
indexes.shape = curIdx:size(S,2)+curIdx-1;
curIdx = size(S,2) + curIdx;
indexes.rot = curIdx:size(R,2)+curIdx-1;
curIdx = size(R,2) + curIdx;
indexes.t = curIdx:size(T,2)+curIdx-1;

M = [candideVect, A, S, R, T];

g = reshape(fiducial',size(fiducial,1)*dims,1);

x = M\g;
%x = pinv(M)*g;   % x = (M'M)^-1 * M'*g;
sst.data = x;    % scale-shape-translation
sst.indexes = indexes;
% s = x(1);   %scale factor
% sigma = x(2:12)'/s; %shape parameters
% tx = x(13);   ty = x(14); %translation
end

