addpath(fileparts(cd));
clc;clear all;close all;

%% do APDM tasks
FIGTITLE = 'Postural tremor tasks - lower body';
FIGTITLE2 = 'Postural tremor tasks with detected tremor only - lower body';

tasks = {'contralegpost'}; % need to change these to proper task
sensors = {'ContraFoot'};

apdm_pre_tasks = []; apdm_post_tasks = []; apdm_pre_tremor_presence = [];

for i = 1:length(tasks) % do APDM tasks
    [pre, post, apdm_subjects] = allAPDMScores(tasks{i}, sensors{i});
    %figure; hold on; plot(pre); plot(post);
    apdm_pre_tasks = [apdm_pre_tasks; pre];
    apdm_post_tasks = [apdm_post_tasks; post];
end

%% combine into aggregate score

weighting = 1 ./ nanmean(apdm_pre_tasks,2);

mean_pre = nanmean(apdm_pre_tasks .* weighting, 1);
mean_post = nanmean(apdm_post_tasks .* weighting, 1);

detectable_tremor = sum(apdm_pre_tremor_presence,1) >= 1;
fprintf('%i out of %i participants have detectable tremor in at least one task\n', sum(detectable_tremor), length(detectable_tremor));


%% remove subjects with no pre tremor, replot and save
close all
mean_pre = mean_pre(~isnan(mean_pre));
mean_post = mean_post(~isnan(mean_post));
apdm_subjects = apdm_subjects(~isnan(mean_post));


[fig1, fig2] = plot_tremor_scores(mean_pre, mean_post, FIGTITLE2, 'Weighted sum score');

savetitle = strrep(FIGTITLE2, ' ', '_');

savepath = ['X:\tremor_figs\group_effects\linear_' savetitle '.png'];
savepath2 = ['X:\tremor_figs\group_effects\log_' savetitle '.png'];
%saveas(fig1, savepath);
saveas(fig2, savepath2);

%% stats
[h,p] = ttest(mean_pre,mean_post);
fprintf('Paired ttest p-value is: %s\n', p)
