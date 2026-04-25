tic
%needs LFP1-8
chspershank=64;
fpass1=0;
fpass2=200;
refchan=64;

numshanks=8;

shankLFP={LFP1 LFP2 LFP3 LFP4 LFP5 LFP6 LFP7 LFP8};

%% 
shankCOH=cell(1,numshanks);
shankPHASE=cell(1,numshanks);
for shank=1:numshanks
    
    LFP=shankLFP{shank};
    
%     run_times=[1/1000 size(LFP,2)/1000];
    run_times=[t0 t1];
    
    cohMATRIX=cell(chspershank,chspershank);
    phaseMATRIX=cell(chspershank,chspershank);
    SmnMATRIX=cell(chspershank,chspershank);
    SmmMATRIX=cell(chspershank,chspershank);
            coh_gamma=NaN(chspershank,chspershank);
            coh_theta=NaN(chspershank,chspershank);
            coh_fastgamma=NaN(chspershank,chspershank);
            coh_slowgamma=NaN(chspershank,chspershank);

            phase_gamma=NaN(chspershank,chspershank);
            phase_theta=NaN(chspershank,chspershank);
            phase_fastgamma=NaN(chspershank,chspershank);
            phase_slowgamma=NaN(chspershank,chspershank);
            
            freq=[];
            
    for ch1=1:chspershank
        for ch2=1:chspershank  %parfor
            if ch2>=ch1            
            [Cmn, Phimn, Smn, Smm, f, ConfC, PhiStd, Cerr]=coherencebyanimal([],[],LFP,run_times,ch1,ch2,fpass1, fpass2);
            cohMATRIX{ch1,ch2}=Cmn;
            phaseMATRIX{ch1,ch2}=Phimn;
            SmnMATRIX{ch1,ch2}=Smn;
            SmmMATRIX{ch1,ch2}=Smm;
            
            bind=find(f>15 & f<30);
            gind=find(f>30 & f<80);
            lgind=find(f>30 & f<50);
            thind=find(f>4 & f<12);
            fgind=find(f>90 & f<130);
            coh_beta(ch1,ch2)=mean(Cmn(bind));
            coh_gamma(ch1,ch2)=mean(Cmn(gind));
            coh_slowgamma(ch1,ch2)=mean(Cmn(lgind));
            coh_theta(ch1,ch2)=mean(Cmn(thind));
            coh_fastgamma(ch1,ch2)=mean(Cmn(fgind));
            phase_gamma(ch1,ch2)=circ_mean(Phimn(gind));
            phase_slowgamma(ch1,ch2)=circ_mean(Phimn(lgind));
            phase_theta(ch1,ch2)=circ_mean(Phimn(thind));
            phase_fastgamma(ch1,ch2)=circ_mean(Phimn(fgind));
            freq=f;
            end
        end
        disp(['done with ch1=' num2str(ch1)]);
    end

    for ch1=1:chspershank
        for ch2=1:chspershank
            if ch2<ch1            
                cohMATRIX{ch1,ch2}=cohMATRIX{ch2,ch1};
                phaseMATRIX{ch1,ch2}=phaseMATRIX{ch2,ch1};
                SmnMATRIX{ch1,ch2}=SmnMATRIX{ch2,ch1};
                SmmMATRIX{ch1,ch2}=SmmMATRIX{ch2,ch1};
                
                coh_beta(ch1,ch2)=coh_beta(ch2,ch1);
                coh_gamma(ch1,ch2)=coh_gamma(ch2,ch1);
                coh_slowgamma(ch1,ch2)=coh_slowgamma(ch2,ch1);
                coh_theta(ch1,ch2)=coh_theta(ch2,ch1);
                coh_fastgamma(ch1,ch2)=coh_fastgamma(ch2,ch1);
                phase_gamma(ch1,ch2)=phase_gamma(ch2,ch1);
                phase_slowgamma(ch1,ch2)=phase_slowgamma(ch2,ch1);
                phase_theta(ch1,ch2)=phase_theta(ch2,ch1);
                phase_fastgamma(ch1,ch2)=phase_fastgamma(ch2,ch1);
            end
        end
    end
    
%     save([exp_dir '\CoherenceALLchannels_matrix_shank' num2str(shank) '.mat'],'cohMATRIX','phaseMATRIX', 'SmnMATRIX','SmmMATRIX', 'fpass1', 'fpass2','freq','coh_gamma','coh_theta','coh_fastgamma','coh_slowgamma','phase_gamma','phase_theta','phase_fastgamma', 'phase_slowgamma');
    disp(['done with shank ' num2str(shank)]);
    
    h=find(HIPmed2lat==shank);
    e=find(ECmed2lat==shank);
    
    if shank>4.5
    figure(100); subplot(1,4,e) %%%%%%%%%%%%%%%%%%%
    else
    figure(200); subplot(1,4,h)
    end
    
   t=phase_theta(refchan,:);
%     plot([64:-1:1], t)
    scatter([1:64], t,'.')
    ylabel('Relative Phase (deg)','FontSize', 12);
    title(['shank ' num2str(shank)])
     view(-90, 90);
    ylim([-pi pi]);

    if shank>4.5
    figure(101); 
    subplot(3,4,e) %%%%%%%%%%%%%%%%%%%
%     t=phase_theta(64,:);
    scatter([1:64], t,'.')
    ylabel('Relative Phase (deg)','FontSize', 12);
    title(['shank ' num2str(shank)])
     view(-90, 90);
    ylim([-pi pi]);

    subplot(3,4,4+e) %%%%%%%%%%%%%%%%%%%
    imagesc(flipud(coh_theta)); 
    title(['shank ' num2str(shank)])
    subplot(3,4,e+8)
    imagesc(flipud(coh_beta)); 
%     suptitle(['Entorhinal Cortex' newline 'Medial<--------------------------------------------->Lateral'])
%     suptitle('Entorhinal Cortex')
    else
    figure(201); 
    subplot(3,4,h) %%%%%%%%%%%%%%%%%%%
%     t=phase_theta(64,:);
    scatter([1:64], t,'.')
    ylabel('Relative Phase (deg)','FontSize', 12);
    title(['shank ' num2str(shank)])
     view(-90, 90);
    ylim([-pi pi]);

    subplot(3,4,h+4)
    imagesc(flipud(coh_theta)); 
%     title(['shank ' num2str(shank)])
    subplot(3,4,h+8)
    imagesc(flipud(coh_beta)); 
%     suptitle(['Hippocampus' newline 'Medial<--------------------------------------------->Lateral'])
%     suptitle('Hippocampus')
    end
    
   
%    subplot(2,4,2);
%    imagesc(flipud(coh_gamma)); 
%    subplot(3,1,3);
%    imagesc(flipud(phase_theta)); 
%    caxis([-pi pi])
% 
%  nextch=64;
% neworder=[64];
% for iter=1:63
%     coh_gamma(:,nextch)=zeros(1,64);
%     ch=nextch;
%    %find max coherence
%    chcoh=coh_gamma(ch,:);
%    chcoh(ch)=0;
%    [m, i]=max(chcoh);
%    nextch=i;
%     
%    neworder=[neworder nextch];
%     
% end
% 
% 
% ct=coh_theta2(neworder,:);
% 
% figure; plot(coh_theta2(neworder,:))
% shankarray=probelayout(:,1);
% shankarray=shankarray(neworder);
%    
end

toc


