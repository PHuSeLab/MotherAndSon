function [returnVal, txtReturnVal] = lvmTwoDPlot(X, lbl, symbol, doTest, Y, LengthTrainSeq ,fhandle)

% LVMTWODPLOT Helper function for plotting the labels in 2-D.
% FORMAT
% DESC helper function for plotting an embedding in 2-D with symbols.
% ARG X : the data to plot.
% ARG lbl : the labels of the data point.
% ARG symbol : the symbols to use for the different labels.
%
% SEEALSO : lvmScatterPlot, lvmVisualise
%
% COPYRIGHT : Neil D. Lawrence, 2004, 2005, 2006, 2008

% MLTOOLS
global visualiseInfo
if nargin < 6
    LengthTrainSeq = [];
end
if nargin < 2
    lbl = [];
end
if(strcmp(lbl, 'connect'))
    connect = true;
    lbl = [];
else
    connect = false;
end

if iscell(lbl)
    labelsString = true;
else
    labelsString = false;
end

if nargin < 3 || isempty(symbol)
    %if isempty(lbl)
        symbol = getSymbols(size(LengthTrainSeq,2));
    %else
    %    symbol = getSymbols(size(lbl,2));
    %end
end
if nargin > 6 && ~isempty(fhandle)
    axisHand = fhandle;
else
    axisHand = gca;
end
returnVal = [];
textReturnVal = [];
nextPlot = get(axisHand, 'nextplot');
labelNo=1;
deb=1;
for i = 1:size(LengthTrainSeq,2)
    x = X(deb:deb+LengthTrainSeq(i)-1, 1);
    y = X(deb:deb+LengthTrainSeq(i)-1, 2);
    returnVal = [returnVal; plot(x, y, symbol{labelNo}, 'linewidth',1)];
    if labelsString
        textReturnVal = [textReturnVal; text(X(deb+LengthTrainSeq(i)-1, 1), X(deb+LengthTrainSeq(i)-1, 2), ['   ' lbl{i}])];
    end
    labelNo = labelNo+1;
    deb= deb+LengthTrainSeq(i);
end

% for i = 1:(size(X, 1)/LengthTrainSeq)
%     returnVal = [returnVal; plot(X(deb:LengthTrainSeq*i, 1), X(deb:LengthTrainSeq*i, 2), symbol{labelNo}, 'linewidth',1)];
%     if labelsString
%         textReturnVal = [textReturnVal; text(X(LengthTrainSeq*i, 1), X(LengthTrainSeq*i, 2), ['   ' lbl{i}])];
%     end
%     labelNo = labelNo+1;
%     deb=(LengthTrainSeq*i)+1;
% end

if doTest==1
%     dataSetNameTest = 'testpoint';
%     [Y, lbls] = lvmLoadData(dataSetNameTest);
    %load model.mat; % load the learned model corresponding to the latent space
    model = visualiseInfo.model;
    iters=100;
    display=1;
    Xtest = zeros(size(Y, 1),model.q);
    for i=1:size(Xtest, 1)
        initXPos = getNearestValue(model.y, Y(i,:));
        if i == 1
            Xtest(i,:) = fgplvmOptimisePoint(model, model.X(initXPos,:), Y(i,:), display, iters);
        else
            Xtest(i,:) = fgplvmOptimisePoint(model,  Xtest(i-1,:), Y(i,:), display, iters);
        end
    end
    returnVal = [returnVal; plot(Xtest(:, visualiseInfo.dim1), Xtest(:, visualiseInfo.dim2), '^-', 'linewidth',1)];
end

set(axisHand, 'nextplot', nextPlot);
set(returnVal, 'markersize', 5);
set(returnVal, 'linewidth', 2);
end

function initXPos = getNearestValue(Ymodel, Y)  
    ytemp = 0;
    dist = Inf(1);
    for i=1:size(Ymodel,1)
        D = sqrt(sum((Ymodel(i,:) - Y) .^ 2));
        if(D < dist)
            dist = D;
            ytemp = i;
        end
    end
    initXPos = ytemp;
end
