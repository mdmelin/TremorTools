function WACOM_reformat_preprocess(datadir,savedir,subject,timepoint)
TASKS = {'handwriting','spiralBig_R1','spiralSmall_R1','lineBig_R1','lineSmall_R1'...
    'spiralBig_R2','spiralSmall_R2','lineBig_R2','lineSmall_R2'...
    'spiralBig_L1','spiralSmall_L1','lineBig_L1','lineSmall_L1'...
    'spiralBig_L2','spiralSmall_L2','lineBig_L2','lineSmall_L2'...
    'reach_R1','reach_R2','reach_L1','Reach_L2'};



filecheckpath = [savedir, subject, timepoint, '.mat'];

if isfile(filecheckpath)
    prompt = ['It looks like there is already a preprocessed file in your save directory.\nAre you sure you want to want to rerun for ' subject , timepoint '? (y/n)'];
    userin = input(prompt,"s");
    if userin == 'n' || userin == 'N'
        fprintf(2, '\nSkipping this subject\n');
        return
    end
end


files = dir([datadir filesep subject filesep subject '_' timepoint filesep 'Wacom Data']);
files = files(~[files.isdir]);
figfiles = files(contains({files.name},'.fig'));
coordfiles = files(contains({files.name},'.mat'));

if length(coordfiles) == 1
    fprintf('\nThere is only one file for this subject, no merging is needed.');
    load([coordfiles(end).folder filesep coordfiles(end).name]);
    save([savedir filesep subject timepoint '.mat'],'cond','penvalinfo','penvals','response','stimulus','t');
    return
end
close all;
for i = 1:length(figfiles)
    openfig([figfiles(i).folder filesep figfiles(i).name]);
end

for i = 1:length(coordfiles)
    filedata(i) = load([coordfiles(i).folder filesep coordfiles(i).name]);
    filedata(i).penvalinfo
end

for i = 1:length(TASKS)
    prompt = ['Which figure should be used for ' TASKS{i} '?'];
    fignum(i) = input(prompt);
end



fields = fieldnames(filedata);

for i = 1:length(fields)
    for j = 1:length(filedata)
        data(j == fignum) = filedata(j).(fields{i})(j == fignum);
        dataout.(fields{i}) = data;
    end
end
%assert(sum(cellfun(@isempty,dataout.t)) == 0, 'There is empty data, double check you have chosen the proper files.')

save([savedir filesep subject timepoint '.mat'],'-struct','dataout')
end
