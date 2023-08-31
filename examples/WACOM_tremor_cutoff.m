addpath(fileparts(cd));
clc;clear all;close all;

%% get availible subjects with pre and post data
% Subjects missing either preop or postop visit will not be exported

datadir = 'X:\WACOMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

tasks = {'spiralBig_contra','spiralSmall_contra','lineBig_contra','lineSmall_contra'...
    'spiralBig_ipsi','spiralSmall_ipsi','lineBig_ipsi','lineSmall_ipsi'};
% 'write''reach_contra','reach_ipsi' tasks not included currently

%subjects = subjects(1);
%lesioned_sides = lesioned_sides(1);
%% Iterate over all sensors and tasks

parfor k=1:length(tasks)

    [pre_subjects, lesioned_sides1] = WACOM_parse_subjects(metadata_filepath, datadir,tasks{k},'pre'); % get the list of subjects we have preop data for, and the path to their data
    [post_subjects, lesioned_sides2] = WACOM_parse_subjects(metadata_filepath, datadir,tasks{k},'post');
    [subjects,ia,ib] = intersect(pre_subjects,post_subjects);
    lesioned_sides = lesioned_sides1(ia);

    assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

    pre_amps = []; post_amps = [];
    pre_freqs = []; post_freqs = [];
    pre_halfs = []; post_halfs = [];

    for i=1:length(subjects)
        subjects{i}

        if lesioned_sides{i} == 'L'  && contains(tasks{k}, 'contra') %get contra or ipsi side
            taskname = strrep(tasks{k},'contra','R');
        elseif lesioned_sides{i} == 'R'  && contains(tasks{k}, 'contra')
            taskname = strrep(tasks{k},'contra','L');
        elseif lesioned_sides{i} == 'L'  && contains(tasks{k}, 'ipsi')
            taskname = strrep(tasks{k},'ipsi','L');
        elseif lesioned_sides{i} == 'R'  && contains(tasks{k}, 'ipsi')
            taskname = strrep(tasks{k},'ipsi','R');
        else
            taskname = tasks{k};
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
    % plotting
    
    fig = figure;
    labels = {'Pre-procedure','Post-procedure'};
    hold on;
    scatter(pre_amps,pre_halfs);
    scatter(post_amps,post_halfs);
    legend({'pre','post'})
    title({['Task: ' tasks{k}]});
    xlabel('amplitude');
    ylabel('half max');

    fig2 = figure;
    labels = {'Pre-procedure','Post-procedure'};
    hold on;
    scatter(log(pre_amps),log(pre_halfs));
    scatter(log(post_amps),log(post_halfs));
    legend({'pre','post'})
    title({['Task: ' tasks{k}]});
    xlabel('log amplitude');
    ylabel('log half max');

    fig3 = figure;
    hold on
    histogram(pre_freqs,20,'Binwidth',.2)
    histogram(post_freqs,20,'BinWidth',.2)
    legend({'pre','post'})

    savepath = ['X:\tremor_figs\wacom\cluster\' tasks{k} '.png'];
    savepath2 = ['X:\tremor_figs\wacom\log_cluster\' tasks{k} '.png'];
    savepath3 = ['X:\tremor_figs\wacom\freq_hist\' tasks{k} '.png'];
    saveas(fig, savepath);
    saveas(fig2, savepath2);
    saveas(fig3, savepath3);
end

