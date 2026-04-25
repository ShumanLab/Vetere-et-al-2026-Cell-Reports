%%Post Processing - LFP Data 

%Once data is pre-processed for all animals, channel assignments have been
%manually checked and input into a spreadsheet, and start and end times of
%desired analysis windows have been set (excluding any obvious issues or
%artifacts that occurred on recording day) - these next steps can be run
%for all animals

%Inputs/Requirements: Preproccessed data in experiment directories for all animals
%Spreadsheets with channel assignments, and spreadsheet with start and end times of usable time
%windows and channel set to use for each window.
%Script containing info for best shank(s) for each animal.

%Outputs: Data used for main LFP Analyses - see each section for more details 
%Power, Coherence, CSD, and Frequency 

%Create a cell array with all animal IDs 
animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' '3xTg123' '3xTg132' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-44-1' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2' 'WT159' 'WT105-0' 'WT69-1' 'WT181' 'WT173' '3xTg165' '3xTg177' '3xTg148-1'};


%% find bad channels
out_dir = 'W:\data analysis';
find_bad_ch_batch(animals, out_dir) %generates bad_chans_table.mat file with bad channels by shank for all animals 

%% Power

out_dir = 'W:\data analysis';

% animals for EC
%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' '3xTg1-2'};
% % %rm WT44-1 and 3x132 because no EC

% animals for hippocampus
animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' 'AD-WT-44-1' '3xTg132' '3xTg1-2'};
% 
% 
filters = {'theta' 'gamma' 'fast_gamma' 'slow_gamma' 'ripple' 'fastripple'}; 
region =  'HIPP'; %or MEC
tracks = {'A'}; %A track, all instances  (options = A1, B1, A2, B2 etc, A,
% %%B, all)
out_dir = 'W:\data analysis';

Power_by_layer_drift(animals, filters, tracks, region, out_dir)

% plotexample_LFPs(animal)  %for example animal data visualization only - 1
% second of data plotted for each layer 

%% Coherence

animals = {}; %cell array of animal IDs 
%animals for hippocampus
%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};
%animals for MEC 
%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' '3xTg1-2'};

filters = {'theta' 'fast_gamma' 'slow_gamma'}; %which filters to analyze 
tracks = {'A'}; %which tracks to analyze (A = all times on familiar A track, B = novel track) 
seg = 1;  %desired time bins in seconds
run_states =  {'runthresh'}; %{'runall' 'runthresh' 'nonrun' 'all' 'diff_runVSnon' 'diff_threshVSnon'}; %which running states to export data for 
out_dir = 'W:\data analysis'; %output where final summary files will go

overwrite = 1; 

Coherency_allregions_multi_drift(animals, seg, filters, tracks) %coherence calculations for all pairs of regions for each animal

%coherency_test_all_regions_multi_drift_bylyr_noweighting %should also work
%similarly - alternate method that doesn't use weighting to average across
%time windows of various lengths and doesn't need animal matrix 

coh_data_export_forR(animals, filters, run_states, seg, out_dir) %export results to a table containing data from all animals that can be imported to R


%% Current Source Density
animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' 'AD-WT-44-1' '3xTg132' '3xTg1-2'};
filters = {'theta'};
filter = 'theta';
region = 'HIPP';
out_dir = 'W:\data analysis';

CSD_bygroup(animals, filter, region) % wrapper function for pre_CSD, bz_eventCSD_lv. Saves data file for each animal and makes summary plots by group

export_CSD(animals, filters, region, out_dir) % export CSD summary data for each animal to a file for R to generate line plots for paper 

%animals = {'WT98-0', '3xTg77-1', '3xTg49-2', 'WT45-2'}
%plot_CSD_examplefigs(animals, filter, region) %generates clean CSD plots
%for a few example animals 


%% Power Spectral Density
track = 'A'; %restrict to familiar track 
freq_range = 'theta'; %restrict to theta freq 4-12Hz, or use 'wide' to do 1-100Hz
limitchans = 0; %use all channels in each layer (set to 1 to only use middle 2 chans in each layer) 
out_dir = 'W:\data analysis'; %where to save exported mat file 

%HIPPOCAMPUS
%all animals with hippocampus data
animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};
region = 'HIPP';
subregions = {'Or' 'Pyr' 'Rad' 'LM' 'Mol' 'Hil'};
for s=1:length(subregions)
    subregion = subregions{s};
    wavelet_PSD_LV_drift(animals, freq_range, region, subregion, track, limitchans, out_dir) 
end 

%MEC
% all animals with MEC data
animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' '3xTg1-2'};
region = 'MEC';
subregions = {'MEC2' 'MEC3'}; %using MEC2 for paper since a few animals are missing MEC3 data
for s=1:length(subregions)
    subregion = subregions{s};
    wavelet_PSD_LV_drift(animals, freq_range, region, subregion, track, limitchans, out_dir) 
end 
