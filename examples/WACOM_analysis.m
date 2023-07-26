addpath(fileparts(cd));
clc;clear all;%close all;

%% an example getting data for the spirals tasks, pre and post op

datadir = 'X:\Wacompreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

[pre_subjects, data_paths_pre] = WACOM_parse_subjects(datadir,'pre'); % get the list of subjects we have preop data for, and the path to their data
[post_subjects, data_paths_post] = WACOM_parse_subjects(datadir,'post');
subjects = intersect(pre_subjects,post_subjects);
lesioned_sides = get_lesioned_sides(metadata_filepath, subjects);
assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

tasks = {};
for i = 1:length(lesioned_sides)
    if lesioned_sides{i} == 'R'
        tasks{i}{1} = 'spiralBig_L'; %pick hand sensor on opposite side of lesion
        %tasks{i}{2} = 'spiralSmall_L';
    else
        tasks{i}{1} = 'spiralBig_R';
        %tasks{i}{2} = 'spiralSmall_R';
    end
end
%% retrieve tremor scores for all spiral tasks (2 large and 2 small)

mean_pre_scores = [];
mean_post_scores = [];
for i=1:length(subjects)
    pre = [];
    post = [];
    for j = 1:length(tasks{i}) %average scores over tasks
        %[temp, ~] = WACOM_euclid_norm_tremor_score(datadir, subjects{i},'pre', tasks{i}{j});
        %[temp2, ~] = WACOM_euclid_norm_tremor_score(datadir, subjects{i},'post', tasks{i}{j});

        [pre_scores,~,~] = WACOM_Welch_score(datadir, subjects{i},'pre', tasks{i}{j}, 2);
        [post_scores,~,~] = WACOM_Welch_score(datadir, subjects{i},'post', tasks{i}{j}, 2);

        pre = [pre pre_scores];
        post = [post post_scores];
    end
    mean_pre_scores = [mean_pre_scores mean(pre)];
    mean_post_scores = [mean_post_scores mean(post)];
end

%% plotting

onevec = ones(1,length(mean_pre_scores));
twovec = onevec + 1;
close all;
figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([mean_pre_scores;mean_post_scores]',labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,mean_pre_scores);
scatter(twovec,mean_post_scores);
parallelcoords([mean_pre_scores;mean_post_scores]');
title('WACOM Tablet - Large and Small Spirals');
ylabel('Tremor Index (AU)');

logpre = log(mean_pre_scores);
logpost = log(mean_post_scores);
figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([logpre;logpost]',labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,logpre);
scatter(twovec,logpost);
parallelcoords([logpre;logpost]');
title('WACOM Tablet - Large and Small Spirals');
ylabel('Log Tremor Index (AU)');