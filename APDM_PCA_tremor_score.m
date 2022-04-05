%This function takes a subject and will output a single value tremor score.
%Specify datadir, subject, and timepoint as in other functions. 'dimension'
%tells the function which PCA dimension to grab (we are almost always using
%the first dimension). padvec specifies how much padding should be added to
%the beginning and end of the task, specified in seconds. If we want 1.5
%seconds of padding at the beginning of the task and no padding at the end,
%we would specify the following:

% padvec = [1.5 0];

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

function [tremor_index,hilbert_envelope] = APDM_PCA_tremor_score(datadir,subject,timepoint,taskname,sensor,dimension,padvec)

fs = 128; %constant
nyquist = fs/2;

sensordata = getSensorData(datadir,subject,timepoint,taskname,sensor);
fieldname = ['pca' num2str(dimension) '_angle'];
signal = sensordata.(fieldname);
t = sensordata.time;

[b,a] = butter(4,[4 11]./nyquist,'bandpass'); %bandpass filter transfer function coeffs
filtered = filtfilt(b,a,signal);

hilb = hilbert(filtered);
hilbert_envelope = abs(hilb);

tremor_index = mean(hilbert_envelope);
end