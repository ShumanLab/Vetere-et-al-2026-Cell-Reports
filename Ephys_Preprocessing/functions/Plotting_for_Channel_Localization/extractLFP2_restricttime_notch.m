% extract raw LFP into one unified file of CA1
function extractLFP2_restricttime_notch(animal,probe,shank,time)   %time in sec
    exp_dir=get_exp(animal);
%     [~, shank]=getCA1DGlocations(animal, side); %only needed for old data   


    
    if exist([exp_dir '\addbadchannels.mat'])>0
load([exp_dir '\addbadchannels.mat']); %loads badchannels
    else
        badchannels=[];
    end
    
    %get probelayout and arrayposition
    if strcmp(probe, 'ECHIP512')==1
load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');
load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\position_dense64.mat');

    elseif strcmp(probe,'ECHIP512_3xTg1-2')==1
load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\position_dense64.mat');
    elseif strcmp(probe, 'probe128A_bottom')==1
load('H:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\probe128A_bottom.mat');
load('H:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\position_dense64.mat');

    end
    
    
    shank_array=probelayout(:,shank);
    if time==0
    [t0, t1]=gettime(animal, 'all','1000');
    else
        %restrict time
        t1=time*1000;
    end
        t1=floor(t1);
        LFP=NaN(length(shank_array),t1);

        

    for chi=1:length(shank_array)
        ch=shank_array(chi);
        cd([exp_dir '\LFP\LFP1000']);
        if exist(['LFPvoltage_ch' num2str(ch) '.mat'])>0  && isempty(intersect(badchannels,ch))==1
            load(['LFPvoltage_ch' num2str(ch) '.mat']);
            LFP(chi,:)=LFPvoltage_notch(1:t1);
        else
            LFP(chi,:)=NaN(1,t1);
        end
    end
    
    
    
    


cd([exp_dir '\LFP']);

save([animal '_shank' num2str(shank) '_LFP.mat'], '-v7.3', 'LFP');  %use this to overwrite 
end








