function [pre_amps, post_amps, subjects, has_tremor_pre] = allWACOMcores(task)

%% get availible subjects with pre and post data
% Subjects missing either preop or postop visit will not be exported

datadir = 'X:\WACOMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

%% Iterate over subjects

    [pre_subjects, lesioned_sides1] = WACOM_parse_subjects(metadata_filepath, datadir,task,'pre'); % get the list of subjects we have preop data for, and the path to their data
    [post_subjects, lesioned_sides2] = WACOM_parse_subjects(metadata_filepath, datadir,task,'post');
    [subjects,ia,ib] = intersect(pre_subjects,post_subjects);
    lesioned_sides = lesioned_sides1(ia);

    assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

    pre_amps = []; post_amps = [];
    pre_freqs = []; post_freqs = [];
    pre_halfs = []; post_halfs = [];

    for i=1:length(subjects)
        subjects{i}

        if lesioned_sides{i} == 'L'  && contains(task, 'contra') %get contra or ipsi side
            taskname = strrep(task,'contra','R');
        elseif lesioned_sides{i} == 'R'  && contains(task, 'contra')
            taskname = strrep(task,'contra','L');
        elseif lesioned_sides{i} == 'L'  && contains(task, 'ipsi')
            taskname = strrep(task,'ipsi','L');
        elseif lesioned_sides{i} == 'R'  && contains(task, 'ipsi')
            taskname = strrep(task,'ipsi','R');
        else
            taskname = task;
        end
        %close all
        [pre_amp,pre_freq,pre_half] = WACOM_Welch_score(datadir, subjects{i},'pre', taskname, 2);
        [post_amp,post_freq,post_half] = WACOM_Welch_score(datadir, subjects{i},'post', taskname, 2);

        pre_amps = [pre_amps, mean(pre_amp)];
        post_amps = [post_amps, mean(post_amp)];

        pre_freqs = [pre_freqs, mean(pre_freq)];
        post_freqs = [post_freqs, mean(post_freq)];

        pre_halfs = [pre_halfs, mean(pre_half)];
        post_halfs = [post_halfs, mean(post_half)];

    end
    has_tremor_pre = apply_tremor_metrics(pre_freqs,pre_halfs);
    has_tremor_post = apply_tremor_metrics(post_freqs,post_halfs);
    fprintf('\nFor %s task:\n',task)
    fprintf('%i of %i subjects had a detectable preop tremor peak\n',sum(has_tremor_pre),length(has_tremor_pre))
    fprintf('%i of %i subjects had a detectable postop tremor peak\n',sum(has_tremor_post),length(has_tremor_post))
end