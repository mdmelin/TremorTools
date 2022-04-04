
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

### Executing preprocessing
##### APDM Data

The APDM software outputs multiple .h5 files (one for each task that was run). To assemble this data into one .mat file per subject visit (and to do some light preprocessing), run APDM_reformat_preprocess.m, or preprocess_multiple_subjects.m if you would like to do this for multiple subject visits. Here is example of how to reformat and preprocess one subject. 

```
datadir = 'Z:\Data\FUS_Gait\'; %path to data server, this should not need changing.
savedir = 'Z:\Data\FUS_Gait\APDMpreprocessed'; %where to put the preprocessed data
subject = 'FUS008';
timepoint = 'pre'; %pre or post depending on visit

APDM_reformat_preprocess(datadir,savedir,subject,timepoint)
```
This script should only be run one time for each subject visit. The results are saved as .mat files and can be used by all subsequent analysis code. Though some preprocessed results are outputted by the above function, all raw APDM data is also saved to the .mat files.  
##### Wacom tablet data
Coming soon.


## License

This project is licensed under the MIT  License - see the LICENSE.md file for details
