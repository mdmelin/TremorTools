addpath(fileparts(cd));
clc;clear all;close all;

%% an example getting data for the wingbeat task, pre and post op
taskname = 'wingbeat';
datadir = 'Y:\APDMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

[pre_subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'pre'); % get the list of subjects we have preop data for, and the path to their data
[post_subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'post');
subjects = intersect(pre_subjects,post_subjects);
lesioned_sides = get_lesioned_sides(metadata_filepath, subjects);
assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

sensors = {};
for i = 1:length(lesioned_sides)
    if lesioned_sides{i} == 'R'
        sensors{i} = 'LeftHand'; %pick hand sensor on opposite side of lesion
    else
        sensors{i} = 'RightHand';
    end
end
%%
pre_scores = [];
post_scores = [];
for i = 1:length(subjects)
    %pre_scores(i) = APDM_PCA_tremor_score(datadir,subjects{i},'pre',taskname,sensors{i},1,[0 0]);
    %post_scores(i) = APDM_PCA_tremor_score(datadir,subjects{i},'post',taskname,sensors{i},1,[0 0]);
    i
    [pre_scores(i),~,~] = APDM_Welch_score(datadir,subjects{i},'pre',taskname,sensors{i},[0 0],2);
    [post_scores(i),~,~] = APDM_Welch_score(datadir,subjects{i},'post',taskname,sensors{i},[0 0],2);
end

%% plotting
onevec = ones(1,length(pre_scores));
twovec = onevec + 1;
figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([pre_scores;post_scores]',labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,pre_scores);
scatter(twovec,post_scores);
parallelcoords([pre_scores;post_scores]');
title('APDM Sensors - Wing-Beating Tremor');
ylabel('Tremor Index (AU)');

logpre = log(pre_scores);
logpost = log(post_scores);
figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([logpre;logpost]',labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,logpre);
scatter(twovec,logpost);
parallelcoords([logpre;logpost]');
title('APDM Sensors - Wing-Beating Tremor');
ylabel('Log Tremor Index (AU)');

