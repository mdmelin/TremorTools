function [subject_list, lesioned_sides, data_paths] = APDM_parse_subjects(metadata_filepath,datadir,taskname,timepoint)
%this function takes a taskname and timepoint and returns a list of the subjects
%that have the desired task for that day. If a subject has not been
%preprocessed by APDM_reformat_preprocess, it will not be found by this
%function.

%Taskname options are described below:

%'resting'
%'headtrunk'
%'ipsilegpost'
%'contralegpost'
%'ipsilegact'
%'contralegact'
%'ipsilegact2'
%'contralegact2'
%'armsextended'
%'wingbeat'
%'ipsiarmact'
%'contraarmact'
%'contraarmact2'
%'ipsiarmact2'

%Timepoint options are described below:

%'pre'
%'post'



%Datadir should point to the directory of preprocessed files
files = dir(datadir);
files = files(~[files.isdir]); %remove extraneous folders
timepointlabels = contains({files.name},[timepoint '_']);
files = files(timepointlabels); %grab files from desired timepoint
hastask = false(length(files),1);

names = {files.name};
subject_list = erase(names,{'pre_preprocessed.mat','post_preprocessed.mat'});
lesioned_sides = get_lesioned_sides(metadata_filepath, subject_list);

for i = 1:length(files)
    load([datadir filesep files(i).name]); %loads the data for one session

    if lesioned_sides{i} == 'L'  && contains(taskname, 'contra') %get contra or ipsi side
        taskname = strrep(taskname,'contra','r');
    elseif lesioned_sides{i} == 'R'  && contains(taskname, 'contra')
        taskname = strrep(taskname,'contra','l');
    elseif lesioned_sides{i} == 'L'  && contains(taskname, 'ipsi')
        taskname = strrep(taskname,'ipsi','l');
    elseif lesioned_sides{i} == 'R'  && contains(taskname, 'ipsi')
        taskname = strrep(taskname,'ipsi','r');
    end

    try
        task = output.(taskname);
        hastask(i) = 1;
    catch
        hastask(i) = 0;
    end
end
files = files(hastask);
names = {files.name};
paths = {files.folder}';
data_paths = {};
for i = 1:length(paths)
    temp = paths{i};
    temp = [temp filesep names{i}];
    data_paths{i} = temp;
end
subject_list = subject_list(hastask);
lesioned_sides = lesioned_sides(hastask);
end