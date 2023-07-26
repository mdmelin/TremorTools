function sensors = getTaskSensors(task)
task_set_a = {'resting','headtrunk','llegpost','rlegpost','llegact','rlegact','llegact2','rlegact2'};
task_set_b = {'armsextended','wingbeat','larmact','rarmact','rarmact2','larmact2'};

if ismember(task, task_set_a)
    sensors = {'RightWrist','LeftWrist','RightFoot','LeftFoot','Lumbar','Sternum'};
elseif ismember(task, task_set_b)
    sensors = {'RightWrist','LeftWrist','RightHand','LeftHand','RightUpperArm','LeftUpperArm'};
end
end