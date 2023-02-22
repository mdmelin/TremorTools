addpath(fileparts(cd));
clc;clear all;close all;

%% an example getting data for the wingbeat task, pre and post op
datadir = 'C:\Users\mmelin\Desktop\tremor\WACOMpreprocessed'; %where the preprocessed data is
taskname = 'lineBig_L';

[subject_list_pre, data_paths_pre] = WACOM_parse_subjects(datadir,taskname,'pre'); % get the list of subjects we have preop data for
%lesioned_side_pre = get_lesioned_side();
mean_scores = [];
for i=1:length(subject_list_pre)
    [scores, data] = WACOM_euclid_norm_tremor_score(data_paths_pre{i}, taskname);
    meanscores(i) = mean(scores);
end


subject_list_post = WACOM_parse_subjects(datadir,taskname,'post');
lesioned_side_post = get_lesioned_side();