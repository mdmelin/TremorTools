clc;clear all;close all;
%% preprocess WACOM data for multiple subjects
subject = {'FUS003','FUS0016','FUS0024','FUS0041'}; %cell of subjects, can contain multiple subjects
%subject = {'FUS0024','FUS0041'}; %cell of subjects, can contain multiple subjects

datadir = 'C:\Users\mmelin\Desktop\tremor\data\'; %path to data server, this should not need changing.
savedir = 'C:\Users\mmelin\Desktop\tremor\WACOMpreprocessed\'; %where to put the preprocessed data

for x = 1:length(subject)

    WACOM_reformat_preprocess(datadir,savedir,subject{x},'pre');
    WACOM_reformat_preprocess(datadir,savedir,subject{x},'post');

end
