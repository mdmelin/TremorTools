addpath(fileparts(cd));
clc;clear all;close all;

%% do APDM tasks
FIGTITLE = 'Action tremor tasks - lower body';
FIGTITLE2 = 'Action tremor tasks with detected tremor only - lower body';

tasks = {'contralegact'}; % need to change these to proper task
sensors = {'ContraFoot'};

apdm_pre_tasks = []; apdm_post_tasks = []; apdm_pre_tremor_presence = [];

for i = 1:length(tasks) % do APDM tasks
    [pre, post, apdm_subjects, has_tremor] = allAPDMScores(tasks{i}, sensors{i});
    %figure; hold on; plot(pre); plot(post);
    apdm_pre_tasks = [apdm_pre_tasks; pre];
    apdm_post_tasks = [apdm_post_tasks; post];
    apdm_pre_tremor_presence = [apdm_pre_tremor_presence; has_tremor];
end

%% combine into aggregate score

weighting = 1 ./ mean(apdm_pre_tasks,2);

mean_pre = sum(apdm_pre_tasks .* weighting, 1);
mean_post = sum(apdm_post_tasks .* weighting, 1);

detectable_tremor = sum(apdm_pre_tremor_presence,1) >= 1;
fprintf('%i out of %i participants have detectable tremor in at least one task\n', sum(detectable_tremor), length(detectable_tremor));


%% plot and save
[fig1, fig2] = plot_tremor_scores(mean_pre, mean_post, FIGTITLE, 'Weighted sum score');

savetitle = strrep(FIGTITLE, ' ', '_');

savepath = ['X:\tremor_figs\group_effects\linear_' savetitle '.png'];
savepath2 = ['X:\tremor_figs\group_effects\log_' savetitle '.png'];
saveas(fig1, savepath);
saveas(fig2, savepath2);

%% remove subjects with no pre tremor, replot and save
close all

mean_pre = mean_pre(detectable_tremor);
mean_post = mean_post(detectable_tremor);
apdm_subjects = apdm_subjects(detectable_tremor);

[fig1, fig2] = plot_tremor_scores(mean_pre, mean_post, FIGTITLE2, 'Weighted sum score');

savetitle = strrep(FIGTITLE2, ' ', '_');

savepath = ['X:\tremor_figs\group_effects\linear_' savetitle '.png'];
savepath2 = ['X:\tremor_figs\group_effects\log_' savetitle '.png'];
saveas(fig1, savepath);
saveas(fig2, savepath2);
