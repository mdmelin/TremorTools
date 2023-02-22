function [subject_list, data_paths] = WACOM_parse_subjects(datadir,timepoint)

paths = dir([datadir filesep '*' timepoint '.mat']);
paths = paths(~[paths.isdir]); %remove extraneous files

hastask = false(length(paths),1);
data_paths = {};
subject_list = {};
for i = 1:length(paths) %iterate over subjects
    subject_list{end+1} = erase(paths(i).name,[timepoint '.mat']);
    data_paths{end+1} = [paths(i).folder filesep paths(i).name];
end
end