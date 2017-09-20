function M = buildActionMatrix(dims)
    
    action = LoadActionVects();
    M =[];
    for i=0:112     %per ogni punto del modello
        A = [];
        for j=1:length(action)         % per ogni action unit
            [~, index] = ismember(i,action{j}(:,1));
            if (index>0)
                A = [A, action{j}(index,2:dims+1)']; %adding this Unit Vector
            else
                A = [A,zeros(dims,1)];
            end
        end
        %A = [A,eye(dims)];
        M = [M;A];
    end