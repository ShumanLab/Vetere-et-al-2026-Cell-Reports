
%This function:
%Calculates and plots CSD for each animal
%Plots summary plots by group
%Saves CSD data to a file for each animal

%Inputs: Cell array of animal IDs, filter name (currently supports 'theta',
%'fast_gamma', 'slow_gamma'), region = 'HIPP' or 'MEC'. 
%This function calls the pre_CSD function and bz_eventCSD_lv functions

%Outputs: CSD data file called animal_filter_region_CSDrunthresh.mat file in each
%animal's experiment directory. Fields within the CSD data structure
%include CSD average magnitude by layer, maximum magnitude, median? 

%CSD for each animal is calculated by taking one row of 21 linear channels
%(chooses the one with the fewest bad channels) and averaging across
%"events" which are defined as any theta cycle that occurs during running
%within the thresholded speed range. 
%The y axis on each plot is channels and the x axis is time, with 0
%representing the trough of the average theta cycle. 

%Currently what I am using for the paper is the csdcycle_max calculation,
%which takes the maximum value of the absolute value of the CSD for each
%layer within roughly one theta cycle (+/- 75ms) from time 0, which is defined as the theta
%trough. This effectively finds and quantifies the largest source/sink within each layer.
%I have also tried using the average in each layer, but that method seems to be
%more sensitive to small differences in probe location/layer assignments that may not be biologically relevant. 

% animals = {'AD-WT-44-1' '3xTg132' '3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' '3xTg1-2'};
% filter = 'theta'
% region = 'HIPP'

function CSD_bygroup(animals, filter, region)

CSD_6wt_mag=[];
CSD_8wt_mag=[];
CSD_63x_mag=[];
CSD_83x_mag=[];

idx6wt = 1;
idx8wt = 1;
idx63x = 1;
idx83x = 1;

CSDlyr_6wt=[];
CSDlyr_8wt=[];
CSDlyr_63x=[];
CSDlyr_83x = [];

CSDlyr_6wt_max=[];
CSDlyr_8wt_max=[];
CSDlyr_63x_max=[];
CSDlyr_83x_max = [];

CSDlyr_6wt_med = [];
CSDlyr_8wt_med=[];
CSDlyr_63x_med=[];
CSDlyr_83x_med = [];

CSD_6wt_avgcycle = [];
CSD_8wt_avgcycle = [];
CSD_63x_avgcycle = [];
CSD_83x_avgcycle = [];

CSD_6wt_lyrcycle = [];
CSD_8wt_lyrcycle = [];
CSD_63x_lyrcycle = [];
CSD_83x_lyrcycle = [];

CSDcycle_6wt_max = [];
CSDcycle_8wt_max = [];
CSDcycle_63x_max = [];
CSDcycle_83x_max = [];

for anim = 1: length(animals)
    animal = animals{anim};
    
    disp(['starting ' animal])
    exp_dir = get_exp(animal);
    %get properly formatted lfp data and theta trough times for current animal
    [lfp, events, group, sex, age, channels_by_layer_csd, remove_chans_csd] = pre_CSD(animal, filter, region);
    
    %get layer borders for plotting 
    
    if strcmp(region, 'HIPP')
        if ~isempty(channels_by_layer_csd{7}) %deal with one animal missing oriens
        csd_lyr_borders = [channels_by_layer_csd{2}(1) channels_by_layer_csd{3}(1) channels_by_layer_csd{4}(1) channels_by_layer_csd{5}(1) channels_by_layer_csd{6}(1) channels_by_layer_csd{7}(1)] - 0.5;
        else
        csd_lyr_borders = [channels_by_layer_csd{2}(1) channels_by_layer_csd{3}(1) channels_by_layer_csd{4}(1) channels_by_layer_csd{5}(1) channels_by_layer_csd{6}(1) ] - 0.5;
        end
    elseif strcmp(region, 'MEC')
       if isempty(channels_by_layer_csd{2}) %deal with animals missing MEC2
        csd_lyr_borders = [channels_by_layer_csd{1}(1) channels_by_layer_csd{1}(end)+1] - 0.5;
        else
        csd_lyr_borders = [channels_by_layer_csd{1}(1) channels_by_layer_csd{2}(1) channels_by_layer_csd{2}(end)+1] - 0.5;
        end
    end 
    
    
    %calculate CSD and plot for each animal
    [csd, lfpAvg] = bz_eventCSD_lv (lfp, events, animal, group, filter, csd_lyr_borders, region);
    
    
    if ~isempty(remove_chans_csd) %remove rows surrounding any bad channels from averages
        csd.data(:, remove_chans_csd) = NaN; 
    end 
    
    csd_mid = csd.data(round(size(csd.data,1)/2)-10:round(size(csd.data,1)/2)+10, :); %get ~20 center columns of CSD data
    csd_mag = mean(csd_mid,1); %take mean to get single value for each channel
    
    %broader version that takes all time around ~a single oscillation cycle
    %instead of just center columns 
    if strcmp(filter, 'theta') 
        csd_cycle = abs(csd.data(round(size(csd.data,1)/2)-75:round(size(csd.data,1)/2)+75, :)); %get center columns of CSD data - around one theta cycle
    elseif strcmp(filter, 'fast_gamma')
        csd_cycle = abs(csd.data(round(size(csd.data,1)/2)-10:round(size(csd.data,1)/2)+10, :));
    elseif strcmp(filter, 'slow_gamma')
        csd_cycle = abs(csd.data(round(size(csd.data,1)/2)-20:round(size(csd.data,1)/2)+20, :));
    end 
    
   csd_mag_cycle = mean(csd_cycle, 1); 
      
   %plot csd magnitude for animal
   figure('Name', ([animal ' ' group ' CSD magnitude (mid 20 rows)']));
   if strcmp(group, '6wt')
       plot(csd_mag, 1:19, 'color', [0.3 0.5 0.8])
   elseif strcmp(group, '63x')
       plot(csd_mag, 1:19, 'color', [0.9 0.6 0.7])
   elseif strcmp(group, '8wt')
       plot(csd_mag, 1:19, 'color', [0.3 0.2 0.6])
   elseif strcmp(group, '83x')
       plot(csd_mag, 1:19, 'color', [0.4 0 0.5])
   end  
   title([animal ' ' group ' CSD magnitude (mid 20 rows)'])
   xlabel('CSD Magnitude');ylabel('Channel');
   
   %plot csd magnitude (absolute value across one oscillation cycle)
   figure('Name', ([animal ' ' group ' CSD magnitude (abs value within 1 cycle)']));
   if strcmp(group, '6wt')
       plot(csd_mag_cycle, 1:19, 'color', [0.3 0.5 0.8])
   elseif strcmp(group, '63x')
       plot(csd_mag_cycle, 1:19, 'color', [0.9 0.6 0.7])
   elseif strcmp(group, '8wt')
       plot(csd_mag_cycle, 1:19, 'color', [0.3 0.2 0.6])
   elseif strcmp(group, '83x')
       plot(csd_mag_cycle, 1:19, 'color', [0.4 0 0.5])
   end  
   title([animal ' ' group ' CSD magnitude (abs value within 1 cycle)'])
   xlabel('CSD Magnitude');ylabel('Channel');  
    
   %add each animal's avg csd by layer (layer x time) to a matrix for each group - single value per
   %row per layer per animal
    
    if strcmp(region, 'HIPP')
        Hil_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{1}),2);
        GC_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{2}),2);
        Mol_csd_avg =nanmean(csd.data(:,channels_by_layer_csd{3}),2);
        LM_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{4}),2);
        Rad_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{5}),2);
        Pyr_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{6}),2);
        Or_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{7}),2);

        if isempty(Or_csd_avg) %deal with one animal missing Oriens
            Or_csd_avg = NaN;
        end 

        csdlyr_avg = [Hil_csd_avg GC_csd_avg Mol_csd_avg LM_csd_avg Rad_csd_avg Pyr_csd_avg Or_csd_avg];
    elseif strcmp(region, 'MEC')
        MEC2_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{1}),2);
        MEC3_csd_avg = nanmean(csd.data(:,channels_by_layer_csd{2}),2);
        
        if isempty(MEC3_csd_avg) %deal with animals missing mec3
            MEC3_csd_avg = NaN;
        end 

        csdlyr_avg = [MEC2_csd_avg MEC3_csd_avg];
    end     
    
    %add each animal's full csd (channels x time) into a cell array - matrix of channels by
     %time for each animal
    %add each animals averaged csd (layerx x time) into a cell array
    if group == '6wt'
    CSD_6wt_mat{idx6wt}= csd.data;
    CSD_6wt_lyravg{idx6wt}= csdlyr_avg;
    idx6wt = idx6wt + 1;
    elseif group == '8wt'
    CSD_8wt_mat{idx8wt}= csd.data;
    CSD_8wt_lyravg{idx8wt}=  csdlyr_avg;
    idx8wt = idx8wt + 1;
    elseif group == '63x'
    CSD_63x_mat{idx63x}= csd.data;
    CSD_63x_lyravg{idx63x}= csdlyr_avg;
    idx63x = idx63x + 1;
    elseif group == '83x'
    CSD_83x_mat{idx83x}= csd.data;
    CSD_83x_lyravg{idx83x}= csdlyr_avg;
    idx83x = idx83x + 1;
    end
  
    %add each animal's avg csd mag by layer to a matrix for each group - single value per
    %LAYER per animal
    if strcmp(region, 'HIPP')
        Hil_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{1})));
        GC_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{2})));
        Mol_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{3})));
        LM_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{4})));
        Rad_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{5})));
        Pyr_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{6})));
        Or_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{7})));

        if isempty(Or_csd_mag) %deal with one animal missing Oriens
            Or_csd_mag = NaN;
        end 

        csdlyr_mag = [Hil_csd_mag GC_csd_mag Mol_csd_mag LM_csd_mag Rad_csd_mag Pyr_csd_mag Or_csd_mag];
    elseif strcmp(region, 'MEC')
        MEC2_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{1})));
        MEC3_csd_mag = nanmean(nanmean(csd_mid(:,channels_by_layer_csd{2})));
      
        if isempty(MEC3_csd_mag) %deal with animals missing MEC3
            MEC3_csd_mag = NaN;
        end 

        csdlyr_mag = [MEC2_csd_mag MEC3_csd_mag];
    end    
    
    
    %repeat for max absolute value for each layer 
    %find largest value (either positive or negative)and take only that
    %value, keeping its sign 
    
    csdlyr_max = [];
    for lyr = 1:length(channels_by_layer_csd)
        lyr_csd = csd_mid(:,channels_by_layer_csd{lyr}); %get columns for current layer
        if isempty(lyr_csd)
            csdlyr_max(lyr) = NaN;
        elseif isnan(nanmean(nanmean(lyr_csd))) %deal with scenario where data is all NaNs
            csdlyr_max(lyr) = NaN;
        else
        [val] = max(max(abs(lyr_csd)));  %find value that has highest abs value
        max_ind = find(abs(lyr_csd)== val); %find index of that value
        max_val = lyr_csd(max_ind); %get that value, along with its original sign 
        csdlyr_max(lyr) = max_val;
        end
    end 
    

    %repeat for median
    csdlyr_med = [];
     for lyr = 1:length(channels_by_layer_csd)
        lyr_csd = csd_mid(:,channels_by_layer_csd{lyr}); %get columns for current layer
        if isempty(lyr_csd)
            csdlyr_med(lyr) = NaN;
        elseif isnan(nanmean(nanmean(lyr_csd))) %deal with scenario where data is all NaNs
            csdlyr_med(lyr) = NaN;
        else
        csdlyr_med(lyr) =  median(median(lyr_csd));
        end
     end 
         
    %add each animal's avg abs value of csd across an oscillation cycle by layer to a matrix for each group - single value per
    %LAYER per animal
    
    if strcmp(region, 'HIPP')
        Hil_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{1})));
        GC_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{2})));
        Mol_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{3})));
        LM_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{4})));
        Rad_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{5})));
        Pyr_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{6})));
        Or_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{7})));

        if isempty(Or_csd_cycle) %deal with one animal missing Oriens
            Or_csd_cycle = NaN;
        end 

        csdlyr_cycle = [Hil_csd_cycle GC_csd_cycle Mol_csd_cycle LM_csd_cycle Rad_csd_cycle Pyr_csd_cycle Or_csd_cycle];
    elseif strcmp(region, 'MEC')
        MEC2_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{1})));
        MEC3_csd_cycle = nanmean(nanmean(csd_cycle(:,channels_by_layer_csd{2})));
        
        if isempty(MEC3_csd_cycle) %deal with one animal missing Oriens
            MEC3_csd_cycle = NaN;
        end 

        csdlyr_cycle = [MEC2_csd_cycle MEC3_csd_cycle];
    end 
     
   %plot csd avg by layer (absolute value across one oscillation cycle)
   figure('Name', ([animal ' ' group ' Avg CSD magnitude by layer (abs value within 1 cycle)']));
   if strcmp(group, '6wt')
       plot(csdlyr_cycle, 1:7, 'color', [0.3 0.5 0.8])
   elseif strcmp(group, '63x')
       plot(csdlyr_cycle, 1:7, 'color', [0.9 0.6 0.7])
   elseif strcmp(group, '8wt')
       plot(csdlyr_cycle, 1:7, 'color', [0.3 0.2 0.6])
   elseif strcmp(group, '83x')
       plot(csdlyr_cycle, 1:7, 'color', [0.4 0 0.5])
   end  
   title([animal ' ' group 'Avg CSD magnitude by layer (abs value within 1 cycle)'])
   xlabel('CSD Magnitude');ylabel('Channel');  
    
    csdcycle_max = [];
    for lyr = 1:length(channels_by_layer_csd)
        lyr_csd = csd_cycle(:,channels_by_layer_csd{lyr}); %get columns for current layer
        if isempty(lyr_csd)
            csdcycle_max(lyr) = NaN;
        elseif isnan(nanmean(nanmean(lyr_csd))) %deal with scenario where data is all NaNs
            csdcycle_max(lyr) = NaN;
        else
        [max_val] = max(max((lyr_csd)));  %find value that has highest value
        csdcycle_max(lyr) = max_val;
        end
    end 
    
    %plot csd avg by layer (absolute value across one oscillation cycle)
   figure('Name', ([animal ' ' group ' Max CSD magnitude by layer (abs value - 1 cycle)']));
   if strcmp(group, '6wt')
       plot(csdcycle_max, 1:7, 'color', [0.3 0.5 0.8])
   elseif strcmp(group, '63x')
       plot(csdcycle_max, 1:7, 'color', [0.9 0.6 0.7])
   elseif strcmp(group, '8wt')
       plot(csdcycle_max, 1:7, 'color', [0.3 0.2 0.6])
   elseif strcmp(group, '83x')
       plot(csdcycle_max, 1:7, 'color', [0.4 0 0.5])
   end  
   title([animal ' ' group 'Max CSD magnitude by layer (abs value - 1 cycle)'])
   xlabel('CSD Magnitude');ylabel('Channel');  
    
    
    %add data to avg magnitude matrix for each group (layer x time)
    if group == '6wt'
    CSDlyr_6wt=[ CSDlyr_6wt; csdlyr_mag];
    elseif group == '8wt'
    CSDlyr_8wt=[CSDlyr_8wt; csdlyr_mag];
    elseif group == '63x'
    CSDlyr_63x=[CSDlyr_63x; csdlyr_mag];
    elseif group == '83x'
    CSDlyr_83x=[CSDlyr_83x; csdlyr_mag];
    end
    
    %add data to max magnitude matrix for each group  
    if group == '6wt'
    CSDlyr_6wt_max=[ CSDlyr_6wt_max; csdlyr_max];
    elseif group == '8wt'
    CSDlyr_8wt_max=[CSDlyr_8wt_max; csdlyr_max];
    elseif group == '63x'
    CSDlyr_63x_max=[CSDlyr_63x_max; csdlyr_max];
    elseif group == '83x'
    CSDlyr_83x_max=[CSDlyr_83x_max; csdlyr_max];
    end
    
     %add data to median magnitude matrix for each group  
    if group == '6wt'
    CSDlyr_6wt_med=[ CSDlyr_6wt_med; csdlyr_med];
    elseif group == '8wt'
    CSDlyr_8wt_med=[CSDlyr_8wt_med; csdlyr_med];
    elseif group == '63x'
    CSDlyr_63x_med=[CSDlyr_63x_med; csdlyr_med];
    elseif group == '83x'
    CSDlyr_83x_med=[CSDlyr_83x_med; csdlyr_med];
    end
    
   %add each animal's csd magnitude (avg of 5 time points (ms) around time zero) to a matrix for each group - single value per
    %channel per animal
    if group == '6wt'
    CSD_6wt_mag=[ CSD_6wt_mag; csd_mag];
    elseif group == '8wt'
    CSD_8wt_mag=[CSD_8wt_mag; csd_mag];
    elseif group == '63x'
    CSD_63x_mag=[CSD_63x_mag; csd_mag];
    elseif group == '83x'
    CSD_83x_mag=[CSD_83x_mag; csd_mag];
    end
    
    %add each animal's CSD magnitude (avg of abs val of ~an oscillation cycle's worth of time points (ms) around time zero) to a matrix 
    %for each group - single value per channel per animal
    if group == '6wt'
    CSD_6wt_avgcycle=[ CSD_6wt_avgcycle; csd_mag_cycle];
    elseif group == '8wt'
    CSD_8wt_avgcycle=[CSD_8wt_avgcycle; csd_mag_cycle];
    elseif group == '63x'
    CSD_63x_avgcycle=[CSD_63x_avgcycle; csd_mag_cycle];
    elseif group == '83x'
    CSD_83x_avgcycle=[CSD_83x_avgcycle; csd_mag_cycle];
    end
 
   %add each animal's CSD magnitude (avg of absolute val of ~an oscillation cycle's worth of time points (ms) around time zero) to a matrix 
    %for each group - single value per LAYER per animal
    if group == '6wt'
    CSD_6wt_lyrcycle=[ CSD_6wt_lyrcycle; csdlyr_cycle];
    elseif group == '8wt'
    CSD_8wt_lyrcycle=[CSD_8wt_lyrcycle; csdlyr_cycle];
    elseif group == '63x'
    CSD_63x_lyrcycle=[CSD_63x_lyrcycle; csdlyr_cycle];
    elseif group == '83x'
    CSD_83x_lyrcycle=[CSD_83x_lyrcycle; csdlyr_cycle];
    end
    
    %add data to max magnitude matrix for each group (around an
    %oscillation cycle)
    if group == '6wt'
    CSDcycle_6wt_max=[ CSDcycle_6wt_max; csdcycle_max];
    elseif group == '8wt'
    CSDcycle_8wt_max=[CSDcycle_8wt_max; csdcycle_max];
    elseif group == '63x'
    CSDcycle_63x_max=[CSDcycle_63x_max; csdcycle_max];
    elseif group == '83x'
    CSDcycle_83x_max=[CSDcycle_83x_max; csdcycle_max];
    end
    

csd_struct = struct();
csd_struct.avgmagbylyr = csdlyr_mag;
csd_struct.maxmagbylyr = csdlyr_max;
csd_struct.medmagbylyr = csdlyr_med;
csd_struct.avgmagbylyr_cycle = csdlyr_cycle;
csd_struct.maxmagbylyr_cycle = csdcycle_max;
csd_struct.group = group;
csd_struct.age = age;
csd_struct.sex = sex;

save([exp_dir '\' animal '_' filter '_' region '_CSDrunthresh.mat'],'csd_struct') ;  

clear  csd_struct 

end


%% plotting by group - csd magnitude - not adjusted for uneven layers! 
%these plots are crude and not adjusted for unequal numbers of channels per layer across
%animals, so interpret with caution!
%Similar plots where data is simplified to one row per layer per animal can
%be found below to deal with this issue. 

%regular means and sem
CSD_63x_mean = mean(CSD_63x_mag, 'omitnan'); 
CSD_6wt_mean =mean(CSD_6wt_mag, 'omitnan'); 
CSD_83x_mean =mean(CSD_83x_mag, 'omitnan');
CSD_8wt_mean = mean(CSD_8wt_mag, 'omitnan');

CSD_63x_std = std(CSD_63x_mag, 'omitnan'); 
CSD_6wt_std =std(CSD_6wt_mag, 'omitnan'); 
CSD_83x_std =std(CSD_83x_mag, 'omitnan');
CSD_8wt_std = std(CSD_8wt_mag, 'omitnan');

CSD_63x_sem = CSD_63x_std/sqrt(size(CSD_63x_mag,1)); 
CSD_6wt_sem =CSD_6wt_std/sqrt(size(CSD_6wt_mag,1)); 
CSD_83x_sem =CSD_83x_std/sqrt(size(CSD_83x_mag,1));
CSD_8wt_sem = CSD_8wt_std/sqrt(size(CSD_8wt_mag,1));

%absolute value means and sem
CSD_63x_mean_abs = mean(abs(CSD_63x_mag), 'omitnan'); 
CSD_6wt_mean_abs =mean(abs(CSD_6wt_mag), 'omitnan'); 
CSD_83x_mean_abs =mean(abs(CSD_83x_mag), 'omitnan');
CSD_8wt_mean_abs = mean(abs(CSD_8wt_mag), 'omitnan');

CSD_63x_std_abs = std(abs(CSD_63x_mag), 'omitnan'); 
CSD_6wt_std_abs =std(abs(CSD_6wt_mag), 'omitnan'); 
CSD_83x_std_abs =std(abs(CSD_83x_mag), 'omitnan');
CSD_8wt_std_abs = std(abs(CSD_8wt_mag), 'omitnan');

CSD_63x_sem_abs = CSD_63x_std_abs/sqrt(size(CSD_63x_mag,1)); 
CSD_6wt_sem_abs =CSD_6wt_std_abs/sqrt(size(CSD_6wt_mag,1)); 
CSD_83x_sem_abs =CSD_83x_std_abs/sqrt(size(CSD_83x_mag,1));
CSD_8wt_sem_abs = CSD_8wt_std_abs/sqrt(size(CSD_8wt_mag,1));



plottitle1 = ['CSD Mag by animal - uneven layers accross animals'];
f=figure('Name',[' CSD by animal - uneven layers accross animals']);

for row=1:size(CSD_6wt_mag, 1)
    plot(CSD_6wt_mag(row,:), (1:length(CSD_6wt_mag)), 'color', [0.3 0.5 0.8])
    yticks(1:1:length(CSD_6wt_mag))
    hold on;
end
hold on;
for row=1:size(CSD_63x_mag, 1)
    plot(CSD_63x_mag(row,:), (1:length(CSD_6wt_mag)),'color',[0.9 0.6 0.7])
    hold on;
end
hold on;
for row=1:size(CSD_83x_mag, 1)
    plot(CSD_83x_mag(row, :), (1:length(CSD_6wt_mag)), 'color',[0.4 0 0.5])
    hold on;
end
for row=1:size(CSD_8wt_mag, 1)
    plot(CSD_8wt_mag(row, :), (1:length(CSD_6wt_mag)),  'color',[0.3 0.2 0.6])
    hold on;
end
hold on;
plot(CSD_63x_mean, (1:length(CSD_6wt_mag)),'color',[0.9 0.6 0.7], 'LineWidth', 3)
hold on;
plot(CSD_83x_mean, (1:length(CSD_6wt_mag)),'color',[0.4 0 0.5], 'LineWidth', 3)
hold on;
plot(CSD_8wt_mean, (1:length(CSD_6wt_mag)),'color',[0.3 0.2 0.6], 'LineWidth', 3)
hold on;
plot(CSD_6wt_mean, (1:length(CSD_6wt_mag)),'color',[0.3 0.5 0.8], 'LineWidth', 3)


hold on;

%plot error bars

patch([CSD_63x_mean-CSD_63x_sem fliplr(CSD_63x_mean+CSD_63x_sem)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.9 0.6 0.7], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSD_83x_mean-CSD_83x_sem fliplr(CSD_83x_mean+CSD_83x_sem)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.4 0 0.5], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSD_6wt_mean-CSD_6wt_sem fliplr(CSD_6wt_mean+CSD_6wt_sem)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.3 0.5 0.8], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSD_8wt_mean-CSD_8wt_sem fliplr(CSD_8wt_mean+CSD_8wt_sem)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.3 0.2 0.6], 'FaceAlpha',0.5, 'EdgeColor','none')

title(plottitle1);
xlabel('CSD')
ylabel('Channel')


%plot again with absolute value

plottitle2 = ['Abs Val CSD Mag by animal - uneven layers accross animals'];
f=figure('Name',['Abs Val CSD by animal - uneven layers accross animals']);

for row=1:size(CSD_6wt_mag, 1)
    plot(abs(CSD_6wt_mag(row,:)), (1:length(CSD_6wt_mag)), 'color', [0.3 0.5 0.8])
    yticks(1:1:length(CSD_6wt_mag))
    hold on;
end
hold on;
for row=1:size(CSD_63x_mag, 1)
    plot(abs(CSD_63x_mag(row,:)), (1:length(CSD_6wt_mag)),'color',[0.9 0.6 0.7])
    hold on;
end
hold on;
for row=1:size(CSD_83x_mag, 1)
    plot(abs(CSD_83x_mag(row, :)), (1:length(CSD_6wt_mag)), 'color',[0.4 0 0.5])
    hold on;
end
for row=1:size(CSD_8wt_mag, 1)
    plot(abs(CSD_8wt_mag(row, :)), (1:length(CSD_6wt_mag)),  'color',[0.3 0.2 0.6])
    hold on;
end
hold on;
plot(CSD_63x_mean_abs, (1:length(CSD_6wt_mag)),'color',[0.9 0.6 0.7], 'LineWidth', 3)
hold on;
plot(CSD_83x_mean_abs, (1:length(CSD_6wt_mag)),'color',[0.4 0 0.5], 'LineWidth', 3)
hold on;
plot(CSD_8wt_mean_abs, (1:length(CSD_6wt_mag)),'color',[0.3 0.2 0.6], 'LineWidth', 3)
hold on;
plot(CSD_6wt_mean_abs, (1:length(CSD_6wt_mag)),'color',[0.3 0.5 0.8], 'LineWidth', 3)


hold on;

%plot error bars

patch([CSD_63x_mean_abs-CSD_63x_sem_abs fliplr(CSD_63x_mean_abs+CSD_63x_sem_abs)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.9 0.6 0.7], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSD_83x_mean_abs-CSD_83x_sem_abs fliplr(CSD_83x_mean_abs+CSD_83x_sem_abs)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.4 0 0.5], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSD_6wt_mean_abs-CSD_6wt_sem_abs fliplr(CSD_6wt_mean_abs+CSD_6wt_sem_abs)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.3 0.5 0.8], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSD_8wt_mean_abs-CSD_8wt_sem_abs fliplr(CSD_8wt_mean_abs+CSD_8wt_sem_abs)], [(1:length(CSD_6wt_mag)) fliplr(1:length(CSD_6wt_mag))], [0.3 0.2 0.6], 'FaceAlpha',0.5, 'EdgeColor','none')

title(plottitle2);
xlabel('CSD')
ylabel('Channel')



%% plotting by group - full csd - not adjusted for layers

% Make Full CSD heatmaps by group
M6wt3D = cat(3, CSD_6wt_mat{:}); %Put all the 6 month WT matrices into 3D
MeanCSD6wt = mean(M6wt3D, 3, 'omitnan'); %and then average them to make one new mean matrix

M8wt3D = cat(3, CSD_8wt_mat{:}); 
MeanCSD8wt = mean(M8wt3D, 3, 'omitnan'); 

M63x3D = cat(3, CSD_63x_mat{:}); %Put all the 6 month WT matrices into 3D
MeanCSD63x = mean(M63x3D, 3, 'omitnan'); %and then average them to make one new mean matrix

M83x3D = cat(3, CSD_83x_mat{:}); %Put all the 6 month WT matrices into 3D
MeanCSD83x = mean(M83x3D, 3, 'omitnan'); %and then average them to make one new mean matrix

%plot
if strcmp(filter,'theta')
    twin = [200 200];
elseif strcmp(filter,'fast_gamma')
    twin = [20 20];
elseif strcmp(filter,'slow_gamma')
    twin = [40 40];
end

samplingRate = 1000;
taxis = (-(twin(1)/samplingRate):(1/samplingRate):(twin(2)/samplingRate))*1e3;
cmax = max(max(MeanCSD6wt)); 
cmin = min(min(MeanCSD6wt));

group = '6wt';
figure('Name', 'Mean CSD 6 mo Wt');
contourf(taxis,1:size(MeanCSD6wt,2),MeanCSD6wt',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
%set(gca,'YDir','reverse');xlabel('time (ms)');ylabel('Channel');title('CSD'); 
plot([0 0],[1 size(MeanCSD6wt,2)],'--k');hold on;
contourcbar('Ticks', []) ;
%set(gca,'visible','off');
xlabel('Time (ms)');ylabel('Channel');title(['CSD Mean '  group ' not adjusted for uneven layers']);  
axis xy

group = '63x';
figure('Name', 'Mean CSD 6 mo 3xTg');
contourf(taxis,1:size(MeanCSD63x,2),MeanCSD63x',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
%set(gca,'YDir','reverse');xlabel('Time (ms)');ylabel('Channel');title('CSD'); 
contourcbar('Ticks', []);
plot([0 0],[1 size(MeanCSD63x,2)],'--k');hold on;
%set(gca,'visible','off');
xlabel('Time (ms)');ylabel('Channel');title(['CSD Mean '  group ' not adjusted for uneven layers']);  
axis xy


group = '8wt';
figure('Name', 'Mean CSD 8 mo WT');
contourf(taxis,1:size(MeanCSD8wt,2),MeanCSD8wt',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
contourcbar('Ticks', []) ;
%set(gca,'YDir','reverse');xlabel('Time (ms)');ylabel('Channel');title('CSD'); 
plot([0 0],[1 size(MeanCSD8wt,2)],'--k');hold on;
%set(gca,'visible','off');
xlabel('Time (ms)');ylabel('Channel');title(['CSD Mean '  group ' not adjusted for uneven layers']);  
axis xy

group = '83x';
figure('Name', 'Mean CSD 8 mo 3xTg');
contourf(taxis,1:size(MeanCSD83x,2),MeanCSD83x',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
contourcbar('Ticks', []) ;
%set(gca,'YDir','reverse');xlabel('Time (ms)');ylabel('Channel');title('CSD'); 
plot([0 0],[1 size(MeanCSD83x,2)],'--k');hold on;
%set(gca,'visible','off');
xlabel('Time (ms)');ylabel('Channel');title(['CSD Mean '  group ' not adjusted for uneven layers']);  
axis xy


    
   
%% plotting by group - full csd - adjusted for layers - one row per layer

% Make Full CSD heatmaps by group
M6wt3D = cat(3, CSD_6wt_lyravg{:}); %Put all the 6 month WT matrices into 3D
MeanCSD6wt = mean(M6wt3D, 3, 'omitnan'); %and then average them to make one new mean matrix

M8wt3D = cat(3, CSD_8wt_lyravg{:}); 
MeanCSD8wt = mean(M8wt3D, 3, 'omitnan'); 

M63x3D = cat(3, CSD_63x_lyravg{:}); %Put all the 6 month WT matrices into 3D
MeanCSD63x = mean(M63x3D, 3, 'omitnan'); %and then average them to make one new mean matrix

M83x3D = cat(3, CSD_83x_lyravg{:}); %Put all the 6 month WT matrices into 3D
MeanCSD83x = mean(M83x3D, 3, 'omitnan'); %and then average them to make one new mean matrix

%plot
if strcmp(filter,'theta')
    twin = [200 200];
elseif strcmp(filter,'fast_gamma')
    twin = [20 20];
elseif strcmp(filter,'slow_gamma')
    twin = [40 40];
end

samplingRate = 1000;
taxis = (-(twin(1)/samplingRate):(1/samplingRate):(twin(2)/samplingRate))*1e3;
cmax = max(max(MeanCSD6wt)); 
cmin = min(min(MeanCSD6wt)); 

group = '6wt';
figure('Name', 'Mean CSD 6 mo WT Avg by Layer');
%subplot(1,2,1);
contourf(taxis,1:size(MeanCSD6wt,2),MeanCSD6wt',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
contourcbar('Ticks', []) ;
%set(gca,'YDir','reverse');xlabel('Time (ms)');ylabel('Channel');title('CSD'); 
plot([0 0],[1 size(MeanCSD6wt,2)],'--k');hold on;
%set(gca,'visible','off');
xticks([-200 0 200]);
xlabel('Time (ms)', 'FontSize', 18);ylabel('Layer', 'FontSize', 18);title(['CSD Mean '  group ' avg by layer '], 'FontSize', 20);  
axis xy
ax.Fontsize = 18;
if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end


group = '63x';
figure('Name', 'Mean CSD 6 mo 3xTg Avg by Layer');
%subplot(1,2,1);
contourf(taxis,1:size(MeanCSD63x,2),MeanCSD63x',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
%set(gca,'YDir','reverse');xlabel('Time (ms)');ylabel('Channel');title('CSD'); 
plot([0 0],[1 size(MeanCSD63x,2)],'--k');hold on;
contourcbar('Ticks', []) ;
%set(gca,'visible','off');
xticks([-200 0 200]);
xlabel('Time (ms)', 'FontSize', 18);ylabel('Layer', 'FontSize', 18);title(['CSD Mean '  group ' avg by layer'], 'FontSize', 20);  
axis xy
ax.Fontsize = 18;
if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end


group = '8wt';
figure('Name', 'Mean CSD 8 mo WT Avg by Layer');
%subplot(1,2,1);
contourf(taxis,1:size(MeanCSD8wt,2),MeanCSD8wt',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
%set(gca,'YDir','reverse');xlabel('Time (ms)');ylabel('Channel');title('CSD'); 
plot([0 0],[1 size(MeanCSD8wt,2)],'--k');hold on;
%set(gca,'visible','off');
xticks([-200 0 200]);
contourcbar('Ticks', []) ;
xlabel('Time (ms)', 'FontSize', 18);ylabel('Layer', 'FontSize', 18);title(['CSD Mean '  group ' avg by layer'], 'FontSize', 20);  
axis xy
ax.Fontsize = 18;
if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end


group = '83x';
figure('Name', 'Mean CSD 8 mo 3xTg Avg by Layer');
%subplot(1,2,1);
contourf(taxis,1:size(MeanCSD83x,2),MeanCSD83x',40,'LineColor','none');hold on;
colormap jet; caxis([cmin cmax]);
%set(gca,'YDir','reverse');xlabel('Time (ms)');ylabel('Channel');title('CSD'); 
plot([0 0],[1 size(MeanCSD83x,2)],'--k');hold on;
contourcbar('Ticks', []) ;
%set(gca,'visible','off');
xticks([-200 0 200]);
xlabel('Time (ms)', 'FontSize', 18);ylabel('Layer', 'FontSize', 18);title(['CSD Mean '  group ' avg by layer'], 'FontSize', 20);  
axis xy
ax.Fontsize = 18;
if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end
   


%% plotting by group - csd magnitude averaged by layer 

%regular means and sem
CSDlyr_63x_mean = mean(CSDlyr_63x, 'omitnan'); 
CSDlyr_6wt_mean = mean(CSDlyr_6wt, 'omitnan'); 
CSDlyr_83x_mean = mean(CSDlyr_83x, 'omitnan');
CSDlyr_8wt_mean = mean(CSDlyr_8wt, 'omitnan');

CSDlyr_63x_std = std(CSDlyr_63x, 'omitnan'); 
CSDlyr_6wt_std = std(CSDlyr_6wt, 'omitnan'); 
CSDlyr_83x_std = std(CSDlyr_83x, 'omitnan');
CSDlyr_8wt_std = std(CSDlyr_8wt, 'omitnan');

CSDlyr_63x_sem = CSDlyr_63x_std/sqrt(size(CSDlyr_63x,1)); 
CSDlyr_6wt_sem = CSDlyr_6wt_std/sqrt(size(CSDlyr_6wt,1)); 
CSDlyr_83x_sem = CSDlyr_83x_std/sqrt(size(CSDlyr_83x,1));
CSDlyr_8wt_sem = CSDlyr_8wt_std/sqrt(size(CSDlyr_8wt,1));



plottitle3 = ['CSD Mag by animal - avg by layer'];
f=figure('Name',[' CSD by animal - avg by layer']);

for row=1:size(CSDlyr_6wt, 1)
    plot(CSDlyr_6wt(row,:), (1:size(CSDlyr_6wt,2)), 'color', [0.3 0.5 0.8])
    yticks(1:1:length(CSDlyr_6wt))
    hold on;
end
hold on;
for row=1:size(CSDlyr_63x, 1)
    plot(CSDlyr_63x(row,:), (1:size(CSDlyr_6wt,2)),'color',[0.9 0.6 0.7])
    hold on;
end
hold on;
for row=1:size(CSDlyr_83x, 1)
    plot(CSDlyr_83x(row, :), (1:size(CSDlyr_6wt,2)), 'color',[0.4 0 0.5])
    hold on;
end
for row=1:size(CSDlyr_8wt, 1)
    plot(CSDlyr_8wt(row, :), (1:size(CSDlyr_6wt,2)),  'color',[0.3 0.2 0.6])
    hold on;
end
hold on;
plot(CSDlyr_63x_mean, (1:size(CSDlyr_6wt,2)),'color',[0.9 0.6 0.7], 'LineWidth', 3)
hold on;
plot(CSDlyr_83x_mean, (1:size(CSDlyr_6wt,2)),'color',[0.4 0 0.5], 'LineWidth', 3)
hold on;
plot(CSDlyr_8wt_mean, (1:size(CSDlyr_6wt,2)),'color',[0.3 0.2 0.6], 'LineWidth', 3)
hold on;
plot(CSDlyr_6wt_mean, (1:size(CSDlyr_6wt,2)),'color',[0.3 0.5 0.8], 'LineWidth', 3)


hold on;

%plot error bars

patch([CSDlyr_63x_mean-CSDlyr_63x_sem fliplr(CSDlyr_63x_mean+CSDlyr_63x_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.9 0.6 0.7], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_83x_mean-CSDlyr_83x_sem fliplr(CSDlyr_83x_mean+CSDlyr_83x_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.4 0 0.5], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_6wt_mean-CSDlyr_6wt_sem fliplr(CSDlyr_6wt_mean+CSDlyr_6wt_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.3 0.5 0.8], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_8wt_mean-CSDlyr_8wt_sem fliplr(CSDlyr_8wt_mean+CSDlyr_8wt_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.3 0.2 0.6], 'FaceAlpha',0.5, 'EdgeColor','none')

title(plottitle3);
xlabel('CSD')
ylabel('Layer')

if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end


%% plotting by group - csd magnitude max by layer

%avg max values
CSDlyr_63x_maxmean = mean(CSDlyr_63x_max, 'omitnan'); 
CSDlyr_6wt_maxmean = mean(CSDlyr_6wt_max, 'omitnan'); 
CSDlyr_83x_maxmean = mean(CSDlyr_83x_max, 'omitnan');
CSDlyr_8wt_maxmean = mean(CSDlyr_8wt_max, 'omitnan');

CSDlyr_63x_max_std = std(CSDlyr_63x_max, 'omitnan'); 
CSDlyr_6wt_max_std = std(CSDlyr_6wt_max, 'omitnan'); 
CSDlyr_83x_max_std = std(CSDlyr_83x_max, 'omitnan');
CSDlyr_8wt_max_std = std(CSDlyr_8wt_max, 'omitnan');

CSDlyr_63x_max_sem = CSDlyr_63x_max_std/sqrt(size(CSDlyr_63x_max,1)); 
CSDlyr_6wt_max_sem = CSDlyr_6wt_max_std/sqrt(size(CSDlyr_6wt_max,1)); 
CSDlyr_83x_max_sem = CSDlyr_83x_max_std/sqrt(size(CSDlyr_83x_max,1));
CSDlyr_8wt_max_sem = CSDlyr_8wt_max_std/sqrt(size(CSDlyr_8wt_max,1));



plottitle4 = ['CSD Mag by animal - max by layer'];
f=figure('Name',[' CSD by animal - max by layer']);

for row=1:size(CSDlyr_6wt_max, 1)
    plot(CSDlyr_6wt_max(row,:), (1:size(CSDlyr_6wt_max,2)), 'color', [0.3 0.5 0.8])
    yticks(1:1:length(CSDlyr_6wt_max))
    hold on;
end
hold on;
for row=1:size(CSDlyr_63x_max, 1)
    plot(CSDlyr_63x_max(row,:), (1:size(CSDlyr_6wt_max,2)),'color',[0.9 0.6 0.7])
    hold on;
end
hold on;
for row=1:size(CSDlyr_83x_max, 1)
    plot(CSDlyr_83x_max(row, :), (1:size(CSDlyr_6wt_max,2)), 'color',[0.4 0 0.5])
    hold on;
end
for row=1:size(CSDlyr_8wt_max, 1)
    plot(CSDlyr_8wt_max(row, :), (1:size(CSDlyr_6wt_max,2)),  'color',[0.3 0.2 0.6])
    hold on;
end
hold on;
plot(CSDlyr_63x_maxmean, (1:size(CSDlyr_6wt_max,2)),'color',[0.9 0.6 0.7], 'LineWidth', 3)
hold on;
plot(CSDlyr_83x_maxmean, (1:size(CSDlyr_6wt_max,2)),'color',[0.4 0 0.5], 'LineWidth', 3)
hold on;
plot(CSDlyr_8wt_maxmean, (1:size(CSDlyr_6wt_max,2)),'color',[0.3 0.2 0.6], 'LineWidth', 3)
hold on;
plot(CSDlyr_6wt_maxmean, (1:size(CSDlyr_6wt_max,2)),'color',[0.3 0.5 0.8], 'LineWidth', 3)


hold on;

%plot error bars

patch([CSDlyr_63x_maxmean-CSDlyr_63x_max_sem fliplr(CSDlyr_63x_maxmean+CSDlyr_63x_max_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.9 0.6 0.7], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_83x_maxmean-CSDlyr_83x_max_sem fliplr(CSDlyr_83x_maxmean+CSDlyr_83x_max_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.4 0 0.5], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_6wt_maxmean-CSDlyr_6wt_max_sem fliplr(CSDlyr_6wt_maxmean+CSDlyr_6wt_max_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.3 0.5 0.8], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_8wt_maxmean-CSDlyr_8wt_max_sem fliplr(CSDlyr_8wt_maxmean+CSDlyr_8wt_max_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.3 0.2 0.6], 'FaceAlpha',0.5, 'EdgeColor','none')

title(plottitle4);
xlabel('CSD')
ylabel('Layer')

if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end


%% plotting by group - csd magnitude median by layer

%avg med values
CSDlyr_63x_medmean = mean(CSDlyr_63x_med, 'omitnan'); 
CSDlyr_6wt_medmean = mean(CSDlyr_6wt_med, 'omitnan'); 
CSDlyr_83x_medmean = mean(CSDlyr_83x_med, 'omitnan');
CSDlyr_8wt_medmean = mean(CSDlyr_8wt_med, 'omitnan');

CSDlyr_63x_med_std = std(CSDlyr_63x_med, 'omitnan'); 
CSDlyr_6wt_med_std = std(CSDlyr_6wt_med, 'omitnan'); 
CSDlyr_83x_med_std = std(CSDlyr_83x_med, 'omitnan');
CSDlyr_8wt_med_std = std(CSDlyr_8wt_med, 'omitnan');

CSDlyr_63x_med_sem = CSDlyr_63x_med_std/sqrt(size(CSDlyr_63x_med,1)); 
CSDlyr_6wt_med_sem = CSDlyr_6wt_med_std/sqrt(size(CSDlyr_6wt_med,1)); 
CSDlyr_83x_med_sem = CSDlyr_83x_med_std/sqrt(size(CSDlyr_83x_med,1));
CSDlyr_8wt_med_sem = CSDlyr_8wt_med_std/sqrt(size(CSDlyr_8wt_med,1));



plottitle5 = ['CSD Mag by animal - med by layer'];
f=figure('Name',[' CSD by animal - med by layer']);

for row=1:size(CSDlyr_6wt_med, 1)
    plot(CSDlyr_6wt_med(row,:), (1:size(CSDlyr_6wt_med,2)), 'color', [0.3 0.5 0.8])
    yticks(1:1:length(CSDlyr_6wt_med))
    hold on;
end
hold on;
for row=1:size(CSDlyr_63x_med, 1)
    plot(CSDlyr_63x_med(row,:), (1:size(CSDlyr_6wt_med,2)),'color',[0.9 0.6 0.7])
    hold on;
end
hold on;
for row=1:size(CSDlyr_83x_med, 1)
    plot(CSDlyr_83x_med(row, :), (1:size(CSDlyr_6wt_med,2)), 'color',[0.4 0 0.5])
    hold on;
end
for row=1:size(CSDlyr_8wt_med, 1)
    plot(CSDlyr_8wt_med(row, :), (1:size(CSDlyr_6wt_med,2)),  'color',[0.3 0.2 0.6])
    hold on;
end
hold on;
plot(CSDlyr_63x_medmean, (1:size(CSDlyr_6wt_med,2)),'color',[0.9 0.6 0.7], 'LineWidth', 3)
hold on;
plot(CSDlyr_83x_medmean, (1:size(CSDlyr_6wt_med,2)),'color',[0.4 0 0.5], 'LineWidth', 3)
hold on;
plot(CSDlyr_8wt_medmean, (1:size(CSDlyr_6wt_med,2)),'color',[0.3 0.2 0.6], 'LineWidth', 3)
hold on;
plot(CSDlyr_6wt_medmean, (1:size(CSDlyr_6wt_med,2)),'color',[0.3 0.5 0.8], 'LineWidth', 3)


hold on;

%plot error bars

patch([CSDlyr_63x_medmean-CSDlyr_63x_med_sem fliplr(CSDlyr_63x_medmean+CSDlyr_63x_med_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.9 0.6 0.7], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_83x_medmean-CSDlyr_83x_med_sem fliplr(CSDlyr_83x_medmean+CSDlyr_83x_med_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.4 0 0.5], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_6wt_medmean-CSDlyr_6wt_med_sem fliplr(CSDlyr_6wt_medmean+CSDlyr_6wt_med_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.3 0.5 0.8], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyr_8wt_medmean-CSDlyr_8wt_med_sem fliplr(CSDlyr_8wt_medmean+CSDlyr_8wt_med_sem)], [(1:size(CSDlyr_6wt,2)) fliplr(1:size(CSDlyr_6wt,2))], [0.3 0.2 0.6], 'FaceAlpha',0.5, 'EdgeColor','none')

title(plottitle5);
xlabel('CSD')
ylabel('Layer')
if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end

%% plotting by group - csd magnitude averaged by layer -  using data across one oscillation cycle

%regular means and sem
CSDlyrcycle_63x_mean = mean(CSD_63x_lyrcycle, 'omitnan'); 
CSDlyrcycle_6wt_mean = mean(CSD_6wt_lyrcycle, 'omitnan'); 
CSDlyrcycle_83x_mean = mean(CSD_83x_lyrcycle, 'omitnan');
CSDlyrcycle_8wt_mean = mean(CSD_8wt_lyrcycle, 'omitnan');

CSDlyrcycle_63x_std = std(CSD_63x_lyrcycle, 'omitnan'); 
CSDlyrcycle_6wt_std = std(CSD_6wt_lyrcycle, 'omitnan'); 
CSDlyrcycle_83x_std = std(CSD_83x_lyrcycle, 'omitnan');
CSDlyrcycle_8wt_std = std(CSD_8wt_lyrcycle, 'omitnan');

CSDlyrcycle_63x_sem = CSDlyrcycle_63x_std/sqrt(size(CSD_63x_lyrcycle,1)); 
CSDlyrcycle_6wt_sem = CSDlyrcycle_6wt_std/sqrt(size(CSD_6wt_lyrcycle,1)); 
CSDlyrcycle_83x_sem = CSDlyrcycle_83x_std/sqrt(size(CSD_83x_lyrcycle,1));
CSDlyrcycle_8wt_sem = CSDlyrcycle_8wt_std/sqrt(size(CSD_8wt_lyrcycle,1));



plottitle6 = ['CSD Mag by animal - avg by layer (using full oscillation cycle)'];
f=figure('Name',[' CSD by animal - avg by layer - full cycle']);

for row=1:size(CSD_6wt_lyrcycle, 1)
    plot(CSD_6wt_lyrcycle(row,:), (1:size(CSD_6wt_lyrcycle,2)), 'color', [0.3 0.5 0.8])
    yticks(1:1:length(CSD_6wt_lyrcycle))
    hold on;
end
hold on;
for row=1:size(CSD_63x_lyrcycle, 1)
    plot(CSD_63x_lyrcycle(row,:), (1:size(CSD_63x_lyrcycle,2)),'color',[0.9 0.6 0.7])
    hold on;
end
hold on;
for row=1:size(CSD_83x_lyrcycle, 1)
    plot(CSD_83x_lyrcycle(row, :), (1:size(CSD_83x_lyrcycle,2)), 'color',[0.4 0 0.5])
    hold on;
end
for row=1:size(CSD_8wt_lyrcycle, 1)
    plot(CSD_8wt_lyrcycle(row, :), (1:size(CSD_8wt_lyrcycle,2)),  'color',[0.3 0.2 0.6])
    hold on;
end
hold on;
plot(CSDlyrcycle_63x_mean, (1:size(CSD_6wt_lyrcycle,2)),'color',[0.9 0.6 0.7], 'LineWidth', 3)
hold on;
plot(CSDlyrcycle_83x_mean, (1:size(CSD_6wt_lyrcycle,2)),'color',[0.4 0 0.5], 'LineWidth', 3)
hold on;
plot(CSDlyrcycle_8wt_mean, (1:size(CSD_6wt_lyrcycle,2)),'color',[0.3 0.2 0.6], 'LineWidth', 3)
hold on;
plot(CSDlyrcycle_6wt_mean, (1:size(CSD_6wt_lyrcycle,2)),'color',[0.3 0.5 0.8], 'LineWidth', 3)


hold on;

%plot error bars

patch([CSDlyrcycle_63x_mean-CSDlyrcycle_63x_sem fliplr(CSDlyrcycle_63x_mean+CSDlyrcycle_63x_sem)], [(1:size(CSD_6wt_lyrcycle,2)) fliplr(1:size(CSD_6wt_lyrcycle,2))], [0.9 0.6 0.7], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyrcycle_83x_mean-CSDlyrcycle_83x_sem fliplr(CSDlyrcycle_83x_mean+CSDlyrcycle_83x_sem)], [(1:size(CSD_6wt_lyrcycle,2)) fliplr(1:size(CSD_6wt_lyrcycle,2))], [0.4 0 0.5], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyrcycle_6wt_mean-CSDlyrcycle_6wt_sem fliplr(CSDlyrcycle_6wt_mean+CSDlyrcycle_6wt_sem)], [(1:size(CSD_6wt_lyrcycle,2)) fliplr(1:size(CSD_6wt_lyrcycle,2))], [0.3 0.5 0.8], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDlyrcycle_8wt_mean-CSDlyrcycle_8wt_sem fliplr(CSDlyrcycle_8wt_mean+CSDlyrcycle_8wt_sem)], [(1:size(CSD_6wt_lyrcycle,2)) fliplr(1:size(CSD_6wt_lyrcycle,2))], [0.3 0.2 0.6], 'FaceAlpha',0.5, 'EdgeColor','none')

title(plottitle6);
xlabel('CSD')
ylabel('Layer')
if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end
%% plotting by group - csd magnitude max by layer - using data across one oscillation cycle

%avg max values
CSDcycle_63x_maxmean = mean(CSDcycle_63x_max, 'omitnan'); 
CSDcycle_6wt_maxmean = mean(CSDcycle_6wt_max, 'omitnan'); 
CSDcycle_83x_maxmean = mean(CSDcycle_83x_max, 'omitnan');
CSDcycle_8wt_maxmean = mean(CSDcycle_8wt_max, 'omitnan');

CSDcycle_63x_max_std = std(CSDcycle_63x_max, 'omitnan'); 
CSDcycle_6wt_max_std = std(CSDcycle_6wt_max, 'omitnan'); 
CSDcycle_83x_max_std = std(CSDcycle_83x_max, 'omitnan');
CSDcycle_8wt_max_std = std(CSDcycle_8wt_max, 'omitnan');

CSDcycle_63x_max_sem = CSDcycle_63x_max_std/sqrt(size(CSDcycle_63x_max,1)); 
CSDcycle_6wt_max_sem = CSDcycle_6wt_max_std/sqrt(size(CSDcycle_6wt_max,1)); 
CSDcycle_83x_max_sem = CSDcycle_83x_max_std/sqrt(size(CSDcycle_83x_max,1));
CSDcycle_8wt_max_sem = CSDcycle_8wt_max_std/sqrt(size(CSDcycle_8wt_max,1));



plottitle7 = ['CSD Mag by animal - max by layer (across a cycle)'];
f=figure('Name',[' CSD by animal - max by layer (across a cycle)']);

for row=1:size(CSDcycle_6wt_max, 1)
    plot(CSDcycle_6wt_max(row,:), (1:size(CSDcycle_6wt_max,2)), 'color', [0.3 0.5 0.8])
    yticks(1:1:length(CSDcycle_6wt_max))
    hold on;
end
hold on;
for row=1:size(CSDcycle_63x_max, 1)
    plot(CSDcycle_63x_max(row,:), (1:size(CSDcycle_6wt_max,2)),'color',[0.9 0.6 0.7])
    hold on;
end
hold on;
for row=1:size(CSDcycle_83x_max, 1)
    plot(CSDcycle_83x_max(row, :), (1:size(CSDcycle_6wt_max,2)), 'color',[0.4 0 0.5])
    hold on;
end
for row=1:size(CSDcycle_8wt_max, 1)
    plot(CSDcycle_8wt_max(row, :), (1:size(CSDcycle_6wt_max,2)),  'color',[0.3 0.2 0.6])
    hold on;
end
hold on;
plot(CSDcycle_63x_maxmean, (1:size(CSDcycle_6wt_max,2)),'color',[0.9 0.6 0.7], 'LineWidth', 3)
hold on;
plot(CSDcycle_83x_maxmean, (1:size(CSDcycle_6wt_max,2)),'color',[0.4 0 0.5], 'LineWidth', 3)
hold on;
plot(CSDcycle_8wt_maxmean, (1:size(CSDcycle_6wt_max,2)),'color',[0.3 0.2 0.6], 'LineWidth', 3)
hold on;
plot(CSDcycle_6wt_maxmean, (1:size(CSDcycle_6wt_max,2)),'color',[0.3 0.5 0.8], 'LineWidth', 3)


hold on;

%plot error bars

patch([CSDcycle_63x_maxmean-CSDcycle_63x_max_sem fliplr(CSDcycle_63x_maxmean+CSDcycle_63x_max_sem)], [(1:size(CSDcycle_6wt_max,2)) fliplr(1:size(CSDcycle_6wt_max,2))], [0.9 0.6 0.7], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDcycle_83x_maxmean-CSDcycle_83x_max_sem fliplr(CSDcycle_83x_maxmean+CSDcycle_83x_max_sem)], [(1:size(CSDcycle_6wt_max,2)) fliplr(1:size(CSDcycle_6wt_max,2))], [0.4 0 0.5], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDcycle_6wt_maxmean-CSDcycle_6wt_max_sem fliplr(CSDcycle_6wt_maxmean+CSDcycle_6wt_max_sem)], [(1:size(CSDcycle_6wt_max,2)) fliplr(1:size(CSDcycle_6wt_max,2))], [0.3 0.5 0.8], 'FaceAlpha',0.5, 'EdgeColor','none')
patch([CSDcycle_8wt_maxmean-CSDcycle_8wt_max_sem fliplr(CSDcycle_8wt_maxmean+CSDcycle_8wt_max_sem)], [(1:size(CSDcycle_6wt_max,2)) fliplr(1:size(CSDcycle_6wt_max,2))], [0.3 0.2 0.6], 'FaceAlpha',0.5, 'EdgeColor','none')

title(plottitle7);
xlabel('CSD')
ylabel('Layer')
if strcmp(region, 'HIPP')
    yticklabels({'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or'})
else
    yticklabels({'MEC2', 'MEC3'})
end




end