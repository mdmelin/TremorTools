datadir = 'Z:\Data\FUS_Gait\APDMpreprocessed';
taskname = 'wingbeat';

subjectspre = APDM_parse_subjects(datadir,taskname,'pre');
subjectspost = APDM_parse_subjects(datadir,taskname,'post');

subjects = intersect(subjectspre,subjectspost); %only get subjects that have pre and post data for the desired task

for i = 1:length(subjects)
    [tremor_index_pre(i),~] = APDM_PCA_tremor_score(datadir,subjects{i},'pre',taskname,'RightHand',1,[0 0]);
    [tremor_index_post(i),~] = APDM_PCA_tremor_score(datadir,subjects{i},'post',taskname,'RightHand',1,[0 0]);
end
