function [pre_amp, post_amp, subjects] = allAPDMScores(task, sensor)
%% get availible subjects with pre and post data
% Subjects missing either preop or postop visit will not be exported

datadir = 'X:\APDMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

%% Iterate over all sensors and tasks

[pre_subjects, lesioned_sides1] = APDM_parse_subjects(metadata_filepath, datadir,task,'pre'); % get the list of subjects we have preop data for, and the path to their data
[post_subjects, lesioned_sides2] = APDM_parse_subjects(metadata_filepath, datadir,task,'post');
[subjects,ia,ib] = intersect(pre_subjects,post_subjects);
lesioned_sides = lesioned_sides1(ia);

assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

pre_amp = []; post_amp = [];
pre_freq = []; post_freq = [];
pre_half = []; post_half = [];

for i=1:length(subjects)
    subjects{i}

    if lesioned_sides{i} == 'L'  && contains(task, 'contra') %get contra or ipsi side
        taskname = strrep(task,'contra','r');
    elseif lesioned_sides{i} == 'R'  && contains(task, 'contra')
        taskname = strrep(task,'contra','l');
    elseif lesioned_sides{i} == 'L'  && contains(task, 'ipsi')
        taskname = strrep(task,'ipsi','l');
    elseif lesioned_sides{i} == 'R'  && contains(task, 'ipsi')
        taskname = strrep(task,'ipsi','r');
    else
        taskname = task;
    end

    if lesioned_sides{i} == 'L'  && contains(sensor, 'Contra') %get contra or ipsi side
        task_sensor = strrep(sensor,'Contra','Right');
    elseif lesioned_sides{i} == 'R'  && contains(sensor, 'Contra')
        task_sensor = strrep(sensor,'Contra','Left');
    elseif lesioned_sides{i} == 'L'  && contains(sensor, 'Ipsi')
        task_sensor = strrep(sensor,'Ipsi','Left');
    elseif lesioned_sides{i} == 'R'  && contains(sensor, 'Ipsi')
        task_sensor = strrep(sensor,'Ipsi','Right');
    else
        task_sensor = sensor;
    end

    [pre_amp(i),pre_freq(i),pre_half(i)] = APDM_Welch_score(datadir,subjects{i},'pre',taskname,task_sensor,[0 0],2);
    if isnan(pre_amp(i))
        post_amp(i) = NaN; post_freq(i) = NaN; post_half(i) = NaN;
    else
        [post_amp(i)] = APDM_Welch_score_at_freq(datadir,subjects{i},'post',taskname,task_sensor,[0 0],2,pre_freq(i));
    end
end

% has_tremor_pre = apply_tremor_metrics(pre_freq,pre_half);
% has_tremor_post = apply_tremor_metrics(post_freq,post_half);
% fprintf('\nFor %s task and sensor %s:\n',task,sensor)
% fprintf('%i of %i subjects had a detectable preop tremor peak\n',sum(has_tremor_pre),length(has_tremor_pre))
% fprintf('%i of %i subjects had a detectable postop tremor peak\n',sum(has_tremor_post),length(has_tremor_post))

end