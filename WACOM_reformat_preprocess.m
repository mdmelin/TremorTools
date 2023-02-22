function WACOM_reformat_preprocess(datadir,savedir,subject,timepoint)
TASKS = {'handwriting','large spiral R1','large spiral R2','large spiral L1'...
    'large spiral L2','small spiral R1','small spiral R2','small spiral L1'...
    'small spiral L2','large line R1','large line R2','large line L1'...
    'large line L2','small line R1','small line R2','small line L1','small line L2'...
    'hold R1','hold R2','hold L1','hold L2'};

files = dir([datadir filesep subject filesep subject '_' timepoint filesep 'Wacom Data']);
files = files(~[files.isdir]);
figfiles = files(contains({files.name},'.fig'));
coordfiles = files(contains({files.name},'.mat'));

if length(coordfiles) == 1
    fprintf('There is only one file for this subject, no merging is needed.');
    load([coordfiles(end).folder filesep coordfiles(end).name]);
    save([savedir filesep subject timepoint '.mat'],'cond','penvalinfo','penvals','response','stimulus','t');
    return
end

for i = 1:length(figfiles)
    openfig([figfiles(i).folder filesep figfiles(i).name]);
end

for i = 1:length(TASKS)
    prompt = ['Which figure should be used for ' TASKS{i} '?'];
    fignum(i) = input(prompt);
end

for i = 1:length(coordfiles)
    filedata(i) = load([coordfiles(i).folder filesep coordfiles(i).name]);
end

fields = fieldnames(filedata);

for i = 1:length(fields)
    for j = 1:length(filedata)
        data(j == fignum) = filedata(j).(fields{i})(j == fignum);
        dataout.(fields{i}) = data;
    end
end
save([savedir filesep subject timepoint '.mat'],'-struct','dataout')
end
