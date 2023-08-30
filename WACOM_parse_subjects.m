function [subject_list, lesioned_sides] = WACOM_parse_subjects(metadata_filepath,datadir,taskname,timepoint)

paths = dir([datadir filesep '*' timepoint '.mat']);
paths = paths(~[paths.isdir]); %remove extraneous files

names = {paths.name};
subject_list = erase(names,{'pre.mat','post.mat'});
lesioned_sides = get_lesioned_sides(metadata_filepath, subject_list);


for i = 1:length(paths) %iterate over subjects
    datapath = [paths(i).folder filesep paths(i).name];

    if lesioned_sides{i} == 'L'  && contains(taskname, 'contra') %get contra or ipsi side
        taskname = strrep(taskname,'contra','R');
    elseif lesioned_sides{i} == 'R'  && contains(taskname, 'contra')
        taskname = strrep(taskname,'contra','L');
    elseif lesioned_sides{i} == 'L'  && contains(taskname, 'ipsi')
        taskname = strrep(taskname,'ipsi','L');
    elseif lesioned_sides{i} == 'R'  && contains(taskname, 'ipsi')
        taskname = strrep(taskname,'ipsi','R');
    end

    data = load(datapath);
    tasklist = (data.cond);
    hastask(i) = ismember(taskname,tasklist);
end
subject_list = subject_list(hastask);
lesioned_sides = lesioned_sides(hastask);
end