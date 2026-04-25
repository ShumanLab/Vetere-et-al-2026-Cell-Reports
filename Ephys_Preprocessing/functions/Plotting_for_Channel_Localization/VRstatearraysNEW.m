function VRstatearraysNEW(animal, binsize)
%Create arrays with info about running times, lick starts/ends, reward
%starts/ends. The running times info is used by getruntimes to identify
%running bouts. 
%LV analysis no longer uses this. 

%Inputs/requirements: Animal ID, binsize (0.1 = 0.1 second bins), matfiles
%in stim_dir containing analog signals for licking (lick sensor signal), position (in VR), reward
%delivery, and running (ball tracker signal).

%Output: VRstatearrays file containing variables: 'running', 'nonrunning', 'runthresh', 
%'binsize', 'bintimes','lickstarts', 'lickends', 'rewards', 'rewardstarts', 'rewardends'

exp_dir=get_exp(animal);
stim_dir=[exp_dir 'stimuli\'];

%get stimuli
load([stim_dir 'licking.mat']);
load([stim_dir 'position.mat']);
load([stim_dir 'reward.mat']);
load([stim_dir 'running.mat']);

%find all lick start and end times
licking=5-licking;
threshold=3; %going up
lickstarts=[];
lickends=[];
maxLickTime=0.200*25000;
minLickTime=0.001*25000;
for l=2:length(licking)
    if licking(l)>threshold && licking(l-1)<threshold % go through lick sensor signal and find all instances where lick signal first passes threshold
        lickstarts=[lickstarts l];
    elseif licking(l)<threshold && licking(l-1)>threshold && length(lickstarts)==length(lickends)+1  %if signal goes back below threshold and there are more lickstarts this may be a lickend
        if l-lickstarts(end)>maxLickTime || l-lickstarts(end)<minLickTime
            lickstarts=lickstarts(1:end-1);
        else            
            lickends=[lickends l];
        end
    end
end


%find all reward start and end times
rewardstarts=[];
rewardends=[];
minTimeRewards=25000;
rthresh=2;
for r=2:length(reward)
    if reward(r)>rthresh && reward(r-1)<rthresh 
        if length(rewardstarts)==0
        rewardstarts=[rewardstarts r];
        else
           if r-rewardstarts(end)>minTimeRewards
               rewardstarts=[rewardstarts r];
           end
        end
    elseif reward(r)<rthresh && reward(r-1)>rthresh && length(rewardstarts)==length(rewardends)+1
        rewardends=[rewardends r];
    end
end
rewards=rewardstarts;


%%
%Create binary running and not running variables
running=double(running);
run1k=decimate(running,25);
frun=smoothts(run1k,'b',1000);
frun25=smoothts(running,'b',25000);

t=1:length(run1k);
t=t/1000;
totaltime=t(end);
totalbins=ceil(totaltime/binsize);
running=zeros(1,totalbins);
nonrunning=zeros(1,totalbins);

bintimes=zeros(totalbins,2);
runthresh=2.7; %2.6 is rest

for bin=1:totalbins  %loop through bins and generate a binary of running or not running 
    b0=binsize*(bin-1);
    b1=b0+binsize;
    bintimes(bin,:)=[b0 b1];
    bt=find(t>=b0 & t<b1);
    meanrun=mean(frun(bt(1):bt(end)));    
        if meanrun>=runthresh
             running(bin)=1;
             nonrunning(bin)=0;
        else
             running(bin)=0;
             nonrunning(bin)=1;
        end
        

         if (mod(bin,5000)==0)
            sprintf(['Running VR state arrays for ' animal '. %2.0f%% done.'], bin/totalbins*100)
        end
end

save([stim_dir animal '_VRstatearrays.mat'], 'running', 'nonrunning', 'runthresh', 'binsize', 'bintimes','lickstarts', 'lickends', 'rewards', 'rewardstarts', 'rewardends');

end