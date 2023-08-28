addpath(fileparts(cd));
clc;clear all;close all;

%% get availible subjects with pre and post data
% Subjects missing either preop or postop visit will not be exported

datadir = 'X:\APDMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

tasks = {'resting','headtrunk','ipsilegpost','contralegpost',...
    'ipsilegact','contralegact','ipsilegact2','contralegact2','armsextended',...
    'wingbeat','ipsiarmact','contraarmact','ipsiarmact2','contraarmact2'};

%subjects = subjects(1);
%lesioned_sides = lesioned_sides(1);
%% Iterate over all sensors and tasks

parfor k=1:length(tasks)

    [pre_subjects, lesioned_sides1, ~] = APDM_parse_subjects(metadata_filepath, datadir,tasks{k},'pre'); % get the list of subjects we have preop data for, and the path to their data
    [post_subjects, lesioned_sides2, ~] = APDM_parse_subjects(metadata_filepath, datadir,tasks{k},'post');
    [subjects,ia,ib] = intersect(pre_subjects,post_subjects);
    lesioned_sides = lesioned_sides1(ia);

    assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

    sensors = getTaskSensors(tasks{k}); %sensors vary for each task

    for l=1:length(sensors)
        pre_scores = []; post_scores = [];

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

            [pre_scores(i),~,~] = APDM_Welch_score(datadir,subjects{i},'pre',taskname,task_sensor,[0 0],2);
            [post_scores(i),~,~] = APDM_Welch_score(datadir,subjects{i},'post',taskname,task_sensor,[0 0],2);
        end

        % plotting
        onevec = ones(1,length(pre_scores));
        twovec = onevec + 1;
        fig = figure;
        labels = {'Pre-procedure','Post-procedure'};
        boxplot([pre_scores;post_scores]',labels,'PlotStyle','traditional','OutlierSize',.0001);
        hold on;
        scatter(onevec,pre_scores);
        scatter(twovec,post_scores);
        parallelcoords([pre_scores;post_scores]');
        title({['Task: ' tasks{k}]},{['Sensor: ' sensors{l}]});
        ylabel('Tremor Index (AU)');

        fig2 = figure;
        logpre = log(pre_scores);
        logpost = log(post_scores);
        labels = {'Pre-procedure','Post-procedure'};
        boxplot([logpre;logpost]',labels,'PlotStyle','traditional','OutlierSize',.0001);
        hold on;
        scatter(onevec,logpre);
        scatter(twovec,logpost);
        parallelcoords([logpre;logpost]');
        title({['Task: ' tasks{k}]},{['Sensor: ' sensors{l}]});
        ylabel('Log Tremor Index (AU)');

        fig3 = figure;
        percent_change = (post_scores - pre_scores) ./ pre_scores * 100;
        %histogram(percent_change,'BinEdges',linspace(-400,400,20))
        labels = {'Percent change'};
        boxplot(percent_change,labels,'PlotStyle','traditional','OutlierSize',.0001);
        hold on;
        scatter(onevec,percent_change);
        title({['Task: ' tasks{k}]},{['Sensor: ' sensors{l}]});
        ylabel('Percent change');
        yline(0);
        ylim([-500,500]);


        savepath = ['X:\APDMpreprocessed\figs\linear_scale\' tasks{k} '_' sensors{l} '.png'];
        savepath2 = ['X:\APDMpreprocessed\figs\log_scale\' tasks{k} '_' sensors{l} '.png'];
        savepath3 = ['X:\APDMpreprocessed\figs\percent_change\' tasks{k} '_' sensors{l} '.png'];
        saveas(fig, savepath);
        saveas(fig2, savepath2);
        saveas(fig3, savepath3);
    end
end

