function sensordata = getSensorData(datadir,subject,timepoint,taskname,sensor)
filename = [subject timepoint '_preprocessed'];
load([datadir filesep filename]);
sensordata = output.(taskname).(sensor);
end