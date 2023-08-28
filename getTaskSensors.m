function sensors = getTaskSensors(task)
task_set_a = {'resting','headtrunk','ipsilegpost','contralegpost','ipsilegact','contralegact','ipsilegact2','contralegact2'};
task_set_b = {'armsextended','wingbeat','ipsiarmact','contraarmact','contraarmact2','ipsiarmact2'};

if ismember(task, task_set_a)
    sensors = {'IpsiWrist','IpsiFoot','ContraWrist','ContraFoot','Lumbar','Sternum'};
elseif ismember(task, task_set_b)
    sensors = {'IpsiWrist','IpsiHand','IpsiUpperArm','ContraWrist','ContraHand','ContraUpperArm'};
end
end