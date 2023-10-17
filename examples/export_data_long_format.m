%% Export data in long format
addpath(fileparts(cd));
clc;clear all;close all;

%% get availible subjects with pre and post data
% Subjects missing either preop or postop visit will not be exported

datadir = 'X:\APDMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

taskname = 'wingbeat'; %just use this to grab subjects that have apdm preprocessed data
[pre_subjects, ~] = APDM_parse_subjects(metadata_filepath, datadir,taskname,'pre'); % get the list of subjects we have preop data for, and the path to their data
[post_subjects, ~] = APDM_parse_subjects(metadata_filepath, datadir,taskname,'post');
subjects = intersect(pre_subjects,post_subjects);
lesioned_sides = get_lesioned_sides(metadata_filepath, subjects);
assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

tasks = {'resting','headtrunk','llegpost','rlegpost',...
    'llegact','rlegact','llegact2','rlegact2','armsextended',...
    'wingbeat','larmact','rarmact','rarmact2','larmact2'};
sensors = {'RightWrist','LeftWrist','RightHand','LeftHand','RightUpperArm'...
    'LeftUpperArm','RightFoot','LeftFoot','Lumbar','Sternum'};

%subjects = subjects(1);
%lesioned_sides = lesioned_sides(1);
%% Iterate over all sensors and tasks
vartypes = ["string","string","string","string","string","double"];
varnames = ["Subject","Lesioned Side", "Timepoint","Task","Sensor","Tremor Score (AU)"];
export_table = table('Size',[0,6], 'VariableTypes', vartypes);
export_table.Properties.VariableNames = varnames;


for i=1:length(subjects)
    for k=1:length(tasks)
        for l=1:length(sensors)
            subjects{i}
            [pre_amp,pre_freq,pre_half] = APDM_Welch_score(datadir,subjects{i},'pre',tasks{k},sensors{l},[0 0],2);
            if isnan(pre_amp)
                post_amp = NaN; post_freq = NaN; post_half = NaN;
            else
                post_amp = APDM_Welch_score_at_freq(datadir,subjects{i},'post',tasks{k},sensors{l},[0 0],2,pre_freq);
            end

            pre_table_row = table(string(subjects{i}),string(lesioned_sides{i}),"pre",string(tasks{k}),string(sensors{l}),pre_amp, 'VariableNames', varnames);
            post_table_row = table(string(subjects{i}),string(lesioned_sides{i}),"post",string(tasks{k}),string(sensors{l}),post_amp, 'VariableNames', varnames);

            export_table = [export_table; pre_table_row; post_table_row];
        end
    end
end

%% now do WACOM
datadir = 'X:\Wacompreprocessed';
taskname = 'spiralBig_R'; %just use this to grab subjects that have wacom preprocessed data
[pre_subjects, ~] = WACOM_parse_subjects(metadata_filepath, datadir,taskname,'pre'); % get the list of subjects we have preop data for, and the path to their data
[post_subjects, ~] = WACOM_parse_subjects(metadata_filepath, datadir,taskname,'post');
subjects = intersect(pre_subjects,post_subjects);
lesioned_sides = get_lesioned_sides(metadata_filepath, subjects);
assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')


tasks = {'write','spiralBig_R'};

for i=1:length(subjects)
    for k=1:length(tasks)
        subjects{i}
        [pre_amp,pre_freq,pre_half] = WACOM_Welch_score(datadir,subjects{i},'pre',tasks{k},2);
        pre_amp = nanmean(pre_amp);
        post_amp = nanmean(post_amp);
        pre_freq = nanmean(pre_freq);

        if isnan(pre_amp)
            post_amp = NaN; post_freq = NaN; post_half = NaN;
        else
            post_amp = WACOM_Welch_score_at_freq(datadir,subjects{i},'post',tasks{k},2,pre_freq);
            post_amp = mean(post_amp);
        end

        pre_table_row = table(string(subjects{i}),string(lesioned_sides{i}),"pre",string(tasks{k}),"Pen",pre_amp, 'VariableNames', varnames);
        post_table_row = table(string(subjects{i}),string(lesioned_sides{i}),"post",string(tasks{k}),"Pen",post_amp, 'VariableNames', varnames);

        export_table = [export_table; pre_table_row; post_table_row];
    end
end


%% Write table to excel doc
outputfilename = 'X:\APDM_scores.xlsx';
writetable(export_table,outputfilename);



