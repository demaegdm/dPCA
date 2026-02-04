function [all_SU,all_S,all_index,cells] = reduce_struct(all_SU,all_S,all_index,local, varargin)


[cells,~] = OnTarget(all_SU,all_S,all_index,local);
[all_SU,all_S,all_index] = reduce_index(all_index,all_S, all_SU, cells);


if varargin{1}=='h'%reduce to include at least 2 trials in each mix/high
    j=1;
    for i = 1:length(all_S)
        S1 = all_S{i};
        S1.RewardAmount = convertreward(S1.RewardAmount);
        for r = 1:5
            mix(i,r) = length(find(S1.Block==1 & S1.RewardAmount==r & S1.hits==1));
        end
        for r = 3:5
            high(i,r-2) = length(find(S1.Block==2 & S1.RewardAmount==r & S1.hits==1));
        end
    end
    m = min(mix')';
    h = min(high')';
    lose  = find(m<1 | h<1);

elseif varargin{1} == 'l'
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
    end
    m = min(mix')';
    l = min(low')';
    lose  = find(m<1 | l<1 );

else % reduce to include at least 2 trials in each block of each volume by default
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
    lose  = find(m<1 | l<1 | h<1);
end


includesession = 1:length(all_S);
includesession(lose) = [];

cells = find(ismember(cell2mat(all_index(:,4)),includesession));
[all_SU,all_S,all_index] = reduce_index(all_index,all_S, all_SU, cells);
