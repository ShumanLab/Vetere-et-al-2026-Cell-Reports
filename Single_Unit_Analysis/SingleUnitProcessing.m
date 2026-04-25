%Single Unit Data Analysis 

%% Generate Binary Files for Kilosort
%See Kilosort Protocol in google drive for info about workflow and how to
%install kilosort - some information may be out of date.
%LV used Kilosort 2.5 for all analysis, others in the lab may have tested
%later versions. 

%Manually decide what shanks you want to use and what time range from t0 to
%t1 (in seconds) you want to use for each animal, then run the function
%below to generate a binary file in int16 format for each shank that can be imported into Kilosort
animal = ' '; 
t0 = 0 ;
t1 = ;
out_dir = 'W:\data analysis\';
shanks = {1, 4, 6}; %choose 1-8
% % set t0 and t1 to 0 to use full time 
% % This version uses background subtracted data files 
% % Name of output file should contain backsubfile_binary, other files can
% % be deleted 
KilosortFormat_LV(animal,t0, t1, shanks, out_dir)

%% PLEASE READ - Notes on Kilosort and Phy 
%Step 2: Run all files through Kilosort. 
%See Kilosort Notes and spike sorting log in google drive for info about parameters used, bad channels
%and any errors encountered 
%Probe map to use for kilosort is called '256AchanMap_SF.mat'
%number of channels = 64, sampling freq = 25000, time range = 0 Inf, N
%blocks = 4, Threshold = 10 5, Lambda = 10, AUC = 0.85
%Kilosort was adapted slightly to avoid error in Matlab 2017a. KS2.5 uses
%the makima interpolation method which is only available in Matlab2020b so
%I changed from makima to linear interpolation. 
%LV ran Kilosort from LV's PC - can't run on Diamond 

%Step 3: Manually curate in Phy
%See Phy protocol in google drive for full instructions.

%Step 4: Kilosort alters the way it numbers channels if some channels are
%labeled as bad so we needed to fix the channel numbers in the Phy output.
%SF wrote something to do this in Python. See channel_map_LV_082820224.csv
%???

%% Exporting data from Phy
animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};
kilosort_dir = 'Z:\Lauren\Ephys Experiments\Kilosort\'; %folder on csstorage where phy
%files are located - 
%note - changing file paths to any of these folders/subfolders after you
%have begun spike sorting a file will make Phy glitch

PhyOutput_LV(animals, kilosort_dir) %generates cells.mat file for each shank 

%% Calculating firing rate, phase locking etc. 
kilosort_dir = 'Z:\Lauren\Ephys Experiments\Kilosort\'; %folder on csstorage where phy files are located 
%metadata_dir = 'Z:\Lauren\Paper\Vetere2025_code\Metadata'; %location of other files/sheets referenced in analysis 
animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};
out_dir = 'W:\data analysis';

FilterSpikes_PAP_LV(animals)  %generate high pass filtered versions of background subtracted data files. These files are used in TSprocessspikes to pull out waveforms of spikes.

TSprocessSpikes_LV_full_batch_allAtrack(animals, kilosort_dir)

%added to do additional phase locking calculations to theta referenced in
%other hippocampal layers
TSprocessSpikes_LV_PLtoLM_Mol_Hil_allAtrack(animals, kilosort_dir)

overwrite = 0; %Set to 1 if you want these last two scripts to regenerate output csv data files rather than just plotting
%Clustering and plotting phase locking polar plots for excitatory and inhibitory
%neurons in CA1, DG, MEC2, MEC3 

animals = { 'AD-WT-44-1', '3xTg132', '3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' '3xTg123' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2' 'WT159' 'WT105-0' 'WT69-1' 'WT181' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' };
HIPP_SpikeProcessing_LV_all_2023_V3_Aonly(animals, kilosort_dir, out_dir, overwrite)

animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' '3xTg123' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2' 'WT159' 'WT105-0' 'WT69-1' 'WT181' 'WT173' '3xTg165' '3xTg177' '3xTg148-1'};
MEC_SpikeProcessing_LV_all_2023_V3_Aonly(animals, kilosort_dir, out_dir, overwrite)

%% Plot example waveforms for visualization purposes
% animal = 'WT126' ;
% shank = 3;
% region = 'HIPP';
% subregion = 'DG';
% celltype = 'i';
kilosort_dir = 'Z:\Lauren\Ephys Experiments\Kilosort\'; %folder on csstorage where phy files are located 

PlotExampleWaveforms(animal, shank, region, subregion, celltype, kilosort_dir)
%% Plotting example phase locking distributions
% animal = 'WT45-2'; %8wt ***
% lfpregion = 'HIPP';
% subregion = 'MEC3';
% celltype = 'e';
% cluster = 8;  %number cluster within given animal, celltype, subregion 
% rval = 0.315;

% animal = '3xTg125'; %83x 
% lfpregion = 'HIPP';
% subregion = 'MEC3';
% celltype = 'e';
% cluster = 4;   %4-7 %number cluster within given animal, celltype, subregion 
% rval = 0.112 ;

kilosort_dir = 'Z:\Lauren\Ephys Experiments\Kilosort\'; %folder on csstorage where phy files are located 

phaselock_vis_drift(animal, lfpregion, subregion, celltype, cluster, rval, kilosort_dir)

%% Supplemental Phase Locking Plots By Group

animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' '3xTg123' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2' 'WT159' 'WT105-0' 'WT69-1' 'WT181' 'WT173' '3xTg165' '3xTg177' '3xTg148-1'};
lfpregion = 'HIPP';
subregion = 'MEC3';
out_dir = 'W:\data analysis';  

kilosort_dir = 'Z:\Lauren\Ephys Experiments\Kilosort\'; %folder on csstorage where phy files are located 

%Excitatory units
celltype = 'e';
phaselock_vis_bygroup_drift(animals, lfpregion, subregion, celltype, kilosort_dir)
%Export to R to run stats
phaselock_vis_bygroup_drift_export2R(animals, lfpregion, subregion, celltype, kilosort_dir, out_dir)

%Inhibitory units
celltype = 'i';
phaselock_vis_bygroup_drift(animals, lfpregion, subregion, celltype, kilosort_dir)
%Export to R to run stats
phaselock_vis_bygroup_drift_export2R(animals, lfpregion, subregion, celltype, kilosort_dir, out_dir)

