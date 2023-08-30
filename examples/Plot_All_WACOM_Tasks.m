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

    pre_scores = []; post_scores = [];

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

        [pre,~,~] = WACOM_Welch_score(datadir, subjects{i},'pre', taskname, 2);
        [post,~,~] = WACOM_Welch_score(datadir, subjects{i},'post', taskname, 2);

        pre_scores = [pre_scores, mean(pre)];
        post_scores = [post_scores, mean(post)];

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
    title({['Task: ' tasks{k}]});
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
    title({['Task: ' tasks{k}]});
    ylabel('Log Tremor Index (AU)');

    fig3 = figure;
    percent_change = (post_scores - pre_scores) ./ pre_scores * 100;
    %histogram(percent_change,'BinEdges',linspace(-400,400,20))
    labels = {'Percent change'};
    boxplot(percent_change,labels,'PlotStyle','traditional','OutlierSize',.0001);
    hold on;
    scatter(onevec,percent_change);
    title({['Task: ' tasks{k}]});
    ylabel('Percent change');
    yline(0);
    ylim([-500,500]);


    savepath = ['X:\WACOMpreprocessed\figs\linear_scale\' tasks{k} '.png'];
    savepath2 = ['X:\WACOMpreprocessed\figs\log_scale\' tasks{k} '.png'];
    savepath3 = ['X:\WACOMpreprocessed\figs\percent_change\' tasks{k} '.png'];
    saveas(fig, savepath);
    saveas(fig2, savepath2);
    saveas(fig3, savepath3);
end

