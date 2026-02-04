Xfull = firingRatesAverage;
plotFunction = @dpca_plot_default;

X = Xfull(:,:)';
% Xcen = bsxfun(@minus, X, mean(X,'omitnan'));
% XfullCen = bsxfun(@minus, Xfull, mean(X,'omitnan')');

Xcen = bsxfun(@minus, X, mean(X));
XfullCen = bsxfun(@minus, Xfull, mean(X)');

N = size(X, 1);
dataDim = size(Xfull);
Z = Xcen * W;
%!!
%Z = bsxfun(@times, Z, 1./std(Z, [], 1));
%!!
% y-axis spans
componentsToPlot = 1:20;
Zfull_control = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]);
vcolors = [0 .4 0; 1 .65 0; 1 0 0]; %need to play with colors to be color blind friendly

for i = 4
figure('color','w','position',[2000 200 1300 400])
subplot(131)
plotFunction(Zfull_control(i,:,:,:,:), time, [-20 20], ...
        [], 4, 0, ...
        [], [],vcolors)
end

Xfull = FRA2;
plotFunction = @dpca_plot_default;

X = Xfull(:,:)';
% Xcen = bsxfun(@minus, X, mean(X,'omitnan'));
% XfullCen = bsxfun(@minus, Xfull, mean(X,'omitnan')');

Xcen = bsxfun(@minus, X, mean(X));
XfullCen = bsxfun(@minus, Xfull, mean(X)');

N = size(X, 1);
dataDim = size(Xfull);
Z = Xcen * W;
%!!
%Z = bsxfun(@times, Z, 1./std(Z, [], 1));
%!!
% y-axis spans
componentsToPlot = 1:20;
Zfull_opto = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]);

vcolors = [0.4 .8 0.4; 1 .8 .5; 1 0.5 0.5]; %need to play with colors to be color blind friendly
for i = 4
    subplot(132)
plotFunction(Zfull_opto(i,:,:,:,:), time, [-20 20], ...
        [], 4, 0, ...
        [], [],vcolors)
end

titlename = {'Control','Opto'};
for s = 1:2
    subplot(1,3,s)
    ylim([-13 13])
    title(titlename{s})
    xlim([-1 4])
end
subplot(1,3,3)
volnum = {'20','40','80'};
vcolors = [0 .4 0; 1 .65 0; 1 0 0]; %need to play with colors to be color blind friendly
vcolorso = [0.4 .8 0.4; 1 .8 .5; 1 0.5 0.5]; %need to play with colors to be color blind friendly

for f = 1:3
    hold on
plot([0.5 1], [f+.1 f+.1], 'color', vcolors(f,:), 'LineWidth', 2)
plot([0.5 1], [f f], 'color', vcolorso(f,:), 'LineWidth', 2)

text(1.2, f+.1, [num2str(volnum{f}) 'uL'])
end
plot([0.5 1], [-2 -2], 'k', 'LineWidth', 2); 
plot([0.5 1], [-3 -3], 'k--', 'LineWidth', 2)
text(1.2, -2, 'Mix block')
text(1.2, -3, 'High block')
axis([0 3 -4.5 1.5+3])
set(gca, 'XTick', [])
set(gca, 'YTick', [])
set(gca,'Visible','off')














%%
figure
for f = 1:3
vcolors = [0 .4 0; 1 .65 0; 1 0 0]; %need to play with colors to be color blind friendly
colors = vcolors(1:3,:);
% PSTH = squeeze(Zfull_control(4, f, 1, :));
% smooth_PSTH = movmean(PSTH,5);
% plot(time, smooth_PSTH, 'color', colors(f,:), 'LineWidth', 2)

PSTH = squeeze(Zfull_control(4, f, 2, :));
smooth_PSTH = movmean(PSTH,5);
plot(time, smooth_PSTH, '--', 'color', colors(f,:), 'LineWidth', 2)
hold on

vcolors = [0.4 .8 0.4; 1 .8 .5; 1 0.5 0.5]; %need to play with colors to be color blind friendly
colors = vcolors(1:3,:);
PSTH = squeeze(Zfull_opto(4, f, 1, :));
smooth_PSTH = movmean(PSTH,5);
plot(time, smooth_PSTH, 'color', colors(f,:), 'LineWidth', 2)
PSTH = squeeze(Zfull_opto(4, f, 2, :));
smooth_PSTH = movmean(PSTH,5);
plot(time, smooth_PSTH, '--', 'color', colors(f,:), 'LineWidth', 2)

end

