function plotexample_theta(animal)
load('W:\bad_chans_table.mat');
bad_chans = table2cell(bad_chans_table);

if strcmp(animal,'3xTg1-2')==1
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
    else
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat')    
end

offset = 800;
win0 = 13;   %plot data from time = win0 s to time = win1 s 
win1 = 15;

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



LFP_HIPP = [];

chans = ch.LM2:ch.LM1;
chans = chans(~ismember(chans,bc_sh)); %remove bad channels
%find middle channel
chan = chans(ceil(length(chans)/2));
%convert to probelayout channel number
chan_512 = probelayout(chan, shank);
    
%load raw data
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

%load theta filtered LFP
LFP_theta =  load([exp_dir 'LFP\theta\LFPvoltage_ch' num2str(chan_512) 'theta.mat']); %load data
LFP_theta = LFP_theta.filt_data; 

%restrict time to window of interest
if t0>0 % greater than time 0
     LFP_theta =  LFP_theta(:, (t0*1000):(t1*1000));
   elseif t0 == 0 %if t0 is the beginning of recording 
     LFP_theta =  LFP_theta(:, 1:(t1*1000));
end

%restrict time to a few seconds as defined by win
 LFP_theta =  LFP_theta(win0*1000:win1*1000);

figure;
plot(LFP, 'Color', 'k')
hold on;
plot(LFP_theta - offset, 'Color', 'k')

        

%MEC

shank = ECshank;
bc_sh = bc{1}{shank}; %get bad channels for current shank  

%load channel sets
[ch] = getchannels_drift(animal, shank, set);
group = ch.group; 
sex = ch.sex;
age = ch.age;

chans = ch.EC22:ch.EC21;
         
chans = chans(~ismember(chans,bc_sh)); %remove bad channels

%find middle channel
chan = chans(ceil(length(chans)/2));

%convert to probelayout channel number
chan_512 = probelayout(chan, shank);

%load raw data
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


%load theta data
LFP_theta =  load([exp_dir 'LFP\theta\LFPvoltage_ch' num2str(chan_512) 'theta.mat']); %load data
LFP_theta  =LFP_theta.filt_data; 

%restrict time to window of interest
if t0>0 % greater than time 0
    LFP_theta  = LFP_theta (:, (t0*1000):(t1*1000));
   elseif t0 == 0 %if t0 is the beginning of recording 
    LFP_theta  = LFP_theta (:, 1:(t1*1000));
end

%restrict time to a few seconds as defined by win
LFP_theta  = LFP_theta(win0*1000:win1*1000);


plot(LFP - offset*1.7, 'Color', 'k')
hold on;
plot(LFP_theta - offset*2.2, 'Color', 'k')




end 