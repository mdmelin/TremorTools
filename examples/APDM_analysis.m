addpath(fileparts(cd));
clc;clear all;close all;

%% an example getting data for the wingbeat task, pre and post op
taskname = 'wingbeat';
datadir = 'Z:\Data\FUS_Gait\APDMpreprocessed';

[subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'pre'); % get the list of subjects we have preop data for, and the path to their data
lesioned_side_pre = get_lesioned_side();

for i = 1:length(subjects)
    score = APDM_PCA_tremor_score(datadir,subjects{i},'pre',taskname,'RightHand',1,[0 0])
end


subject_list_post = APDM_parse_subjects(datadir,taskname,'post');
lesioned_side_post = get_lesioned_side();

%% plotting
close all;
figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([pre,post],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,pre);
scatter(twovec,post);
parallelcoords([pre,post]);
title('APDM Sensors - Wing-Beating Tremor');
ylabel('Tremor Index (AU)');


figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([logpre,logpost],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,logpre);
scatter(twovec,logpost);
parallelcoords([logpre,logpost]);
title('APDM Sensors - Wing-Beating Tremor');
ylabel('Log Tremor Index (AU)');


figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([pre2,post2],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onev,pre2);
scatter(twov,post2);
parallelcoords([pre2,post2]);
title('Wacom Tablet - Small and Large Spirals');
ylabel('Tremor Index (AU)');


figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([logpre2,logpost2],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onev,logpre2);
scatter(twov,logpost2);
parallelcoords([logpre2,logpost2]);
title('Wacom Tablet - Small and Large Spirals');
ylabel('Log Tremor Index (AU)');
