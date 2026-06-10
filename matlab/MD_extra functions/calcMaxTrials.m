function [trialNum]=calcMaxTrials(all_SU,all_S,all_index,cells,Comp)

N = length(cells);
S = 3; %rewards
if Comp=='l'
    sv = 1:3;
else
    sv = 3:5;
end

%d= blocks
T = all_SU{1}.xvec.CON; %time
trialNum = [];


for n = 1:N
    for s = sv
            SU = all_SU{n};
            S1 = all_S{all_index{n,4}};
            S1.RewardAmount = convertreward(S1.RewardAmount);

            %mix rewards
            trials = find(S1.RewardAmount==s & S1.Block==1 & S1.hits==1); %

            %adapt rewards
            if Comp == 'l'
               trialNum(n,s,1) = length(trials);

                trials2 = find(S1.RewardAmount==s & S1.Block==3 & S1.hits==1); %low block rewarded trials only
                trialNum(n,s,2) = length(trials2);

            else
                trialNum(n,s-2,1) = length(trials);

                trials2 = find(S1.RewardAmount==s & S1.Block==2 & S1.hits==1); %high block rewarded trials only
                trialNum(n,s-2,2) = length(trials2);

            end
            
    end
end
