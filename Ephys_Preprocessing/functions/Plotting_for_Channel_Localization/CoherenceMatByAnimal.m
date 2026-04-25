%needs LFP, run_times, timesync
chspershank=64;
fpass1=0;
fpass2=200;

for shank=1:8
    exp_dir=get_exp(animal);
%     load(strcat(exp_dir, '\stimuli\', animal,'_VRtimesync.mat'));
    load([exp_dir '\LFP\' animal '_shank' num2str(shank) '_LFP.mat'], 'LFP'); %loads LFP
%     load(strcat(exp_dir, '\stimuli\', animal, '_runtimes.mat'),'run_times','V','critV2');
    load(strcat(exp_dir, '\stimuli\', animal, '_runtimesNEW.mat'),'run_times');
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
            
    parfor ch1=1:chspershank  %parfor here
        for ch2=1:chspershank
            if ch2>=ch1            
            [Cmn, Phimn, Smn, Smm, f, ConfC, PhiStd, Cerr]=coherencebyanimal(animal,[],LFP,run_times,ch1,ch2,fpass1, fpass2);
            cohMATRIX{ch1,ch2}=Cmn;
            phaseMATRIX{ch1,ch2}=Phimn;
            SmnMATRIX{ch1,ch2}=Smn;
            SmmMATRIX{ch1,ch2}=Smm;
            
            gind=find(f>30 & f<80);
            lgind=find(f>30 & f<50);
            thind=find(f>4 & f<12);
            fgind=find(f>90 & f<130);
            coh_gamma(ch1,ch2)=mean(Cmn(gind));
            coh_slowgamma(ch1,ch2)=mean(Cmn(lgind));
            coh_theta(ch1,ch2)=mean(Cmn(thind));
            coh_fastgamma(ch1,ch2)=mean(Cmn(fgind));
            phase_gamma(ch1,ch2)=circ_mean(Phimn(gind));
            phase_slowgamma(ch1,ch2)=mean(Phimn(lgind));
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
    
    save([exp_dir '\CoherenceALLchannels_matrix_shank' num2str(shank) '.mat'],'cohMATRIX','phaseMATRIX', 'SmnMATRIX','SmmMATRIX', 'fpass1', 'fpass2','freq','coh_gamma','coh_theta','coh_fastgamma','coh_slowgamma','phase_gamma','phase_theta','phase_fastgamma', 'phase_slowgamma');
    disp(['done with shank ' num2str(shank) 'for animal ' animal]);
    
   

   figure;
   subplot(3,1,1);
   imagesc(flipud(coh_theta)); 
   subplot(3,1,2);
   imagesc(flipud(coh_gamma)); 
   subplot(3,1,3);
   imagesc(flipud(coh_fastgamma)); 


   
end


