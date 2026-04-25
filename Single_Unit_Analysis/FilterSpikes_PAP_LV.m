
%Produces high pass filtered versions of background subtracted LFP data to
%use in single unit analysis. 
%Specifically needed to find waveforms that correspond to spike times
%identified by kilosort/phy. 
%Doing this ahead of time makes single unit analysis code run much faster
%and saving this data removes the need to repeat filtering process in new
%or repeated analyses. 

%Inputs: List of animals, background subtracted LFP files must exist in
%LFP/Backsub directory for each animal.

%Outputs: New high pass filtered (600-6000Hz) and post-background
%subtracted files in LFP/spikes folder. 

% animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};
function FilterSpikes_PAP_LV(animals)

for anim = 1:length(animals)
    
    animal = animals{anim};
    
    [exp_dir]=get_exp(animal);
    
    %load probelayout
    if strcmp(animal,'3xTg1-2')  %load probe layout
        load('ECHIP512_3xTg1-2.mat') 
    else
        load('ECHIP512.mat') 
    end

    
    LFPdir=[exp_dir 'LFP\'];
    load('filt_600_6000.mat');
    bf=filt1.tf.num;
    af=filt1.tf.den;
    filtertype ='spikes';
    
    %save filtered data
    if exist([LFPdir filtertype]) ~= 7 %make folder only if it does not exist
    mkdir([LFPdir filtertype]);
    end
    
    %[HIPshank, ECshank]=getshankECHIP_LV(animal);   %update this to account for possibility of multiple good shanks
    
    [HIPshanks, ECshanks]=getshankECHIP_LV_multi(animal);
    shanks = [HIPshanks, ECshanks];
    
    if ECshanks == 0
        shanks = [HIPshanks];
    end 
    
    numchans_per_shank = 64;
    realAllchans =[];
    
    for sh = 1:length(shanks)
        realshchans = probelayout(1:64, shanks(sh));
    %realHIPchans = probelayout(1:64, HIPshank);
    %realMECchans = probelayout(1:64, ECshank);
    %realAllchans = cat(1, realHIPchans, realMECchans);
        realAllchans = cat(1, realAllchans, realshchans);
    end
    
    numchans = length(realAllchans);

    
    parfor ch=1:numchans
        chdir = [exp_dir '\LFP\BackSub\LFPvoltage_ch' num2str(realAllchans(ch)) '.mat'];
        outdir = [LFPdir filtertype '\LFPvoltage_ch' num2str(realAllchans(ch)) filtertype '.mat'];
        if exist(outdir, 'file') == 0 %to check if filtered file exists already and skip if so
            if exist(chdir,'file')>0   
                fname= chdir;
                [LFP]=parloadLFPvoltage(fname);
                data=double(LFP);
                filt_data=filtfilt(bf,af,data);

                filt_data=single(filt_data);
                fname=[LFPdir filtertype '\LFPvoltage_ch' num2str(realAllchans(ch)) filtertype '.mat'];
                parSave_filt_data(fname,filt_data);
            else
                disp('BackSub file is missing!');
            end
            disp(['done with filtering ' num2str(ch) ' out of ' num2str(numchans) ' channels'])
        else
        end
    end
    disp(['done with filtering ' filtertype ' for ' animal]);        

    end
end 