function [subject_list, data_paths] = APDM_parse_subjects(datadir,taskname,timepoint)
%this function takes a taskname and timepoint and returns a list of the subjects
%that have the desired task for that day. If a subject has not been
%preprocessed by APDM_reformat_preprocess, it will not be found by this
%function.

%Taskname options are described below:

%'resting'
%'headtrunk'
%'llegpost'
%'rlegpost'
%'llegact'
%'rlegact'
%'llegact2'
%'rlegact2'
%'armsextended'
%'wingbeat'
%'larmact'
%'rarmact'
%'rarmact2'
%'larmact2'

%Timepoint options are described below:

%'pre'
%'post'

%Datadir should point to the directory of preprocessed files
    files = dir(datadir);
    files = files(~[files.isdir]); %remove extraneous folders
    timepointlabels = contains({files.name},[timepoint '_']);
    files = files(timepointlabels); %grab files from desired timepoint
    hastask = false(length(files),1);
    for i = 1:length(files)
        load([datadir filesep files(i).name]); %loads the data for one session
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
    subject_list = erase(names,{'pre_preprocessed.mat','post_preprocessed.mat'});
end