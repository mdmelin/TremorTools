%plots a time-frequency spectrogram via Morlet wavelet convolution -
%specified by min_freq, max_freq, and evenly spaced with num_frex. Morle
%wavelet convolution is done via frequency domain multiplication. 

%DO NOT USE, THIS FUNCTION IS CURRENTLY BROKEN

function output = morletConvolutionPlot(input,fs,t,num_frex,min_freq,max_freq,waveletwidth,numlevels,normalize,clim) % This code performs morlet convolution and outputs a plot of the results.
%% Parameters
%num_frex = 40; %number of convolutions to run
%min_freq =  .5; minimum frequency
%max_freq = 50; maximum frequency
range_cycles = [ 3 10 ]; % sets wavelet width range
%clim = 15;
signaltime = t;
signal = input;
%% I NEED TO MAKE SURE I SEGMENT TIME 
wavelettime = -waveletwidth/2/fs:1/fs:waveletwidth/2/fs; %waveletwidth is the width of the wavelet in frames
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
    cmwX = cmwX ./ max(cmwX); %preserve units
    
    % run convolution
    as = ifft(cmwX.*dataX'); %analytic signal
    as = as(half_wave+1:end-half_wave); %trim
    
    % put power data into big matrix
    tf(fi,:) = abs(as).^2;
end


%% NORMALIZATION NOW INCLUDED
if normalize == "True"
%      means = mean(tf,2);
%      tf = tf ./ means;
     means = mean(tf,2);
     tf = 10*log10(tf ./ means);
end
%% plotting
figure;
contourf(signaltime(1:end),frex,tf(:,1:end),numlevels,'linecolor','none')
set(gca,'ydir','normal','yscale','log','ytick',ceil(logspace(log10(frex(1)),log10(frex(end)),8)));
xlabel('Time (s)'), ylabel('Frequency (Hz,log scale)');
caxis(clim);
c = colorbar;
c.Label.String = 'dB change from mean';
maxval = max(max(tf));


end