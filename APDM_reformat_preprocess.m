% By Max Melin
% This code reformats all of the APDM .h5 files from a subject on any given day,
% does some preprocessing, and puts them into one .mat file.
% The structure contains the task names. Within each task it contains data
% for all sensors.

% This only ever needs to be run once for each subject/day. The function asks
% for a fair amount of user input, so that all of the tasks and sensors get
% properly indexed to be called by later functions.

function APDM_reformat_preprocess(datadir,savedir,subject,timepoint)
loadpath = [datadir,subject,'\',subject,'_',timepoint,'\Tremor Raw Data'];
files = dir([loadpath,'\*.h5']);

filename = [subject,timepoint];
filecheckpath = [savedir,'\',filename,'_preprocessed.mat'];

if isfile(filecheckpath)
    prompt = ['It looks like there is already a preprocessed file in your save directory.\nAre you sure you want to want to rerun for ' subject , timepoint '? (y/n)'];
    userin = input(prompt,"s");
    if userin == 'n' || userin == 'N'
        fprintf(2, '\nSkipping this subject\n');
        return
    end
end

%input variables. These will need to change if number of tasks or sensors changes

numsensors = 6; %number of APDM sensors used, should always be 6
fs = 128; %sample rate of sensors, should always be 128
nyquist = fs/2;
orderedtasks = {'resting','headtrunk','llegpost','rlegpost','llegact','rlegact','llegact2','rlegact2','armsextended','wingbeat','larmact','rarmact','larmact2','rarmact2'};


% here, we will get the sensors and the tasks in the right order
temp = {files(:).name};
inds = [];
fprintf('\nHere is the original order of the %i files as they were named for subject %s%s. \nPlease view the pop-up figure and enter the proper index for each task.',length(temp),subject,timepoint);

for i = 1:length(orderedtasks)
    for j = 1:length(temp)
        fprintf('\n%i: %s',j,temp{j});
    end
    prompt = ['\nWhich file is the ',orderedtasks{i},' file? (Type the integer number.\nEnter 0 if it does not exist.)'];
    userin = input(prompt);
    inds = [inds userin];
end

inds(inds == 0) = NaN;
clear temp
for i = 1:length(orderedtasks)
    if ~isnan(inds(i))
        temp(i) = files(inds(i));%reorder the files to their proper order
    else
        temp(i).name = 'empty';
    end
end
files = temp;clear temp;

% h5 data reformatting
for i = 1:length(orderedtasks)
    if files(i).name ~= "empty" %only process tasks with data
        output.(orderedtasks{i}) = processFile([loadpath,'\',files(i).name],numsensors);
    end
end

numtasks = length(fieldnames(output));

%Now we have all of the tasks in the proper order, but the sensor names are
%not correct for some tasks. For the sake of speed during data collection, we do not rename the
%sensors while collecting data from participants, we just move them to the
%second configuration without renaming. We need to update the field names
%to show the proper sensor names for some of the tasks.

fields = fieldnames(output);
for i = 1:length(fields)
    fprintf('\n%i: %s',i,fields{i});
end

userin = input('\nWhich files need sensor relabeling? (input as comma separated values)',"s");
filestochange = str2num(userin);

movedsensors = fieldnames(output.wingbeat); % the original sensor location names for the second configuration
newlocations = {'LeftUpperArm','RightUpperArm','LeftWrist','RightWrist','LeftHand','RightHand'}; % their actual locations
inds = [];
for i = 1:length(movedsensors)
    for j = 1:length(newlocations)
        fprintf('\n%i: %s',j,newlocations{j});
    end
    prompt = ['\nWhere did the ' movedsensors{i} ' sensor go?'];
    userin = input(prompt);
    inds = [inds userin];
end
un = unique(inds);
assert(length(un) == length(newlocations),'Double check your labeling!!! Something is wrong.');


for i = filestochange %relabel the tasks that need it
    for j = 1:length(movedsensors) %relabel each sensor for that task
        temp = output.(fields{i}).(movedsensors{j}); %reassign and delete
        output.(fields{i}) = rmfield(output.(fields{i}),movedsensors{j});
        output.(fields{i}).(newlocations{inds(j)}) = temp;
    end
end

% Now some lite preprocessing: calculate pca on gyro data and filter it.
% Raw gyro and accelerometer data are still stored if other preprocessing
% is desired
for i = 1:numtasks %iterate thru tasks
    allsensors = output.(fields{i});
    sensorfields = fieldnames(allsensors);
    
    for j = 1:length(sensorfields) %iterate thru sensors
        gyrodata = allsensors.(sensorfields{j}).rawgyro; %this data is in rads/sec.
        gyrodata_filtered = filter(gyrodata,fs);
        t = 0:1/fs:500;
        t = t(1:length(gyrodata_filtered));
        
        [coeff,score,latent] = pca(gyrodata_filtered);
        firstcomponent = score(:,1);
        secondcomponent = score(:,2);
        thirdcomponent = score(:,3);
        angle1 = cumtrapz(1/fs, firstcomponent); %integrate the principal velocity component (rad/sec) to get position (radians)
        angle2 = cumtrapz(1/fs, secondcomponent);
        angle3 = cumtrapz(1/fs, thirdcomponent);
        
        morletConvolutionPlot(angle1,fs,t,40,1,50,100,30,"True",[-5 5]); %THIS FUNCTION IS CURRENTLY BROKEN
        
        output.(fields{i}).(sensorfields{j}).pca1_angle = angle1; % adds the "pca angle" data to the struct. where i is the task and j is the sensor
        output.(fields{i}).(sensorfields{j}).pca2_angle = angle2;
        output.(fields{i}).(sensorfields{j}).pca3_angle = angle3;
        
        pca_raw.coeff = coeff;pca_raw.score = score;pca_raw.latent = latent;
        
        output.(fields{i}).(sensorfields{j}).pca_raw = pca_raw; %raw outputs of PCA() function
    end
end

%saving
filename = [subject,timepoint];
save([savedir,'\',filename,'_preprocessed'], 'output');
end

%% Nested functions

% trim and filtering
function gyrodata_filtered = filter(gyrodata,fs)
lopasscut = 50;
hipasscut = .5;
nyquist = fs/2;
gyrodata_trim = gyrodata(:,fs:end - fs)';%trim off end of recordings (1 second on each end)
[b,a] = butter(3,lopasscut/nyquist,'low'); %lo pass filter transfer funciton coeffs
[d,c] = butter(3,hipasscut/nyquist,'high'); %hi pass filter transfer funciton coeffs

gyrodata_filtered = filtfilt(b,a,gyrodata_trim);
gyrodata_filtered = filtfilt(d,c,gyrodata_filtered);
end

% h5 file parsing
function output = processFile(filepath,numsensors)
h5 = h5info(filepath);
for i = 1:numsensors
    sensorname = h5.Groups(2).Groups(i).Groups(1).Attributes(1).Value;
    sensorname = strrep(sensorname, ' ', ''); %remove spaces so the sensor name can be a struct field
    sensorID = h5.Groups(2).Groups(i).Name;
    
    sensors.(sensorname).rawgyro = h5read(filepath,[sensorID, '/Gyroscope']);
    sensors.(sensorname).rawaccel = h5read(filepath,[sensorID, '/Accelerometer']);
    sensors.(sensorname).temperature = h5read(filepath,[sensorID, '/Temperature']);
    sensors.(sensorname).magnetometer = h5read(filepath,[sensorID, '/Magnetometer']);
    sensors.(sensorname).barometer = h5read(filepath,[sensorID, '/Barometer']);
    
    time = h5read(filepath,[sensorID, '/Time']); %this is in microseconds
    time = time - time(1);
    time = double(time) / 1000000.0; %convert to seconds, in microseconds originally
    sensors.(sensorname).time = time;
end

output = sensors;
end