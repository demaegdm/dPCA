
function [Zfull_control] = prepplot(FR,event,W)

%preps the dpca output for plotting single PCs


FR_control = FR.(event);
FR_control_mean = nanmean(FR_control, 5);

Xfull = FR_control_mean;
plotFunction = @dpca_plot_default;

X = Xfull(:,:)';
Xcen = bsxfun(@minus, X, mean(X));
XfullCen = bsxfun(@minus, Xfull, mean(X)');

N = size(X, 1);
dataDim = size(Xfull);
Z = Xcen * W;

componentsToPlot = 1:20;
Zfull_control = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]);
