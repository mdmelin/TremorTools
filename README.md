

# TremorTools
MATLAB tools for APDM and WACOM based quantification of body tremors.

## Description

This repo contains tools for reformatting and preprocessing APDM and Wacom data. It also contains some analysis code to compare tremor before and after MRgFUS treatment for essential tremor patients. 

## Getting Started


### Dependencies

This code was developed with MATLAB R2021a and requires the Signal Processing and Wavelet toolboxes. 

### Installing

To copy and use this repository locally, run 
```
git clone git@github.com:mdmelin/TremorTools.git 
```
in the desired folder for download.

### Preprocessing
Only run once per subject visit. The output of these functions gets saved to .mat files that are called by later functions. 
#### APDM data

The APDM software outputs multiple .h5 files (one for each task that was run). To assemble this data into one .mat file per subject visit (and to do some light preprocessing), run APDM_reformat_preprocess.m, or preprocess_multiple_subjects.m if you would like to do this for multiple subject visits. Here is example of how to reformat and preprocess one subject. 

```
datadir = 'Z:\Data\FUS_Gait\'; %path to data server, this should not need changing.
savedir = 'Z:\Data\FUS_Gait\APDMpreprocessed'; %where to put the preprocessed data
subject = 'FUS008';
timepoint = 'pre'; %pre or post depending on visit

APDM_reformat_preprocess(datadir,savedir,subject,timepoint)
```
This script should only be run one time for each subject visit. The results are saved as .mat files and can be used by all subsequent analysis code. Though some preprocessed results are outputted by the above function, all raw APDM data is also saved to the .mat files.  
#### Wacom tablet data
Coming soon.
### Computing tremor scores
#### APDM data
APDM tremor scores can be computed a variety of ways for each task. Call
```
APDM_parse_subjects(datadir,taskname,timepoint)
```
to get a list of subjects that have data for the desired task and visit day. The list of possible tasknames is shown below.
```
'resting' - the resting task
'headtrunk' - sitting upright postural task
'llegpost' - left leg held out
'rlegpost' - right leg held out
'llegact' - left leg floor to finger
'rlegact' - right leg floor to finger
'llegact2' - left leg floor to finger, slow
'rlegact2' - right leg floor to finger, slow
'armsextended' - arms extended postural tremor
'wingbeat' - wingbeat pose
'larmact' - left arm finger to nose
'rarmact' - right arm finger to nose
'rarmact2' - left arm finger to nose, slow
'larmact2' - right arm finger to nose, slow
```
The possible timepoints are:
```
'pre' - pre-op visit
'post' - post-op visit
```
The sensor names are:
```
'RightWrist'
'LeftWrist'
'RightHand'
'LeftHand'
'RightUpperArm'
'LeftUpperArm'
'RightFood'
'LeftFoot'
'Lumbar'
'Sternum'
```
Importantly, not all sensors are present for all tasks. We only have six sensors and they are moved around depending on the task, but the preprocessing/reformatting function takes care of all this renaming. 

The .mat files for each visit contain a MATLAB struct of the form output.[task].[sensor]. So data from the RightHand sensor for the wingbeat task will be found under output.wingbeat.RightHand. 

Once you know which subjects have data, we can compute tremor in a variety of ways. For now, we are using a combination of PCA and the Hilbert transform to extract tremor relevant movement. In brief, x/y/z gyroscope data is integrated to convert rads/s to rads for each dimension. We then run PCA on these three dimensions and use the first component as our movement signal for analysis. This signal is bandpassed from 4-11Hz and then the Hilbert transform is used to compute the envelope of this signal. The average value of the envelope is the tremor index (TI). Here is an example of how one would compute the right hand sensor tremor scores for several subjects during the wingbeat task. **Pay close attention to handedness when calling this function (in reality, we would not want to just grab the RightHand sensor from every single subject, since we expect to see improvements primarily contralateral to the FUS ablation).** In the future, I will include a function to automatically get the subject handedness and procedure side, but for now it needs to be found on the excel sheet and passed as an input. 
```
datadir = 'Z:\Data\FUS_Gait\APDMpreprocessed';
taskname = 'wingbeat';

subjectspre = APDM_parse_subjects(datadir,taskname,'pre'); %get subjects with preop data for the desired task
subjectspost = APDM_parse_subjects(datadir,taskname,'post'); %get subjects with postop data for the desired task

subjects = intersect(subjectspre,subjectspost); %only get subjects that have pre and post data for the desired task

for i = 1:length(subjects)
    [tremor_index_pre(i),~] = APDM_PCA_tremor_score(datadir,subjects{i},'pre',taskname,'RightHand',1,[0 0]);
    [tremor_index_post(i),~] = APDM_PCA_tremor_score(datadir,subjects{i},'post',taskname,'RightHand',1,[0 0]);
end
```
This script above is also saved as APDM_tutorial.m if you would just like to run that. 
#### Wacom tablet data
Coming soon.

## License

This project is licensed under the MIT  License - see the LICENSE.md file for details
