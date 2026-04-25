 %Adapted from power_over_time
%goal: to see visualize the relationship between power and running speed
%across animals and groups 

%to do - add steps to loop through windows to get LFP data and adjust
%channel-layer assignments for drift
%make sure speed value accounts for each animal's baseline 
%add something to deal with/skip bad channels 
%check how script is deciding what channel to use 

%currently script is using paul's power calculation method w/ hilbert
%transform and envelope - other option commented out
%%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' '3xTg123' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2' 'WT159' 'WT105-0' 'WT69-1' 'WT181' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132'};
%animals ={'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' 'WT126'  'WT45-1' '3xTg123' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2'  'WT105-0' 'WT69-1' '3xTg148-1' 'AD-WT-44-1' '3xTg132'};
% animals = {'WT98-0'};
% filter = 'theta';
% region = 'HIPP';
% subregion = 'LM'
% speedbinsize = 0.2; #also try 0.5
% multiple_channels = 1;  %set to 0 if you want to use only 1 channel, 1 if multiple
% binsstart = 0.1 %0 if you want the first bin to start at 0 or baseline
% ball tracker signal, 0.1 if you want to start at the lowest possible
% running speed 
% 

function Power_by_speed(animals, filter, region, subregion, speedbinsize, binsstart, multiple_channels)

idx = 1; 

load('W:\bad_chans_table.mat');
bad_chans = table2cell(bad_chans_table);


for anim = 1:length(animals)
    animal = animals{anim};
    exp_dir=get_exp(animal); %get animal directory
    
    if strcmp(animal,'3xTg1-2')  %load probe layout
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat');
    else
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');
    end
     
    stim_dir=[exp_dir 'stimuli\'];

    %load behavior data and downsample to 1000Hz - same as LFP
    load([stim_dir 'running.mat']);
    running=downsample(running,25);
    load([stim_dir 'position.mat']);
    position=downsample(position,25);
    
    run_bl = mode(running);
    
    [HIPshank, ECshank]=getshankECHIP_LV(animal); %get best LFP shanks
    
    tracks = {'A'};
    [anim_windows] = get_time_windows_drift(animal, tracks); %get time windows for each track for given animal
    
    Power_full = [];
    RunSpeed_full = [];
    
    for r = 1:size(anim_windows,1)
         
         track = anim_windows{r,2};
         t0 = anim_windows{r,3};
         t1 = anim_windows{r, 4};
         set = anim_windows{r,5};
         
         if strcmp(region, 'HIPP')
            shank = HIPshank;
            [ch]=getchannels_drift(animal,shank,set);  %get channel sets for given track/time
            MidPyr=ch.MidPyr; Pyr1=ch.Pyr1; Pyr2=ch.Pyr2; Or1=ch.Or1; Or2=ch.Or2; Rad1=ch.Rad1; Rad2=ch.Rad2;
            LM1=ch.LM1; LM2=ch.LM2; Mol1=ch.Mol1; Mol2=ch.Mol2; GC1=ch.GC1; GC2=ch.GC2; Hil1=ch.Hil1; Hil2=ch.Hil2;
         elseif strcmp(region, 'MEC')
            shank = ECshank;
            [ch]=getchannels_drift(animal,shank,set);  %get channel sets for given track/time
            EC12=ch.EC12; EC11=ch.EC11; EC22=ch.EC22; EC21=ch.EC21; EC32=ch.EC32; EC31=ch.EC31;
         end

         group =ch.group;
         sex = ch.sex;
         age = ch.age;
         
        if strcmp(subregion, 'LM')
            chans = ch.LM2:ch.LM1;
        elseif strcmp(subregion, 'Mol')
            chans = ch.Mol2:ch.Mol1;
        elseif strcmp(subregion, 'Rad')
            chans = ch.Rad2:ch.Rad1;
        elseif strcmp(subregion, 'Hil')
            chans = ch.Hil2:ch.Hil1;
        elseif strcmp(subregion, 'Pyr')
            chans = ch.Pyr2:ch.Pyr1;  
        elseif strcmp(subregion, 'Or')
            chans = ch.Or2:ch.Or1; 
        elseif strcmp(subregion, 'MEC2')
            chans = ch.EC22:ch.EC21;
        elseif strcmp(subregion, 'MEC3')
            chans = ch.EC32:ch.EC31;
        end 
        
        bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
        bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks
        bc_sh = bc{1}{shank}; %get bad channels for current shank

        chans = chans(~ismember(chans,bc_sh)); %remove bad channels
        
        if multiple_channels == 0 %take center channel
            if strcmp(subregion, 'Pyr')
                chans = ch.MidPyr; %or mid pyr channel if using pyramidal layer
            else
            chans = chans(round(length(chans)/2));
            end
        end 
       
        LFP_in_win = [];
        for c = 1:length(chans)  
            channel = chans(c);
            pc=probelayout(channel,HIPshank); %convert to corresponding channel on probe
            load([exp_dir '\LFP\' filter '\LFPvoltage_ch' num2str(pc) filter '.mat'])  %maybe fix -- is this grabbing the right channel?
            LFP_in_win(c,:) = filt_data;
        end    
        
        running_in_win = [];
        %restrict data to time window of interest 
        if t0>0 % greater than time 0
            LFP_in_win = LFP_in_win(:, (t0*1000):(t1*1000));
            running_in_win= running(:, (t0*1000):(t1*1000));  %get runspeed restricted to time window for current track
        elseif t0 == 0 %if t0 is the beginning of recording 
            LFP_in_win = LFP_in_win(:, 1:(t1*1000));
            running_in_win = running(:, 1:(t1*1000));  %get runspeed restricted to time window for current track
        end
           
        Power_in_win = [];
        for c = 1:length(chans)  %calculate power for all channels
            channel = chans(c);
            Power_in_win(c,:) = abs(hilbert(LFP_in_win(c,:)));
        end     
   
        if length(chans) > 1  %if more than one channel, average across channels 
            Power_in_win = mean(Power_in_win);
        end 
     
       Power_full = [Power_full Power_in_win];
       RunSpeed_full = [RunSpeed_full running_in_win];
      
    disp(['done with window ' num2str(r)]);
    end
    
    RunSpeed_full = RunSpeed_full - run_bl;
    
    max_speed = max(RunSpeed_full);
    min_speed = binsstart;
    
    speed_bins = min_speed:speedbinsize:max_speed;
    
    %get data in each speed bin and find power 
    for b = 1:length(speed_bins)-1
        mins = speed_bins(b);
        maxs = speed_bins(b+1);
        
        run_in_range = find(RunSpeed_full > mins & RunSpeed_full <= maxs);
        
        if isempty(run_in_range) %if no data in the current speed range 
            power_in_range = NaN;
            mpower_in_range = NaN;
            std_power_in_range = NaN;
            sem_power_in_range = NaN;
            max_power_in_range = NaN;
            min_power_in_range = NaN;
        else
            power_in_range = Power_full(run_in_range); %get power at all valid timepoints
            mpower_in_range = mean(power_in_range); %get mean across time 
            std_power_in_range = std(Power_full(run_in_range));
            sem_power_in_range = std(Power_full(run_in_range))/(sqrt(length(Power_full)));
            max_power_in_range = max(Power_full(run_in_range));
            min_power_in_range = min(Power_full(run_in_range));
        end
        %use idx to make a new value for each bin to create a table at the
        %end 
        binmax(idx) = maxs; %get high end of each bin
        binmin(idx) = mins; 
        bsize(idx) = speedbinsize; 
        pow_in_range(idx) = mpower_in_range;  
        meanspd(idx) = mean(RunSpeed_full(run_in_range)); 
        if isempty(run_in_range)
           length_time_s(idx) = NaN;
        else
            length_time_s(idx) = length(power_in_range)/1000; 
        end 
        numchans(idx) = length(chans); 
        std_power(idx) = std_power_in_range;
        max_power(idx) = max_power_in_range;
        min_power(idx) = min_power_in_range;
        sem_power(idx) = sem_power_in_range;
        Animal{idx} = animal;
        Age(idx) = age;
        Group{idx} = group;
        Sex{idx} = sex;
        Region{idx} = region;
        Subregion{idx} = subregion; 
        Filter{idx} = filter;
        idx = idx + 1; 
    end 
    
    disp(['done with ' animal])
end  



Table = table(Animal', Group', Sex', Age', Region', Subregion', Filter', numchans',  length_time_s', meanspd', pow_in_range',  binmin', binmax', bsize', std_power', min_power', max_power', sem_power', 'VariableNames',{'Animal','Group', 'Sex', 'Age', 'Region', 'Subregion', 'Filter', 'NumChans', 'Length_time_s', 'Mean_speed', 'Power_in_range',  'Speed_bin_min', 'Speed_bin_max', 'Speed_bin_size', 'Std_power_in_range', 'Min_power_in_range', 'Max_power_in_range', 'Sem_power_in_range'});

out_dir = 'W:\data analysis';
cd(out_dir);
writetable(Table,['Power_by_speed_' filter '_' region '_' subregion '_' num2str(speedbinsize) '_trackA.csv'])




end   
    
    %scatter plot for each animal plotting running speed vs. theta power
%     figure; hold on;
%     title(animal);
%     if strcmp(group, '6wt')
%     s =scatter(power_data, running_data);
%     s.MarkerEdgeColor = [0 0.4470 0.7410];
%     line = lsline;
%     line.Color = [0 0.4470 0.7410];
%     elseif strcmp(group, '83x')
%     s = scatter(power_data, running_data);
%     s.MarkerEdgeColor = [0.4940 0.1840 0.5560];
%     line = lsline;
%     line.Color = [0.4940 0.1840 0.5560];
%     elseif strcmp(group, '8wt')
%     s = scatter(power_data, running_data);
%     s.MarkerEdgeColor = [0.3 0.3 0.8];
%     line = lsline;
%     line.Color = [0.3 0.3 0.8];
%     elseif strcmp(group, '63x')
%     s = scatter(power_data, running_data);
%     s.MarkerEdgeColor = [0.8 0.5 0.6];
%     line = lsline;
%     line.Color = [0.8 0.5 0.6];
%     end
%     disp(animal)
%     disp(group)
%     [R,P] = corrcoef(power_data', running_data')
%     R_all(anim) = R(1,2);
%     P_all(anim) = P(1,2);
%     Group_name{anim} = group;
    
%     %plot with all animals in one graph
%     if strcmp(group, '6wt')
%     figure(101);
%     hold on;
%     s2 = scatter(power_data, running_data);
%     s2.MarkerEdgeColor = [0 0.4470 0.7410];
%     line2 = lsline;
%     %line2.Color = 'b';
%     elseif strcmp(group, '83x')
%     figure(101);
%     hold on;
%     s2 =scatter(power_data, running_data);
%     s2.MarkerEdgeColor = [0.4940 0.1840 0.5560];
%     line3 = lsline;
%     elseif strcmp(group, '8wt')
%     figure(101);
%     hold on;
%     s2 =scatter(power_data, running_data);
%     s2.MarkerEdgeColor = [0.3 0.3 0.8];
%     line4 = lsline;    
%     elseif strcmp(group, '63x')
%     figure(101);
%     hold on;
%     s2 =scatter(power_data, running_data);
%     s2.MarkerEdgeColor = [0.8 0.5 0.6];
%     line4 = lsline;    
%     %line3.Color = 'm';
%     %title('test');
%      end
    
    
 
 

 