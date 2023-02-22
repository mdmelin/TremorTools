function [scores, concatenated_datas] = WACOM_euclid_norm_tremor_score(datapath, subject, timepoint, taskname)

PADLENGTH = 50; %NEED to pad before resampling signal
fs_resample = 185;
fnyquist = fs_resample/2;
timevec = linspace(0,PADLENGTH/fs_resample,PADLENGTH);
data = load([datapath filesep subject timepoint '.mat']);
task_index = find(strcmp(data.cond,taskname));

%%
scores = [];concatenated_datas = {};
for i = 1:length(task_index) %there are multiple trials for one type of task
    task_data = data.penvals{1,task_index(i)};
    times = data.t{1,task_index(i)};
    numstrokes = length(task_data);
    concatenated_data = [];
    for j = 1:numstrokes
        singlestroke = task_data{j};
        time = times{j};
        x = singlestroke(:,1);
        y = singlestroke(:,2);
        x = x - x(1);
        y = y - y(1);
        padded_time = [timevec + time(1) - (timevec(end)-timevec(1)) - 1/fs_resample, time, timevec + time(end) + 1/fs_resample];
        y_end = zeros(1,PADLENGTH);y_end(:) = y(end);
        x_end = zeros(1,PADLENGTH);x_end(:) = x(end);
        padded_y = [zeros(1,PADLENGTH),y',y_end];
        padded_x = [zeros(1,PADLENGTH),x',x_end];
        [y2, Ty] = resample(padded_y,padded_time,fs_resample);
        [x2, Tx] = resample(padded_x,padded_time,fs_resample);

        if length(x2) > 24 %cant filter if stroke is too short, cannot just filter with strokes put together becuase there would be weird artifact from the position jumps
            [b,a] = butter(4,[4 11]./fnyquist,'bandpass'); %bandpass filter transfer funciton coeffs
            xfilt = filtfilt(b,a,x2);
            yfilt = filtfilt(b,a,y2);
            xenv = abs(hilbert(xfilt));
            yenv = abs(hilbert(yfilt));
            euclidean_norm = sqrt(xenv.^2 + yenv.^2);
            euclidean_norm = euclidean_norm((Ty >= time(1) & Ty <= time(end))); %recover the unpadded data
            concatenated_data = [concatenated_data; euclidean_norm'];
        end
    end
    concatenated_datas{i} = concatenated_data;
    scores(i) = mean(concatenated_data);
end
end