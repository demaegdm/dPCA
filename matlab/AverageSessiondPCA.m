function [D_PSTH_block_avg,D_PSTH_block_opto_avg,D_PSTH_Rew_avg, ...
    D_PSTH_Rew_opto_avg, sig_block, ...
    sig_rew,pv_block,pv_rew] = AverageSessiondPCA(Comp,event, varargin)

%averages the top Block/Reward PC for each session
%adapt - mix block for each session
%volume 3-volume 1 for each session
    % Low-mix: V3 = 20 V1 = 5;
    % High-mix: V3 = 80 V1 = 20;
%Inputs:
    % Comp = 'h' for high-mix, 'l' for low-mix
    % varargin = 1 to plot abs(difference) in block and reward averaged across
    % sessions
        % abs bc some sessions have mix>adapt unit sign doesn't matter,
        % unit size does
%Outputs: 
    %D_PSTH_block_avg = average signed adapt-mix for each session control
    %D_PSTH_block_opto_avg = average signed adapt-mix for each session opto
    %D_PSTH_Rew_avg = average signed V3-V1 for each session control
    %D_PSTH_Rew_opto_avg = average signed V3-V1 for each session opto
    %sig_block = permutation significance for each point in time
    %sig_rew = permutation significance for each point in time
        


%find files in dPCA folder
if Comp == 'l'
    F = '\\constantinoplelab.cns.nyu.edu\server2\PhysiologyData\Maggie\Chronic_implant\Npxl\Optotagged_cells\figures\dPCA\Low-mix\Data';
    c = 'mix-low';
else
    F =  '\\constantinoplelab.cns.nyu.edu\server2\PhysiologyData\Maggie\Chronic_implant\Npxl\Optotagged_cells\figures\dPCA\High-mix\Data';
    c = 'mix-high';
end


N = dir(F);
N = {N(contains({N.name},'.mat') & ~contains({N.name},'Average')).name}';

for i = 1:length(N(:,1))
%load data control and opto data
load(fullfile(F,N{i}),'FR','FRo','PC','W','time')

%find top block/reward component number
% event = 'COFF';
% firingRates_new = FR.(event);
% firingRates_opto = FRo.(event);
% trialsvec = trialNumco;
% trialsveco = trialNumoo;
% 
% %naming
% weight1 = ['OFC-opto_',event,'_',c,'weights'];
% weight2 = ['OFC-opto_',event,'_',c,'weights_regular'];


% [W,V,PC] = dPCA_MD(firingRates_new,time,trialsvec,...
%     weight1,weight2,...
%     firingRates_opto,trialsveco);
% close all;

%
[Zfull_control] = prepplot(FR,event,W);
[Zfull_opto] = prepplot(FRo,event,W);

Top_block = PC{3}(1);
for v = 1:3
PSTH_mix(v,:) = squeeze(Zfull_control(Top_block,v,1,:));
PSTH_adapt(v,:) = squeeze(Zfull_control(Top_block,v,2,:));

PSTH_mix_opto(v,:) = squeeze(Zfull_opto(Top_block,v,1,:));
PSTH_adapt_opto(v,:) = squeeze(Zfull_opto(Top_block,v,2,:));
end
        % % plot
        % figure
        % hold on
        % plot(time,PSTH_mix)
        % plot(time, PSTH_adapt)

% %subtract adapt from mix
% D_PSTH = PSTH_adapt-PSTH_mix;
% D_PSTH_opto = PSTH_adapt_opto-PSTH_mix_opto;
% 
% D_PSTH_block_avg(i,:) = mean(D_PSTH,'omitnan');
% D_PSTH_block_opto_avg(i,:) = mean(D_PSTH_opto,'omitnan');

% subtract prefered from non-preferred
a = mean(PSTH_mix,'all');
b = mean(PSTH_adapt,'all');

if a>b
    D_PSTH = PSTH_mix-PSTH_adapt;
    D_PSTH_opto = PSTH_mix_opto-PSTH_adapt_opto;
else
    D_PSTH = PSTH_adapt-PSTH_mix;
    D_PSTH_opto = PSTH_adapt_opto-PSTH_mix_opto;
end

D_PSTH_block_avg(i,:) = mean(D_PSTH,'omitnan');
D_PSTH_block_opto_avg(i,:) = mean(D_PSTH_opto,'omitnan');



        % % %plot
        % figure
        % shadedErrorBar(time, mean(D_PSTH,'omitnan'), std(D_PSTH,'omitnan'))
        % shadedErrorBar(time, mean(D_PSTH_opto,'omitnan'), std(D_PSTH_opto,'omitnan'), 'lineprops',{'color',[0.5 0.5 0.5]})
        % xline(0,'--')
        % ylabel('Mean difference in firing rates')
        % xlabel('')
        % % ylim([-17 35])
        % set(gca, "Box", 'off', 'TickDir', 'out')


Top_reward = PC{2}(1);
for v = 1:3
PSTH_mix(v,:) = squeeze(Zfull_control(Top_reward,v,1,:));
PSTH_adapt(v,:) = squeeze(Zfull_control(Top_reward,v,2,:));

PSTH_mix_opto(v,:) = squeeze(Zfull_opto(Top_reward,v,1,:));
PSTH_adapt_opto(v,:) = squeeze(Zfull_opto(Top_reward,v,2,:));
end
        % % plot
        % figure
        % hold on
        % plot(time,PSTH_mix)
        % plot(time, PSTH_adapt)

% %subtract adapt from mix
% D_PSTH = [];
% D_PSTH_opto = [];
% 
% D_PSTH = [PSTH_mix(3,:)-PSTH_mix(1,:);PSTH_adapt(3,:)-PSTH_adapt(1,:)];
% D_PSTH_opto = [PSTH_mix_opto(3,:)-PSTH_mix_opto(1,:);PSTH_adapt_opto(3,:)-PSTH_adapt_opto(1,:)];
% 
% D_PSTH_Rew_avg(i,:) = mean(D_PSTH,'omitnan');
% D_PSTH_Rew_opto_avg(i,:) = mean(D_PSTH_opto,'omitnan');



% subtract prefered from non-preferred
a = mean(PSTH_mix(1,:));
b = mean(PSTH_mix(3,:));

if a>b
    D_PSTH = [PSTH_mix(1,:)-PSTH_mix(3,:);PSTH_adapt(1,:)-PSTH_adapt(3,:)];
    D_PSTH_opto = [PSTH_mix_opto(1,:)-PSTH_mix_opto(3,:);PSTH_adapt_opto(1,:)-PSTH_adapt_opto(3,:)];
else
    D_PSTH = [PSTH_mix(3,:)-PSTH_mix(1,:);PSTH_adapt(3,:)-PSTH_adapt(1,:)];
    D_PSTH_opto = [PSTH_mix_opto(3,:)-PSTH_mix_opto(1,:);PSTH_adapt_opto(3,:)-PSTH_adapt_opto(1,:)];
end

D_PSTH_Rew_avg(i,:) = mean(D_PSTH,'omitnan');
D_PSTH_Rew_opto_avg(i,:) = mean(D_PSTH_opto,'omitnan');


        % %plotplotplotpl
        % figure
        % shadedErrorBar(time, mean(D_PSTH,'omitnan'), std(D_PSTH,'omitnan'))
        % shadedErrorBar(time, mean(D_PSTH_opto,'omitnan'), std(D_PSTH_opto,'omitnan'), 'lineprops',{'color',[0.5 0.5 0.5]})
        % xline(0,'--')
        % ylabel('Mean difference in firing rates')
        % xlabel('')
        % % ylim([-17 35])
        % set(gca, "Box", 'off', 'TickDir', 'out')
end

for i = 1:length(time)
% pv_block(i) = permute_test(abs(D_PSTH_block_avg(:,i)),abs(D_PSTH_block_opto_avg(:,i)),100);
% pv_rew(i) = permute_test(abs(D_PSTH_Rew_avg(:,i)),abs(D_PSTH_Rew_opto_avg(:,i)),100);

pv_block(i) = permute_test(D_PSTH_block_avg(:,i),D_PSTH_block_opto_avg(:,i),1000);
pv_rew(i) = permute_test(D_PSTH_Rew_avg(:,i),D_PSTH_Rew_opto_avg(:,i),1000);
end

sig_block = pv_block<0.05;
sig_rew = pv_rew<0.05;
h = ones(1,length(time));

if ~isempty(varargin)
figure
subplot(2,1,1)
% shadedErrorBar(time, mean(abs(D_PSTH_block_avg)), sem(abs(D_PSTH_block_avg)))
% shadedErrorBar(time, mean(abs(D_PSTH_block_opto_avg)), sem(abs(D_PSTH_block_opto_avg)),'lineprops',{'color',[0.5 0.5 0.5]});

shadedErrorBar(time, mean(D_PSTH_block_avg), sem(D_PSTH_block_avg))
shadedErrorBar(time, mean(D_PSTH_block_opto_avg), sem(D_PSTH_block_opto_avg),'lineprops',{'color',[0.5 0.5 0.5]});

hold on
plot(time(sig_block),h(sig_block)+20,'.k')
title('Block difference')
ylabel([ '\Delta' 'FR'])

subplot(2,1,2)
% shadedErrorBar(time, mean(abs(D_PSTH_Rew_avg)), sem(abs(D_PSTH_Rew_avg)))
% shadedErrorBar(time, mean(abs(D_PSTH_Rew_opto_avg)), sem(abs(D_PSTH_Rew_opto_avg)),'lineprops',{'color',[0.5 0.5 0.5]});

shadedErrorBar(time, mean(D_PSTH_Rew_avg), sem(D_PSTH_Rew_avg))
shadedErrorBar(time, mean(D_PSTH_Rew_opto_avg), sem(D_PSTH_Rew_opto_avg),'lineprops',{'color',[0.5 0.5 0.5]});
hold on
plot(time(sig_rew),h(sig_rew)+20,'.k')
title('Reward difference')
ylabel([ '\Delta' 'FR'])
end




