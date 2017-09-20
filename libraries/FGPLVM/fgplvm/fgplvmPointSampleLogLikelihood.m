function [out, maxX] = fgplvmPointSampleLogLikelihood(model,y,N,display)

% FGPLVMPOINTSAMPLELOGLIKELIHOOD
%
% COPYRIGHT : Carl Henrik Ek, 2008

% FGPLVM

if(nargin<4)
  display = true;
  if(nargin<3)
    N = 50;
    if(nargin<2)
      error('Too few Arguments');
    end
  end
end

if(model.q>3)
  error('Only Two and Three dimensional latent spaces supported');
end

% get limits
x_min = min(model.X);
x_max = max(model.X);

% get sample grid
switch model.q
 case 1  
  G = linspace(x_min,x_max,N)';
 case 2
  [X, Y] = meshgrid(linspace(x_min(1),x_max(1),N),linspace(x_min(2),x_max(2), ...
						    N));
  G = [reshape(X,numel(X),1) reshape(Y,numel(Y),1)];
 case 3 
  [X, Y, Z] = meshgrid(linspace(x_min(1),x_max(1),N),linspace(x_min(2),x_max(2),N), ...
		     linspace(x_min(3),x_max(3),N));
  G = [reshape(X,numel(X),1) reshape(Y,numel(Y),1) reshape(Z,numel(Z),1)];
end

l = zeros(size(G,1),1);
if(display)
  handle_waitbar = waitbar(0,'Computing point likelihood');
end
for(i = 1:1:size(G,1))
  l(i) = fgplvmPointLogLikelihood(model,G(i,:),y);
  if(display)
    waitbar(i/size(G,1));
  end
end
if(display)
  close(handle_waitbar);
end

[~, idx] = max(l(:));
maxX = G(idx, :);

switch model.q
 case 1
  out = l;clear l;
 case 2
  out = reshape(l,N,N);clear l;
 case 3
  out = reshape(l,N,N,N);clear l;
end



if(display)
    figure;
    colormap winter;
    %h = imagesc(out);colorbar;
    surfc(X,Y,out);
    hold on;
    plot3(maxX(1), maxX(2), out(idx), 'ro');
    %shading flat
end

return
