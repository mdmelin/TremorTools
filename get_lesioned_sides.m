function [lesioned_sides] = get_lesioned_sides(metadata_filepath, subjects)
UCLA_metadata = readtable(metadata_filepath,'sheet','UCLA');
UT_metadata = readtable(metadata_filepath,'sheet','UTSW');
lesioned_sides = {};
for i = 1:length(subjects)
    if contains(subjects{i},'UT')
        rownumber = find(strcmp(UT_metadata.SubjectCode,subjects{i}));
        lesioned_sides{i} = UT_metadata.LesionSide{rownumber};
    else
        rownumber = find(strcmp(UCLA_metadata.SubjectCode,subjects{i}));
        lesioned_sides{i} = UCLA_metadata.VimLesionSide{rownumber};
    end
end
end