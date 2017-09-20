function plotAUV(dataAll,lts,index)
idx = cumsum(lts);
figure;
plot(dataAll(1:idx(1), index));hold on;
for i = 1:length(idx)-1
    plot(dataAll(idx(i)+1:idx(i+1), index));hold on;
end