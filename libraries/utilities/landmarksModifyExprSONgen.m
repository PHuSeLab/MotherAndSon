function landmarksModifyExprSONgen(action_vector)

% LANDMARKSMODIFY Helper code for visualisation of facial landmarks data.

% MLTOOLS

global visualiseInfo

[candideMask_son, ~, ~] = CandideLinearActionSimul(visualiseInfo.fiducialSon, visualiseInfo.modalitySon, 0, action_vector', visualiseInfo.candideHandle, visualiseInfo.neutral, visualiseInfo.dims);

dims = 2;%size(candideMask_son,2);

if dims == 3
    FV.vertices=[candideMask_son(:,1), candideMask_son(:,2), candideMask_son(:,3)];
    FV.faces = visualiseInfo.TRI;
    [FV] = refinepatch(FV);
    
    visualiseInfo.newTRI = FV.faces;
    candideMask_son = FV.vertices;
    
    FV.vertices=[visualiseInfo.candideShape_son(:,1), visualiseInfo.candideShape_son(:,2), visualiseInfo.candideShape_son(:,3)];
    FV.faces = visualiseInfo.TRI;
    [FV] = refinepatch(FV);
    
    visualiseInfo.candideShape_son = FV.vertices;    
else
    visualiseInfo.newTRI = visualiseInfo.TRI;
end


transformed = NaN(size(visualiseInfo.neutral,1),size(visualiseInfo.neutral,2),size(visualiseInfo.neutral,3));

for t=1:size(visualiseInfo.newTRI,1)
    c = [visualiseInfo.candideShape_son(visualiseInfo.newTRI(t,1),1),visualiseInfo.candideShape_son(visualiseInfo.newTRI(t,2),1),visualiseInfo.candideShape_son(visualiseInfo.newTRI(t,3),1)];
    r = [visualiseInfo.candideShape_son(visualiseInfo.newTRI(t,1),2),visualiseInfo.candideShape_son(visualiseInfo.newTRI(t,2),2),visualiseInfo.candideShape_son(visualiseInfo.newTRI(t,3),2)];
    T = [c;r;[1 1 1]];
    c2 = [candideMask_son(visualiseInfo.newTRI(t,1),1),candideMask_son(visualiseInfo.newTRI(t,2),1),candideMask_son(visualiseInfo.newTRI(t,3),1)];
    r2 = [candideMask_son(visualiseInfo.newTRI(t,1),2),candideMask_son(visualiseInfo.newTRI(t,2),2),candideMask_son(visualiseInfo.newTRI(t,3),2)];
    S = [c2;r2;[1 1 1]];
    B = S/T;
    BW = roipoly(visualiseInfo.neutral, c, r);
    [u,v] = find(BW);
    for j=1:length(u)
        x = [v(j);u(j);1];
        x2 = round(B*x);
        transformed(x2(2),x2(1),:) = visualiseInfo.neutral(u(j),v(j),:);
    end
end

idxFace = [1 45 46 48 63 62 64 66 11 33 31 29 30 15 13 12];
idxMouth = [89 82 88 83 90 85 41 84];
face = roipoly(transformed,candideMask_son(idxFace,1),candideMask_son(idxFace,2));
mouth = roipoly(transformed,candideMask_son(idxMouth,1),candideMask_son(idxMouth,2));

if (size(transformed,3) == 3)
    tic;
    % get NaN matrices
    r = transformed(:,:,1); 
    g = transformed(:,:,2);
    b = transformed(:,:,3);
    % get neutral matrices
    nr = visualiseInfo.neutral(:,:,1);
    ng = visualiseInfo.neutral(:,:,2);
    nb = visualiseInfo.neutral(:,:,3);
    % remove area outside face and inside mouth
    r(~face | mouth) = 0;
    g(~face | mouth) = 0;
    b(~face | mouth) = 0;
    % calculate value for NaN points
    r = inpaint_nans(r,3);
    g = inpaint_nans(g,3);
    b = inpaint_nans(b,3);
    % restore area outside face
    r(~face) = nr(~face);
    g(~face) = ng(~face);
    b(~face) = nb(~face);
    % assign to image
    Interpolated(:,:,1) = r;
    Interpolated(:,:,2) = g;
    Interpolated(:,:,3) = b;
    toc
else
    tic;
    % remove area outside face and inside mouth
    transformed(~face | mouth) = 0;
    % calculate value for NaN points
    Interpolated = inpaint_nans(transformed,3);
    % restore area outside face
    Interpolated(~face) = visualiseInfo.neutral(~face);
    toc;
end
%figure(visualiseInfo.visHandle)
%set(0, 'CurrentFigure', visualiseInfo.visHandle);

A = imhandles(visualiseInfo.visHandle);
set(A, 'CData', Interpolated);
% imshow(Interpolated);
% hold on;
% triplot(visualiseInfo.TRI,candideMask_son(:,1),candideMask_son(:,2));
% hold off;
% drawnow limitrate;
