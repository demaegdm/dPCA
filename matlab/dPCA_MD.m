function [W,V,PC] = dPCA_MD(FR_control,time,trialNum,savename,savename2,FR_opto,trials2)
% firingRates
% time
% trialNum
% savename: non regularized weights
% savename2: regularized weights

FR_control_mean = nanmean(FR_control, 5);
FR_opto_mean = nanmean(FR_opto, 5);
%% Define parameter grouping
% *** Don't change this if you don't know what you are doing! ***
% firingRates array has [N S D T E] size; here we ignore the 1st dimension 
% (neurons), i.e. we have the following parameters:
%    1 - stimulus 
%    2 - decision
%    3 - time
% There are three pairwise interactions:
%    [1 3] - stimulus/time interaction
%    [2 3] - decision/time interaction
%    [1 2] - stimulus/decision interaction
% And one three-way interaction:
%    [1 2 3] - rest
% As explained in the eLife paper, we group stimulus with stimulus/time interaction etc.:

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Reward', 'Block', 'Condition-independent', 'S/D Interaction'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% For two parameters (e.g. stimulus and time, but no decision), we would have
% firingRates array of [N S T E] size (one dimension less, and only the following
% possible marginalizations:
%    1 - stimulus
%    2 - time
%    [1 2] - stimulus/time interaction
% They could be grouped as follows: 
%    combinedParams = {{1, [1 2]}, {2}};

% Time events of interest (e.g. stimulus onset/offset, cues etc.)
% They are marked on the plots with vertical lines
%timeEvents = time(round(length(time)/2));
timeEvents = 0;

% check consistency between trialNum and firingRates
for n = 1:size(FR_control,1)
    for s = 1:size(FR_control,2)
        for d = 1:size(FR_control,3)
            assert(isempty(find(isnan(FR_control(n,s,d,:,1:trialNum(n,s,d))), 1)), 'Something is wrong!')
        end
    end
end
disp('done')
%% Step 1: PCA of the dataset

X = FR_control_mean(:,:);
X = bsxfun(@minus, X, mean(X,2));

[W,~,~] = svd(X, 'econ');
W = W(:,1:20);

% minimal plotting
dpca_plot(FR_control_mean, W, W, @dpca_plot_default);

% computing explained variance
explVar = dpca_explainedVariance(FR_control_mean, W, W, ...
    'combinedParams', combinedParams);

% a bit more informative plotting
dpca_plot(FR_control_mean, W, W, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours);
disp('done')

%% Step 2: PCA in each marginalization separately

dpca_perMarginalization(FR_control_mean, @dpca_plot_default, ...
   'combinedParams', combinedParams);

%% Step 3: dPCA without regularization and ignoring noise covariance

% This is the core function.
% W is the decoder, V is the encoder (ordered by explained variance),
% whichMarg is an array that tells you which component comes from which
% marginalization

tic
[W,V,whichMarg] = dpca(FR_control_mean, 20, ...
    'combinedParams', combinedParams);
toc

explVar = dpca_explainedVariance(FR_control_mean, W, V, ...
    'combinedParams', combinedParams);

close all %all the figures until this point are just PCA

%% dpca on first dataset
[PC] = dpca_plot(FR_control_mean, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);
sgtitle('Control Sessions')
%% dpca on second dataset
[PC] = dpca_plot(FR_opto_mean, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);
sgtitle('Opto Sessions')

% %%
% Xfull = FR_control_mean;
% plotFunction = @dpca_plot_default;
% 
% X = Xfull(:,:)';
% % Xcen = bsxfun(@minus, X, mean(X,'omitnan'));
% % XfullCen = bsxfun(@minus, Xfull, mean(X,'omitnan')');
% 
% Xcen = bsxfun(@minus, X, mean(X));
% XfullCen = bsxfun(@minus, Xfull, mean(X)');
% 
% N = size(X, 1);
% dataDim = size(Xfull);
% Z = Xcen * W;
% %!!
% %Z = bsxfun(@times, Z, 1./std(Z, [], 1));
% %!!
% % y-axis spans
% componentsToPlot = 1:20;
% Zfull_control = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]);
% vcolors = [0 .4 0; 1 .65 0; 1 0 0]; %need to play with colors to be color blind friendly
% 
% for i = 9
% figure('color','w','position',[2000 200 1300 400])
% subplot(131)
% plotFunction(Zfull_control(i,:,:,:,:), time, [-50 50], ...
%         [], 4, 0, ...
%         [], [],vcolors)
% end
% ylabel('Normalized firing rate (Hz)')
% Xfull = FR_opto_mean;
% plotFunction = @dpca_plot_default;
% 
% X = Xfull(:,:)';
% % Xcen = bsxfun(@minus, X, mean(X,'omitnan'));
% % XfullCen = bsxfun(@minus, Xfull, mean(X,'omitnan')');
% 
% Xcen = bsxfun(@minus, X, mean(X));
% XfullCen = bsxfun(@minus, Xfull, mean(X)');
% 
% N = size(X, 1);
% dataDim = size(Xfull);
% Z = Xcen * W;
% %!!
% %Z = bsxfun(@times, Z, 1./std(Z, [], 1));
% %!!
% % y-axis spans
% componentsToPlot = 1:20;
% Zfull_opto = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]);
% 
% vcolors = [0.4 .8 0.4; 1 .8 .5; 1 0.5 0.5]; %need to play with colors to be color blind friendly
% for i = 9%4
%     subplot(132)
% plotFunction(Zfull_opto(i,:,:,:,:), time, [-20 20], ...
%         [], 4, 0, ...
%         [], [],vcolors)
% end
% 
% titlename = {'Control','Opto'};
% for s = 1:2
%     subplot(1,3,s)
%     %ylim([-13 13])
%     ylim([-10 10])
%     title(titlename{s})
%     xlim([-1 4])
% end
% subplot(1,3,3)
% %volnum = {'20','40','80'};
% volnum = {'5','10','20'};
% vcolors = [0 .4 0; 1 .65 0; 1 0 0]; %need to play with colors to be color blind friendly
% vcolorso = [0.4 .8 0.4; 1 .8 .5; 1 0.5 0.5]; %need to play with colors to be color blind friendly
% 
% for f = 1:3
%     hold on
% plot([0.5 1], [f+.1 f+.1], 'color', vcolors(f,:), 'LineWidth', 2)
% plot([0.5 1], [f f], 'color', vcolorso(f,:), 'LineWidth', 2)
% 
% text(1.2, f+.1, [num2str(volnum{f}) 'uL'])
% end
% plot([0.5 1], [-2 -2], 'k', 'LineWidth', 2); 
% plot([0.5 1], [-3 -3], 'k--', 'LineWidth', 2)
% text(1.2, -2, 'Mix block')
% text(1.2, -3, 'Low block')
% %text(1.2, -3, 'High block')
% axis([0 3 -4.5 1.5+3])
% set(gca, 'XTick', [])
% set(gca, 'YTick', [])
% set(gca,'Visible','off')
% %%





%keyboard
% save(['C:\Users\mld9131\Documents\GitHub\dPCA\matlab\' savename '.mat'],'W','V','whichMarg', 'FR_control_mean','FR_opto_mean');






%% Next bit
% try
% %% Step 4: dPCA with regularization
% % This function takes some minutes to run. It will save the computations 
% % in a .mat file with a given name. Once computed, you can simply load 
% % lambdas out of this file:
% %   load('tmp_optimalLambdas.mat', 'optimalLambda')
% 
% % Please note that this now includes noise covariance matrix Cnoise which
% % tends to provide substantial regularization by itself (even with lambda set
% % to zero).
% 
% optimalLambda = dpca_optimizeLambda(firingRatesAverage, firingRates, trialNum, ...
%     'combinedParams', combinedParams, ...
%     'simultaneous', ifSimultaneousRecording, ...
%     'numRep', 2, ...  % increase this number to ~10 for better accuracy
%     'filename', 'tmp_optimalLambdas.mat');
% 
% Cnoise = dpca_getNoiseCovariance(firingRatesAverage, ...
%     firingRates, trialNum, 'simultaneous', ifSimultaneousRecording);
% 
% [W,V,whichMarg] = dpca(firingRatesAverage, 20, ...
%     'combinedParams', combinedParams, ...
%     'lambda', optimalLambda, ...
%     'Cnoise', Cnoise);
% 
% explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
%     'combinedParams', combinedParams);
% 
% dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
%     'explainedVar', explVar, ...
%     'marginalizationNames', margNames, ...
%     'marginalizationColours', margColours, ...
%     'whichMarg', whichMarg,                 ...
%     'time', time,                        ...
%     'timeEvents', timeEvents,               ...
%     'timeMarginalization', 3,           ...
%     'legendSubplot', 16);
% 
% %% Optional: estimating "signal variance"
% 
% explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
%     'combinedParams', combinedParams, ...
%     'Cnoise', Cnoise, 'numOfTrials', trialNum);
% 
% % Note how the pie chart changes relative to the previous figure.
% % That is because it is displaying percentages of (estimated) signal PSTH
% % variances, not total PSTH variances. See paper for more details.
% 
% dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
%     'explainedVar', explVar, ...
%     'marginalizationNames', margNames, ...
%     'marginalizationColours', margColours, ...
%     'whichMarg', whichMarg,                 ...
%     'time', time,                        ...
%     'timeEvents', timeEvents,               ...
%     'timeMarginalization', 3,           ...
%     'legendSubplot', 16);
% 
% %% Optional: decoding
% 
% decodingClasses = {[(1:S)' (1:S)'], repmat([1:2], [S 1]), [], [(1:S)' (S+(1:S))']};
% 
% accuracy = dpca_classificationAccuracy(firingRatesAverage, firingRates, trialNum, ...
%     'lambda', optimalLambda, ...
%     'combinedParams', combinedParams, ...
%     'decodingClasses', decodingClasses, ...
%     'simultaneous', ifSimultaneousRecording, ...
%     'numRep', 5, ...        % increase to 100
%     'filename', [savename2 '.mat']);
% 
% dpca_classificationPlot(accuracy, [], [], [], decodingClasses)
% 
% accuracyShuffle = dpca_classificationShuffled(firingRates, trialNum, ...
%     'lambda', optimalLambda, ...
%     'combinedParams', combinedParams, ...
%     'decodingClasses', decodingClasses, ...
%     'simultaneous', ifSimultaneousRecording, ...
%     'numRep', 5, ...        % increase to 100
%     'numShuffles', 20, ...  % increase to 100 (takes a lot of time)
%     'filename', 'tmp_classification_accuracy.mat');
% 
% dpca_classificationPlot(accuracy, [], accuracyShuffle, [], decodingClasses)
% 
% componentsSignif = dpca_signifComponents(accuracy, accuracyShuffle, whichMarg);
% 
% dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
%     'explainedVar', explVar, ...
%     'marginalizationNames', margNames, ...
%     'marginalizationColours', margColours, ...
%     'whichMarg', whichMarg,                 ...
%     'time', time,                        ...
%     'timeEvents', timeEvents,               ...
%     'timeMarginalization', 3,           ...
%     'legendSubplot', 16,                ...
%     'componentsSignif', componentsSignif);
% catch
%     disp('no regularization')
% end
