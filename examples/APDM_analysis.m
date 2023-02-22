addpath(fileparts(cd));
clc;clear all;close all;

%% an example getting data for the wingbeat task, pre and post op
taskname = 'wingbeat';
datadir = 'Z:\Data\FUS_Gait\APDMpreprocessed';

[pre_subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'pre'); % get the list of subjects we have preop data for, and the path to their data
[post_subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'post');
subjects = intersect(pre_subjects,post_subjects);
%lesioned_side_pre = get_lesioned_side();
pre_scores = [];
post_scores = [];
for i = 1:length(subjects)
    pre_scores(i) = APDM_PCA_tremor_score(datadir,subjects{i},'pre',taskname,'RightHand',1,[0 0]);
    post_scores(i) = APDM_PCA_tremor_score(datadir,subjects{i},'post',taskname,'RightHand',1,[0 0]);
end


%% plotting
onevec = ones(1,length(pre_scores));
twovec = onevec + 1;
close all;
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

