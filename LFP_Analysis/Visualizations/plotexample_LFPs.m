function plotexample_LFPs(animal)
load('W:\bad_chans_table.mat');
bad_chans = table2cell(bad_chans_table);

if strcmp(animal,'3xTg1-2')==1
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
    else
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat')    
end

offset = 450;
win0 = 12;   %plot data from time = win0 s to time = win1 s 
win1 = 13;

%get analysis directory for animal
exp_dir = get_exp(animal);

bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks


%get good time windows on track A for this animal and use the first one
%available
[anim_windows] = get_time_windows_drift(animal, {'A'});
anim_windows = anim_windows(1, :);
set = anim_windows{1, 5};
t0 = anim_windows{1,3};
t1 = anim_windows{1,4};

%get best shanks
[HIPshank, ECshank] = getshankECHIP_LV(animal);

%HIPPOCAMPUS
shank = HIPshank;
bc_sh = bc{1}{shank}; %get bad channels for current shank  

%load channel sets
[ch] = getchannels_drift(animal, shank, set);
group = ch.group; 
sex = ch.sex;
age = ch.age;


layers = {'Or', 'Pyr', 'Rad', 'LM', 'Mol', 'GC', 'Hil'};
LFP_HIPP = [];

for lyr = 1:length(layers) %loop through each layer and load data from a representative channel
    layer = layers{lyr};
    
    if strcmp(layer, 'Or')
        chans = ch.Or2:ch.Or1;
    elseif strcmp(layer, 'Pyr')
        chans = ch.Pyr2:ch.Pyr1;
    elseif strcmp(layer, 'Rad')
        chans = ch.Rad2:ch.Rad1;
    elseif strcmp(layer, 'LM')
        chans = ch.LM2:ch.LM1;
    elseif strcmp(layer, 'Mol')
        chans = ch.Mol2:ch.Mol1;
    elseif strcmp(layer, 'GC')
        chans = ch.GC2:ch.GC1;
    elseif strcmp(layer, 'Hil')
        chans = ch.Hil2:ch.Hil1;
    end 
    
    chans = chans(~ismember(chans,bc_sh)); %remove bad channels
    
    %find middle channel
    chan = chans(ceil(length(chans)/2));
    
    %convert to probelayout channel number
    chan_512 = probelayout(chan, shank);
    
    %load data
    LFP =  load([exp_dir 'LFP\LFP1000\LFPvoltage_ch' num2str(chan_512) '.mat']); %load data
    LFP = LFP.LFPvoltage_notch; 
    
    %restrict time to window of interest
    if t0>0 % greater than time 0
        LFP = LFP(:, (t0*1000):(t1*1000));
       elseif t0 == 0 %if t0 is the beginning of recording 
        LFP = LFP(:, 1:(t1*1000));
    end
    
    %restrict time to a few seconds as defined by win
    LFP = LFP(win0*1000:win1*1000);
    
    LFP_HIPP(lyr, :) = LFP;
    
end

%plot!
figure;
for lyr = 1:length(layers)
    %mycolors = [0 0.2 0.7; 0 0.3 0.7; 0 0.4 0.7; 0 0.5 0.7; 0 0.6 0.7; 0 0.7 0.7; 0 0.8 0.7];
    mycolors = [0 0.8 0.7; 0 0.7 0.7; 0 0.6 0.7; 0 0.5 0.7; 0 0.4 0.7; 0 0.3 0.7; 0 0.2 0.7;];
    ax = gca;
    ax.ColorOrder = mycolors;
    %plot(LFP_all(lyr,:)- offset*lyr, 'Color', [0 0.4470 0.7410])
    plot(LFP_HIPP(lyr,:)- offset*lyr)
    hold on;
end



  
        

      

%MEC

shank = ECshank;
bc_sh = bc{1}{shank}; %get bad channels for current shank  

%load channel sets
[ch] = getchannels_drift(animal, shank, set);
group = ch.group; 
sex = ch.sex;
age = ch.age;


layers = {'MEC3' 'MEC2'};
LFP_MEC = []; 

for lyr = 1:length(layers) %loop through each layer and load data from a representative channel
    layer = layers{lyr};
    
    if strcmp(layer, 'MEC2')
        chans = ch.EC22:ch.EC21;
    elseif strcmp(layer, 'MEC3')
        chans = ch.EC32:ch.EC31;
    end     
    
    chans = chans(~ismember(chans,bc_sh)); %remove bad channels
    
    %find middle channel
    chan = chans(ceil(length(chans)/2));
    
    %convert to probelayout channel number
    chan_512 = probelayout(chan, shank);
    
    %load data
    LFP =  load([exp_dir 'LFP\LFP1000\LFPvoltage_ch' num2str(chan_512) '.mat']); %load data
    LFP = LFP.LFPvoltage_notch; 
    
    %restrict time to window of interest
    if t0>0 % greater than time 0
        LFP = LFP(:, (t0*1000):(t1*1000));
       elseif t0 == 0 %if t0 is the beginning of recording 
        LFP = LFP(:, 1:(t1*1000));
    end
    
    %restrict time to a few seconds as defined by win
    LFP = LFP(win0*1000:win1*1000);
    
    LFP_MEC(lyr, :) = LFP;
    
end

%plot!
figure;
for lyr = 1:length(layers)
    mycolors = [ 0 0.4 0.7; 0 0.3 0.7; ];
    ax = gca;
    ax.ColorOrder = mycolors;
    %plot(LFP_all(lyr,:)- offset*lyr, 'Color', [0 0.4470 0.7410])
    plot(LFP_MEC(lyr,:)- offset*lyr)
    hold on;
end




end 