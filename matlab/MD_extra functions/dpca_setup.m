function [FR,time] = dpca_setup(all_SU,all_S,all_index,cells,trialNum,Comp)

%generates the firing rate matrices for dmixpca
% inputs: 
    % all_SU: 
    % all_S: 
    % all_index: 
    % cells: which cells to include in the analyis
    % trialNum: max number of trials for the mix block
    % trialNumTest: max number of trials for the test block
    % Comp: COMParison you want to use ('l' = low/mix, 'h' = high/mix)
% outputs: 
    % FR: mix block firing rate for the 3 reward volumes for 2 blocks in
        % the specified comparison
        % FR = N, S, D, T, E
            % N = neurons (1:length(cells)
            % S = rewards (1:3)
            % D = blocks (1:2) 1 = mix, 2 = adaptations
            % T = time (length(xvec))        
            % E = data (hmat data)

    % time: time vector



N = length(cells);
S = 3; %rewards
if Comp=='l'
    sv = 1:3;
else
    sv = 3:5;
end
D = 2; %blocks

T = all_SU{1}.xvec.CON; %time
maxTrialNum = max(trialNum,[],'all');

alignto = {'COFF', 'SON','SOFF','Rew','Opt','CON'};
for k = 1:length(alignto)
%firingRates: N x S x D x T x maxTrialNum
FR.(alignto{k}) = nan(N,S,D,length(T),maxTrialNum);
end

for n = 1:N %length of cells
    for s = sv %rewards
            SU = all_SU{n};
            S1 = all_S{all_index{n,4}};
            S1.RewardAmount = convertreward(S1.RewardAmount);

            %mix block
            trials = find(S1.RewardAmount==s & S1.Block==1 & S1.hits==1); %rewarded trials only
            for k = 1:length(alignto)
            a = SU.hmat.(alignto{k})(trials,:);
            a(isnan(a)) = 0;
            if Comp=='l'
            FR.(alignto{k})(n,s,1,:,1:length(trials)) = a';
            else
            FR.(alignto{k})(n,s-2,1,:,1:length(trials)) = a';
            end
            end

            %adaptation blocks
            if Comp == 'l'
                %low block
            trials2 = find(S1.RewardAmount==s & S1.Block==3 & S1.hits==1); %rewarded trials only
            else
                %high block
            trials2 = find(S1.RewardAmount==s & S1.Block==2 & S1.hits==1); %rewarded trials only
            end

            for k = 1:length(alignto)
            b = SU.hmat.(alignto{k})(trials2,:);
            b(isnan(b)) = 0;
            if Comp=='l'
            FR.(alignto{k})(n,s,2,:,1:length(trials2))=b';
            else
            FR.(alignto{k})(n,s-2,2,:,1:length(trials2))=b';
            end
            end 
    end
end

%compute PSTH
%plots a subset of cells vol PSTH
for k = 1:length(alignto)
    FRavg.(alignto{k}) = mean(FR.(alignto{k}),5,'omitnan');
end
figure('color','white')
for k = 1:length(alignto)
    subplot(1,length(alignto),k)
plot(T,squeeze(FRavg.(alignto{k})(randi([1 N],10,1),1,1,:))')
title(alignto{k})
end

time = all_SU{1}.xvec.CON;
