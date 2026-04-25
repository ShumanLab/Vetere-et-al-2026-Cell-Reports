%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This scipt is for cleaning 60, 120, 180Hz noise from LFP1000 downsampled signal.
%Inputs: animal ID, numchans of your probe
%Output: add a LFPvoltage_notch to LFP1000 files together with original LFPvoltage
%Writen by SF, 8/1/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function clean60hznoise_LV(animals, numchans)
tic
for anim = 1:length(animals)
    animal=animals{anim};
    exp_dir=get_exp(animal);
    lfp_dir = fullfile(exp_dir,'LFP\LFP1000\');

    %parfor ch=1:numchans 
    for ch = 1:numchans
        data = load([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat']);
        data = data.LFPvoltage; %to handle ones that already have notch file
        Fs =1000;  % Sampling frequency (1kHz) 
        %data = struct2cell(data);
        %data = cell2mat(data);
        data = double(data);

        %below is self build notch filter
        d_60 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',59.6,'HalfPowerFrequency2',60.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

        d_120 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',119.6,'HalfPowerFrequency2',120.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

        d_180 = designfilt('bandstopiir','FilterOrder',2, ...
                       'HalfPowerFrequency1',179.6,'HalfPowerFrequency2',180.4, ...
                       'DesignMethod','butter','SampleRate',Fs);

        LFPvoltage_notch = filtfilt(d_60,data);
        LFPvoltage_notch = filtfilt(d_120,LFPvoltage_notch);
        LFPvoltage_notch = filtfilt(d_180,LFPvoltage_notch);
        
        %data=single(data);
        LFPvoltage_notch = single(LFPvoltage_notch);
        
        
         m=matfile([lfp_dir 'LFPvoltage_ch' num2str(ch) '.mat'],'Writable', true);
         %m.LFPvoltage=data;
         m.LFPvoltage_notch = LFPvoltage_notch;
       % save(lfp_dir strcat('LFPvoltage_ch', num2str(ch),'.mat'), 'LFPvoltage', 'LFPvoltage_notch');
         if (mod(ch,10)==0)
            sprintf('filtering channels. %2.0f%% done.', ch/numchans*100)
         end
        
    end
    
toc
end



% 
% %below are testing how well this is getting rid of 60, 120, 180hz noise
% Fs =1000;
% L = length(LFPvoltage_notch(1,:)); % Length of signal 
% t = (0:L-1)*(1/Fs);   % Time vector (in sec)
% Fs =1000
% Y = fft(LFPvoltage_notch);
% PSD = abs(Y./L);
% PSD = PSD(:,1:L/2+1); 
% PSD(:,2:end-1) = 2*PSD(:,2:end-1); 
% f = Fs*(0:(L/2))/L;
% 
% 
% figure 
% plot(f,mean(PSD,1),'color',[0 0 0],'LineWidth',2)
% xlim
% xlabel('Frequency (Hz)')
% ylabel('Power (AU)')
% title('LFP2 PSD')
% 
% 
% 
% figure;
% plot(LFPvoltage_notch, 'r');
% hold on;
% plot(data, 'b');
