addpath(fileparts(cd));
clc;clear all;close all;

%% do APDM tasks
FIGTITLE = 'Postural tremor tasks - upper body';
FIGTITLE2 = 'IPSILATERAL - Postural tremor tasks with detected tremor only - upper body';


tasks = {'armsextended','wingbeat'};
sensors = {'IpsiHand','IpsiHand'};

apdm_pre_tasks = []; apdm_post_tasks = []; apdm_pre_tremor_presence = [];

for i = 1:length(tasks) % do APDM tasks
    [pre, post, apdm_subjects] = allAPDMScores(tasks{i}, sensors{i});
    %figure; hold on; plot(pre); plot(post);
    apdm_pre_tasks = [apdm_pre_tasks; pre];
    apdm_post_tasks = [apdm_post_tasks; post];
end

%% now do WACOM tasks

task = 'reach_ipsi';

[wacom_pre, wacom_post, wacom_subjects] = allWACOMScores(task);
%figure; hold on; plot(pre); plot(post);


%% combine into aggregate score

[subjects,ia,ib] = intersect(apdm_subjects,wacom_subjects);

all_pre_tasks = [apdm_pre_tasks(:,ia) ; wacom_pre(ib)];
all_post_tasks = [apdm_post_tasks(:,ia) ; wacom_post(ib)];
%has_tremor = [apdm_pre_tremor_presence(:,ia) ; wacom_pre_tremor_presence(:,ib)];

weighting = 1 ./ nanmean(all_pre_tasks,2);

mean_pre = nanmean(all_pre_tasks .* weighting, 1);
mean_post = nanmean(all_post_tasks .* weighting, 1);

%% remove subjects with no pre tremor, replot and save

close all
mean_pre = mean_pre(~isnan(mean_pre));
mean_post = mean_post(~isnan(mean_post));

[fig1, fig2] = plot_tremor_scores(mean_pre, mean_post, FIGTITLE2, 'Weighted sum score');

savetitle = strrep(FIGTITLE2, ' ', '_');

savepath = ['X:\tremor_figs\group_effects\linear_' savetitle '.png'];
savepath2 = ['X:\tremor_figs\group_effects\log_' savetitle '.png'];
%saveas(fig1, savepath);
saveas(fig2, savepath2);

%% stats
[h,p] = ttest(mean_pre,mean_post);
fprintf('Paired ttest p-value is: %s\n', p)


