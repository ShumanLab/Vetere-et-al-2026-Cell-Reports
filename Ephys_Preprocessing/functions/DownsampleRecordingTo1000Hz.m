function DownsampleRecordingTo1000Hz(animal, srate, numchans)

%Inputs/Requirements: animal ID, sampling rate (25000kHz here), total number of channels
%LFP\Full folder in animal's analysis directory (exp_dir) must contain full
%LFP files for each channel.

%Output: LFP\LFP1000 folder containing downsampled LFP files for each
%channel 

exp_dir=get_exp(animal);
load([exp_dir 'exp.mat']);
LFP_dir=[exp_dir '\LFP\Full\'];
re_dir=[exp_dir '\LFP\LFP1000\'];

mkdir(re_dir)

for ch=1:numchans
    L=matfile([LFP_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
    LFPvoltage=double(L.LFPvoltage(1, :));
    reLFP=decimate(LFPvoltage,srate/1000);
    LFPvoltage=single(reLFP);
    m=matfile([re_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
    m.LFPvoltage=LFPvoltage;
    
         if (mod(ch,10)==0)
         sprintf('Downsampling channels. %2.0f%% done.', ch/numchans*100)
         end
    
end

end