%+++++++++++++++++++++++++
% THIS CODE IS NOW DEPRACATED AND DOES NOT WORK WITH NEWLY PREPROCESSED
% DATA. IT WILL BE REMOVED SOON.
%++++++++++++++++++++++++
clc;clear all;close all;
%% 
dir = 'C:/Data/Pouratian_lab/fus_data/';
filename = uigetfile(dir, 'Select a file');
load([dir filesep filename]);
try
    tasklist = outputt(1,:)'
    tasknum = input('Select the task you would like\n');
    taskdata = outputt(2,tasknum);
catch
    tasklist = output(1,:)'
    tasknum = input('Select the task you would like\n');
    taskdata = output(2,tasknum);
end

fprintf('\nSelected task: %s\n',tasklist{tasknum});
taskdata = taskdata{1,1};

sensorlist = {taskdata(:).location}'
sensornum = input('Select the sensor you would like. Remember that some sensors are mislabeled. \n');
fprintf('\nSelected sensor: %s\n',sensorlist{sensornum});
angledata = taskdata(sensornum).pca_angle;

fs = 127.9918; %sample rate of sensors
t = 0:1/fs:500;
t = t(1:length(angledata));
morletConvolutionPlot(angledata',fs,t) % tf plot to check data
%% filter for hilbert transform
nyquist = fs/2;
[b,a] = butter(4,[4 11]./nyquist,'bandpass'); %bandpass filter transfer funciton coeffs

angledata_filtered = filtfilt(b,a,angledata);

hilb = hilbert(angledata_filtered);
envelope = abs(hilb);

tremorscore = mean(envelope)

fprintf('\nThe tremor score for %s %s in %s sensor is %f\n',filename, tasklist{tasknum},sensorlist{sensornum},tremorscore);

%%
function output = morletConvolutionPlot(input,fs,t) % This code performs morlet convolution and outputs a plot of the results.
%% Parameters
num_frex = 40; %number of convolutions to run
min_freq =  .5;
max_freq = 50;
range_cycles = [ 4 10 ]; % sets wavelet width range
signaltime = t;
signal = input;
%% I NEED TO MAKE SuRE I SEGMENT TIME 
wavelettime = -2:1/fs:2;
frex = linspace(min_freq,max_freq,num_frex);
nCycles = logspace(log10(range_cycles(1)),log10(range_cycles(end)),num_frex);
half_wave = (length(wavelettime)-1)/2;
nKern = length(wavelettime);
nData = length(signaltime);
nConv = nKern+nData-1;
%% Morlet convolution via frequency-domain multiplication

tf = zeros(length(frex),length(signaltime)); %initialize output matrix
dataX = fft(signal,nConv); %FFT the real signal

for fi=1:length(frex)
    
    % create wavelet and get its FFT
    s = nCycles(fi)/(2*pi*frex(fi));
    cmw = exp(2*1i*pi*frex(fi).*wavelettime) .* exp(-wavelettime.^2./(2*s^2));
    
    cmwX = fft(cmw,nConv);
    cmwX = cmwX ./ max(cmwX);
    
    % run convolution
    as = ifft(cmwX.*dataX); %analytic signal
    as = as(half_wave+1:end-half_wave); %trim
    
    % put power data into big matrix
    tf(fi,:) = abs(as).^2;
end


%% NORMALIZATION NOW INCLUDED
% means = mean(tf,1);
% tf = tf ./ means;
%% plotting
figure;
contourf(signaltime(1:end),frex,tf(:,1:end),60,'linecolor','none')
set(gca,'ydir','normal','yscale','log','ytick',ceil(logspace(log10(1),log10(num_frex),8)));
xlabel('Time (s)'), ylabel('Frequency (Hz)');
maxval = max(max(tf));


end