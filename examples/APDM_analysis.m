addpath(fileparts(cd));
clc;clear all;close all;

%% an example getting data for the wingbeat task, pre and post op
taskname = 'wingbeat';
datadir = 'C:\Users\mmelin\Desktop\tremor\APDMpreprocessed';

[subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'pre'); % get the list of subjects we have preop data for, and the path to their data
lesioned_side_pre = get_lesioned_side();

for i = 1:length(subjects)
    score = APDM_PCA_tremor_score(datadir,subjects{i},'pre',taskname,'RightHand',1,[0 0])
end


subject_list_post = APDM_parse_subjects(datadir,taskname,'post');
lesioned_side_post = get_lesioned_side();