function [Power, NPower] = PowerByChannel(animal, state, filtertype, probetype)

if strcmp(probetype,'ECHIP512')==1
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat')
    numshanks=8;
    numchans=512;
elseif strcmp(probetype,'ECHIP512_3xTg1-2')==1
    numshanks=8;
    numchans=512;
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
elseif strcmp(probetype,'128A')==1
    numchans=128;
    numshanks=2;
    load('F:\Tristan\VLSE neuro 4-4\probe_data\probe128A.mat')
elseif strcmp(probetype,'128A_bottom')==1
    numshanks=2;
    numchans=128;
    load('H:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\probe128A_bottom.mat')
end



[t0 t1]=gettime(animal, 'all', '1000');    
exp_dir=get_exp(animal);

load([exp_dir '\stimuli\' animal '_VRstatearrays.mat']);


%eliminate noise artifacts
if exist([exp_dir '\noisetimes.mat'])>0
    load([exp_dir '\noisetimes.mat']);
    
    if isempty(noisetimes1K)==0
    eliminatenoise=1;
    noisetime=0.5; %seconds - time to eliminate after noise spike
    noisepoints=noisetime*1000; %numsamples to eliminate

    noise=[transpose(noisetimes1K) transpose(noisetimes1K)+noisepoints];
    
    else
        eliminatenoise=0;
    end
else
    eliminatenoise=0;
end


btimes=bintimes(:,2);
lastbin=find(btimes>=t1/1000,1,'first')-1;

if isempty(lastbin)==0
    bins=lastbin;
else
    bins=size(bintimes,1);
end


if strcmp(state,'all')==1 || strcmp(state, 'first30')==1
    %calculate filtered power
    Power=NaN(numchans/numshanks, numshanks);
    NPower=NaN(numchans/numshanks, numshanks);
    cd(strcat(exp_dir, '\LFP\', filtertype));
    for chi=1:numchans
        ch=probelayout(chi,shank);
            if exist(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'))>0
            load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
            else
                Power(ch)=NaN;
                NPower(ch)=NaN;
                continue
            end    %calculate power for each bin
            
            
            
            
    x=filt_data(t0:t1);
    power = (norm(x)^2)/length(x);
    Power(ch)=power;

    end
           ch_power=0;
          ch_power_div=0;

elseif strcmp(state, 'running')==1
   
    %calculate filtered power
    Power=NaN(numchans/numshanks, numshanks);
    NPower=NaN(numchans/numshanks, numshanks);
    cd(strcat(exp_dir, '\LFP\', filtertype));
    for shank=1:numshanks
        for chi=1:numchans/numshanks
            ch=probelayout(chi,shank);

             if exist(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'))>0
                load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
                else
                    Power(chi,shank)=NaN;
                    NPower(chi,shank)=NaN;
                    continue
                end    %calculate power for each bin

                ch_power=0;
                ch_power_div=0;                        
                actualnoise=0;

                for b=1:bins
                    if bintimes(b,1)<=0
                        continue
                    end
                    
                    %%%%%%%elinate noise bins
                    if eliminatenoise==1
                        %index bounds of bin
                        binstart_index=round(bintimes(b,1)*1000);
                        binend_index=round(bintimes(b,2)*1000);
                        
                        for n=1:size(noise,1)
                           if binend_index>noise(n,1) && binend_index<noise(n,2)
                               binnoise=1;
                               break
                           else
                               binnoise=0;
                           end
                        end
%                         noise1=find(noise(:,1)<binstart_index); %noise times before start
%                         noise2=find(noise(:,1)<binstart_index);  %noise times before end
%                         binnoise=length(intersect(noise1,noise2));
                        if binnoise>0
%                             disp('noise bin!')
                            actualnoise=actualnoise+1;
                            continue
                        end
                    end
                    %%%%%%%%%%%%%%%%%%
                    
                    if running(b)==1  
                   x=filt_data(round(bintimes(b,1)*1000):round(bintimes(b,2)*1000));



                    power = (norm(x)^2)/length(x);
                    ch_power=ch_power+power;
                    ch_power_div=ch_power_div+1;
                    end
                end
                    Power(chi,shank)=ch_power;
                    NPower(chi,shank)=ch_power/ch_power_div;

        end
    end
elseif strcmp(state, 'non-running')==1

%calculate filtered power
    Power=NaN(numchans/numshanks, numshanks);
    NPower=NaN(numchans/numshanks, numshanks);
cd(strcat(exp_dir, '\LFP\', filtertype));
    for shank=1:numshanks
        for chi=1:numchans/numshanks
        ch=probelayout(chi,shank);
            if exist(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'))>0
            load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
            else
                Power(chi,shank)=NaN;
                NPower(chi,shank)=NaN;
                continue
            end    %calculate power for each bin

    ch_power=0;
    ch_power_div=0;
    actualnoise=0;

        for b=1:bins
            if bintimes(b,1)<=0 || round(bintimes(b,2)*1000)>length(filt_data)
                continue
            end


                                      %%%%%%%elinate noise bins
                    if eliminatenoise==1
                        %index bounds of bin
                        binstart_index=round(bintimes(b,1)*1000);
                        binend_index=round(bintimes(b,2)*1000);
                        
                        for n=1:size(noise,1)
                           if binend_index>noise(n,1) && binend_index<noise(n,2)
                               binnoise=1;
                               break
                           else
                               binnoise=0;
                           end
                        end
%                         noise1=find(noise(:,1)<binstart_index); %noise times before start
%                         noise2=find(noise(:,1)<binstart_index);  %noise times before end
%                         binnoise=length(intersect(noise1,noise2));
                        if binnoise>0
%                             disp('noise bin!')
                            actualnoise=actualnoise+1;
                            continue
                        end
                    end
                    %%%%%%%%%%%%%%%%%%
                    
                    
            if nonrunning(b)==1
               x=filt_data(round(bintimes(b,1)*1000):round(bintimes(b,2)*1000));



            power = (norm(x)^2)/length(x);
            ch_power=ch_power+power;
            ch_power_div=ch_power_div+1;
            end
        end
        Power(chi,shank)=ch_power;
        NPower(chi,shank)=ch_power/ch_power_div;
    end
    end
    
elseif strcmp(state, 'ITI')==1

%calculate filtered power
    Power=NaN(numchans/numshanks, numshanks);
    NPower=NaN(numchans/numshanks, numshanks);
cd(strcat(exp_dir, '\LFP\', filtertype));
    for shank=1:numshanks
        for chi=1:numchans/numshanks
        ch=probelayout(chi,shank);
            if exist(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'))>0
            load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
            else
                Power(chi,shank)=NaN;
                NPower(chi,shank)=NaN;
                continue
            end    %calculate power for each bin


    ch_power=0;
    ch_power_div=0;
    actualnoise=0;
        for b=1:bins
            if bintimes(b,1)<0
                continue
            end


                                     %%%%%%%elinate noise bins
                    if eliminatenoise==1
                        %index bounds of bin
                        binstart_index=round(bintimes(b,1)*1000);
                        binend_index=round(bintimes(b,2)*1000);
                        
                        for n=1:size(noise,1)
                           if binend_index>noise(n,1) && binend_index<noise(n,2)
                               binnoise=1;
                               break
                           else
                               binnoise=0;
                           end
                        end
%                         noise1=find(noise(:,1)<binstart_index); %noise times before start
%                         noise2=find(noise(:,1)<binstart_index);  %noise times before end
%                         binnoise=length(intersect(noise1,noise2));
                        if binnoise>0
%                             disp('noise bin!')
                            actualnoise=actualnoise+1;
                            continue
                        end
                    end
                    %%%%%%%%%%%%%%%%%%
                    
                    
            if ITT(b)==1
               x=filt_data(round(bintimes(b,1)*1000):round(bintimes(b,2)*1000));



            power = (norm(x)^2)/length(x);
            ch_power=ch_power+power;
            ch_power_div=ch_power_div+1;
            end
        end
        Power(chi,shank)=ch_power;
        NPower(chi,shank)=ch_power/ch_power_div;
    end

    
    end
end

if exist(strcat(exp_dir, '\LFP\PowerByChannel\', state))==0
    mkdir(strcat(exp_dir, '\LFP\PowerByChannel\', state));
end


cd(strcat(exp_dir, '\LFP\PowerByChannel\', state));
    save(strcat(animal, '_', filtertype, 'powerbychannel.mat'), 'Power', 'NPower','ch_power_div');
% power_plot=Power(a);
    
% figure;
% imagesc((power_plot));
    
% 
% %% running
% 
% %calculate filtered power
% Power=[1, numchans];
% cd(strcat(exp_dir, '\LFP\', filtertype));
% for ch=1:numchans
% load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
% %calculate theta power within time frame
% x=filt_data(round(r0/25):round(r1/25));
% power = (norm(x)^2)/length(x);
% Power(ch)=power;
% end
% 
% cd('C:\Users\Tristan\Desktop\VLSE neuro 4-4\nanoprobe geometry');
% load('128Dxyshank.mat');
% PowerXY=cat(1,Power,D128);
% 
% [d1,d2] = sort(PowerXY(4,:), 'descend');
% s=PowerXY(:,d2);
% st=transpose(s(1,:));
% [s1,s2]=sort(s(5,:));
% sts=s(:,s2);
% stsh=[sts(1, 1:32); sts(1, 33:64); sts(1, 65:96); sts(1, 97:128)];
% 
%  h=fspecial('gaussian',8, 3);  %gaussian filter.
%  
% %  smooth_s=filter2(h, s);
%  
%   if strcmp(animal, 'Con1')==1
%  smooth_st=filter2(h, st([1:73 75:end]));
%   else
%        smooth_st=filter2(h, st);
%   end
%  smooth_stsh = filter2(h, stsh);
% 
% 
% % figure; imagesc(smooth_s(1,:)); colorbar;
% figure(40+fign);
% clf;
% subplot(3, 2, 1)
% imagesc(smooth_st(:,1), [0 max1]); colorbar; %[0 3000] for theta
% title('Running');
% subplot(3,2,2); imagesc(transpose(smooth_stsh), [0 max2]); colorbar; %[0 11000]
% title(strcat(filtertype, ' power by channel location, ', animal));
% 
% if strcmp(animal, '7-18C')==1
%     figure(60+f);
%     subplot(1,2,1);
%     imagesc(transpose(smooth_stsh), [0 max2]); colorbar; %[0 3000] for theta
%     title('Pilocarpine - Running');
%     ylabel('Channel Location');
%     xlabel(strcat(filtertype, ' power'));
% elseif strcmp(animal, 'Con1')==1
%     figure(60+f);
%     subplot(1,2,2);
%     imagesc(transpose(smooth_stsh), [0 max2]); colorbar; %[0 3000] for theta
%     title('Control - Running');
%     ylabel('Channel Location');
%     xlabel(strcat(filtertype, ' power'));
% 
% end
% 
% 
% 
% %% non running
% 
% 
% %calculate filtered power
% Power2=[1, numchans];
% cd(strcat(exp_dir, '\LFP\', filtertype));
% for ch=1:numchans
% load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
% %calculate theta power within time frame
% x=filt_data(round(n0/25):round(n1/25));
% power = (norm(x)^2)/length(x);
% Power2(ch)=power;
% end
% 
% cd('C:\Users\Tristan\Desktop\VLSE neuro 4-4\nanoprobe geometry');
% load('128Dxyshank.mat');
% PowerXY2=cat(1,Power2,D128);
% 
% [d1,d2] = sort(PowerXY2(4,:), 'descend');
% s=PowerXY2(:,d2);
% st=transpose(s(1,:));
% [s1,s2]=sort(s(5,:));
% sts=s(:,s2);
% stsh=[sts(1, 1:32); sts(1, 33:64); sts(1, 65:96); sts(1, 97:128)];
% 
%  h=fspecial('gaussian',8, 3);  %gaussian filter.
%  
%  smooth_s=filter2(h, s);
%   if strcmp(animal, 'Con1')==1
%  smooth_st=filter2(h, st([1:73 75:end]));
%   else
%        smooth_st=filter2(h, st);
%   end
%  smooth_stsh = filter2(h, stsh);
% 
% 
% % figure; imagesc(smooth_s(1,:)); colorbar;
% figure(40+fign);
% subplot(3,2,3); 
% imagesc(smooth_st(:,1), [0 max1]); colorbar; %[0 3000] for theta
% title('Non-running');
% subplot(3,2,4); 
% imagesc(transpose(smooth_stsh), [0 max2]); colorbar; %[0 11000]title(strcat(filtertype, ' power by channel location, ', animal));
% 
% if strcmp(animal, '7-18C')==1
%     figure(70+f);
%     subplot(1,2,1);
%     imagesc(transpose(smooth_stsh), [0 max2]); colorbar; %[0 3000] for theta
%     title('Pilocarpine - Non-Running');
%     ylabel('Channel Location');
%     xlabel(strcat(filtertype, ' power'));
% elseif strcmp(animal, 'Con1')==1
%     figure(70+f);
%     subplot(1,2,2);
%     imagesc(transpose(smooth_stsh), [0 max2]); colorbar; %[0 3000] for theta
%     title('Control - Non-Running');
%     ylabel('Channel Location');
%     xlabel(strcat(filtertype, ' power'));
% 
% end
% 
% 
% 
% %% both running and non-running over time
% 
% binsize=100;  %1000=1second
% bins=(t1-t0)/binsize;
%     Power3=zeros(bins, numchans);
%     cd(strcat(exp_dir, '\LFP\', filtertype));
% 
%     
%     %calculate filtered power
%     for ch=1:numchans
%         load(strcat('LFPvoltage_ch', num2str(ch), filtertype, '.mat'));
%         for t=1:bins
%         %calculate theta power within time frame
%         x=filt_data((t0+(binsize*(t-1))):(t0+binsize*t));
%         power = (norm(x)^2)/length(x);
%         Power3(t, ch)=power;
%         end
%     end
% cd('C:\Users\Tristan\Desktop\VLSE neuro 4-4\nanoprobe geometry');
% load('128Dxyshank.mat');
% PowerXY3=cat(1,Power3,D128);
% 
% [d1,d2] = sort(PowerXY3((bins+3),:), 'descend');
% s=PowerXY3(:,d2);
% st=transpose(s(1:bins,:));
% 
% 
% 
%  h=fspecial('gaussian',6, 3);  %gaussian filter.
%  
%  if strcmp(animal, 'Con1')==1
%  smooth_st=filter2(h, st([1:73 75:end], :));
%  else
%       smooth_st=filter2(h, st);
%  end
% 
% % figure; imagesc(smooth_s(1,:)); colorbar;
% figure(40+fign);
% subplot(3,2,5:6); 
% imagesc(smooth_st, [0 max3]); colorbar; %[0 3000] for theta
% title('Non-running + Running');
% 
% 
% 
% if strcmp(animal, '7-18C')==1
%     figure(50+f);
%     subplot(2,2,1:2);
%     imagesc(smooth_st, [0 max3]); colorbar; %[0 3000] for theta
%     title('Pilocarpine');
%     ylabel(strcat(filtertype, ' power'));
%     xlabel('Non-running + Running');
% elseif strcmp(animal, 'Con1')==1
%     figure(50+f);
%     subplot(2,2,3:4);
%     imagesc(smooth_st, [0 max3]); colorbar; %[0 3000] for theta
%     title('Control');
%     ylabel(strcat(filtertype, ' power'));
%     xlabel('Non-running + Running');
% 
% end



end





