

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
There is also an example script for APDM preprocessing in the ```examples``` folder.
#### Wacom tablet data
Occasionally, the wacom collection program was run twice, if any data was accidentally not collected on the first go. The preprocessing script for Wacom data asks the user to merge thes files (if more than one exist) into a combined output. There is an example of Wacom preprocessing found in the ```examples``` folder.
### Computing tremor scores
This step can only be done after the initial preprocessing (described above).
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

Once you know which subjects have data, we can compute tremor in a variety of ways. For now, we are using a combination of PCA and the Hilbert transform to extract tremor relevant movement. In brief, x/y/z gyroscope data is integrated to convert rads/s to rads for each dimension. We then run PCA on these three dimensions and use the first component as our movement signal for analysis. This signal is bandpassed from 4-11Hz and then the Hilbert transform is used to compute the envelope of this signal. The average value of the envelope is the tremor index (TI).

Look in the ```examples``` folder for an example of how to compute tremor scores and plot them from the APDM data.
#### Wacom tablet data
We are computing the tremor scores for wacom data in a manner somewhat similar to the APDM data. Currently, this is being handled by ```WACOM_euclid_norm_tremor_score.m```. This script requires a subject ID, timepoint, and task. Subject ID and timepoint are as described above.

For Wacom data, the possible tasknames are:
```
'write' - handwriting, always with dominant hand
'spiralBig_R' -  large spirals, right hand
'spiralSmall_R' - small spirals, right hand
'lineBig_R' - stay between large lines, right hand
'lineSmall_R' - stay between small lines, right hand 
'spiralBig_L' - large spirals, left hand
'spiralSmall_L' - small spirals, left hand
'lineBig_L' - stay between large lines, left hand
'lineSmall_L' - stay between small lines, left hand
'reach_R' - hold pen floating above target, right hand
'reach_L' - hold pen floating above target, left hand
```
Importantly, most tasks are run more than once. ```WACOM_euclid_norm_tremor_score.m``` will return the tremor score for every time the task was run (ie. 3 values if a particular task was run 3 times).
Look in the ```examples``` folder for an example of how to compute tremor scores and plot them from the WACOM data.

## License

This project is licensed under the MIT  License - see the LICENSE.md file for details
