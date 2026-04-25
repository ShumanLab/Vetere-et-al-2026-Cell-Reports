%This script is designed to calculate coherence between pairs of channels
%using an adapted coherencyc function from chronux 

%ADDING STEPS TO LOOP THROUGH POSSIBLE SPEED RANGES - NOT DONE YET

%Saves a structure for each animal that contains a coherence matrix for
%each behavioral state (for this script: full recording, running time,
%running time within threshold, and non-running)
%Plus info about start and end times of time windows used, amount of time
%in each behavioral state, and other identifying info for each animal. 

%Coherence calculations are calculated across time with one value per
%segment of time defined by "seg" (seg of 1 = bins of 1 second)
%Coherence is calculated between each pair of channels and then averaged
%across all channels within a layer. Multiple channel-layer assignments are
%used to account for drift. 

%Currently using all time windows when the animal was on track A and taking a weighted average based on
%the length of time in each time window 

%Inputs: Cell array of animal IDs, seg value (usually seg = 1) in seconds -
%dictates bin size for calculating coherence, cell array of filter names,
%cell array of tracks to analyze. 
%Table containing bad channels 

%Outputs: 


%filters = {'theta'}% 'fast_gamma', 'gamma' 'slow_gamma' 'ripple'};
%tracks = {'A'} %'all';   
%seg = 1;  %desired time bins in seconds


function coherency_allregions_multi_drift_byspeed(animals, seg, filters, tracks, binnstart, speedbinsize)

idx = 1;
load('bad_chans_table.mat');  %load in table with bad channels for each animal 1-64 for each shank
bad_chans = table2cell(bad_chans_table);

EC_matrix_out = 16; %adjust to reflect columns that are NaN or layer 1 in all templates 
HIP_matrix_out = 2; %adjust to reflect columns that are NaN in all templates 
%runthresh_low = 0.1;
%runthresh_high = 0.2; 

for filt = 1:length(filters)
filter = filters{filt};
disp(['starting filter ' filter])
    
    for anim = 1:length(animals)
        
    animal = animals{anim};
    disp(['starting animal ' animal])

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
    [HIPshank, ECshank]=getshankECHIP_LV(animal); %get HIP and EC                                                                                                                                                                                                                                                                        shanks for this animal
        
    [anim_windows] = get_time_windows_drift(animal, tracks);
    
        for w = 1:size(anim_windows,1)
            set = anim_windows{w,5};

            load([exp_dir '\animalECmatrix_chset' num2str(set) '.mat']);
            animalECmatrix(1:(EC_matrix_out)) = [];
            load([exp_dir '\animalCA1DGmatrix_chset' num2str(set) '.mat']);
            animalCA1DGmatrix(1:(HIP_matrix_out)) = [];
            fullmatrixlength = length(animalCA1DGmatrix) + length(animalECmatrix);
 
            run_speed = load([stim_dir 'running.mat']);
            run_speed = downsample(run_speed.running,25); %maybe downsample even more - this is now 1000Hz 
            run_bl = mode(run_speed);

            %MAKE LFP MATRIX 
            LFP =  load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(1) filter '.mat']); %load a channel just to get signal length
            LFP = LFP.filt_data;
            LFPsignals = zeros(fullmatrixlength, length(LFP)); %make a matrix to put all the LFP signals into 

            %%%Hippocampus Shank
            [ch] = getchannels_drift(animal, HIPshank, set);
            bc_sh = bc{1}{HIPshank}; %get bad channels for current shank  

            %load LFP data into LFP matrix - Hilus-Or, EC2-EC3
                 for channel = 1:length(animalCA1DGmatrix) 
                     chan_64 = animalCA1DGmatrix(channel); %get channel number from animal matrix
                     if ismember(chan_64, bc_sh) || isnan(chan_64)
                         LFPsignals(channel, :) =  NaN(1,length(LFP)); %use NaNs for bad channels or channels that don't exist
                     else
                         chan_512 = probelayout(chan_64, HIPshank);  %find ch number out of 512
                         LFP =  load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(chan_512) filter  '.mat']); %load file
                         LFPsignals(channel,:) = LFP.filt_data; %add to matrix
                     end
                 end
                 
            %%%EC Shank
                if ECshank > 0 
                    [ch] = getchannels_drift(animal, ECshank, set);
                    bc_sh = bc{1}{ECshank}; %get bad channels for current shank
                    
                     for channel = length(animalCA1DGmatrix)+1:length(animalCA1DGmatrix) + length(animalECmatrix) %start after HIP chans end    
                         chan_64 = animalECmatrix(channel-length(animalCA1DGmatrix)); %start at first value in EC matrix 
                         if isnan(chan_64) %for animals missing MEC3
                             LFPsignals(channel, :) =  NaN(1,length(LFP));
                         else
                              if ismember(chan_64, bc_sh)
                                 LFPsignals(channel, :) =  NaN(1,length(LFP)); %don't load bad channels
                             else
                             chan_512 = probelayout(chan_64, ECshank);  
                             LFP =  load([exp_dir 'LFP\' filter '\LFPvoltage_ch' num2str(chan_512) filter  '.mat']);
                             LFPsignals(channel,:) = LFP.filt_data;
                              end
                         end
                     end
                else
                     LFPsignals(length(animalCA1DGmatrix)+1:length(animalCA1DGmatrix) + length(animalECmatrix), :) = NaN;
                end   

            group = ch.group;
            sex = ch.sex;
            age = ch.age;
            
            disp(['done loading signals']) 

            t0 = anim_windows{w, 3};
            t1 = anim_windows{w, 4};
            

                if t0>0 % greater than time 0
                    LFPsignals = LFPsignals(:, (t0*1000):(t1*1000));
                    run_speed = run_speed(:, (t0*1000):(t1*1000));  %get runspeed restricted to time window for current track
                elseif t0 == 0 %if t0 is the beginning of recording 
                    LFPsignals = LFPsignals(:, 1:(t1*1000));
                    run_speed = run_speed(:, 1:(t1*1000));  %get runspeed restricted to time window for current track
                end
            
           % disp(['done restricting data to track ' track]) 
     
        Fs = 1000;
        
        %make time bins
        binsize_sec = seg; %in seconds
        binsize_samples = binsize_sec*Fs;
        num_bins = floor(length(LFPsignals)/binsize_samples); %round down to avoid extra bin at the end that coh analysis doesn't have
        %based on length of recording make bins
        run_bins = zeros(1,num_bins);   %matrix to keep avg running speed for each bin of length seg 
        n=0;
        r=1;

        %get avg running speed for each bin - corresponding to number of time bins that will be present in
        %coherency output
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
        length_run_time = length(run_times_all)*seg;
        length_nonrun_time = length(non_run_times)*seg;
        length_thresh_run_time = length(run_times_in_thresh)*seg;
        length_full = num_bins*seg;
       
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
       
        coh_all = zeros(fullmatrixlength, fullmatrixlength);
        coh_run_all = zeros(fullmatrixlength, fullmatrixlength);
        coh_run_in_thresh = zeros(fullmatrixlength, fullmatrixlength);
        coh_non_run = zeros(fullmatrixlength, fullmatrixlength);
        
        phase_all = zeros(fullmatrixlength, fullmatrixlength);
        phase_run_all =zeros(fullmatrixlength, fullmatrixlength);
        phase_run_in_thresh=zeros(fullmatrixlength, fullmatrixlength);
        phase_non_run = zeros(fullmatrixlength, fullmatrixlength);
        
        diff_threshVSnon = zeros(fullmatrixlength, fullmatrixlength);
        diff_runVSnon= zeros(fullmatrixlength, fullmatrixlength);  
        
        for ch1=1:fullmatrixlength %parfor here   %switch back to for if this doesn't work
            for ch2=1:fullmatrixlength
                 if ch2>=ch1 %loop through every pair of channels

                    data1 = LFPsignals(ch1,:); %load data for just those two channels
                    data2 = LFPsignals(ch2,:);
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
                        %behavior
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
     

        for ch1=1:fullmatrixlength  %fill out other (mirrored) half of the matrix
            for ch2=1:fullmatrixlength
                if ch2<ch1  
                    coh_all(ch1,ch2) = coh_all(ch2, ch1);
                    coh_run_all(ch1,ch2) = coh_run_all(ch2,ch1);
                    coh_run_in_thresh(ch1,ch2) = coh_run_in_thresh(ch2, ch1);
                    coh_non_run(ch1,ch2) = coh_non_run(ch2, ch1);

                    diff_threshVSnon(ch1, ch2) = diff_threshVSnon(ch2, ch1);
                    diff_runVSnon(ch1,ch2) = diff_runVSnon(ch2, ch1);

                    %FIX DIRECTIONALITY HERE SOMEHOW???
                    phase_all(ch1,ch2) = phase_all(ch2, ch1);
                    phase_run_all(ch1,ch2) = phase_run_all(ch2, ch1);
                    phase_run_in_thresh(ch1,ch2) = phase_run_in_thresh(ch2,ch1);
                    phase_non_run(ch1,ch2) = phase_non_run(ch2,ch1);
                end
            end 
        end 
          
        %ADD COHERENCE TO 3D MATRIX - one matrix for each window
        coh_all_3D(:,:,w) = coh_all;
        coh_run_all_3D(:,:,w) =coh_run_all;
        coh_run_in_thresh_3D(:,:,w) = coh_run_in_thresh;
        coh_non_run_3D(:,:,w) =coh_non_run;

        diff_threshVSnon_3D(:,:,w) = diff_threshVSnon;
        diff_runVSnon_3D(:,:,w) = diff_runVSnon;   

        phase_all_3D(:,:,w) = phase_all;
        phase_run_all_3D(:,:,w) = phase_run_all;
        phase_run_in_thresh_3D(:,:,w) = phase_run_in_thresh;
        phase_non_run_3D(:,:,w) = phase_non_run;
        
        %save length for each window/behavior state
        length_run_time_bywin(w) = length_run_time;
        length_nonrun_time_bywin(w) = length_nonrun_time;
        length_thresh_run_time_bywin(w) = length_thresh_run_time;
        length_full_bywin(w) = length_full;
        
        %save speeds by window/behavior state
        speed_all_bywin(w) = avg_speed;
        speed_run_all_bywin(w) = avg_run_speed;
        speed_run_in_thresh_bywin(w) = avg_run_speed_w_thresh;
        speed_non_run_bywin(w) = avg_speed_non_run; 
        
        disp(['done with window ' num2str(w) ' of ' num2str(size(anim_windows,1))]);
        end 
       
        %get weighted average matrix that summarizes all windows, weights
        %are based on length of data for each window
        
        %Full data regardless of running
        weights = length_full_bywin/(sum(length_full_bywin)); %calculate weights
        num_wins = length(weights); 
        %Need to deal with cases where weighted average is invalid because
        %of NaN values
        weight_matrix = bsxfun(@times,~isnan(coh_all_3D),reshape(weights,[1,1,num_wins])); %new weights matrix accounting for NaN values
        coh_all_3D(isnan(coh_all_3D)) = 0; %replace NaNs with 0 
        coh_all = sum(coh_all_3D.*weight_matrix,3)./sum(weight_matrix,3); %take weighted average across all windows, adjust weights for cases where a certain window had a NaN value
        
        phase_all_3D(isnan(phase_all_3D)) =0;
        phase_all = sum(phase_all_3D.*weight_matrix,3)./sum(weight_matrix,3);  
        
        %repeat for diff values
        %%% run vs non
        weight_matrix = bsxfun(@times,~isnan(diff_runVSnon_3D),reshape(weights,[1,1,num_wins])); 
        diff_runVSnon_3D(isnan(diff_runVSnon_3D)) = 0; 
        diff_runVSnon = sum(diff_runVSnon_3D.*weight_matrix,3)./sum(weight_matrix,3); 
        
        %%% thresh vs non
        weight_matrix = bsxfun(@times,~isnan(diff_threshVSnon_3D),reshape(weights,[1,1,num_wins])); 
        diff_threshVSnon_3D(isnan(diff_threshVSnon_3D)) = 0; 
        diff_threshVSnon = sum(diff_threshVSnon_3D.*weight_matrix,3)./sum(weight_matrix,3); 
     
        %repeat for each behavior state
        %%%All running
        weights = length_run_time_bywin/(sum(length_run_time_bywin)); %recalculate weights based on running time
        weight_matrix = bsxfun(@times,~isnan(coh_run_all_3D),reshape(weights,[1,1,num_wins])); 
        
        coh_run_all_3D(isnan(coh_run_all_3D)) = 0; 
        coh_run_all = sum(coh_run_all_3D.*weight_matrix,3)./sum(weight_matrix,3);
  
        phase_run_all_3D(isnan(phase_run_all_3D)) = 0; 
        phase_run_all = sum(phase_run_all_3D.*weight_matrix,3)./sum(weight_matrix,3);
         
        %%%Running in thresh
        weights = length_thresh_run_time_bywin/(sum(length_thresh_run_time_bywin)); %recalculate weights based on running time in thresh
        weight_matrix = bsxfun(@times,~isnan(coh_run_in_thresh_3D),reshape(weights,[1,1,num_wins])); 
        
        coh_run_in_thresh_3D(isnan(coh_run_in_thresh_3D)) = 0; 
        coh_run_in_thresh = sum(coh_run_in_thresh_3D.*weight_matrix,3)./sum(weight_matrix,3);
  
        phase_run_in_thresh_3D(isnan(phase_run_in_thresh_3D)) = 0; 
        phase_run_in_thresh = sum(phase_run_in_thresh_3D.*weight_matrix,3)./sum(weight_matrix,3);
         
        
        %%%Non running
        weights = length_nonrun_time_bywin/(sum(length_nonrun_time_bywin)); %recalculate weights based on non runnign time
        weight_matrix = bsxfun(@times,~isnan(coh_non_run_3D),reshape(weights,[1,1,num_wins])); 
        
        coh_non_run_3D(isnan(coh_non_run_3D)) = 0; 
        coh_non_run = sum(coh_non_run_3D.*weight_matrix,3)./sum(weight_matrix,3);
  
        phase_non_run_3D(isnan(phase_non_run_3D)) = 0; 
        phase_non_run = sum(phase_non_run_3D.*weight_matrix,3)./sum(weight_matrix,3);


        %save all versions of coherence
        coh_struct = struct();
        coh_struct.coh_all = coh_all;
        coh_struct.coh_run_all = coh_run_all;
        coh_struct.coh_non_run = coh_non_run;
        coh_struct.coh_run_in_thresh = coh_run_in_thresh;

        coh_struct.diff_threshVSnon = diff_threshVSnon;
        coh_struct.diff_runVSnon = diff_runVSnon;

        %phase info 
        coh_struct.phase_all = phase_all; 
        coh_struct.phase_run_all = phase_run_all;
        coh_struct.phase_run_in_thresh = phase_run_in_thresh;
        coh_struct.phase_non_run= phase_non_run;

        % save running speeds by window
        coh_struct.speed_all_bywin = speed_all_bywin;
        coh_struct.speed_run_all_bywin = speed_run_all_bywin;
        coh_struct.speed_run_in_thresh_bywin = speed_run_in_thresh_bywin;
        coh_struct.speed_non_run_bywin =speed_non_run_bywin ; 
        
        %save avg run speed for each state overall 
        coh_struct.avg_speed = nanmean(speed_all_bywin);
        coh_struct.avg_run_speed = nanmean(speed_run_all_bywin);
        coh_struct.avg_run_speed_w_thresh = nanmean(speed_run_in_thresh_bywin);
        coh_struct.avg_speed_non_run = nanmean(speed_non_run_bywin);
        
        %save amount of time mouse spent in each running state in each
        %window
        coh_struct.length_run_time_bywin = length_run_time_bywin;
        coh_struct.length_nonrun_time_bywin = length_nonrun_time_bywin;
        coh_struct.length_thresh_run_time_bywin = length_thresh_run_time_bywin;
        coh_struct.length_full_bywin = length_full_bywin;
        
        %amount of time in each state across all windows
        coh_struct.length_run_time = sum(length_run_time_bywin);
        coh_struct.length_nonrun_time = sum(length_nonrun_time_bywin);
        coh_struct.length_thresh_run_time = sum(length_thresh_run_time_bywin);
        coh_struct.length_full = sum(length_full_bywin);

        %thresholds used to define running
        coh_struct.runthresh_low = runthresh_low; 
        coh_struct.runthresh_high = runthresh_high;  
        coh_struct.baseline = run_bl; 
        
        coh_struct.group = group;
        coh_struct.sex = sex;
        coh_struct.age = age;
        coh_struct.windows = anim_windows; 
        
        %coh_struct.num_bins = num_bins;

            
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
 
        save([exp_dir '\' animal '_' filter '_' num2str(seg) 'sbins_cohmat_byrunning_drift_Atracks.mat'],'coh_struct')   
        disp(['done with ' animal ])
        
        clear coh_struct
        clear coh_all_3D
        clear coh_run_all_3D
        clear coh_run_in_thresh_3D
        clear coh_non_run_3D
        clear diff_threshVSnon_3D
        clear diff_runVSnon_3D  

        clear phase_all_3D
        clear phase_run_all_3D
        clear phase_run_in_thresh_3D
        clear phase_non_run_3D
       
        clear length_run_time_bywin
        clear length_nonrun_time_bywin
        clear length_thresh_run_time_bywin
        clear length_full_bywin
       
        clear speed_all_bywin
        clear speed_run_all_bywin
        clear speed_run_in_thresh_bywin
        clear speed_non_run_bywin 
        
        end

    end   
    disp(['done with '  filter])    
end  



