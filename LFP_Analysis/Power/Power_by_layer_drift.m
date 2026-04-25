
%For each animal and frequency
%This function calculates average power during running, during running
%using threshold for running speed, and during non-running.
%Also finds difference between power during running vs. non running.
%Repeats for each layer, and time window, plus calculates a value that is
%averaged across all data in all usable time windows. 
%Makes final table where each animal has a row for each
%layer and time window w/ corresponding power info 


%Inputs: List of animals as a cell array, list of filters as a cell array,
% tracks = cell array of desired track labels, ex: 'A', 'B', 'all', or 'A1', 'B1' (first
%instance of A track or first instance of B track etc.) tracks = {'A'}
%would direct the script to analyze all periods on the A track. 
%region = 'MEC' or 'HIPP'
%Output directory out_dir - where should the final table be saved? 

%Outputs: Table(CSV)as described above. This can then be analyzed in R.
%Power is calculated with the envelope method and hilbert transform abs(hilbert(filt_data));  

% animals for EC
%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' '3xTg1-2'};
% % %rm WT44-1 and 3x132 because no EC

%animals for hippocampus
%  animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' 'AD-WT-44-1' '3xTg132' '3xTg1-2'};
% 
% 
% filters = {'theta' 'gamma' 'fast_gamma' 'slow_gamma' 'ripple' 'fastripple'}; 
% region =  'MEC'; %or HIPP
% tracks = {'A'}; %A track, all instances  (options = A1, B1, A2, B2 etc, A,
% %%B, all)
%out_dir = 'W:\data analysis';


function Power_by_layer_drift(animals, filters, tracks, region, out_dir)

for f = 1:length(filters)
filter = filters{f};

load('bad_chans_table.mat');
bad_chans = table2cell(bad_chans_table);
    
table_row = 1;

for anim = 1:length(animals)
    animal = animals{anim};
    disp(['starting ' animal]);
    exp_dir=get_exp(animal); %get animal directory
    
     if strcmp(animal,'3xTg1-2')  %load probe layout
        load('ECHIP512_3xTg1-2.mat');
        else
        load('ECHIP512.mat');
     end
     
    stim_dir=[exp_dir 'stimuli\'];

    run_speed = load([stim_dir 'running.mat']);
    run_speed = downsample(run_speed.running,25); %this is now 1000Hz 
    run_bl = mode(run_speed);
    runthresh_low = 0.1;
    runthresh_high = 0.2;
    
    [anim_windows] = get_time_windows_drift(animal, tracks); %get time windows for each track for given animal
    
     %get shank and channel locations
    [HIPshank, ECshank]=getshankECHIP_LV(animal);
    
    if strcmp(region, 'HIPP')
        shank = HIPshank;
    elseif strcmp(region, 'MEC')
        shank = ECshank;
    end 
    
    bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
    bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks
    bc_sh = bc{1}{shank}; %get bad channels for current shank
    
    if strcmp(region, 'HIPP')
        layers = {'Or' 'Pyr' 'Rad' 'LM' 'Mol' 'GC' 'Hil'};
    elseif strcmp(region, 'MEC')
        layers = {'MEC2' 'MEC3'} ;
    end
    
    for layer_idx = 1:length(layers)  %loop through each layer  
        layer = layers{layer_idx};
        disp(['starting layer ' layer]);
   

        lyr_power_all_run_full = [];
        lyr_power_run_thresh_full =  [] ;
        lyr_power_non_running_full =  [] ;
        lyr_diff_power_allvsnon_full = [];
        lyr_diff_power_threshvsnon_full = []; 
        running_all_wins = [];    
        running_thresh_all_wins = [] ; 

        
        for r = 1:size(anim_windows,1)+1   %+1 to add extra loop to take average of all windows
            
        lyr_power_all_run = [];  %new empty variables for each layer + window combo
        lyr_power_run_thresh = [];
        lyr_power_non_running = [];
        lyr_diff_power_allvsnon = []; 
        lyr_diff_power_threshvsnon = [];


            if r <= size(anim_windows,1)

                track = anim_windows{r,2};
                t0 = anim_windows{r,3};
                t1 = anim_windows{r, 4};
                set = anim_windows{r,5};

                [ch]=getchannels_drift(animal,shank,set);  %get channel sets for given track/time

                if strcmp(region, 'HIPP')
                    MidPyr=ch.MidPyr; Pyr1=ch.Pyr1; Pyr2=ch.Pyr2; Or1=ch.Or1; Or2=ch.Or2; Rad1=ch.Rad1; Rad2=ch.Rad2;
                    LM1=ch.LM1; LM2=ch.LM2; Mol1=ch.Mol1; Mol2=ch.Mol2; GC1=ch.GC1; GC2=ch.GC2; Hil1=ch.Hil1; Hil2=ch.Hil2;
                elseif strcmp(region, 'MEC')
                    [ch]=getchannels_LV(animal,ECshank);
                    EC12=ch.EC12; EC11=ch.EC11; EC22=ch.EC22; EC21=ch.EC21; EC32=ch.EC32; EC31=ch.EC31;
                end

                group =ch.group;
                sex = ch.sex;
                age_real = ch.age;

                if strcmp(layers{layer_idx}, 'Or')
                   chans = Or2:Or1;
                elseif strcmp(layers{layer_idx}, 'Pyr')
                   chans = Pyr2:Pyr1;
                elseif strcmp(layers{layer_idx}, 'Rad')
                   chans = Rad2:Rad1;
                elseif strcmp(layers{layer_idx}, 'LM')
                   chans = LM2:LM1;
                elseif strcmp(layers{layer_idx}, 'Mol')
                   chans = Mol2:Mol1;
                elseif strcmp(layers{layer_idx}, 'GC')
                   chans = GC2:GC1;    
                elseif strcmp(layers{layer_idx}, 'Hil')
                   chans = Hil2:Hil1;
                elseif strcmp(layers{layer_idx}, 'MEC2')
                   chans = EC22:EC21;    
                elseif strcmp(layers{layer_idx}, 'MEC3')
                   chans = EC32:EC31;    
                end 
                
                %remove any bad chans from channels included in current
                %layer
                chans = chans(~ismember(chans, bc_sh));
 
                lyr_avg_power_all_run = [];  %new empty variable for avg for each new layer, 
                %overwrite for each new time window
                lyr_avg_power_run_thresh = [];
                lyr_avg_power_non_running = [];
                lyr_avg_diff_power_allvsnon = []; 
                lyr_avg_diff_power_threshvsnon = []; 
        
                %Loop through channels
                for chan = 1:length(chans)

                    p=probelayout(chans(chan),shank); %convert to corresponding channel on probe
                    load([exp_dir '\LFP\' filter '\LFPvoltage_ch' num2str(p) filter '.mat'])  %1000Hz

                    if t0 == 0  %deal with situation when t0= 0 or start 
                    filt_data = filt_data(1:(t1*1000));
                    run_speed_restricted = run_speed(1:(t1*1000));  %get runspeed restricted to time window
                    else
                    filt_data = filt_data((t0*1000):(t1*1000));
                    run_speed_restricted = run_speed((t0*1000):(t1*1000));  %get runspeed restricted to time window
                    end
                    
                    filt_data = abs(hilbert(filt_data));  %calculate power with envelope method

                    data = filt_data; 

                    %find run times within a narrow threshold 
                    run_times_all = find(run_speed_restricted > (run_bl + runthresh_low));  %anywhere 0.1 above baseline ball tracker reading - usually ~2.7 %fixed to deal with different baselines across animals
                    run_times_thresh = find(run_speed_restricted >  (run_bl + runthresh_low) & run_speed_restricted <  (run_bl + runthresh_high)); %only narrow threshold above baseline
                    non_run_times = find(run_speed_restricted < (run_bl + 0.02) & run_speed_restricted > (run_bl - 0.02)); %restricted to get out downward deflections that may or may not be running

                    length_running_time = length(run_times_all)/1000;   %get time spent in each running state - convert to s
                    length_running_thresh_time = length(run_times_thresh)/1000;
                    length_nonrunning_time = length(non_run_times)/1000;
                   
                    %ALL DATA IN TIME WINDOW
                    lyr_power_all_run(chan,:) =  data(run_times_all);  %all data points for each channel in given window
                    lyr_power_run_thresh(chan,:) = data(run_times_thresh);
                    lyr_power_non_running(chan,:) = data(non_run_times);  
                    
                    %AVG FOR ONLY THIS TIME WINDOW - one value per channel
                    %across all window time
                    lyr_avg_power_all_run(chan) =  mean(data(run_times_all));  %collect mean power for each channel in a separate variable 
                    %to average across the current time window once we've looped through all channels
                    lyr_avg_power_run_thresh(chan) =  mean(data(run_times_thresh));
                    lyr_avg_power_non_running(chan) = mean(data(non_run_times));
                    lyr_avg_diff_power_allvsnon(chan) = (mean(data(run_times_all))) -  (mean(data(non_run_times)));
                    lyr_avg_diff_power_threshvsnon(chan) = (mean(data(run_times_thresh))) -  (mean(data(non_run_times)));;
                       
                        

                disp(['done with channel ' num2str(chan) ' of ' num2str(length(chans))])
                end
                
                %ADD MEAN OF ALL CHANNELS (in layer) ACROSS WINDOW TO A MATRIX THAT WILL EVENTUALLY CONTAIN SINGLE ROW OF DATA
                %ACROSS ALL VALID TIMES
                %need to average across channels because some time windows
                %may have different numbers of channels in the same layer
                lyr_power_all_run_full = [lyr_power_all_run_full mean(lyr_power_all_run,1)]; 
                lyr_power_run_thresh_full =  [lyr_power_run_thresh_full mean(lyr_power_run_thresh,1)] ;
                lyr_power_non_running_full =  [lyr_power_non_running_full mean(lyr_power_non_running,1)] ;
                lyr_diff_power_allvsnon_full = [lyr_diff_power_allvsnon_full mean(lyr_avg_diff_power_allvsnon)];  
                lyr_diff_power_threshvsnon_full = [lyr_diff_power_threshvsnon_full mean(lyr_avg_diff_power_threshvsnon)];
                     
                running_speed_all_run = mean(run_speed_restricted(run_times_all)); %getting running speed avg for current window
                running_speed_thresh = mean(run_speed_restricted(run_times_thresh));   
            
                running_all_wins = [running_all_wins run_speed_restricted(run_times_all)  ];   %collect running speed across all valid times for each window 
                running_thresh_all_wins = [running_thresh_all_wins run_speed_restricted(run_times_thresh)] ; 
            
            
            else %final iteration of loop after going through all time windows
                
            track = 'all';   
            lyr_avg_power_all_run = lyr_power_all_run_full;
            lyr_avg_power_run_thresh = lyr_power_run_thresh_full;
            lyr_avg_power_non_running =lyr_power_non_running_full ;
            lyr_avg_diff_power_allvsnon =  lyr_diff_power_allvsnon_full;
            lyr_avg_diff_power_threshvsnon = lyr_diff_power_threshvsnon_full; 
            
            t0 = min(cell2mat(anim_windows(:,3))); 
            t1 = max(cell2mat(anim_windows(:,4))); 
            length_running_time = length(lyr_power_all_run_full)/1000;
            length_running_thresh_time = length(lyr_power_run_thresh_full)/1000;
            length_nonrunning_time = length(lyr_power_non_running_full)/1000; 
            running_speed_all_run =mean(running_all_wins); 
            running_speed_thresh =mean(running_thresh_all_wins);
              
            end   
               
              %Add info to variables that will make up the final table 
              AnimalName{table_row} = animal;
              GroupName{table_row} = group;
              Sex{table_row} = sex;
              LayerName{table_row} = layers{layer_idx};
              NumChans(table_row) = length(chans);
              RunPower(table_row) = mean(lyr_avg_power_all_run);
              RunThreshPower(table_row) = mean(lyr_avg_power_run_thresh);
              NonRunPower(table_row) = mean(lyr_avg_power_non_running);
              DiffPowerAllvsNon(table_row) = mean( lyr_avg_diff_power_allvsnon, 'omitnan');
              DiffPowerThreshvsNon(table_row) = mean( lyr_avg_diff_power_threshvsnon, 'omitnan');
              LengthRun(table_row) = length_running_time;
              LengthRunThresh(table_row) = length_running_thresh_time;
              LengthNonRun(table_row) = length_nonrunning_time; 
              RunSpeed(table_row) = running_speed_all_run;
              RunSpeedinThresh(table_row) = running_speed_thresh;
              Track{table_row} = track;  
              Age_Real(table_row) = age_real;
              Start(table_row) = t0;   %add something to deal with row that represents avg across tracks 
              End(table_row) = t1;
              
              RunThresh_low(table_row) = 0.1;
              RunThresh_high(table_row) = 0.2;
              Run_baseline(table_row) = run_bl;

           
              table_row = table_row + 1;
   
              disp(['done with track ' track]);
          
 
            end 
    
    disp(['done with layer ' layer]); 
    end 
    
   disp(['done with ' animal]);     
end
    
    
%Create Table
Table = table(AnimalName', GroupName', Sex', Age_Real', LayerName', Track', NumChans', RunPower',  RunThreshPower', NonRunPower', DiffPowerAllvsNon',  DiffPowerThreshvsNon', LengthRun', LengthRunThresh', LengthNonRun', RunSpeed', RunSpeedinThresh', Start', End', RunThresh_high', RunThresh_low', Run_baseline', 'VariableNames',{'animals','Group_name', 'Sex', 'Age_Real', 'Layer_name', 'Track', 'Num_chans', 'Run_power', 'Run_thresh_power', 'NonRun_power', 'Diff_power_allrunvsnon',  'Diff_power_threshvsnon', 'LengthRun', 'LengthRunThresh', 'LengthNonRun', 'RunSpeed', 'RunSpeedinThresh', 't0', 't1', 'RunThresh_high', 'RunThresh_low', 'Run_baseline'});

%Save Table 
cd(out_dir);
writetable(Table,['Running_Power_Test_' filter '_A_all_' region '.csv'])
end  
disp(['done with ' filter])
end 
   
    
   

