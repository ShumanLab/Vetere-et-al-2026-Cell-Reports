
%%%Calculate power spectral density and peak theta frequency for each animal.
%%%In a given subregion and frequency range 
%%%%Concatenates data across valid time windows.

%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};

%list for MEC 
%  animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'WT181' '3xTg123' '3xTg1-2'};
% 
% region = 'HIPP';
% subregion = 'Rad';
% track = 'A';
% freq_range = 'theta'   %'theta' or 'wide'
% limitchans = 0; % if limitchans = 1 will use only middle two channels for each layer to save
%%% time, if limitchans = 0, will use all channels in the layer


function wavelet_PSD_LV_drift(animals, freq_range, region, subregion, track, limitchans) 

load('W:\bad_chans_table.mat');
bad_chans = table2cell(bad_chans_table);

runthresh_low = 0.1;
runthresh_high = 0.2;

Fs=1000;


%can narrow the freqency range or increase frequency resolution to look just at theta
if strcmp(freq_range, 'theta')
    min_freq = 4;
    max_freq = 12; 
    num_freq = 33;  %0.25 Hz resolution, 17 for 0.5 Hz resolution 
elseif strcmp(freq_range, 'wide')
    min_freq = 1;
    max_freq = 100;
    num_freq = 100;
end

%freq_ratio = (max_freq-min_freq)/num_freq;
freq_ticks = [(1:1:num_freq)];
%freq_axis = [(min_freq:freq_ratio:max_freq)];


for anim = 1:length(animals)
    animal = animals{anim};
    
    exp_dir=get_exp(animal); 
    lfp_dir = fullfile(exp_dir,'LFP\LFP1000');
    stim_dir=[exp_dir 'stimuli\'];
 
    if strcmp(animal,'3xTg1-2')==1
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
    else
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat')    
    end

    [HIPshank, ECshank]=getshankECHIP_LV(animal);
    if strcmp(region,'HIPP')
    shank = HIPshank;
    elseif strcmp(region,'MEC')
    shank = ECshank;
    end 
    
    shankchs=probelayout(:,shank);  %get actual channel numbers based on shank
    
    bc_row = find(strcmp(bad_chans(:,1), animal)); %find bad chans row for current animal
    bc = bad_chans(bc_row, 2); %get cell  with bad channels for all shanks
    bc_sh = bc{1}{shank}; %get bad channels for current shank

    [anim_windows] = get_time_windows_drift(animal, {track});
    
    %anim_windows = anim_windows(1, :); %just first window for testing 
    %w=1;
    
    LFPsignals_full = [];
    run_speed_full = []; 
    
    %concatenate LFP data from all time windows 
    for w = 1:size(anim_windows,1)
        set = anim_windows{w, 5}; 
        [ch] = getchannels_drift(animal, shank, set);
        group = ch.group; 
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

        chans = chans(~ismember(chans,bc_sh)); %remove bad channels
        
        
        if length(chans) == 0  %skip if no channels available for this layer+window
            disp(['no channels available for this layer + window']);
            continue
        else    
            
            if limitchans == 1
            chans_length = length(chans);
                if rem(chans_length,2)== 0 %if even number of channels
                    middle_chans = chans_length/2:((chans_length/2)+1);
                else %if odd number of channels
                    if chans_length >= 3
                        middle_chans = floor(chans_length/2):ceil(chans_length/2);
                    elseif chans_length == 1
                        middle_chans = 1; 
                    elseif chans_length == 3
                        middle_chans = [2,3]; 
                    end
                end
            chans = chans(middle_chans);
            else
            end 

        chans_length = length(chans);

            if w == 1
                chans_length_w1 = length(chans); 
            end 
            
            rawchans=shankchs(chans); %convert to true channel numbers
          
            if w > 1
                if length(rawchans) > chans_length_w1
                    rawchans = rawchans(1:chans_length_w1); %make sure all windows have same number of channels
                elseif length(rawchans) < chans_length_w1
                    LFPsignals_full = LFPsignals_full(1:length(rawchans),:); 
                end
            end 
            
            numChan = length(rawchans);

            t0 = anim_windows{w, 3};
            t1 = anim_windows{w, 4};

            LFPsignals = []; % reset LFPsignals for each window 
            %LOAD IN DATA
            for channel = 1:length(rawchans)  
                chan = rawchans(channel);
                LFP =  load([exp_dir 'LFP\LFP1000\LFPvoltage_ch' num2str(chan) '.mat']); %load data
                LFPsignals(channel,:) = LFP.LFPvoltage_notch; 
                disp(['loaded channel ' num2str(channel) ' of ' num2str(length(rawchans))]);
            end

            run_speed = load([stim_dir 'running.mat']);
            run_speed = downsample(run_speed.running,25); %1000Hz

            %restrict data to time window of interest 
            if t0>0 % greater than time 0
                LFPsignals = LFPsignals(:, (t0*1000):(t1*1000));
                run_speed = run_speed(:, (t0*1000):(t1*1000));  %get runspeed restricted to time window for current track
            elseif t0 == 0 %if t0 is the beginning of recording 
                LFPsignals = LFPsignals(:, 1:(t1*1000));
                run_speed = run_speed(:, 1:(t1*1000));  %get runspeed restricted to time window for current track
            end

            LFPsignals_full = [LFPsignals_full LFPsignals];  %final matrix that has data from all time windows combined
            run_speed_full = [run_speed_full run_speed]; 
            disp(['imported window ' num2str(w)]);
        end
    end
  
   
    run_bl = mode(run_speed_full); 

    if isempty(LFPsignals_full) %skip this animal if no lfp data is available for this layer
        continue
    end
      
    %calucate kernel sizes for current animal based on length of
    %data
    srate = Fs;
    nsam = size(LFPsignals_full,2);
    time = (0:nsam-1)/srate;
    time = time - mean(time);
    %dataR = timeSeries;
    %dataR = dataR-mean(dataR);
    %ndata = length(dataR); 
    ndata = size(LFPsignals_full,2);
    nkern = length(time);
    nConv = ndata + nkern - 1;
    halfK = floor(nkern/2);

    %build array or freqeuncies to iterate over
    frex = linspace(min_freq,max_freq,num_freq);
               
    %generate frequency representation of wavelet library
    h= 0.3;  %better frequency resolution 
    %h = 0.05;  %better temporal resolution
    waveletLib = zeros(num_freq,nConv);
    for fi=1:num_freq
            % create wavelet
            cmw  = exp(1i*2*pi*frex(fi)*time) .* ...
                   exp( -4*log(2)*time.^2 / h^2 );

            cmwX = fft(cmw,nConv);
            cmwX = cmwX./max(abs(cmwX));
            waveletLib(fi,:)=cmwX;
    end
    disp('generated wavelets');

    %tic
    ft_all = NaN(num_freq, ndata, numChan);

        for chi=1:numChan 
            ft_ch = NaN(num_freq,ndata); %frequency by time for a single channel  zeros(num_freq,ndata-1);

            lfp = LFPsignals_full(chi, :); %get lfp signal from current channel

            dataR = lfp;
            dataX = fft( dataR,nConv ); %frequency representation of signal

            for fi=1:num_freq
                %retrieve frequency representation of wavelet
                cmwX = waveletLib(fi,:); 
                % perform convolution as multiplication in frequency domain
                as = ifft( dataX.*cmwX );
                as = as(halfK+1:end-halfK);
                % extract power
                aspow = abs(as).^2;

                if size(ft_ch,2) == length(aspow)
                    ft_ch(fi, :) = aspow; 
                else
                    ft_ch(fi, 1:end-1) = aspow;  %to deal with times where aspow is one sample shorter ??
                end 


            end

             ft_all(:, :, chi) = ft_ch;
             %if size(ft_all,2) == length(aspow)
             %       ft_all(:, :, chi) = ft_ch; %add to freq x time x channel 3D matrix for current animal
             %   else
             %       ft_all(:, 1:end-1, chi) = ft_ch;  %to deal with times where aspow is one sample shorter ??
             % end 

            %toc
            disp(['done with channel ' num2str(chi) ' of ' num2str(numChan)]) 

    %     scale = [0 1600];
    %     figure;
    %     imagesc(ft_ch)  %(:,1:100000));
    %     axis xy ;
    %     yticks(freq_ticks)
    %     yticklabels(frex)
    %     c = colorbar;
    %     caxis(scale);
    %     title([filter ' ' animal ' ' subregion ' ' group ' Power (freq vs time)']);
    %     hold on;
    %     plot(run_speed, 'r')    

        end


        ft_mean = nanmean(ft_all,3);  %average across channels - leaving freq vs time


    %     scale = [0 1600];
    %     figure;
    %     imagesc(ft_mean);
    %     axis xy ;
    %     yticks(freq_ticks)
    %     yticklabels(frex)
    %     c = colorbar;
    %     caxis(scale);
    %     title([filter ' ' animal ' ' subregion ' ' group ' Power (freq vs time)']);
    %     hold on;
    %     plot(run_speed, 'r')

        
        %find run times within a narrow threshold 
        run_times_all = find(run_speed_full > (run_bl + runthresh_low));  %anywhere 0.1 above baseline ball tracker reading - usually ~2.7 %fixed to deal with different baselines across animals
        run_times_thresh = find(run_speed_full >  (run_bl + runthresh_low) & run_speed_full <=  (run_bl + runthresh_high)); %only narrow threshold above baseline
        non_run_times = find(run_speed_full < (run_bl + 0.02) & run_speed_full > (run_bl - 0.02)); %restricted to get out downward deflections that may or may not be running

        ft_mean_run = ft_mean(:,run_times_all);
        ft_mean_runthresh = ft_mean(:,run_times_thresh);
        ft_mean_nonrun =  ft_mean(:,non_run_times);

        PSD_full = nanmean(ft_mean,2);
        PSD_run = nanmean(ft_mean_run,2);
        PSD_runthresh = nanmean(ft_mean_runthresh,2);
        PSD_nonrun =nanmean(ft_mean_nonrun,2) ;

        %calculate length of time in each  run state in seconds 
        length_run= length(run_times_all)/1000;
        length_nonrun = length(non_run_times)/1000;
        length_runthresh= length(run_times_thresh)/1000;
        length_full = length(run_speed)/1000;


    %     figure;
    %     plot(PSD_all)
    %     xticks(freq_ticks)
    %     xticklabels(frex)
    %     title([filter ' ' animal ' ' subregion ' ' group ' PSD (Power vs Freq)']);
    %     
    
        Animal{anim} = animal;
        Group{anim} = group;
        Sex{anim} = sex;
        Age{anim} = age;
        FullPSD{anim, :} = PSD_full;
        RunPSD{anim,:} = PSD_run;
        RunThreshPSD{anim,:} = PSD_runthresh;
        NonRunPSD{anim,:} = PSD_nonrun;
        Length_full{anim} = length_full;
        Length_run{anim} = length_run;
        Length_runthresh{anim} = length_runthresh;
        Length_nonrun{anim} = length_nonrun;


        disp(['done with ' animal ' ' subregion]); 
end

    

%make summary file for all animals

PSD_struct.Animal = Animal;
PSD_struct.Group = Group;
PSD_struct.Sex = Sex;
PSD_struct.Age = Age;
PSD_struct.FullPSD = FullPSD;
PSD_struct.RunPSD = RunPSD;
PSD_struct.RunThreshPSD = RunThreshPSD;
PSD_struct.NonRunPSD = NonRunPSD;
PSD_struct.minfreq = min_freq;
PSD_struct.maxfreq = max_freq;
PSD_struct.numfreq = num_freq;
PSD_struct.Length_full =Length_full;
PSD_struct.Length_run =Length_run;
PSD_struct.Length_runthresh =Length_runthresh;
PSD_struct.Length_nonrun =Length_nonrun;


out_dir = 'W:\data analysis';  

if limitchans == 1
save([ out_dir '\WaveletPSD_Atracks' region '_' subregion '_' freq_range '2chansperlyr_fixed.mat'],'PSD_struct') 
else        
save([ out_dir '\WaveletPSD_Atracks' region '_' subregion '_' freq_range 'allchans_fixed.mat'],'PSD_struct') 
end

end   
    
    
    %WaveletPS.ft_all  =  ft_mean;
    %WaveletPS.ft_run  =  ft_mean_run;     %saving all of this makes files
    %too big!! 
    %WaveletPS.ft_runthresh  =  ft_mean_runthresh;
    %WaveletPS.ft_nonrun  =  ft_mean_nonrun;

    %WaveletPS.PSD_all  =  PSD_all;
    %WaveletPS.PSD_run  =  PSD_run;
    %WaveletPS.PSD_runthresh  =  PSD_runthresh;
    %WaveletPS.PSD_nonrun  =  PSD_nonrun;

    %WaveletPS.Group = group;
    %WaveletPS.Sex = sex;
    %WaveletPS.Age = age;
    %WaveletPS.Shank = shank;
    
    %WaveletPS.minfreq = min_freq;
    %WaveletPS.maxfreq = max_freq;
    %WaveletPS.numfreq = num_freq;
    

    %save([ exp_dir 'waveletPSD' region '_' subregion '_' filter '_A1.mat'],'WaveletPS') 

    




    








