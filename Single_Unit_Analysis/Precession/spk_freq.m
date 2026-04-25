 %% calculate "phase precession" as the difference between instantaneous frequency of spike train and LFP

%Adapted by Lauren Vetere from code by Antonio Fernandez Ruiz 

%NOTE: In the manuscript, the spike frequency from this script was used and
%compared to the LFP frequency calculated elsewhere using a more accurate
%wavelet method

%STEPS: 
%load theta filtered LFP for CA1 pyr channel
%get info about running periods 

%get theta amplitude and phase 
%restrict to running times

%load in spike times for all units
%restrict to all spikes that happened during any running time 

%amplitude = abs of hilbert of theta 
%phase = angle of hilbert transform of theta


%% get metadata and set parameters

%load bad channels
load('W:\bad_chans_table.mat');  %load in table with bad channels for each animal 1-64 for each shank
bad_chans = table2cell(bad_chans_table);

%set up directory with kilosort files
kilosort_dir = 'Z:\Lauren\Ephys Experiments\Kilosort\';
all = dir(fullfile(kilosort_dir,'*')); %all stuff in directory
folder_names = setdiff({all([all.isdir]).name},{'.','..'}); % list of subfolders

% get info about time windows used for kilosort
ks_times = readtable(['F:\Ephys Analysis\ks_times.csv']);
ks_times = table2cell(ks_times);

%set thresholds for running 
runthresh_low = 0.1;
runthresh_high = 0.2;  

uind=0;  %master unit index

filter = 'theta';

%ctype = 'eCA1';

%animals = {'WT98-0','WT78-0' };
animals = { 'AD-WT-44-1', '3xTg132', 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT98-0' '3xTg77-1' 'WT153' 'WT157' '3xTg125' 'WT126' '3xTg123' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2' 'WT159' 'WT105-0' 'WT69-1' 'WT181' 'WT173' '3xTg165' '3xTg177' '3xTg148-1'  '3xTg136' 'WT158'  'WT89-0' };


% loop through animals
for anim = 1:length(animals)
    animal = animals{anim};
    disp(['loading ' animal]);   

    exp_dir = get_exp(animal); %get directory info for animal

    %get location of phy output files for animal
    for fold = 1:length(folder_names)  %find folder that has current animal's raw unit files inside - some folders have arbitrary blinded names but have files inside with animal name in them
        all_in_sub = dir(fullfile(kilosort_dir,folder_names{fold},'*')); %stuff in subfolder
        files = {all_in_sub(~[all_in_sub.isdir]).name}; % only files in subfolder.
        file = fullfile(kilosort_dir,folder_names{fold},files{1}); %grab first file
        if contains(file, animal)
        spike_dir = [kilosort_dir folder_names{fold}];
        %cd(spike_dir);
        end
    end  

    %load probelayout
    if strcmp(animal,'3xTg1-2')  %load probe layout
        load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat');
    else
        load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');
    end

    %Fs = 25000; %sampling rate in Hz for single unit data

    %load in shank info
    [HIPshanks, ECshanks]=getshankECHIP_LV_multi(animal);
    shanks = [HIPshanks, ECshanks];
    [HIPshankLFP, ECshankLFP]=getshankECHIP_LV(animal);

    if ECshanks == 0  %deal with situations where there is no available EC shank 
        shanks = [HIPshanks];
    end

    %load bad channels for this animal
    bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
    bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks


    %% load running data
    %load run speed data
    stim_dir=[exp_dir 'stimuli\'];
    run_speed = load([stim_dir 'running.mat']);
    run_speed = run_speed.running; 
    run_speed_1khz = downsample(run_speed,25);
    run_bl = mode(run_speed);

    %% load lfp data 

    tracks = {'A'}; %only on familiar 'A' track
    [anim_windows] = get_time_windows_drift(animal, tracks); %get time windows for each track for given animal

    LFP_full = [];
    running_full = [];

    %loop through windows and grab LFP and running data
    for w = 1:size(anim_windows,1) 
        t0 = anim_windows{w,3};
        t1 = anim_windows{w, 4};
        set = anim_windows{w,5};

        [ch] = getchannels_drift(animal, HIPshankLFP, set);  % get channels from channel set designed to be for spikes

        MidPyr = ch.MidPyr; %get mid pyramidal CA1 channel
        MidPyr_512 = probelayout(MidPyr, HIPshankLFP); %convert to number out of 512
        
        if ~isempty(MidPyr_512) %added to deal with situation when mid pyr channel not available
            load([exp_dir '\LFP\' filter '\LFPvoltage_ch' num2str(MidPyr_512) filter '.mat'])  % load 1000Hz theta filtered data

            %get LFP and running data in this time window
            if t0 == 0 
                LFP_in_win = filt_data(1:t1*1000); %x1000 to convert seconds to samples 
                running_in_win = run_speed_1khz(1:t1*1000); 
            else
                LFP_in_win = filt_data(t0*1000:t1*1000);
                running_in_win = run_speed_1khz(t0*1000:t1*1000);     
            end 

            LFP_full = [LFP_full LFP_in_win];
            running_full = [running_full running_in_win];
        else
        end

    end 

    %find run times within a narrow threshold 
    run_times_all = find(running_full> (run_bl + runthresh_low));  %anywhere 0.1 above baseline ball tracker reading - usually ~2.7 %fixed to deal with different baselines across animals
    run_times_thresh = find(running_full >  (run_bl + runthresh_low) & running_full<  (run_bl + runthresh_high)); %only narrow threshold above baseline
    non_run_times = find(running_full < (run_bl + 0.02) & running_full > (run_bl - 0.02)); %restricted to get out downward deflections that may or may not be running

    %restrict data to running times in threshold
    %LFP_run_thresh = LFP_full(run_times_thresh);
    LFP_run_all = LFP_full(run_times_all); %this is different from how I used run thresh to get frequency in the paper - maybe come back to this after I figure out how I'm dealing with runnning speed stuff for other figs

    %plot(LFP_run_thresh); %looks weird maybe don't use this - too chopped up 
    %plot(LFP_run_all)

    %% calculate frequency of LFP

      %lfp = GetLFP(layerCh);
      %filt = Filter(lfp2,'passband',[5 15]);

      %ampT1 = Restrict([filt.timestamps filt.amp],intervals); % list of [start stop] time intervals (e.g., running)
      %phaseT1 = Restrict([filt.timestamps filt.phase],intervals);

      ampT1 = abs(hilbert(LFP_run_all));
      phaseT1 = angle(hilbert(LFP_run_all));

      %lfpPow = mean(ampT1(:,ch+1).^2);
      lfpFreq = mean(1250/(2*pi)*diff(unwrap(phaseT1(:))));    %should we average across channels here - do we want to relate this to phase locking data or frequency analysis?
      %lfpFreq = mean(1250/(2*pi)*diff(unwrap(phaseT1(:,ch+1))));   


    %% load spike times during running + relevant data to sort units by region/cell type

    %loop through shanks to load
    for sh=1:length(HIPshanks) 
        shank = HIPshanks(sh); %get units from each shank
        [ch] = getchannels_drift(animal, shank, 4);  % get channels from channel set designed to be for spikes

        %get info about this animal's sex, group, age 
        group = ch.group;
        sex = ch.sex;
        age = ch.age; 

        load([spike_dir '/' animal 'shank' num2str(shank) '_units_output_allAtrack.mat']) %structure called units_output  

        for u=1:length(units_output.meanAC_all)  %getting all the important info about each unit from file we loaded in earlier 
            uind=uind+1;

            animal_ind{uind} = animal;  %added this so I can know which animal each cluster belongs to for plotting later
            shank_ind(uind) = shank;
            group_ind{uind} = ch.group;
            sex_ind{uind} = ch.sex;
            age_ind{uind} = ch.age;
            spiketimes_allunits{uind} = units_output.spiketimes_all_run{u};
            lfpFreq_ind(uind) = lfpFreq; %save LFP that each unit is being compared to 

            if isnan(units_output.mISI_all(u))
                mFR_all(uind)=NaN;   
                meanAC_all(uind) = NaN;
                CSI_all(uind) = NaN;
                c(uind) = NaN;
                correctch(uind) = NaN;   
            else
                mFR_all(uind)=units_output.mFR_all(u);  
                meanAC_all(uind) = units_output.meanAC_all(u);  
                CSI_all(uind) = units_output.CSI_all(u); 
                c(uind) = units_output.waveforms{u}.c;
                correctch(uind) = units_output.correctch(u);
            end 
            
            
            if isnan(units_output.mISI_run_thresh(u))
                mFR_runthresh(uind)=NaN;  
                CA1thetaPL_runthresh_r(uind) = NaN;
                CA1thetaPL_runthresh_mu(uind) = NaN;
            else
                mFR_runthresh(uind)=units_output.mFR_run_thresh(u);
                CA1thetaPL_runthresh_r(uind) = units_output.CA1thetaPL_run_thresh{u}.r;
                CA1thetaPL_runthresh_mu(uind) = units_output.CA1thetaPL_run_thresh{u}.mu; %need to add pi later?
            end 
            

             if ~isempty(ch.DGlow) && ~isempty (ch.DGup) && units_output.correctch(u)>=ch.DGlow-3 && units_output.correctch(u)<=ch.DGup+6  %added +/- 3 to be a little broader
                 region{uind} = 'DG';
             elseif ~isempty(ch.CA1up) && ~isempty (ch.CA1low) && units_output.correctch(u)>=ch.CA1low-10 && units_output.correctch(u)<=ch.CA1up+7
                 region{uind} = 'CA1';
             else
                 region{uind} = 'other';
             end

        end 
    end 
end
   % spiketimes_allunits = units_output.spiketimes_all_run;
    
    %% find excitatory and inhibitory clusters   
 disp(['sorting into celltypes']);   
    %could add this too units loop above and get rid of some of the stuff
    %lower in this section that I'm not using? 
    type = [];
    for idx=1:length(animal_ind)
        if c(idx) > 0.26 && meanAC_all(idx) <0.114 && mFR_all(idx) < 10 && CSI_all(idx) > -15
             type(idx)=2; 
             celltype{idx} = 'exc';
        elseif meanAC_all(idx) > 0.11 && mFR_all(idx) >= 0.25
             type(idx)=1;
             celltype{idx} = 'inh';
        else
             type(idx)=3;  
             celltype{idx} = 'unknown';
        end
    end
    inh = find(type == 1);
    exc = find(type == 2);
    weird = find(type == 3);

    CA1_idx = find(contains(region, 'CA1'));
    DG_idx = find(contains(region, 'DG'));

    eCA1_idx = CA1_idx(ismember(CA1_idx, exc)); %indices of excitatory CA1 units
    eDG_idx = DG_idx(ismember(DG_idx, exc));
    iCA1_idx = CA1_idx(ismember(CA1_idx, inh));
    iDG_idx = DG_idx(ismember(DG_idx, inh));

    % if strcmp(ctype, 'eCA1')
    %     for unit = 1:length(units_output.spiketimes_all_run)
    %        if ismember(unit, eCA1_idx);  %make logical index of which units match the cell type of interest
    %            idx(unit) = 1;
    %        else
    %            idx(unit) = 0; 
    %        end 
    %     end 
    % end

    % c = 1; 
    % celltype_units = {};
    % for unit = 1:length(spiketimes_allunits)
    %     if ismember(unit, eCA1_idx) %set to grab spiketimes for all eCA1 clusters 
    %         spiketimes_celltype{c} = spiketimes_allunits{unit};
    %         c = c+1; 
    %     else
    %     end
    % end 


    %% 
    % calculate freq of spike trains and difference between unit and LFP freqs
   disp(['calculating spike frequencies']); 
      for u = 1:length(spiketimes_allunits) % run this for each of your cells (spike timestamps in seconds)
           spk = spiketimes_allunits{u}/25000; %get spikes for current unit, convert to seconds
           %spk = Restrict(spikes.times{u},intervals);
           lfpFreq = lfpFreq_ind(u);
           numspks(u) = length(spk); 
           if length(spk) > 100 % minimum n of spikes   
              [ccg2,ccg_time2] = CCG(spk,ones(length(spk)),'binSize',0.001,'duration',1);
              %ccg2 = counts, ccg_time2 = time lags? 
              ccg_smth = Smooth(ccg2,5); %originally set to 10 - too much? 2? 
              
               
              %figure;subplot(1,2,1);plot(ccg_time,ccg);subplot(1,2,2);plot(ccg_time2,ccg_smth);
              
              [~,ind]=max(ccg_smth(551:651)); %find peak between 50-150ms? 
              if ind ~= 1 && ind ~= 101 %don't count peaks at edges 
                 unitFreq(u) = 1/ccg_time2(551+ind); % this is the freq of the spike train 
                 unitLFPfreq(u) = unitFreq(u)-lfpFreq;
                 %unitLFPfreq(u,2) = unitFreq(u,2)-lfpFreq{1}(1,2); % difference between unit and LFP freqs
              
                if mod(u, 10) == 0   %plot every 10th unit
                figure;subplot(1,2,1);plot(ccg_time2,ccg2);subplot(1,2,2);plot(ccg_time2,ccg_smth);   
                title([animal_ind(u) ' unit ' num2str(u) ' ' group_ind(u) ' ' celltype{u} ' unit freq = ' num2str(unitFreq(u))]);
                end
              
              else
                 unitFreq(u)=NaN;  unitLFPfreq(u) = NaN;
              end

           else
                 unitFreq(u)=NaN;    unitLFPfreq(u) = NaN;
           end
           
           
           disp(['done with unit ' num2str(u) ' of ' num2str(length(spiketimes_allunits))]);
      end

 
 %% Add info to a table to export 
 
 

Table = table(animal_ind', group_ind', sex_ind', age_ind', shank_ind', region', celltype', lfpFreq_ind',unitFreq', unitLFPfreq', numspks', CA1thetaPL_runthresh_r', CA1thetaPL_runthresh_mu', mFR_all', mFR_runthresh', 'VariableNames',{'Animal', 'Group','Sex', 'Age', 'Shank', 'Region','Celltype', 'LFPfreq', 'Unitfreq','UnitvLFPfreq', 'NumSpks', 'CA1thetaPL_runthresh_r', 'CA1thetaPL_runthresh_mu', 'mFR_all', 'mFR_runthresh'});


out_dir = 'W:\data analysis';
cd(out_dir);

%load('WaveletPSD_Atracks_MidPyr_theta.mat')

writetable(Table,['precession_withPL_Smooth5.csv'])

%  
%could save with phase locking info too to try to relate them together??? 

