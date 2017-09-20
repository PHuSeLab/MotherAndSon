function M = buildShapeMatrix(dims)
    
    shape = LoadShapeVects();
    M =[];
    for i=0:112     %per ogni punto del modello
        S = [];     
        for j=1:length(shape)          % per ogni shape unit
            [~, index] = ismember(i,shape{j}(:,1));
            if (index>0)
                S = [S, shape{j}(index,2:dims+1)']; %adding this Unit Vector
            else
                S = [S, zeros(dims,1)];
            end
        end
        %S = [S,eye(dims)];
        M = [M;S];
    end