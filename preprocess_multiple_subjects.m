clc;clear all;close all;
%% run for multiple subjects
subject = {'FUS002' 'FUS003' 'FUS004' 'FUS005' 'FUS006' 'FUS008' ...
    'FUS009' 'FUS0011' 'FUS0012' 'FUS0013' 'FUS0014' 'FUS0015' 'FUS0016' 'FUS0017' ...
    'FUS0018' 'FUS0019' 'FUS0020' 'FUS0021' 'UT_FUS01' 'UT_FUS02' 'UT_FUS03' 'UT_FUS04' ...
    'UT_FUS05' 'UT_FUS06' 'UT_FUS07' 'UT_FUS08'}; %cell of subjects, can contain multiple subjects

badsubjects = {'FUS001','FUS007','FUS0010'};

datadir = 'Z:\Data\FUS_Gait\'; %path to data server, this should not need changing.
savedir = 'Z:\Data\FUS_Gait\APDMpreprocessed'; %where to put the preprocessed data
        
for x = 1:length(subject)
    try
        APDM_reformat_preprocess(datadir,savedir,subject{x},'pre');
    catch
        fprintf(2,'\nPreprocessing failed for subject %s PRE\n',subject{x});
    end
    
    try
        APDM_reformat_preprocess(datadir,savedir,subject{x},'post');
    catch
        fprintf(2,'\nPreprocessing failed for subject %s POST\n',subject{x});
    end
end