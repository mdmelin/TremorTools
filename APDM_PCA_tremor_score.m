function [tremor_index,hilbert_envelope] = APDM_PCA_tremor_score(datadir,subject,timepoint,taskname,sensor,dimension,padvec)
%This function takes a subject and will output a single value tremor score.
%Specify datadir, subject, and timepoint as in other functions. 'dimension'
%tells the function which PCA dimension to grab (we are almost always using
%the first dimension). padvec specifies how much padding should be added to
%the beginning and end of the task, specified in seconds. If we want to chop 1.5
%seconds at the beginning of the task and chop nothing at the end,
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

%Possible sensor names are

% 'RightWrist'
% 'LeftWrist'
% 'RightHand'
% 'LeftHand'
% 'RightUpperArm'
% 'LeftUpperArm'
% 'RightFoot'
% 'LeftFoot'
% 'Lumbar'
% 'Sternum'


fs = 128; %constant
nyquist = fs/2;

sensordata = getSensorData(datadir,subject,timepoint,taskname,sensor);

if isempty(sensordata) %handle case of sensors not having data
    tremor_index = NaN; hilbert_envelope = NaN;
    return
end

fieldname = ['pca' num2str(dimension) '_angle'];
signal = sensordata.(fieldname);
t = sensordata.time;

%do padding now
samplestograb = find(t >= padvec(1) & t <= (t(end) - padvec(2)));
t = t(samplestograb);
signal = signal(samplestograb);


[b,a] = butter(4,[4 11]./nyquist,'bandpass'); %bandpass filter transfer function coeffs
filtered = filtfilt(b,a,signal);

hilb = hilbert(filtered);
hilbert_envelope = abs(hilb);

tremor_index = mean(hilbert_envelope);
end