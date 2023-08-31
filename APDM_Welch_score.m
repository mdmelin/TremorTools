function [PeakAmp,PeakFreq,halfBandwidth] = APDM_Welch_score(datadir,subject,timepoint,taskname,sensor,padvec,windowDuration)
% Implementation of TremorSpectrum.m (from Elble et al 2016)

%--------------------------------------------------------------------------
% Constants
nTimesSpectrogram = 500;                               % Number of points (approximately) to plot for the spectrogram
nFFTMinimum       = 2^12;                              % Minimum number of points to calculate the FFT with zero padding
frequencyRange    = [0 20];                            % Frequency range to display (Hz)
frequencySearch   = [3.8 10];                            % Frequency range to search for peak

datatype = 'rawgyro';
%--------------------------------------------------------------------------


sensordata = getSensorData(datadir,subject,timepoint,taskname,sensor);
X = sensordata.(datatype);
t = sensordata.time;

%optionally chop off beginning and end of recording
samplestograb = find(t >= padvec(1) & t <= (t(end) - padvec(2)));
t = t(samplestograb);
X = X(:,samplestograb)';

fs = 1 / mean(diff(t)); %constant, should be 128 for APDM sensors
nyquist = fs/2;


N = size(X,1); % Number of samples in the recording
L = min(N,round(fs*windowDuration)); % Number of samples in the data window

% If the number of samples is less than 10 or there is an invalid
% segment duration or sample rate, do not try to update the display
if N<10 || windowDuration<=0 || isnan(windowDuration) || fs<0 || isnan(fs)
    return;
end

recordingDuration = N/fs;

dataWindow = window(@hamming,L);
nPad = max(nFFTMinimum,2^nextpow2(L));

%--------------------------------------------------------------------------
% Compute PSD or Spectrogram
%--------------------------------------------------------------------------
nChannels = size(X,2);

% Use Welch's method to estimate the PSD from the detrended data with
% 75% overlap. This is done separately for each channel to be
% compatible with earlier versions of Matlab.
for cChannel=1:nChannels
    [p,f] = pwelch(detrend(X(:,cChannel)),dataWindow,round(L*0.75),nPad,fs,'power');
    p = (p*2).^(1/2); %convert to ASD
    if cChannel==1
        P = p;
    else
        P = [P p];
    end
end                                     % Combine all three PSD estiamtes into one matrix

asd = sum(P.^2,2).^(1/2); %Amplitude spectrum for all 3 dimensions


PeakAmp  = max(asd(f>frequencySearch(1) & f<frequencySearch(2))); % find peak amplitude and frequency of the resultant amplitude spectrum
PeakFreq = f(find(asd==PeakAmp));
%%
asd_small = asd(f>frequencySearch(1) & f<frequencySearch(2)); %restrict to freq search range
f_small = f(f>frequencySearch(1) & f<frequencySearch(2));

%%
isHalfMax = ~(asd < .707*PeakAmp);
peakIndex = find(asd==PeakAmp);
switches = find(diff(isHalfMax) == -1 | diff(isHalfMax) == 1); %find indices passing above and below halfmax
if switches(1) > peakIndex
    lo_ind = 1; hi_ind = switches(1);
else
    less_than_max = find(switches < peakIndex);
    lo_ind = switches(less_than_max(end));
    more_than_max = find(switches > peakIndex);
    hi_ind = switches(more_than_max(1));
end


halfBandwidth = f(hi_ind) - f(lo_ind);

figure;
plot(f,asd); hold on;
xlim(frequencyRange);
xline(f(lo_ind));xline(f(hi_ind));
xlabel('Frequency (Hz)')
ylabel('Amplitude Spectrum')
set(gca,'Visible','On');


end
