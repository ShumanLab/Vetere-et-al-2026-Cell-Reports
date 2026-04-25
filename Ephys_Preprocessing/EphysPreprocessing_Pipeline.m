%% Preprocess Data

%Run one animal's data through this pipeline at a time 

%Input = directory containing full recording data from a single animal. 
%This should consist of raw intan files where each file contains one
%minute of data from all channels.

%Output = an experiment directory for this animal/recording with subfolders containing
%raw LFP data for each channel, downsampled (1000Hz) data, as well as data filtered for different
%frequencies, and background subtracted data for spike sorting.
%This version of the pipeline has been modified to include a notch filter
%step. 

%Optional sections at the end for generating plots to aid in
%identifying channel locations.

%% set animal/recording identifier info 
%select data directory
data_dir = uigetdir;

animal='AD-WT-1-0';  %replace with your animal name
experiment='3xTgAD'; %experiment name
datei='190820';      %date of recording
filename='Recording';%name to give folder 

fileindex=[animal '*.rhd'];

%% create/set experiment directory (exp_dir)

%make directory for processed files 
exp_dir=['H:\data analysis\' experiment '\' animal '\' datei '\' filename '\'];

if exist(exp_dir)==0
mkdir(exp_dir)
end

edit get_exp  %add directory for animal to this file/script manually

%% set directory and parameters
exp_dir=get_exp(animal);  %get directory path

probetype='ECHIP512';
numchans=512;

%save parameters
exp.animal=animal;
exp.experiment=experiment;
exp.datei=datei;
exp.filename=filename;
exp.fileindex=fileindex;
exp.exp_dir=exp_dir;
exp.data_dir=data_dir;
exp.badchannels=badchannels;
exp.probetype=probetype;
exp.numchans=numchans;

save([exp_dir 'exp.mat'],'-struct', 'exp');

%% save full data by channel
parfor shank=1:8
SaveEachChannel(animal,shank, data_dir) %saves each channel and stimuli into mat files in exp_dir
end

%% get downsampled LFP
srate=25000; %full sampling rate 
DownsampleRecordingTo1000Hz(animal, srate, numchans) %generate LFP files downsampled to 1000Hz - used for LFP analysis 

%% create background subtracted data
BackgroundSubtraction(animal, probetype); %used for single unit analysis 

%% notch filter 
animals = {animal};
clean60hznoise_LV(animals, numchans)  %takes a cell array of animal names - can loop through multiple animals 

%%
% generate filtered data for various frequency bands 
filters={'theta' 'gamma' 'ripple' 'slow_gamma' 'fast_gamma' 'fastripple' 'beta' 'theta_fastgamma'}; %filters with these names have been pre-generated
refchannels=[64 64 64 64 64 64 64 64]; 
numloops=1000;

filt_dir = 'Z:\Lauren\Paper\Vetere2025_code\LFP\Filters\'; %folder where filter files are located

for filt=1:length(filters)
    filtertype=filters{filt};
    FilterOnly_P_notch(animal, filtertype, numchans, filt_dir);  %save filtered LFP files to LFP/filtertype subfolders 
end

%% Identifying channel locations

%The following code was only used in this experiment for generating plots
%to identify channel locations. Some code may be outdated or redundant. 

% get running times, non running times -
binsize = 0.1; %binsize = 0.1 seconds 
VRstatearraysNEW(animal, binsize);  
getruntimes(animal, binsize); %makes run_times from running bins made in VRstatearraysNEW - 

state='running'; %only running bouts >3s in length will be used by subsequent scripts 

filters={'theta' 'gamma' 'ripple' 'slow_gamma' 'fast_gamma' 'fastripple' 'beta' 'theta_fastgamma'};

for filt=1:length(filters)
    filtertype=filters{filt};
       [LFP128, PX]=power128byshank2(animal, filtertype,probetype);  %generates 128power.mat
       [phasedev3, stddev]=LFPphasedev_running(animal,filtertype, refchannels, numloops);  %takes 128power.mat and makes phasedevrunning
       PowerByChannel(animal, state, filtertype, probetype); %loads LFPvoltage_ch_filtertype and makes powerbychannel for each filter
end

time=0;
parfor shank=1:8
extractLFP2_restricttime_notch(animal,probetype,shank,time) %takes LFP1000 data and makes shank_LFP files
end

%make a coherence matrix - plot to see layers
CoherenceMatByAnimal %takes shank_LFP files and creates CoherenceALLchannels_matrix_shank files

PlotBehavior(animal) %Plot running, licking, position, reward delivery

filters={'theta' 'gamma' 'ripple' 'slow_gamma' 'fast_gamma' 'fastripple' 'beta'};
plotlayers(animal, probetype, filters)  %Make plots of power at various frequencies across the length of a shank
plotcoherence(animal,probe) %Make heatmaps of coherence across pairs of channels along a shank

t0 = 10;
t1 = 18;
PlotChannelsToGetLayers(t0, t1) %plot a few seconds of data between t0 and t1 seconds to look at 
%spikes, phase shift, coherence in a few seconds of data
%Running this will prompt the user to select a raw intan data file to use 

%%%%%



