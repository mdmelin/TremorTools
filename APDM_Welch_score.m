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
if isempty(sensordata)
    PeakAmp = NaN; PeakFreq = NaN; halfBandwidth = NaN;
    return
end
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

asd_small = asd(f>frequencySearch(1) & f<frequencySearch(2)); %restrict to freq search range
f_small = f(f>frequencySearch(1) & f<frequencySearch(2));

[amps,locs,w,p] = findpeaks(asd_small);

halfBandwidth = [];
for i=1:length(locs)
    isHalfMax = ~(asd_small < .707*amps(i));
    %figure;hold on;plot(asd_small);plot(isHalfMax);
    halfmax_f = f_small(isHalfMax);
    halfBandwidth = [halfBandwidth, halfmax_f(end) - halfmax_f(1)];
end
valid_tremor_peaks = f_small(locs) > 3.7 & f_small(locs) < 10 & halfBandwidth' < 2;

PeakAmp = amps(valid_tremor_peaks);
PeakFreq = f_small(locs(valid_tremor_peaks));
halfBandwidth = halfBandwidth(valid_tremor_peaks);

if sum(valid_tremor_peaks) == 0
    PeakAmp = NaN;
    PeakFreq = NaN;
    halfBandwidth = NaN;
else
    [~,biggest_peak] = max(PeakAmp);
    PeakAmp = PeakAmp(biggest_peak);
    PeakFreq = PeakFreq(biggest_peak);
    halfBandwidth = halfBandwidth(biggest_peak);
end



% figure;
% plot(f,asd); hold on;
% xlim(frequencyRange);
% xline(f(lo_ind));xline(f(hi_ind));
% xlabel('Frequency (Hz)')
% ylabel('Amplitude Spectrum')
% set(gca,'Visible','On');


end
