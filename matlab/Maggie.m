%% load OFC data
load('Y:\Maggie\Chronic_implant\Npxl\Optotagged_cells\all_cells_2025-06-02.mat');

%% reduce struct to only OFC neurons
[cells,~] = OnTarget(all_SU,all_S,all_index,'OFC');
[all_SU,all_S,all_index] = reduce_index(all_index,all_S, all_SU, cells);

% reduce to include at least 2 trials in each block of each volume
j=1;
for i = 1:length(all_S)
    S1 = all_S{i};
    S1.RewardAmount = convertreward(S1.RewardAmount);
    for r = 1:5
    mix(i,r) = length(find(S1.Block==1 & S1.RewardAmount==r & S1.hits==1));
    end
    for r = 1:3
    low(i,r) = length(find(S1.Block==3 & S1.RewardAmount==r & S1.hits==1));
    end
    for r = 3:5
    high(i,r-2) = length(find(S1.Block==2 & S1.RewardAmount==r & S1.hits==1));
    end
end
m = min(mix')';
l = min(low')';
h = min(high')';
lose  = find(m<2 | l<2 | h<2);

includesession = 1:length(all_S);
includesession(lose) = [];

cells = find(ismember(cell2mat(all_index(:,4)),includesession));
[all_SU1,all_S1,all_index1] = reduce_index(all_index,all_S, all_SU, cells);

%% calculate max trials
N = length(cells);
S = 3; %rewards
D = 2; %blocks
T = all_SU{1}.xvec.CON; %time
trialNum = [];
trialNumlow = [];

for n = 1:N
    for s = 3:5
        for d = 1:D
            SU = all_SU{n};
            S1 = all_S{all_index{n,4}};
            S1.RewardAmount = convertreward(S1.RewardAmount);
            
            %high rewards
            trials = find(S1.RewardAmount==s & S1.Block==d & S1.hits==1); %
            trialNum(n,s-2,d) = length(trials);

            %low rewards
            if d == 1
                trials2 = find(S1.RewardAmount==s-2 & S1.Block==d & S1.hits==1); %rewarded trials only
            else
                trials2 = find(S1.RewardAmount==s-2 & S1.Block==d+1 & S1.hits==1); %rewarded trials only
            end
            trialNumlow(n,s-2,d) = length(trials2);

        end
    end
end


%% ensure all hmats have the same number of times
for i = 1:length(all_SU)
SU = all_SU{i};
time(i) = length(SU.xvec.CON);
end
if length(unique(time))>1
for i = 1:length(cells)
    bins = 0.05;
    win = [-4 4];
    all_SU(i) = makeHeatmat(all_SU(i),all_S{all_index{i,4}},all_S{all_index{i,4}}.behEvents,win,bins);
end
end

%% set data up for dPCA
N = length(cells);
S = 3; %rewards
D = 2; %blocks
T = all_SU{1}.xvec.CON; %time
maxTrialNum = max(trialNum,[],'all');
maxTrialNumlow = max(trialNumlow,[],'all');

alignto = {'COFF', 'SON','SOFF','Rew','Opt','CON'};
for k = 1:length(alignto)
%firingRates: N x S x D x T x maxTrialNum
FR.(alignto{k}) = nan(N,S,D,length(T),maxTrialNum);
FRLow.(alignto{k}) = nan(N,S,D,length(T),maxTrialNumlow);
end

for n = 1:N
    for s = 3:5
        for d = 1:D
            SU = all_SU{n};
            S1 = all_S{all_index{n,4}};
            S1.RewardAmount = convertreward(S1.RewardAmount);

            %high reward and high/mix blocks
            trials = find(S1.RewardAmount==s & S1.Block==d & S1.hits==1); %rewarded trials only
            for k = 1:length(alignto)
            a = SU.hmat.(alignto{k})(trials,:);
            a(isnan(a)) = 0;
            FR.(alignto{k})(n,s-2,d,:,1:length(trials)) = a';
            end

            %low reawrds and low/mix blocks
            if d == 1
            trials2 = find(S1.RewardAmount==s-2 & S1.Block==d & S1.hits==1); %rewarded trials only
            else
            trials2 = find(S1.RewardAmount==s-2 & S1.Block==d+1 & S1.hits==1); %rewarded trials only
            end
            for k = 1:length(alignto)
            b = SU.hmat.(alignto{k})(trials2,:);
            b(isnan(b)) = 0;
            FRLow.(alignto{k})(n,s-2,d,:,1:length(trials2))=b';
            end 
         end
    end
end

%compute PSTH
for k = 1:length(alignto)
    FRavg.(alignto{k}) = mean(FR.(alignto{k}),5,'omitnan');
    FRLowavg.(alignto{k}) = mean(FRLow.(alignto{k}),5,'omitnan');
end
figure('color','white')
for k = 1:length(alignto)
    subplot(1,length(alignto),k)
plot(T,squeeze(FRavg.(alignto{k})(randi([1 N],10,1),1,1,:))')
title(alignto{k})
end

time = all_SU{1}.xvec.CON;

%% dPCA
firingRates_new = FR.Rew;
trialsvec = trialNum;
[W,V] = dPCA_MD(firingRates_new,time,trialsvec,'OFC-opto_Rew_high_weights','OFC-opto_Rew_high_weights_regular');

%% check out the weights 
DLS_weights = W(DLS,:);
VS_weights = W(VS,:);
[a,i] = max(abs(DLS_weights),[],2);
[av,iv] = max(abs(VS_weights),[],2);
figure('color','white')
subplot(121)
histogram(i)
title('DS');xlabel('Components'),ylabel('number of neurons');box off; set(gca,'TickDir','out');yticks(1:100)
subplot(122)
histogram(iv,'FaceColor','r')
title('VS');xlabel('Components'),ylabel('number of neurons');box off; set(gca,'TickDir','out');yticks(1:100)
