%% Load ETable
load('\\constantinoplelab.cns.nyu.edu\server2\PhysiologyData\EphysTable.mat');

%% Find sessions
% Opto fiber in DS, control first session, opto second session
Opto2 = find(strcmp(ETable.fiber_site,'DLS') & ETable.session_num==2 & ETable.stimulation ==1 & string(ETable.recording_site)=='OFC');
Control1 = find(contains(string(ETable.sessiondate),string(ETable.sessiondate(Opto2))) & ETable.session_num==1 & ETable.stimulation==0 & string(ETable.recording_site)=='OFC');

%% Initialize variables
alignto = {'CON','COFF','SON','SOFF','Rew','Opt'};
all_S = {};
all_SU = {};
all_index = [];

all_Sco = {};
all_SUco = {};
all_indexco = [];

all_Soo = {};
all_SUoo = {};
all_indexoo = [];

counter = 1;
Snum = 1;

%% Split sessions by high/mix or low/mix 
for i = 1:length(Opto2)
    Sc = [];
    SUc = [];

    Sco = [];
    SUco = [];

    Soo = [];
    SUoo = [];

    if ETable.sessiondate(Opto2(i))==ETable.sessiondate(Control1(i)) && strcmp(ETable.ratname{Opto2(i)},ETable.ratname{Control1(i)})
        if contains(string(ETable.matfile{Opto2(i)}),'.mat') &&  contains(string(ETable.matfile{Control1(i)}),'.mat')
            OptoS = load(fullfile(ETable.savepath{Opto2(i)},ETable.matfile{Opto2(i)}));
            ControlS = load(fullfile(ETable.savepath{Control1(i)},ETable.matfile{Control1(i)}));
            if isempty(OptoS.SU) && isempty(ControlS.SU)
            else
                Sc = ControlS.S;
                Sco = ControlS.S;
                Soo = OptoS.S;

                % identify which blocks exist
                ScBlock = [sum(Sc.Block==1);sum(Sc.Block==2);sum(Sc.Block==3)];
                SooBlock = [sum(Soo.Block==1);sum(Soo.Block==2);sum(Soo.Block==3)];

                FieldNames_S = {'NoseInCenter', 'TrainingStage', 'Block', 'BlockLengthAd',...
                    'BlockLengthTest', 'ProbCatch', 'RewardDelay', 'RewardAmount', 'IsOpto',...
                    'OptoEvent', 'hits', 'ReactionTime', 'vios',  'optout', 'WaitForPoke',...
                    'wait_time', 'iti', 'Cled', 'Lled', 'l_opt', 'Rled', 'r_opt','SessId'};
                for j = 1:length(FieldNames_S)
                    Sc.(FieldNames_S{j}) = [];
                    try
                        Sc.(FieldNames_S{j}) = [ControlS.S.(FieldNames_S{j});OptoS.S.(FieldNames_S{j})];
                    catch
                        Sc.(FieldNames_S{j}) = [ControlS.S.(FieldNames_S{j}),OptoS.S.(FieldNames_S{j})];
                    end
                end
                Sc.RewardedSide = [ControlS.S.RewardedSide,OptoS.S.RewardedSide];
                Sc.behEvents = [];
                for j = 1:length(OptoS.SU)
                    SUc{j} = ControlS.SU{j};
                    SUco{j} = ControlS.SU{j};
                    SUoo{j} = OptoS.SU{j};

                    for k = 1:length(alignto)
                        SUc{j}.hmat.(alignto{k}) = [];
                        SUc{j}.hmat.(alignto{k}) = [ControlS.SU{j}.hmat.(alignto{k});OptoS.SU{j}.hmat.(alignto{k})];
                    end
                end
                %make a struct
                all_S= [all_S,Sc];
                all_SU = [all_SU,SUc];
                all_Sco= [all_Sco,Sco];
                all_SUco = [all_SUco,SUco];
                all_Soo= [all_Soo,Soo];
                all_SUoo = [all_SUoo,SUoo];
                for cluster = 1:length(SUc)
                    %combined control and opto
                    all_index{counter,1} = Sc.RatName;
                    all_index{counter,2} = string(datetime(Sc.SessionDate,'Format','yyyy-MM-dd'));
                    all_index{counter,3} = SUc{cluster}.cluster_id;
                    all_index{counter,4} = Snum;
                    all_index{counter,5} = counter;

                    %control only
                    all_indexco{counter,1} = Sco.RatName;
                    all_indexco{counter,2} = string(datetime(Sco.SessionDate,'Format','yyyy-MM-dd'));
                    all_indexco{counter,3} = SUco{cluster}.cluster_id;
                    all_indexco{counter,4} = Snum;
                    all_indexco{counter,5} = counter;

                    %opto only
                    all_indexoo{counter,1} = Soo.RatName;
                    all_indexoo{counter,2} = string(datetime(Soo.SessionDate,'Format','yyyy-MM-dd'));
                    all_indexoo{counter,3} = SUoo{cluster}.cluster_id;
                    all_indexoo{counter,4} = Snum;
                    all_indexoo{counter,5} = counter;

                    counter = counter+1;
                end
                Snum = Snum+1;
            end
        end
    else
        keyboard
    end
end


%% reduce struct to only OFC neurons
[all_SUco,all_Sco,all_indexco,cellsco] = reduce_struct(all_SUco,all_Sco,all_indexco,'OFC');
 %[all_SUco,all_Sco,all_indexco] = reduce_index(all_indexco,all_Sco,all_SUco,cellsoo);
[all_SUoo,all_Soo,all_indexoo,cellsoo] = reduce_struct(all_SUoo,all_Soo,all_indexoo,'OFC');


%% calculate max trials
[trialNumco,trialNumlowco]=calcMaxTrials(all_SUco,all_Sco,all_indexco,cellsoo);
[trialNumoo,trialNumlowoo]=calcMaxTrials(all_SUoo,all_Soo,all_indexoo,cellsoo);

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
[FR,FRLow,time] = dpca_setup(all_SUco,all_Sco,all_indexco,cellsoo,trialNumco,trialNumlowco);
[FRo,FRLowo,timeo] = dpca_setup(all_SUoo,all_Soo,all_indexoo,cellsoo,trialNumoo,trialNumlowoo);

%% dPCA
firingRates_new = FR.COFF;
firingRates_opto = FRo.COFF;
trialsvec = trialNumco;
trialsveco = trialNumoo;
[W,V] = dPCA_MD(firingRates_new,time,trialsvec,...
    'OFC-opto_Rew_high_weights','OFC-opto_Rew_high_weights_regular',...
    firingRates_opto,trialsveco);
