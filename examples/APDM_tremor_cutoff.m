addpath(fileparts(cd));
clc;clear all;close all;

%% get availible subjects with pre and post data
% Subjects missing either preop or postop visit will not be exported

datadir = 'X:\APDMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

tasks = {'resting','headtrunk','ipsilegpost','contralegpost',...
    'ipsilegact','contralegact','ipsilegact2','contralegact2','armsextended',...
    'wingbeat','ipsiarmact','contraarmact','ipsiarmact2','contraarmact2'};

tasks = {'armsextended'};
sensors = {'ContraHand'};
%subjects = subjects(1);
%lesioned_sides = lesioned_sides(1);
%% Iterate over all sensors and tasks

for k=1:length(tasks)

    [pre_subjects, lesioned_sides1] = APDM_parse_subjects(metadata_filepath, datadir,tasks{k},'pre'); % get the list of subjects we have preop data for, and the path to their data
    [post_subjects, lesioned_sides2] = APDM_parse_subjects(metadata_filepath, datadir,tasks{k},'post');
    [subjects,ia,ib] = intersect(pre_subjects,post_subjects);
    lesioned_sides = lesioned_sides1(ia);

    assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

    sensors = getTaskSensors(tasks{k}); %sensors vary for each task

    for l=1:length(sensors)
        pre_amp = []; post_amp = [];
        pre_freq = []; post_freq = [];
        pre_half = []; post_half = [];

        for i=1:length(subjects)
            subjects{i}

            if lesioned_sides{i} == 'L'  && contains(tasks{k}, 'contra') %get contra or ipsi side
                taskname = strrep(tasks{k},'contra','r');
            elseif lesioned_sides{i} == 'R'  && contains(tasks{k}, 'contra')
                taskname = strrep(tasks{k},'contra','l');
            elseif lesioned_sides{i} == 'L'  && contains(tasks{k}, 'ipsi')
                taskname = strrep(tasks{k},'ipsi','l');
            elseif lesioned_sides{i} == 'R'  && contains(tasks{k}, 'ipsi')
                taskname = strrep(tasks{k},'ipsi','r');
            else
                taskname = tasks{k}
            end

            if lesioned_sides{i} == 'L'  && contains(sensors{l}, 'Contra') %get contra or ipsi side
                task_sensor = strrep(sensors{l},'Contra','Right');
            elseif lesioned_sides{i} == 'R'  && contains(sensors{l}, 'Contra')
                task_sensor = strrep(sensors{l},'Contra','Left');
            elseif lesioned_sides{i} == 'L'  && contains(sensors{l}, 'Ipsi')
                task_sensor = strrep(sensors{l},'Ipsi','Left');
            elseif lesioned_sides{i} == 'R'  && contains(sensors{l}, 'Ipsi')
                task_sensor = strrep(sensors{l},'Ipsi','Right');
            else
                task_sensor = sensors{l};
            end

            [pre_amp(i),pre_freq(i),pre_half(i)] = APDM_Welch_score(datadir,subjects{i},'pre',taskname,task_sensor,[0 0],2);
            [post_amp(i),post_freq(i),post_half(i)] = APDM_Welch_score(datadir,subjects{i},'post',taskname,task_sensor,[0 0],2);
        end

        % plotting
        fig = figure;
        labels = {'Pre-procedure','Post-procedure'};
        hold on;
        scatter(pre_amp,pre_half);
        scatter(post_amp,post_half);
        legend({'pre','post'})
        title({['Task: ' tasks{k}]},{['Sensor: ' sensors{l}]});
        xlabel('amplitude');
        ylabel('half max');

        fig2 = figure;
        labels = {'Pre-procedure','Post-procedure'};
        hold on;
        scatter(log(pre_amp),log(pre_half));
        scatter(log(post_amp),log(post_half));
        legend({'pre','post'})
        title({['Task: ' tasks{k}]},{['Sensor: ' sensors{l}]});
        xlabel('log amplitude');
        ylabel('log half max');

        fig3 = figure;
        hold on
        histogram(pre_freq,20,'Binwidth',.1)
        histogram(post_freq,20,'BinWidth',.1)
        legend({'pre','post'})


        savepath = ['X:\tremor_figs\apdm\cluster\' tasks{k} '_' sensors{l} '.png'];
        savepath2 = ['X:\tremor_figs\apdm\log_cluster\' tasks{k} '_' sensors{l} '.png'];
        savepath3 = ['X:\tremor_figs\apdm\freq_hist\' tasks{k} '_' sensors{l} '.png'];

        saveas(fig, savepath);
        saveas(fig2, savepath2);
        saveas(fig3,savepath3)
    end
end