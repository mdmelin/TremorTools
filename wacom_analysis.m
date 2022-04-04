% THIS CODE IS DEPRACATED AND WILL SOON BE REMOVED. THERE IS ALSO A
% PROBLEM: the sampling rate of the wacom seems not to be constant. this
% may require resampling. 

clear all;close all;

subject = 'FUS0017'
timepoint = 'post'

savedir = 'Y:\Pouratian_lab\fus_data\Wacom'
loadpath = ['Z:\Data\FUS_Gait\',subject,'\',subject,'_',timepoint,'\Wacom Data\']
files = dir([loadpath '*.mat']);
{files(:).name}'
prompt = '\nselect file to import\n';
index = uint16(str2num(input(prompt,'s')));
%index = 1;
load([loadpath,files(index).name]);

fs = 63.223406339969756; %THIS IS NOT ACCURATE!!!! JUST PRETENDING FOR NOW
fnyquist = fs/2;
%%
fprintf('\n\nConditions\n');
for i = 1:length(cond)
    fprintf('%i: %s',i,cond{i})
    onetask = penvals{1,i};
    numstrokes = length(onetask);
    appendednormie = [];
    for j = 1:numstrokes
        singlestroke = onetask{j};
        x = singlestroke(:,1);
        y = singlestroke(:,2);
        
        if length(x) > 24 %cant filter if stroke is too short, cannot just filter with strokes put together becuase there would be weird artifact from the position jumps
            [b,a] = butter(4,[4 11]./fnyquist,'bandpass'); %bandpass filter transfer funciton coeffs
            xfilt = filtfilt(b,a,x);
            yfilt = filtfilt(b,a,y);
            xenv = abs(hilbert(xfilt));
            yenv = abs(hilbert(yfilt));
            normie = sqrt(xenv.^2 + yenv.^2);
            appendednormie = [appendednormie; normie];
        end
    end
    allconds{i} = appendednormie;
    fprintf(', num samplepoints = %i. ',length(appendednormie))
    fprintf('Mean tremor index = %f\n',mean(appendednormie));
end
%% now select trials to average from

r_allspiral_avging_inds = [2 3 6 7]; %the indices to average tremor amplitude over all right spirals
l_allspiral_avging_inds = [10 11 14 15]; %the indices to average tremor amplitude over all left spirals
numconds = length(r_allspiral_avging_inds);
hand = input('\nL or R hand?','s');
if hand == 'r'
    usedconds = allconds(1,r_allspiral_avging_inds);
elseif hand == 'l'
    usedconds = allconds(1,l_allspiral_avging_inds);
end
temp = cellfun(@isempty,usedconds);
if sum(temp) > 0
    fprintf('MISSING TRIALS!!!! terminating now...\n\n');
else
    for i = 1:numconds
        avgs(i) = mean(usedconds{i});
    end
    mean(avgs)
end

