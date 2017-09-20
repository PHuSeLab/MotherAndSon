function genLatentSpaceMotherSon(ms)

dataAll = [];
lbls = [];
LengthTrainSeq = [];

for m = 1:ms.motherCount
    load(ms.motherData{m});
    % get all processed mother data
    for i = 1:length(data)
        % action parameters
        dataAll = [dataAll; data{i}.sstAction'];
        % corresponding labels
        lbls = [lbls, data{i}.label];
        % and length of data for each label
        LengthTrainSeq = [LengthTrainSeq size(data{i}.sstAction,2)];
    end
end


%% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

Y = dataAll;

% Set up model
options = fgplvmOptions('ftc');
latentDim = 2;
d = size(Y, 2);
iters = 10000; % Number of iterations to optimise the data

disp('Generating model...');
model = fgplvmCreate(latentDim, d, Y, options);
  
% % Add dynamics model.
options = gpOptions('ftc');
options.kern = kernCreate(model.X, {'rbf', 'white'});
options.kern.comp{1}.inverseWidth = 0.2;
% This gives signal to noise of 0.1:1e-3 or 100:1.
options.kern.comp{1}.variance = 0.1^2;
options.kern.comp{2}.variance = 1e-3^2;
model = fgplvmAddDynamics(model, 'gp', options);
% Optimise the model.
model = fgplvmOptimise(model, 1, iters);

disp('Model generated.');

% Save the generated model that will construct the latent space and the labels.
filename = [ms.dataPath 'model_CandideSon_XXXX_' num2str(ms.dims) 'D_action.mat'];
[file,path] = uiputfile(filename,'Save model as');
if isequal(file,0)
    error('User selected Cancel')
else
    save([path '/' file], 'model', 'lbls', 'LengthTrainSeq');
end