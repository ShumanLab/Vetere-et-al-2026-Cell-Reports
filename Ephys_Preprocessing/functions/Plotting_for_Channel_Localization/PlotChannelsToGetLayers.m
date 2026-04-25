% plot theta phase deviations, coherence, spikes for a few seconds of data
% for confirming probe placement 
function PlotChannelsToGetLayers(t0, t1)

%Select data file to use for this animal

%%%%%%% This needs to be updated for your computer
load('ECHIP512.mat');

% load data
read_Intan_RHD2000_file
ampData = evalin('base', 'amplifier_data');

%downsample to 1000hz
LFPdata=ampData(:,1:25:end); %just take every 25th data point (faster than decimate)

%%
%plot phase deviation and coherence 
% create LFP matrix
LFP1=LFPdata(probelayout(:,1),:);
LFP2=LFPdata(probelayout(:,2),:);
LFP3=LFPdata(probelayout(:,3),:);
LFP4=LFPdata(probelayout(:,4),:);
LFP5=LFPdata(probelayout(:,5),:);
LFP6=LFPdata(probelayout(:,6),:);
LFP7=LFPdata(probelayout(:,7),:);
LFP8=LFPdata(probelayout(:,8),:);

CoherenceMatByAnimalPlot   

%% plot spikes
    
sdata=[];
load('filt_600_6000.mat')  %also need to add directory here
b=filt1.tf.num;
a=filt1.tf.den;

background=mean(ampData,1);
backsub=ampData-background;

for ch=1:size(ampData,1)
    sdata(ch,:)=filtfilt(b,a, backsub(ch,t0*25000:t1*25000)); %filtered
%    sdata(ch,:)=backsub(ch,t0*25000:t1*25000); %raw backsub traces
        if (mod(ch,10)==0)
        sprintf('Filtering channels. %2.0f%% done.', ch/size(ampData,1)*100)
        end
end

s1=sdata(probelayout(:,1),:);
s2=sdata(probelayout(:,2),:);
s3=sdata(probelayout(:,3),:);
s4=sdata(probelayout(:,4),:);
s5=sdata(probelayout(:,5),:);
s6=sdata(probelayout(:,6),:);
s7=sdata(probelayout(:,7),:);
s8=sdata(probelayout(:,8),:);

    sLFPs={s1 s2 s3 s4 s5 s6 s7 s8};

offset=100;
figure; 
for i=1:4
    shank=HIPmed2lat(i);
    subplot(1,4,i);hold on
    LFP=sLFPs{shank};
    for ch=1:64
        plot(LFP(ch,:)+offset*ch)
    end
    title(['shank ' num2str(shank)])
end
figure; 
for i=1:4
    shank=ECmed2lat(i);
    subplot(1,4,i);hold on
    LFP=sLFPs{shank};
    for ch=1:64
        plot(LFP(ch,:)+offset*ch)
    end
        title(['shank ' num2str(shank)])
end

end 

