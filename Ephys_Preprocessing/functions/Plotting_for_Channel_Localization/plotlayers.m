% plot layer specific changes in power and phase deviations


function plotlayers(animal, probetype, filtertypes)



exp_dir=get_exp(animal);


if strcmp(probetype,'ECHIP512')==1
    numchans=512; 
    numshanks=8; 
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');

elseif strcmp(probetype,'ECHIP512_3xTg1-2')==1
    numshanks=8;
    numchans=512;
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
elseif strcmp(probetype,'probe128A_bottom')==1
    numchans=128;
    numshanks=2;
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\probe128A_bottom.mat')
    
elseif strcmp(probetype,'probe_256BiHipp')==1
    numshanks=4;
    pershank=64;
    numchans=256;
    load('F:\Tristan\VLSE neuro 4-4\probe_data\probe256BiHipp.mat')

end


%load data
LFPdir=[exp_dir '\LFP\'];

shankLFP=cell(1,numshanks);

for shank=1:numshanks
            figure; 
        shankLFP{shank}=NaN(numchans/numshanks,length(filtertypes));
    for f=1:length(filtertypes)
        
        filtertype=filtertypes{f};


            load([LFPdir 'PowerByChannel\running\' animal '_' filtertype 'powerbychannel.mat'],'NPower');
            
            if exist([LFPdir '\RunningPhaseDev\' animal '_' filtertype '_phasedev_running.mat'])
                load([LFPdir '\RunningPhaseDev\' animal '_' filtertype '_phasedev_running.mat'],'phasedev', 'phasedev3');
            else
                load([LFPdir filtertype '\' animal '_' filtertype '_phasedev.mat'],'phasedev', 'phasedev3');
                disp('running not available - showing all');
            end
            
            
            
%             load([LFPdir filtertype '\' animal '_' filtertype '_128power.mat']);
            
                %plot 

                %plot power by shank
            subplot(2,length(filtertypes),f);
            plot(NPower(:,shank),(1:64));
            ylim([0 65]);
            xlabel('channel position');
            ylabel([filtertype ' power']);
            title([animal ' shank ' num2str(shank) ' ' filtertype]);

                %plot phase deviation by shank
            subplot(2,length(filtertypes),f+length(filtertypes));
            plot(phasedev(:,shank),(1:64), '.');
            
            ylim([0 65]);
            xlim([-180 180]);
            ylabel([filtertype ' phase']);
            title([animal ' shank ' num2str(shank) ' ' filtertype]);

            shankLFP{shank}(:,f)=phasedev(:,shank);
            
            
    end
   
%             figure;
%             imagesc(shankLFP{shank}); colorbar;
 
end







end