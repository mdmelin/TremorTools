function sensordata = getSensorData(datadir,subject,timepoint,taskname,sensor)
filename = [subject timepoint '_preprocessed'];
load([datadir filesep filename]);

availible_tasks = fields(output);
if ~ismember(taskname, availible_tasks)
    fprintf('There is no %s task for subject %s%s\n',taskname,subject,timepoint);
    sensordata = {};
    return
end

availible_sensors = fields(output.(taskname));

if ismember(sensor,availible_sensors)
    sensordata = output.(taskname).(sensor);
else
    fprintf('There is no %s sensordata for %s task\n',sensor,taskname);
    sensordata = {};
end
end