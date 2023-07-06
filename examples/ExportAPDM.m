%% Export data in long format
addpath(fileparts(cd));
clc;clear all;close all;

%% get availible subjects with pre and post data
% Subjects missing either preop or postop visit will not be exported

datadir = 'Y:\APDMpreprocessed';
metadata_filepath = 'C:\Users\mmelin\Desktop\tremor\data\FUS Participants_backup_Updated.xlsx'; %contains info on lesion side

taskname = 'wingbeat'; %just use this to grab subjects that have apdm preprocessed data
[pre_subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'pre'); % get the list of subjects we have preop data for, and the path to their data
[post_subjects, datapaths] = APDM_parse_subjects(datadir,taskname,'post');
subjects = intersect(pre_subjects,post_subjects);
lesioned_sides = get_lesioned_sides(metadata_filepath, subjects);
assert(length(lesioned_sides) == length(subjects), 'Some subjects missing lesioned side.')

timepoints = {'pre','post'};
tasks = {'resting','headtrunk','llegpost','rlegpost',...
        'llegact','rlegact','llegact2','rlegact2','armsextended',...
        'wingbeat','larmact','rarmact','rarmact2','larmact2'};
sensors = {'RightWrist','LeftWrist','RightHand','LeftHand','RightUpperArm'...
        'LeftUpperArm','RightFoot','LeftFoot','Lumbar','Sternum'};

%subjects = subjects(1);
%lesioned_sides = lesioned_sides(1);
%% Iterate over all sensors and tasks
export_table = table();

for i=1:length(subjects)
    for j=1:length(timepoints)
        for k=1:length(tasks)
            for l=1:length(sensors)
                [score,~] = APDM_PCA_tremor_score(datadir, ...
                    subjects{i}, ...
                    timepoints{j}, ...
                    tasks{k}, ...
                    sensors{l}, ...
                    1,[0 0]);

                table_row = table(string(subjects{i}),string(lesioned_sides{i}),string(timepoints{j}),string(tasks{k}),string(sensors{l}),score);
                export_table = [export_table;table_row];
            end
        end
    end
end

%% Write table to excel doc
outputfilename = 'Y:\APDM_scores.xlsx';
export_table.Properties.VariableNames = ["Subject","Lesioned Side", "Timepoint","Task","Sensor","Tremor Score (AU)"];
writetable(export_table,outputfilename);



