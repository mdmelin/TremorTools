function [peak_amps,peak_freqs,half_bandwidths] = WACOM_Welch_score_at_freq(datapath, subject, timepoint, taskname, windowDuration, target_freq)
%Personal implementation of TabletSpectrum.m (from Elble et al 2016)

frequencySearch   = [3.8 10];                            % Frequency range to search for peak
%datapath
%subject
%timepoint

% fetch the data
task_data = load([datapath filesep subject timepoint '.mat']);
task_index = find(strcmp(task_data.cond,taskname));

peak_amps = []; peak_freqs = []; half_bandwidths = [];
for i = 1:length(task_index) %there are multiple trials for one type of task
    signals = task_data.penvals{1,task_index(i)};
    times = task_data.t{1,task_index(i)};
    numstrokes = length(task_data); %each trial may have multiple strokes

    %x = task_data{j}(:,1);

    signals = cat(1,signals{:}); % concatenate strokes together

    time = cat(2,times{:});

    if size(signals,1)<10
        fprintf('Not enough samples in this task for analysis\n');
        continue;
    end

    signals=signals(:,1:3); % [x,y,pressure]

    signals = signals - mean(signals,1);
    [x,time_resamp,fs_resample] = resample_and_filter(signals(:,1),time);
    [y,~,~] = resample_and_filter(signals(:,2),time);
    [pen,~,~] = resample_and_filter(signals(:,3),time);

    N = length(x);
    L = round(fs_resample*windowDuration);
    L = min(N-1,L);

    FreqRes = fs_resample/L; %   frequency resolution of FFT without zero padding

    % Now perform zero padding, if necessary, to achieve a frequency resolution of at least
    % 0.01 Hz.
    if FreqRes > 0.01
        nfft = 2^nextpow2((FreqRes/0.01)*L);
    else
        nfft = 2^nextpow2(L);
    end

    %   Hanning window with 50% overlapping segments (Welch's method.
    %   IEEE Trans Audio and Electroacoust. 1967;AU-15:70-3)
    dataWindow = hanning(L);
    [px,f] = pwelch(x,dataWindow,round(L*0.75),nfft,fs_resample,'power');
    [py,f] = pwelch(y,dataWindow,round(L*0.75),nfft,fs_resample,'power');
    [pp,f] = pwelch(pen,dataWindow,round(L*0.75),nfft,fs_resample,'power');
    px = (px*2).^(1/2);
    py = (py*2).^(1/2);
    pp = (pp*2).^(1/2);

    p = (px.^2 + py.^2).^(1/2); % XY amplitude

    asd_small = p(f>frequencySearch(1) & f<frequencySearch(2)); %restrict to freq search range
    f_small = f(f>frequencySearch(1) & f<frequencySearch(2));

    %% find peaks
    [amps,locs,w,p] = findpeaks(asd_small);
    [~, closest_peak_ind] = min(abs(f_small(locs) - target_freq));

    PeakAmp = amps(closest_peak_ind);
    PeakFreq = f_small(locs(closest_peak_ind));

    %     figure;
    %     plot(f,p); hold on;
    %     xlim([0,20]);
    %     xline(f(lo_ind));xline(f(hi_ind));
    %     xlabel('Frequency (Hz)')
    %     ylabel('Amplitude Spectrum')
    %     set(gca,'Visible','On');

    peak_amps = [peak_amps PeakAmp];
    peak_freqs = [peak_freqs PeakFreq];
    %half_bandwidths = [half_bandwidths halfBandwidth];

end
end



function [x,time,fs_resample] = resample_and_filter(x,time)
PADLENGTH = 200; %NEED to pad before resampling and filtering signal

fs_resample = floor(1 / mean(diff(time)));

if fs_resample <= 18*2 % enforce minimum fs so bandpass filter works
    fs_resample = 18.01*2;
end
fnyquist = fs_resample / 2;

timevec = linspace(0,PADLENGTH/fs_resample,PADLENGTH);
padded_time = [timevec + time(1) - (timevec(end)-timevec(1)) - 1/fs_resample, time, timevec + time(end) + 1/fs_resample];
x_end = zeros(1,PADLENGTH);x_end(:) = x(end);
padded_x = [zeros(1,PADLENGTH),x',x_end];

[x,time] = resample(padded_x, padded_time, fs_resample);


[b,a] = butter(2,[.5 18]./fnyquist,'bandpass'); %bandpass filter transfer funciton coeffs
xfilt = filtfilt(b,a,x);
xfilt = detrend(xfilt);

bb = remez(20,[0 .9],[0 0.9*pi*fs_resample],'d');
x = filter(bb,1,xfilt);		% velocity
x = x(PADLENGTH+1:end-PADLENGTH-1); % now that filtering is done, chop off the pad
time = time(PADLENGTH+1:end-PADLENGTH-1); % now that filtering is done, chop off the pad

end