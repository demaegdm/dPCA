function PrepforFigure

%% High-mix block
Comp = 'h';
c = 'High-mix';

% Generate Individual Session dPCA
Individual_session_dPcA(Comp)

[D_PSTH_block_avg,D_PSTH_block_opto_avg,D_PSTH_Rew_avg, ...
    D_PSTH_Rew_opto_avg, sig_block, sig_rew,pv_block,pv_reward] = AverageSessiondPCA(Comp);

save(fullfile('\\constantinoplelab.cns.nyu.edu\server2\PhysiologyData\Maggie\Chronic_implant\Npxl\Optotagged_cells\figures\dPCA\',c,'\Data','AverageSessionddPCA.mat'),...
    'D_PSTH_block_avg','D_PSTH_block_opto_avg','D_PSTH_Rew_avg', ...
    'D_PSTH_Rew_opto_avg', 'sig_block', 'sig_rew');

%extended data table
time  = -1:0.05:3;
T = table(time', pv_block','VariableNames',{'Time','p value'});
writetable(T,'Z:\Maggie\Papers\Physiology\Extended_data_tables\dpca_high-mix_block_pvalues.xlsx')
T = table(time', pv_reward','VariableNames',{'Time','p value'});
writetable(T,'Z:\Maggie\Papers\Physiology\Extended_data_tables\dpca_high-mix_reward_pvalues.xlsx')



%% Low-mix block
Comp = 'l';
c = 'Low-mix';

% Generate Individual Session dPCA
Individual_session_dPcA(Comp)

[D_PSTH_block_avg,D_PSTH_block_opto_avg,D_PSTH_Rew_avg, ...
    D_PSTH_Rew_opto_avg, sig_block, sig_rew, pv_block, pv_reward] = AverageSessiondPCA(Comp);

save(fullfile('\\constantinoplelab.cns.nyu.edu\server2\PhysiologyData\Maggie\Chronic_implant\Npxl\Optotagged_cells\figures\dPCA\',c,'\Data','AverageSessionddPCA.mat'),...
    'D_PSTH_block_avg','D_PSTH_block_opto_avg','D_PSTH_Rew_avg', ...
    'D_PSTH_Rew_opto_avg', 'sig_block', 'sig_rew','pv_reward','pv_block');

%extended data table
time  = -1:0.05:3;
T = table(time', pv_block','VariableNames',{'Time','p value'});
writetable(T,'Z:\Maggie\Papers\Physiology\Extended_data_tables\dpca_low-mix_block_pvalues.xlsx')
T = table(time', pv_reward','VariableNames',{'Time','p value'});
writetable(T,'Z:\Maggie\Papers\Physiology\Extended_data_tables\dpca_low-mix_reward_pvalues.xlsx')
