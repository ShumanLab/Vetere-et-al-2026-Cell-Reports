function [PL]=phaselockunitLV(spikes_ch,fLFP)
%this version takes in spike times and LFP at 1k Hz 

% baseline_power=(norm(fLFP)^2)/length(fLFP); %if you want a threshold
%find troughs of fLFP
        hLFP=hilbert(fLFP);
        aLFP=angle(hLFP);
        [pks, pLFP]=findpeaks(aLFP); %pLFP is index of troughs (1000hz)

%find spike phases
deg=18;  %bins
bins=zeros(1, deg);
timebins=zeros(1,deg);
spike_rad_test=[];
spike_rad=[];

for i=1:length(spikes_ch) %for each spike find bin
    spike = spikes_ch(i);        
    trough2=find(pLFP>spike,1,'first');
        if isempty(trough2)  || trough2==1 %make sure not the first or last index
            continue
        end
    tr1=pLFP(trough2-1);    %beginning of cycle
    tr2=pLFP(trough2);      %end of cycle
    cyclelength=tr2-tr1;    %length of this cycle
    b=ceil(((spike-tr1)/cyclelength)*deg);  %find bin
           if b==0  
                b=1;
           end
    %find rad
    spike_rad_s = (spike-tr1)/cyclelength*2*pi;
    spike_rad(i)=spike_rad_s;

    bins(b)=bins(b)+1;
    spike_rad_test=[spike_rad_test spike_rad_s];
    
end

%run tests
            [pval z]=circ_rtest(transpose(spike_rad_test));
            [mu ul ll] = circ_mean(transpose(spike_rad_test));
%             [k k0] = circ_kurtosis(transpose(spike_rad_test));
            %     k         kurtosis (from Pewsey)
            %     k0        kurtosis (from Fisher)
            stats=circ_stats(transpose(spike_rad_test));
            r=circ_r(transpose(spike_rad_test));

% figure; polarhistogram(spike_rad,18)

PL.spike_rad=spike_rad;
PL.spike_rad_test=spike_rad_test;
PL.bins=bins;
PL.r=r;
PL.pval=pval;
PL.mu=mu;
PL.stats=stats;



end