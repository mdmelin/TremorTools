addpath(fileparts(cd));
clc;clear all;close all;

%% do APDM tasks
FIGTITLE = 'Postural tremor tasks - upper body';
FIGTITLE2 = 'Postural tremor tasks with detected tremor only - upper body';


tasks = {'armsextended','wingbeat'};
sensors = {'ContraHand','ContraHand'};

apdm_pre_tasks = []; apdm_post_tasks = []; apdm_pre_tremor_presence = [];

for i = 1:length(tasks) % do APDM tasks
    [pre, post, apdm_subjects, has_tremor] = allAPDMScores(tasks{i}, sensors{i});
    %figure; hold on; plot(pre); plot(post);
    apdm_pre_tasks = [apdm_pre_tasks; pre];
    apdm_post_tasks = [apdm_post_tasks; post];
    apdm_pre_tremor_presence = [apdm_pre_tremor_presence; has_tremor];
end

%% now do WACOM tasks

task = 'reach_contra';

[wacom_pre, wacom_post, wacom_subjects, wacom_pre_tremor_presence] = allWACOMScores(task);
%figure; hold on; plot(pre); plot(post);


%% combine into aggregate score

[subjects,ia,ib] = intersect(apdm_subjects,wacom_subjects);

all_pre_tasks = [apdm_pre_tasks(:,ia) ; wacom_pre(ib)];
all_post_tasks = [apdm_post_tasks(:,ia) ; wacom_post(ib)];
has_tremor = [apdm_pre_tremor_presence(:,ia) ; wacom_pre_tremor_presence(ib)];

weighting = 1 ./ mean(all_pre_tasks,2);

mean_pre = sum(all_pre_tasks .* weighting, 1);
mean_post = sum(all_post_tasks .* weighting, 1);

detectable_tremor = sum(has_tremor,1) >= 1;
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
subjects = subjects(detectable_tremor);

[fig1, fig2] = plot_tremor_scores(mean_pre, mean_post, FIGTITLE2, 'Weighted sum score');

savetitle = strrep(FIGTITLE2, ' ', '_');

savepath = ['X:\tremor_figs\group_effects\linear_' savetitle '.png'];
savepath2 = ['X:\tremor_figs\group_effects\log_' savetitle '.png'];
saveas(fig1, savepath);
saveas(fig2, savepath2);


