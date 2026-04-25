%Copy of coherency_test_all_regions_multi_drift_fixed

%NOTE: NOT SURE IF RUN SPEED IS BEING HANDLED CORRECTLY 

%**Edited to concatenate data across windows instead of calculating each
%window and taking weighted average. Downside to this is the number of
%channels of data used for a given animal + layer is the lowest number of
%channels in any window 

%This script is designed to calculate coherence between pairs of channels
%using coherencyc function from chronux 

%fixed this version to save overall running speeds instead of just in last
%window

%Saves a structure for each animal that contains a coherence matrix for
%each behavioral state (for this script: full recording, running time,
%running time within threshold, and non-running)
%Plus info about start and end times of time windows used, amount of time
%in each behavioral state, and other identifying info for each animal. 

%Coherence calculations are calculated across time with one value per unit
%of time defined by "seg" (seg of 1 = bins of 1 second)

%Currently using 'all' valid tracks that correspond to track variable chosen by user 
% 
%   filters = {'theta'}% 'fast_gamma', 'gamma' 'slow_gamma' 'ripple'};
%   tracks = {'A'} %'all';   
%   seg = 1;  %desired time bins in seconds
%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};


%animals = {'AD-WT-44-1', 'WT162'} 

%animals = {'3xTg125'}

animals = {'WT162', 'WT126'}; 

function coherency_test_all_regions_multi_drift_bylyr_noweighting(animals, seg, filters, tracks)

load('W:\bad_chans_table.mat');  %load in table with bad channels for each animal 1-64 for each shank
bad_chans = table2cell(bad_chans_table);

runthresh_low = 0.1;
runthresh_high = 0.2; 

layers = {'Or', 'Pyr', 'Rad', 'LM', 'Mol', 'GC', 'Hil', 'MEC2' 'MEC3'}; 

%layers = {'Or', 'Pyr', 'Rad'};

table_row = 1;

for filt = 1:length(filters)
    filter = filters{filt};
    disp(['starting filter ' filter])
    
    for anim = 1:length(animals)
        
    animal = animals{anim};
    disp(['starting animal ' animal])

    if strcmp(animal,'3xTg1-2')  %load probe layout
        load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat');              
    else
        load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');     
    end
        
    exp_dir = get_exp(animal);
    stim_dir=[exp_dir 'stimuli\'];
    
    %get bad channels for this animal - all shanks
    bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
    bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks
    
    %get shanks for this animal
    [HIPshank, ECshank]=getshankECHIP_LV(animal); %get HIP and EC                                                                                                                                                                                                                                                                        shanks for this animal
        
    [anim_windows] = get_time_windows_drift(animal, tracks);
    
    run_speed_full = [];
    run_speed = load([stim_dir 'running.mat']);
    run_speed = downsample(run_speed.running,25); %1000Hz
    
    %loop through windows to get data about running speed - moved outside
    %of main loop so that it doesn't get re-calculated for every layer pair
    for wr = 1:size(anim_windows,1)
        set = anim_windows{wr,5};
        t0 = anim_windows{wr, 3};
        t1 = anim_windows{wr, 4};
        %restrict data to time window of interest 
        if t0>0 % greater than time 0
            run_speed_win = run_speed(:, (t0*1000):(t1*1000));  %get runspeed restricted to time window for current track
        elseif t0 == 0 %if t0 is the beginning of recording 
            run_speed_win = run_speed(:, 1:(t1*1000));  %get runspeed restricted to time window for current track
        end
        run_speed_full = [run_speed_full run_speed_win]; 
    end
    
    run_bl = mode(run_speed_full);
    %%%GET INFO ABOUT RUNNING TIMES + LENGTH OF TIME SPENT RUNNING
    %get avg running speed for each bin - corresponding to number of time bins that will be present in
    %coherency output
    Fs = 1000;
    binsize_sec = seg; %in seconds
    binsize_samples = binsize_sec*Fs;
    num_bins = floor(length(run_speed_full)/binsize_samples); %round down to avoid extra bin at the end that coh analysis doesn't have
    %based on length of recording make bins
    run_bins = zeros(1,num_bins);   %matrix to keep avg running speed for each bin of length seg 
    n=0;
    r=1;

    for bin = 1:length(run_bins)
        start_bin = n*binsize_samples+1;
        end_bin = r*binsize_samples;
        run_speed_in_bin = run_speed(start_bin:end_bin);
        run_speed_avg = mean(run_speed_in_bin);
        run_bins(bin) = run_speed_avg;

        n = n+1;
        r = r+1;
    end

    %find run times within a narrow threshold 
    run_times_all = find(run_bins > (run_bl + runthresh_low));  %anywhere 0.1 above baseline ball tracker reading - usually ~2.7
    run_times_in_thresh = find(run_bins >  (run_bl + runthresh_low) & run_bins <  (run_bl + runthresh_high)); %fix to deal with different baselines across animals? %code these thresholds as a variable
    non_run_times = find(run_bins < (run_bl + 0.02) & run_bins > (run_bl - 0.02)); %to get out downward deflections that may or may not be running

    %avg speeds 
    avg_speed = mean(run_bins);
    avg_run_speed = mean(run_bins(run_times_all));
    avg_run_speed_w_thresh = mean(run_bins(run_times_in_thresh));
    avg_speed_non_run = mean(run_bins(non_run_times));

    %time spent running vs not
    length_run = length(run_times_all)*seg;
    length_nonrun = length(non_run_times)*seg;
    length_runthresh = length(run_times_in_thresh)*seg;
    length_full = num_bins*seg;
    
    disp(['done importing running speed data']);
    
    %loop through each pair of layers, load data,  
    for lind1 = 1:length(layers) %loop through layers 
        lyr1 = layers{lind1};
        lyr1_lfp_full = [];
        
        disp(['loading data for layer 1 ' lyr1]);
        for w1 = 1:size(anim_windows,1)
            lyr1_lfp = []; 
            set = anim_windows{w1,5};
            t0 = anim_windows{w1, 3};
            t1 = anim_windows{w1, 4};

            [HIPP_ch] = getchannels_drift(animal, HIPshank, set);
            HIPP_bc_sh = bc{1}{HIPshank}; %get bad channels for shanks
             
            if ECshank > 0 
                [MEC_ch] = getchannels_drift(animal, ECshank, set);
                MEC_bc_sh = bc{1}{ECshank}; 
            else
                 MEC_ch = [];
                 MEC_bc_sh = [];
            end
            
            %get channels for layer 1
            if strcmp(lyr1, 'Hil')
                lyr1_chans = HIPP_ch.Hil2:HIPP_ch.Hil1;            
            elseif strcmp(lyr1, 'GC')
                 lyr1_chans = HIPP_ch.GC2:HIPP_ch.GC1;
            elseif strcmp(lyr1, 'Mol')
                 lyr1_chans = HIPP_ch.Mol2:HIPP_ch.Mol1;      
            elseif strcmp(lyr1, 'LM')
                 lyr1_chans = HIPP_ch.LM2:HIPP_ch.LM1;     
            elseif strcmp(lyr1, 'Rad')
                 lyr1_chans = HIPP_ch.Rad2:HIPP_ch.Rad1;
            elseif strcmp(lyr1, 'Pyr')
                 lyr1_chans = HIPP_ch.Pyr2:HIPP_ch.Pyr1;
            elseif strcmp(lyr1, 'Or')
                 lyr1_chans = HIPP_ch.Or2:HIPP_ch.Or1; 
            elseif strcmp(lyr1, 'MEC2') && ~isempty(MEC_ch)
                 lyr1_chans = MEC_ch.EC22:MEC_ch.EC21; 
            elseif strcmp(lyr1, 'MEC3') && ~isempty(MEC_ch)
                 lyr1_chans = MEC_ch.EC32:MEC_ch.EC31;   
            else 
                 lyr1_chans = []; 
            end

            if lind1 <= 7 %if hipp layer
                lyr1_chans = lyr1_chans(~ismember(lyr1_chans,HIPP_bc_sh)); %remove bad channels
            else
                lyr1_chans = lyr1_chans(~ismember(lyr1_chans,MEC_bc_sh));    
            end

            if w1 == 1
                lyr1_chans_length_w1 = length(lyr1_chans); 
            end

            if w1 > 1  %deal with situations where one window has fewer channels than others
                if length(lyr1_chans) > lyr1_chans_length_w1
                    lyr1_chans = lyr1_chans(1:lyr1_chans_length_w1); %make sure all windows have same number of channels
                elseif length(lyr1_chans) < lyr1_chans_length_w1
                    lyr1_lfp_full = lyr1_lfp_full(1:length(lyr1_chans),:); %?? Could use NaNs instead of removing data? 
                end
            end  

            lyr1_numchans = length(lyr1_chans);
            
            if lyr1_numchans == 0  %skip this window if no channels available
                continue
            end

            if lind1 <= 7 %if hipp layer
                shankchs=probelayout(:,HIPshank);
                lyr1_rawchans=shankchs(lyr1_chans); %convert to true channel numbers
            else
                shankchs=probelayout(:,ECshank);
                lyr1_rawchans=shankchs(lyr1_chans); %convert to true channel numbers
            end    

            %loop through layer 1 chans, load data
            for channel = 1:length(lyr1_rawchans)  
                chan = lyr1_rawchans(channel);
                LFP =  load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(chan) filter '.mat']);    
                lyr1_lfp(channel,:) = LFP.filt_data; 
                disp(['loaded channel ' num2str(channel) ' of ' num2str(length(lyr1_rawchans))]);
            end

            %restrict data to time window of interest 
            if t0>0 % greater than time 0
                lyr1_lfp= lyr1_lfp(:, (t0*1000):(t1*1000)); 
            elseif t0 == 0 %if t0 is the beginning of recording 
                lyr1_lfp = lyr1_lfp(:, 1:(t1*1000));
            end

            lyr1_lfp_full = [lyr1_lfp_full lyr1_lfp];  %final matrix that has data from all time windows combined
            
            disp(['loaded lfp data for ' lyr1 ' window ' num2str(w1)]);
        end
        disp(['loaded lfp data for ' lyr1 ' all windows']);
        
        if isempty(lyr1_lfp_full)
            disp(['no data for ' lyr1 ' ' animal ' skipping']); 
            continue
        end
        
        for lind2 = 1:length(layers)
            lyr2_lfp_full = []; 
            if lind2>=lind1 %only do each pair of layers once 
                lyr2 = layers{lind2};    
                disp(['loading data for layer 2 ' lyr2]);
                
                for w2 = 1:size(anim_windows,1)
                    lyr2_lfp = [];
                    set = anim_windows{w2,5};
                    t0 = anim_windows{w2, 3};
                    t1 = anim_windows{w2, 4};

                    [HIPP_ch] = getchannels_drift(animal, HIPshank, set);
                    HIPP_bc_sh = bc{1}{HIPshank}; %get bad channels for shanks
                    
                    if ECshank > 0
                        [MEC_ch] = getchannels_drift(animal, ECshank, set);
                        MEC_bc_sh = bc{1}{ECshank}; 
                    else
                        MEC_ch = [];
                        MEC_bc_sh = [];
                    end 
                    
                    %get channels for layer 2
                    if strcmp(lyr2, 'Hil')
                        lyr2_chans = HIPP_ch.Hil2:HIPP_ch.Hil1;            
                    elseif strcmp(lyr2, 'GC')
                         lyr2_chans = HIPP_ch.GC2:HIPP_ch.GC1;
                    elseif strcmp(lyr2, 'Mol')
                         lyr2_chans = HIPP_ch.Mol2:HIPP_ch.Mol1;      
                    elseif strcmp(lyr2, 'LM')
                         lyr2_chans = HIPP_ch.LM2:HIPP_ch.LM1;     
                    elseif strcmp(lyr2, 'Rad')
                         lyr2_chans = HIPP_ch.Rad2:HIPP_ch.Rad1;
                    elseif strcmp(lyr2, 'Pyr')
                         lyr2_chans = HIPP_ch.Pyr2:HIPP_ch.Pyr1;
                    elseif strcmp(lyr2, 'Or')
                         lyr2_chans = HIPP_ch.Or2:HIPP_ch.Or1; 
                    elseif strcmp(lyr2, 'MEC2') && ~isempty(MEC_ch)
                         lyr2_chans = MEC_ch.EC22:MEC_ch.EC21; 
                    elseif strcmp(lyr2, 'MEC3') && ~isempty(MEC_ch)
                         lyr2_chans = MEC_ch.EC32:MEC_ch.EC31;  
                    else 
                        lyr2_chans = [];      
                    end
            
                    if lind2 <= 7 %if hipp layer
                        lyr2_chans = lyr2_chans(~ismember(lyr2_chans,HIPP_bc_sh)); %remove bad channels
                    else
                        lyr2_chans = lyr2_chans(~ismember(lyr2_chans,MEC_bc_sh));    
                    end
                    
                    if w2 == 1
                        lyr2_chans_length_w1 = length(lyr2_chans); 
                    end

                    if w2 > 1  %deal with situations where one window has fewer channels than others
                        if length(lyr2_chans) > lyr2_chans_length_w1
                            lyr2_chans = lyr2_chans(1:lyr2_chans_length_w1); %make sure all windows have same number of channels
                        elseif length(lyr2_chans) < lyr2_chans_length_w1
                            lyr2_lfp_full = lyr2_lfp_full(1:length(lyr2_chans),:); %?? Could use NaNs instead of removing data? 
                        end         
                    end  
                    
                    lyr2_numchans = length(lyr2_chans);
                    
                    if lyr2_numchans == 0  %skip this window if no channels available
                        continue
                    end
                    
                    if lind2 <= 7 %if hipp layer
                        shankchs=probelayout(:,HIPshank);
                        lyr2_rawchans=shankchs(lyr2_chans); %convert to true channel numbers
                    else
                        shankchs=probelayout(:,ECshank);
                        lyr2_rawchans=shankchs(lyr2_chans); %convert to true channel numbers
                    end 


                    %loop through layer 2 chans, load data
                    for channel = 1:length(lyr2_rawchans)  
                        chan = lyr2_rawchans(channel);
                        LFP =  load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(chan) filter '.mat']);    
                        lyr2_lfp(channel,:) = LFP.filt_data; 
                        disp(['loaded channel ' num2str(channel) ' of ' num2str(length(lyr2_rawchans))]);
                    end

                    %restrict data to time window of interest 
                    if t0>0 % greater than time 0
                        lyr2_lfp= lyr2_lfp(:, (t0*1000):(t1*1000));
                    elseif t0 == 0 %if t0 is the beginning of recording 
                        lyr2_lfp = lyr2_lfp(:, 1:(t1*1000));
                    end

                    lyr2_lfp_full = [lyr2_lfp_full lyr2_lfp]; 

                    disp(['loaded lfp data for ' lyr2 ' window ' num2str(w2)]);
                end    
                disp(['done importing data for ' lyr1 ' vs ' lyr2]);  
                
                group = HIPP_ch.group; 
                sex = HIPP_ch.sex;
                age = HIPP_ch.age; 

                
                if ~isempty(lyr1_lfp_full) && ~isempty(lyr2_lfp_full)   %if data is available for current pair of layers
                    disp(['calculating coherence between ' lyr1 ' and ' lyr2]);
                    %%%SET PARAMETERS

                    params = struct();
                    params.Fs = Fs;  %sampling rate
                    params.trialave = 0;  %don't average across segments/trials

                    if strcmp(filter, 'theta')
                    params.fpass = [5 12];
                    elseif strcmp(filter, 'gamma')
                    params.fpass = [30 80];
                    elseif strcmp(filter, 'fast_gamma')
                    params.fpass = [90 130];
                    elseif strcmp(filter, 'slow_gamma')
                    params.fpass = [30 50];
                    end 

                 %add something to deal with when a layer or shank is
                 %missing ??

                %make matrices to store coherence data for each channel pair 
                coh_all = NaN(lyr1_numchans, lyr2_numchans);
                coh_run_all = NaN(lyr1_numchans, lyr2_numchans);
                coh_run_in_thresh = NaN(lyr1_numchans, lyr2_numchans);
                coh_non_run = NaN(lyr1_numchans, lyr2_numchans);

                phase_all = NaN(lyr1_numchans, lyr2_numchans);
                phase_run_all =NaN(lyr1_numchans, lyr2_numchans);
                phase_run_in_thresh=NaN(lyr1_numchans, lyr2_numchans);
                phase_non_run = NaN(lyr1_numchans, lyr2_numchans);

                diff_threshVSnon = NaN(lyr1_numchans, lyr2_numchans);
                diff_runVSnon= NaN(lyr1_numchans, lyr2_numchans);  

                for ch1=1:lyr1_numchans 
                    for ch2=1:lyr2_numchans
                         if ch2>=ch1 %loop through every pair of channels

                            data1 = lyr1_lfp_full(ch1,:); %load data for just those two channels
                            data2 = lyr2_lfp_full(ch2,:);
                            data1 = data1';
                            data2 = data2';

                            if ~any(isnan(data1))&& ~any(isnan(data2)) %check if both channels contain valid data (i.e. not bad channels)

                                %taken from coherencysegc script
                                [tapers,pad,Fs,fpass,err,trialave,params]=getparams(params); %sets any undefined parameters to defaults
                                N=check_consistency(data1,data2);
                                dt=1/Fs; % sampling interval m,
                                T=N*dt; % length of data in seconds
                                win = seg;
                                E=0:win:T-win; % fictitious event triggers
                                win=[0 win]; % use window length to define left and right limits of windows around triggers
                                data1=createdatamatc(data1,E,Fs,win); % segmented data 1 %segments data so each column is a window and each row is a sample -LV
                                data2=createdatamatc(data2,E,Fs,win); % segmented data 2

                                [C,phi,S12,S1,S2,f]=coherencyc(data1,data2,params); %calculate coherence between two signals
                                
                                coh_pair = mean(C,1); %average across all frequencies in range (ex. theta avg across7 rows representing 5-12Hz)
                                phase_pair = mean(phi,1);

                                %get coherence across time windows of interest based on running
                                %behavior - collect value for each pair of
                                %channels
                                coh_all(ch1,ch2) = mean(coh_pair); 
                                coh_run_all(ch1,ch2) = mean(coh_pair(:, run_times_all));
                                coh_run_in_thresh(ch1,ch2) = mean(coh_pair(:, run_times_in_thresh));
                                coh_non_run(ch1,ch2) = mean(coh_pair(:, non_run_times));

                                %coh differences between running vs non
                                diff_threshVSnon(ch1, ch2) = coh_run_in_thresh(ch1, ch2) - coh_non_run(ch1,ch2);
                                diff_runVSnon(ch1,ch2) = coh_run_all(ch1,ch2) - coh_non_run(ch1,ch2);    

                                %phase differences
                                phase_all(ch1,ch2) = mean(phase_pair); 
                                phase_run_all(ch1,ch2) = mean(phase_pair(:, run_times_all));
                                phase_run_in_thresh(ch1,ch2) = mean(phase_pair(:, run_times_in_thresh));
                                phase_non_run(ch1,ch2) = mean(phase_pair(:, non_run_times));
                            else 
                                coh_all(ch1,ch2) = NaN; 
                                coh_run_all(ch1,ch2) = NaN;
                                coh_run_in_thresh(ch1,ch2) = NaN;
                                coh_non_run(ch1,ch2) = NaN;

                                diff_threshVSnon(ch1, ch2) = NaN;
                                diff_runVSnon(ch1,ch2) = NaN;   

                                phase_all(ch1,ch2) = NaN;
                                phase_run_all(ch1,ch2) =NaN;
                                phase_run_in_thresh(ch1,ch2) = NaN;
                                phase_non_run(ch1,ch2) = NaN;
                            end

                        end
                    end
                    disp(['done with ch1=' num2str(ch1)]);
                end

%                 for ch1=1:lyr1_numchans%fill out other (mirrored) half of the matrix
%                     for ch2=1:lyr2_numchans
%                         if ch2<ch1  
%                             coh_all(ch1,ch2) = coh_all(ch2, ch1);
%                             coh_run_all(ch1,ch2) = coh_run_all(ch2,ch1);
%                             coh_run_in_thresh(ch1,ch2) = coh_run_in_thresh(ch2, ch1);
%                             coh_non_run(ch1,ch2) = coh_non_run(ch2, ch1);
% 
%                             diff_threshVSnon(ch1, ch2) = diff_threshVSnon(ch2, ch1);
%                             diff_runVSnon(ch1,ch2) = diff_runVSnon(ch2, ch1);
% 
%                             %FIX DIRECTIONALITY HERE SOMEHOW???
%                             phase_all(ch1,ch2) = phase_all(ch2, ch1);
%                             phase_run_all(ch1,ch2) = phase_run_all(ch2, ch1);
%                             phase_run_in_thresh(ch1,ch2) = phase_run_in_thresh(ch2,ch1);
%                             phase_non_run(ch1,ch2) = phase_non_run(ch2,ch1);
%                         end
%                     end 
%                 end 

            %get means for current layer pair across all channel pairs
            coh_all_mean = nanmean(nanmean(coh_all));
            coh_run_all_mean = nanmean(nanmean(coh_run_all));
            coh_run_in_thresh_mean = nanmean(nanmean(coh_run_in_thresh));
            coh_non_run_mean = nanmean(nanmean(coh_non_run));
            
            diff_threshVSnon_mean = nanmean(nanmean(diff_threshVSnon));
            diff_runVSnon_mean = nanmean(nanmean(diff_runVSnon));

            %FIX DIRECTIONALITY HERE SOMEHOW???
            phase_all_mean = nanmean(nanmean(phase_all));
            phase_run_all_mean = nanmean(nanmean(phase_run_all));
            phase_run_in_thresh_mean = nanmean(nanmean(phase_run_in_thresh));
            phase_non_run_mean = nanmean(nanmean(phase_non_run));



            %disp(['done with??' ]);
           
           else  %if data not available -> set to NaN
               disp(['sufficient data for ' lyr1 ' vs ' lyr2 ' not available']);
                coh_all_mean = NaN;
                coh_run_all_mean = NaN;
                coh_run_in_thresh_mean =NaN;
                coh_non_run_mean = NaN;
                diff_threshVSnon_mean = NaN;
                diff_runVSnon_mean = NaN;
                phase_all_mean = NaN;
                phase_run_all_mean = NaN;
                phase_run_in_thresh_mean = NaN;
                phase_non_run_mean = NaN;
                    
           end
       
     
       %save info for each layer pair 
        Animal{table_row} = animal;
        Group{table_row} = group;
        Sex{table_row} = sex;
        Age{table_row} = age;
        
        Filter{table_row} = filter;
        Layer1{table_row} = lyr1;
        Layer2{table_row} = lyr2;
        Track{table_row} = tracks; 
        
        Coh_All{table_row} = coh_all_mean;
        Coh_Run{table_row} = coh_run_all_mean;
        Coh_Run_Thresh{table_row} = coh_run_in_thresh_mean;
        Coh_Non_Run{table_row} = coh_non_run_mean;
        Coh_Diff_ThreshvsNon{table_row} = diff_threshVSnon_mean;
        Coh_Diff_RunvsNon{table_row} = diff_runVSnon_mean;

        Phase_All{table_row} = phase_all_mean;
        Phase_Run{table_row} = phase_run_all_mean;
        Phase_Run_Thresh{table_row} = phase_run_in_thresh_mean;
        Phase_Non_Run{table_row} = phase_non_run_mean; 
        
        Length_Full{table_row} = length_full;
        Length_Run{table_row} = length_run;
        Length_Run_Thresh{table_row} = length_runthresh;
        Length_Non_Run{table_row} = length_nonrun;
        
        Avg_Speed{table_row} = avg_speed;
        Avg_Speed_Run{table_row} = avg_run_speed;
        Avg_Speed_Run_Thresh{table_row} = avg_run_speed_w_thresh;
        Avg_Speed_Non_Run{table_row} =avg_speed_non_run;
         
        RunThresh_Low{table_row} = runthresh_low;
        RunThresh_High{table_row} = runthresh_high;
        Run_Baseline{table_row} = run_bl;
     
        table_row = table_row + 1; 
       end 
       

            %plotting code for testing 
            %figure;
            %plot(coh_over_time)
            %PlotBehavior(animal)
        
               
            %Plotting code for testing%
            %figure; hold on;
            %title(animal);
            %plot(coh_full, 'b');
            %plot (run_bins-2, 'r');
            %legend('coherence','run speed')
            %xlabel(['time in' num2str(binsize_sec) 's bins']) 

            %figure;
            %title(animal);
            %scatter(coh_full, run_bins);
            %[R,P] = corrcoef(coh_full', run_bins')
 
        clear coh_all_mean
        clear coh_run_all_mean
        clear coh_run_in_thresh_mean
        clear coh_non_run_mean
        clear diff_threshVSnon_mean
        clear diff_runVSnon_mean 

        clear phase_all_mean
        clear phase_run_all_mean
        clear phase_run_in_thresh_mean
        clear phase_non_run_mean
       
        clear length_run_time_mean
        clear length_nonrun_time_mean
        clear length_thresh_run_time_mean
        clear length_full_mean
       
        clear speed_all_mean
        clear speed_run_all_mean
        clear speed_run_in_thresh_mean
        clear speed_non_run _mean
      
    
        end
        disp(['done with layer pair ' lyr1 ' vs ' lyr2])

    end  
    disp(['done with layer ' lyr1])  
    
   end 
  disp(['done with animal ' animal ' ' filter])  
   
end
  disp(['done with ' filter]) 
Table = table(Animal', Group', Sex', Age', Filter', Layer1', Layer2', Track', Coh_All' , Coh_Run', Coh_Run_Thresh', Coh_Non_Run', Coh_Diff_ThreshvsNon', Coh_Diff_RunvsNon', Phase_All', Phase_Run',Phase_Run_Thresh', Phase_Non_Run', Length_Full', Length_Run', Length_Run_Thresh', Length_Non_Run', Avg_Speed',Avg_Speed_Run', Avg_Speed_Run_Thresh', Avg_Speed_Non_Run', RunThresh_Low', RunThresh_High', Run_Baseline',  'VariableNames',{'Animal', 'Group', 'Sex', 'Age',  'Filter', 'Layer1', 'Layer2', 'Track', 'Coh_All' , 'Coh_Run', 'Coh_Run_Thresh', 'Coh_Non_Run', 'Coh_Diff_ThreshvsNon', 'Coh_Diff_RunvsNon', 'Phase_All', 'Phase_Run','Phase_Run_Thresh', 'Phase_Non_Run', 'Length_Full', 'Length_Run', 'Length_Run_Thresh', 'Length_Non_Run', 'Avg_Speed','Avg_Speed_Run', 'Avg_Speed_Run_Thresh', 'Avg_Speed_Non_Run', 'RunThresh_Low', 'RunThresh_High', 'Run_Baseline'});

out_dir = 'W:\data analysis';
cd(out_dir);
writetable(Table,['Coherence_by_Layer_NoWeights_test.csv'])   
     
end   
    
