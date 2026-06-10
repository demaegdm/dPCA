function Individual_session_dPcA(Comp)

%% Load ETable
load('\\constantinoplelab.cns.nyu.edu\server2\PhysiologyData\EphysTable.mat');

%% Find sessions
% Opto fiber in DS, control first session, opto second session
Opto2 = find(strcmp(ETable.fiber_site,'DLS') & ETable.session_num==2 & ETable.stimulation ==1 & string(ETable.recording_site)=='OFC' & contains(string(ETable.matfile),'mat'));
Control1 = find(contains(string(ETable.sessiondate),string(ETable.sessiondate(Opto2))) & ETable.session_num==1 & ETable.stimulation==0 & string(ETable.recording_site)=='OFC' & contains(string(ETable.matfile),'mat'));

%% Decide which comparison to do
% Comp = 'h'; %l = low/mix
%             %h = high/mix

    if Comp=='l'
        c = 'mix-low';
    else
        c = 'mix-high';
    end

%% Initialize

%% Compare control and opto session so they have
% 1. either high/mix or low/mix
% 2. at least 2 trials of each volume for
for i = 1:length(Opto2)
    %load the same date sessions
    if ETable.sessiondate(Opto2(i))==ETable.sessiondate(Control1(i)) && strcmp(ETable.ratname{Opto2(i)},ETable.ratname{Control1(i)})
        OptoS = load(fullfile(ETable.savepath{Opto2(i)},ETable.matfile{Opto2(i)}));
        ControlS = load(fullfile(ETable.savepath{Control1(i)},ETable.matfile{Control1(i)}));

        if ~isempty(OptoS.SU) && ~isempty(ControlS.SU)
            Sco = ControlS.S; %S struct for control session
            Soo = OptoS.S;    %S struct for opto session

            %identify if there are two trials per reward for each reward
            %volume

            if Comp=='l'
                Sco_RewardAmount = convertreward(Sco.RewardAmount);
                Soo_RewardAmount = convertreward(Soo.RewardAmount);
                for r = 1:3
                    Sco_mix(r) = length(find(Sco.Block==1 & Sco_RewardAmount==r & Sco.hits==1));
                    Sco_test(r) = length(find(Sco.Block==3 & Sco_RewardAmount==r & Sco.hits==1));
                    Soo_mix(r) = length(find(Soo.Block==1 & Soo_RewardAmount==r & Soo.hits==1));
                    Soo_test(r) = length(find(Soo.Block==3 & Soo_RewardAmount==r & Soo.hits==1));

                    % % remove opto trials from opto sessions
                    % Sco_mix(r) = length(find(Sco.Block==1 & Sco_RewardAmount==r & Sco.hits==1));
                    % Sco_test(r) = length(find(Sco.Block==3 & Sco_RewardAmount==r & Sco.hits==1));
                    % Soo_mix(r) = length(find(Soo.Block==1 & Soo_RewardAmount==r & Soo.hits==1 & Soo.IsOpto==1));
                    % Soo_test(r) = length(find(Soo.Block==3 & Soo_RewardAmount==r & Soo.hits==1 & Soo.IsOpto==1));
                end
            else
                Sco_RewardAmount = convertreward(Sco.RewardAmount);
                Soo_RewardAmount = convertreward(Soo.RewardAmount);
                for r = 3:5
                    Sco_mix(r-2) = length(find(Sco.Block==1 & Sco_RewardAmount==r & Sco.hits==1));
                    Sco_test(r-2) = length(find(Sco.Block==2 & Sco_RewardAmount==r & Sco.hits==1));
                    Soo_mix(r-2) = length(find(Soo.Block==1 & Soo_RewardAmount==r & Soo.hits==1));
                    Soo_test(r-2) = length(find(Soo.Block==2 & Soo_RewardAmount==r & Soo.hits==1));
                    % 
                    % Sco_mix(r-2) = length(find(Sco.Block==1 & Sco_RewardAmount==r & Sco.hits==1));
                    % Sco_test(r-2) = length(find(Sco.Block==2 & Sco_RewardAmount==r & Sco.hits==1));
                    % Soo_mix(r-2) = length(find(Soo.Block==1 & Soo_RewardAmount==r & Soo.hits==1 & Soo.IsOpto==1));
                    % Soo_test(r-2) = length(find(Soo.Block==2 & Soo_RewardAmount==r & Soo.hits==1 & Soo.IsOpto==1));
                end
            end

            % if both mix/test blocks have 2 of each volume in control/opto sessions
            if sum(Sco_mix>1)==3 && sum(Soo_mix>1)==3 && sum(Sco_test>1)==3 && sum(Soo_test>1)==3

                all_Sco= [all_Sco,Sco];
                all_SUco = [all_SUco,ControlS.SU];
                all_Soo= [all_Soo,Soo];
                all_SUoo = [all_SUoo,OptoS.SU];

                for cluster = 1:length(ControlS.SU)

                    %control only
                    all_indexco{counter,1} = Sco.RatName;
                    all_indexco{counter,2} = string(datetime(Sco.SessionDate,'Format','yyyy-MM-dd'));
                    all_indexco{counter,3} = ControlS.SU{cluster}.cluster_id;
                    all_indexco{counter,4} = Snum;
                    all_indexco{counter,5} = counter;

                    %opto only
                    all_indexoo{counter,1} = Soo.RatName;
                    all_indexoo{counter,2} = string(datetime(Soo.SessionDate,'Format','yyyy-MM-dd'));
                    all_indexoo{counter,3} = OptoS.SU{cluster}.cluster_id;
                    all_indexoo{counter,4} = Snum;
                    all_indexoo{counter,5} = counter;

                    counter = counter+1;
                end
                Snum=Snum+1;
            end
        end
    end
end

%% Reduce structs to only OFC cells
[cells,~] = OnTarget(all_SUco,all_Sco,all_indexco,'OFC');
[all_SUco,all_Sco,all_indexco] = reduce_index(all_indexco,all_Sco, all_SUco, cells);
[all_SUoo,all_Soo,all_indexoo] = reduce_index(all_indexoo,all_Soo, all_SUoo, cells);


%% Individual sessions
all_Sco_original = all_Sco;
all_Soo_original = all_Soo;

all_SUco_original = all_SUco;
all_SUoo_original = all_SUoo;

all_indexco_original = all_indexco;
all_indexoo_original = all_indexoo;


% select one session at a time
for i = 1:length(all_Sco_original)
    cells =[all_indexco_original{[all_indexco_original{:,4}]==i,5}]';

    [all_SUco,all_Sco,all_indexco] = reduce_index(all_indexco_original,all_Sco_original, all_SUco_original, cells);
    [all_SUoo,all_Soo,all_indexoo] = reduce_index(all_indexoo_original,all_Soo_original, all_SUoo_original, cells);

    for j = 1:length([all_indexco{:,5}])
    bins = 0.05;
    win = [-1 3];
    all_SUco(j) = makeHeatmat(all_SUco(j),all_Sco{all_indexco{j,4}},all_Sco{all_indexco{j,4}}.behEvents,win,bins);
    all_SUoo(j) = makeHeatmat(all_SUoo(j),all_Soo{all_indexoo{j,4}},all_Soo{all_indexoo{j,4}}.behEvents,win,bins);
    end

    [trialNumco]=calcMaxTrials(all_SUco,all_Sco,all_indexco,[all_indexco{:,5}],Comp);
    [trialNumoo]=calcMaxTrials(all_SUoo,all_Soo,all_indexoo,[all_indexco{:,5}],Comp);

    [FR,time] = dpca_setup(all_SUco,all_Sco,all_indexco,[all_indexco{:,5}],trialNumco,Comp);
    [FRo,timeo] = dpca_setup(all_SUoo,all_Soo,all_indexoo,[all_indexco{:,5}],trialNumoo,Comp);

    event = 'Rew';
    firingRates_new = FR.(event);
    firingRates_opto = FRo.(event);
    trialsvec = trialNumco;
    trialsveco = trialNumoo;

    %naming
        weight1 = ['OFC-opto_',event,'_',c,'weights'];
        weight2 = ['OFC-opto_',event,'_',c,'weights_regular'];


    [W,V, PC] = dPCA_MD(firingRates_new,time,trialsvec,...
        weight1,weight2,...
        firingRates_opto,trialsveco);

    figurename = [all_Sco{1}.RatName,'_',all_Sco{1}.SessionDate];
    if Comp=='l'
        F = 'Low-mix';
    else
        F = 'High-mix';
    end


    save(fullfile('Y:\Maggie\Chronic_implant\Npxl\Optotagged_cells\figures\dPCA\',F,'\Data',[figurename,'.mat']),...
        'FR','FRo','time','timeo','trialNumco','trialNumoo',...
         'all_indexco','all_indexoo','all_Sco','all_Soo','all_SUco','all_SUoo','cells','Comp',...
         'W','V', 'PC',...
         '-v7.3');

    sgtitle(['OptoSession_',all_Sco{1}.SessionDate])
    savefig(fullfile('Y:\Maggie\Chronic_implant\Npxl\Optotagged_cells\figures\dPCA',F,[figurename,'_opto']))
    close
    sgtitle(['ControlSession_',all_Sco{1}.SessionDate])
    savefig(fullfile('Y:\Maggie\Chronic_implant\Npxl\Optotagged_cells\figures\dPCA',F,[figurename,'_control']))
    close
end
