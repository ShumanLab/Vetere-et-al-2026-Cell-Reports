function [phasedev3 stddev]=LFPphasedev_running(animal,filtertype, refchannels, numloops)

exp_dir=get_exp(animal);
load([exp_dir '\LFP\' filtertype '\' animal, '_', filtertype, '_128power.mat']);
%LFP128 and PX
phasedev=[];
phasedev2=[];
phasedev3=[];
stddev=[];


load([exp_dir '\stimuli\' animal '_VRstatearrays.mat']);


if strcmp(filtertype,'theta')==1
    mindur=100;
    maxdur=200;
elseif strcmp(filtertype,'gamma')==1
    mindur=10;
    maxdur=50;
else
    mindur=1;
    maxdur=100;
end
    
    for shank=1:length(refchannels)

        refch=refchannels(shank);

        rPX=PX{refch,shank};


            for ch=1:size(PX,1)
                sigch=ch;


                sPX=PX{sigch,shank};

                loops=min([length(rPX),length(sPX)]);
                realloops=0;
                
                if loops==0
                    phasedev(ch,shank)=NaN;
                    phasedev2(ch,shank)=NaN;
                    phasedev3(ch,shank)=NaN;
                    stddev(ch,shank)=NaN;
                    continue
                end
                
                sdev=[];
                sdevphase=[];
                sdev2=[];
                sdevphase2=[];
                for loop=1:loops-1

                    if realloops>=numloops
                        break
                    end
                    
                    
                    %if power > threshold

                    t0=rPX(loop);
                    t1=rPX(loop+1);
                    
                    %if running
                    time0=t0/1000;
                    ind=find(bintimes(:,1)>time0,1,'first');
                    if running(ind)==0
                        continue
                    else
                        realloops=realloops+1;
                    end
                    
                    if t1-t0>mindur && t1-t0<maxdur


                        r=rPX(loop);
                        rn=rPX(loop+1);

                        sind=find(sPX>r,1, 'first'); %find index of next value
                        s=sPX(sind); %get actual next value
                        
                        sdevphase(loop)=(s-r)/(rn-r)*360;
                        sdev(loop)=s-r;
                        sdev2=[sdev2 s-r];
                        sdevphase2=[sdevphase2 (s-r)/(rn-r)*360];
                    else
                        sdevphase(loop)=NaN;
                        sdev(loop)=NaN;
                    end
                end

                %check this!!!!!
                phasedev(ch,shank)=circ_rad2ang(circ_mean(transpose(circ_ang2rad(sdevphase2))));
                  phasedev2(ch,shank)=mode(sdevphase2);
                 stddev(ch,shank)=circ_rad2ang(circ_std(transpose(circ_ang2rad(sdevphase2))));
                
                if phasedev(ch,shank)>50
                    phasedev3(ch,shank)=phasedev(ch,shank)-360;
                else
                    phasedev3(ch,shank)=phasedev(ch,shank);
                end
                
                   
                
            end
            
            
    end
    
    if exist([exp_dir '\LFP\RunningPhaseDev\'])==0
        mkdir([exp_dir '\LFP\RunningPhaseDev\']);
    end
    
    clear PX
    
    save([exp_dir '\LFP\RunningPhaseDev\' animal '_' filtertype '_phasedev_running.mat']);
    figure; plot(phasedev3); title([animal '_' filtertype]);
    
end



    