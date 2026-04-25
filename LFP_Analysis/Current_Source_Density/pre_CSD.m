%This function is called within the CSD_bygroup function 
%Loads and formats an animal's data for CSD analysis

%Determines best column of 21 linear channels on the 64 channel silicon
%probe (by finding which column has the fewest bad channels). 

%Loads in LFP data + creates a time x channels matrix 

%Loads corresponding layer assignments for each channel and bad channels
%that will need to be removed/dealt with later in group analysis. 

%Finds "events" defined as theta trough times 
%Here I am restricting to theta trough times during running 

%Inputs: Animal ID, filter (currently using 'theta'), region = 'HIPP' or 
%'MEC'

%Outputs: %lfp data structured as time x channels (21), events = theta
%trough times during running within speed threshold, group, sex, and age
%information for later group analysis and export, channels_by_layer_csd = which channels are located in each layer
% remove_chans_csd = channel numbers corresponding to bad channels to exclude/deal with later. 

function [lfp, events, group, sex, age, channels_by_layer_csd, remove_chans_csd] = pre_CSD(animal,filter, region) 

load('bad_chans_table.mat');  %load in table with bad channels for each animal 1-64 for each shank
bad_chans = table2cell(bad_chans_table);

fs=1000;

    
if strcmp(animal,'3xTg1-2')  %load probe layout
load('ECHIP512_3xTg1-2.mat');              
else
load('ECHIP512.mat');     
end
        
exp_dir = get_exp(animal);
stim_dir=[exp_dir 'stimuli\'];

%get bad channels for this animal - all shanks
bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks

%get shanks for this animal
[HIPshank, ECshank]=getshankECHIP_LV(animal); %get HIP and EC shanks for this animal

if strcmp(region, 'HIPP')
    shank = HIPshank;
elseif strcmp(region, 'MEC')
    shank = ECshank;
end 

tracks = {'A'};
[anim_windows] = get_time_windows_drift(animal, tracks);

anim_windows = anim_windows(1, :);
set = anim_windows{1,5};
t0 = anim_windows{1,3};
t1 = anim_windows{1,4};

[ch] = getchannels_drift(animal, shank, set);
group = ch.group; 
sex = ch.sex;
age = ch.age;

run_speed = load([stim_dir 'running.mat']);
run_speed = downsample(run_speed.running,25); %maybe downsample even more - this is now 1000Hz 
run_bl = mode(run_speed);
runthresh_low = 0.1;
runthresh_high = 0.2;

%MAKE LFP MATRIX 
LFP =  load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(1) filter '.mat']); %load a channel just to get signal length
LFP = LFP.filt_data;
LFPsignals = zeros(length(LFP), 21);

%[HIPshank, ECshank]=getshankECHIP_LV(animal); %get HIP and EC shanks for this animal
%shank = HIPshank;
%bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
%bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks

bc_sh = bc{1}{shank}; %get bad channels for current shank  

%get single row of linear channels

% 3 options
channels1 = [3:3:64];
channels2 = [2:3:64];
channels3 = [4:3:64];

%find option with fewest bad channels

%count number of bad channels in each row
bc_set1 = nnz(ismember(bc_sh, channels1));
bc_set2 = nnz(ismember(bc_sh, channels2));
bc_set3 = nnz(ismember(bc_sh, channels3));

if bc_set1 == 0
    channels = channels1;
elseif bc_set2 == 0
    channels = channels2;
elseif bc_set3 == 0 
    channels = channels3;
else
    lowest = min([bc_set1 bc_set2 bc_set3]);
    best_set = find(lowest == [bc_set1, bc_set2, bc_set3]);
    best_set = best_set(1);  %to deal with cases where two sets are tied for lowest value
    
    if best_set == 1
       channels = channels1;
    elseif best_set == 2
        channels = channels2;
    elseif best_set == 3
        channels = channels3;
    end 
end 

if strcmp(animal, 'WT162') %added to avoid these animals having no oriens channels strcmp(animal, 'WT159') |
    channels = channels3;
end

%load LFP data into LFP matrix
     for channel = 1:length(channels) 
         
         %if ismember(chan_64, bc_sh) || isnan(chan_64)
         %    LFPsignals(channel, :) =  NaN(1,length(LFP)); %use NaNs for bad channels or channels that don't exist
         %else
             chan_512 = probelayout(channels(channel), shank);  %find ch number out of 512
             LFP =  load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(chan_512) filter  '.mat']); %load file
             LFPsignals(:, channel) = LFP.filt_data; %add to matrix
         %end
     end
     
%clear channels; 

 
 %RefChan=ch.MidPyr; %channel in mid pyramidal layer
 %RefChan = ch.GC1; %testing for gamma 
 if strcmp(region, 'HIPP')
    RefChan = ch.Pyr1;
 elseif strcmp(region, 'MEC')  %middle of MEC2 
    RefChan = round((ch.EC21 + ch.EC22)/2);
 end
 
 if ismember(RefChan, bc_sh)
     disp('ref channel is bad, moving one chan over')
     RefChan = RefChan -1; 
 end
 
 RefChan = probelayout(RefChan, shank);
 load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(RefChan) filter '.mat']);
 %load(fullfile(lfp_dir, strcat('LFPvoltage_ch', num2str(PyrChan), filter, '.mat')));
   
 ref_lfp=filt_data;
 
  %restrict LFP and run_speed to time window

if t0>0 % greater than time 0
    LFPsignals = LFPsignals((t0*1000):(t1*1000),:);
    ref_lfp = ref_lfp((t0*1000):(t1*1000));
    run_speed = run_speed((t0*1000):(t1*1000));  %get runspeed restricted to time window for current track
elseif t0 == 0 %if t0 is the beginning of recording 
    LFPsignals = LFPsignals(1:(t1*1000),:);
    ref_lfp = ref_lfp(1:(t1*1000));
    run_speed = run_speed(1:(t1*1000));  %get runspeed restricted to time window for current track
end
    
%     if t0>0 % greater than time 0
%         filt_lfp = filt_lfp(:, (t0*1000):(t1*1000));  %get data restricted to time window for current track
%     elseif t0 == 0 %if t0 is the beginning of recording 
%         
%         filt_lfp = filt_lfp(:, 1:(t1*1000));  %get runspeed restricted to time window for current track
%     end

%find events 
filt_phase=angle(hilbert(ref_lfp));
[filt_troughs, filt_trough_inds]=findpeaks(filt_phase); %get sample indicies of mid pyramidal oscillation troughs for whole recording

%find all filt_troughs that are during running times
%for each filt_trough time check if value in run_speed at that time is
%greater than run_bl + runthresh_low, make logical index 
%get only filt_troughs with running = 1

run_troughs = zeros(1,length(filt_trough_inds)); 
for t = 1:length(filt_trough_inds)
    troughtime = filt_trough_inds(t); %trough time in samples
    if run_speed(troughtime) > run_bl + runthresh_low & (run_speed(troughtime) < run_bl + runthresh_high)
        run_troughs(t) = 1;
    else
        run_troughs(t) = 0; 
    end
end 

filt_trough_inds = filt_trough_inds(run_troughs ==1);

filt_trough_times = filt_trough_inds/fs;

%restrict to subset of data for testing
%events = filt_trough_times(filt_trough_times < 500);
%lfp.data = LFPsignals(1:500000,:);
%lfp.timestamps = [0.001:0.001:500];
%lfp.samplingRate = 1000;
    
events = filt_trough_times;
lfp.data = LFPsignals;
lfp.timestamps = [0.001:0.001:(length(LFPsignals)/1000)];
lfp.samplingRate = 1000;
 
%plot to test if LFP data looks right 
lfpdata = lfp.data;  %(1:60000,:);   
figure;
for chan=1:size(lfpdata,2)
        offset = 400*(chan-1);  
        plot(lfpdata(:,chan) + offset,'k','LineWidth',1.5); hold on;
end
   axis xy
   

%find indices in channels that correspond to each layer
channels_csd = channels;
channels_csd(1) = NaN;  %remove edges since CSD will not exist for those channels
channels_csd(21) = NaN;

if strcmp(region, 'HIPP')
    Hil_chans = find(channels_csd >= ch.Hil2 & channels_csd <= ch.Hil1);
    GC_chans = find(channels_csd >= ch.GC2 & channels_csd <= ch.GC1);
    Mol_chans = find(channels_csd >= ch.Mol2 & channels_csd <= ch.Mol1);
    LM_chans = find(channels_csd >= ch.LM2 & channels_csd <= ch.LM1);
    Rad_chans = find(channels_csd >= ch.Rad2 & channels_csd <= ch.Rad1);
    Pyr_chans = find(channels_csd >= ch.Pyr2 & channels_csd <= ch.Pyr1);
    Or_chans = find(channels_csd >= ch.Or2 & channels_csd <= ch.Or1);

    %channels numbered 1-21 to correspond with input to csd
    channels_by_layer_21 = {Hil_chans, GC_chans, Mol_chans, LM_chans, Rad_chans, Pyr_chans, Or_chans};
    %channels numbered 1-19 to correspond with csd output 
    channels_by_layer_csd = {Hil_chans-1, GC_chans-1, Mol_chans-1, LM_chans-1, Rad_chans-1, Pyr_chans-1, Or_chans-1};
elseif strcmp(region, 'MEC')
    MEC2_chans = find(channels_csd >= ch.EC22 & channels_csd <= ch.EC21);
    
    if isempty(ch.EC31)
        MEC3_chans = [];
    else
        MEC3_chans = find(channels_csd >= ch.EC32 & channels_csd <= ch.EC31);
    end 
    
    %channels numbered 1-21 to correspond with input to csd
    channels_by_layer_21 = {MEC2_chans, MEC3_chans};
    %channels numbered 1-19 to correspond with csd output 
    channels_by_layer_csd = {MEC2_chans-1, MEC3_chans-1};
end


%note any channels that will need to be removed from final analysis due to bad channels
%For HIPP - WT89-0, WT158, WT47-0, 3xTg48-0, 3xTg132 should have one remaining bad
%channel after choosing best row on probe for each animal
remove_chans_21 = find(ismember(channels, bc_sh));  % find location of channel out of 21
remove_chans_csd = remove_chans_21 - 1;    %adjust to out of 19 
remove_chans_csd = [remove_chans_csd-1 remove_chans_csd remove_chans_csd+1];  %remove adjacent channels too? 



%make sure no values greater than 19 or less than 1 are present
remove_chans_csd = remove_chans_csd(remove_chans_csd <=19 & remove_chans_csd >= 1);
end


