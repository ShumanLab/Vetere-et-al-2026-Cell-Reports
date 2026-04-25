function PlotBehavior(animal)
exp_dir=get_exp(animal);

stim_dir=[exp_dir 'stimuli\'];


load([stim_dir 'position.mat'])
position=downsample(position,25);
load([stim_dir 'running.mat'])
running=downsample(running,25);
load([stim_dir 'licking.mat'])
licking=downsample(licking,25);
load([stim_dir 'reward.mat'])
reward=downsample(reward,25);
load([stim_dir animal '_VRstatearrays.mat'],'lickstarts','lickends','rewardstarts','rewards');
lickstarts=round(lickstarts/25);
rewardstarts=round(rewardstarts/25);
rewards=round(rewards/25);

%run_bl = mode(running);
%running_vs_bl = running - run_bl;

t0=1;
t1=length(position); %in 1k samples
figure; hold on;
plot(position(t0:t1))
plot (running(t0:t1)-7,'r')
%plot(running_vs_bl(t0:t1)-8, 'y')
plot(-2+(5-licking(t0:t1))/5,'g')
plot(-3+reward(t0:t1)/10,'k')


firstB=find(position>=4.3,1,'first');%
switchtoB=firstB/1000/60; %in minutes
backA=find(position(firstB:end)<4.25,1,'first');
backtoA=backA/1000/60; %in minutes
endofrec=length(position)/1000/60; %in minutes

if isempty(backtoA)
    backtoA=endofrec;
end
times=[switchtoB backtoA endofrec];

rewA=rewards(rewards<firstB);
totArew=length(rewA);

Bend=find(position>4.25,1,'last');
rewafterA=rewards(rewards>firstB);
rewB=rewafterA(rewafterA<Bend);
totBrew=length(rewB);

disp(['A rewards = ' num2str(totArew) '; B rewards = ' num2str(totBrew)]);
disp(['A time = 0 - ' num2str(switchtoB) ' minutes; B time = ' num2str(switchtoB) ' - ' num2str(backtoA) ' minutes']);



%extra code to find conversion factor to convert ball tracker reading to m/s 
% 
% position_10Hz = downsample(position,100);  %downsample again to go from 1000hz to 10 
% time_stamps = [0.1:0.1:length(position_10Hz)/10]; %time stamps in seconds - 1 per every 10th of a second - 
% %technically the first one should be nearly zero but doing it this way so matrices are matching lengths
% running_bl = mode(running); %get ball tracker zero value for current animal 
% running_10Hz=downsample(running,100);
% running_from_bl = running_10Hz - running_bl;
% 
% 
% figure;
% 
% t0=1;
% t1=length(position_10Hz); 
% figure; hold on;
% plot(position_10Hz(t0:t1)+2)
% plot(running_from_bl(t0:t1),'r')
% 
% 
% velocity = diff(position_10Hz)./diff(time_stamps);
% 
% distance_conversion = 2/4.2; % 4.2 unit track = 2 meters 
% time_conversion = 10;  %convert m/0.1s to m/s 
% 
% velocity_test = velocity*time_conversion*distance_conversion;
% 
% running_from_bl_test = running_from_bl(2:end);
% 
% run_and_vel = vertcat(running_from_bl_test, velocity_test);
% 
% poscols = all(run_and_vel>0, 1); %find columns that don't contain negative numbers for ball tracker or velocity
% 
% run_and_vel_final = run_and_vel(:,poscols);
% 
% figure;
% t0=1;
% t1=length(run_and_vel_final); 
% figure; hold on;
% plot(run_and_vel_final(1,(t0:t1))) %ball tracker
% plot(run_and_vel_final(2, (t0:t1)),'r') %velocity
% 
% %test = run_and_vel_final(2,:)./run_and_vel_final(1,:);
% %test_avg = mean(test);
% 
% threshcols = all(run_and_vel_final>0.1 & run_and_vel_final<0.2, 1); %find columns that don't contain negative numbers for ball tracker or velocity
% 
% run_and_vel_thresh = run_and_vel_final(:,threshcols );
% 
% %testthresh = run_and_vel_thresh(2,:)./run_and_vel_thresh(1,:)
% %testthresh_avg = mean(testthresh);
% 
% 
% 
% 
% %not a clear linear relationship between velocity based on position and
% %ball tracker reading??
% 
% 
% %maybe need to take out negative values before calculating velocity? 
% 
% position_10Hz = downsample(position,100);  %downsample again to go from 1000hz to 10 
% time_stamps = [0.1:0.1:length(position_10Hz)/10]; %time stamps in seconds - 1 per every 10th of a second - 
% %technically the first one should be nearly zero but doing it this way so matrices are matching lengths
% running_bl = mode(running); %get ball tracker zero value for current animal 
% running_10Hz=downsample(running,100);
% running_from_bl = running_10Hz - running_bl;
% 
% 
% figure;
% 
% t0=1;
% t1=length(position_10Hz); 
% figure; hold on;
% plot(position_10Hz(t0:t1)+2)
% plot(running_from_bl(t0:t1),'r')
% 
% poscols = all(running_from_bl>0,1);
% position_10Hz_pos = position_10Hz(:, poscols);
% running_from_bl_pos = running_from_bl(:, poscols);
% time_stamps_pos = [0.1:0.1:length(position_10Hz_pos)/10]; %not sure this makes sense?? 
% 
% t0=1;
% t1=length(position_10Hz_pos); 
% figure; hold on;
% plot(position_10Hz_pos(t0:t1)+2)
% plot(running_from_bl_pos(t0:t1),'r')
% 
% velocity_pos = diff(position_10Hz_pos)./diff(time_stamps_pos);
% 
% distance_conversion = 2/4.2; % 4.2 unit track = 2 meters 
% time_conversion = 10;  %convert m/0.1s to m/s 
% 
% velocity_pos_test = velocity_pos*time_conversion*distance_conversion;
% 
% running_from_bl_pos_test = running_from_bl_pos(2:end);
% 
% run_and_vel_pos= vertcat(running_from_bl_pos_test, velocity_pos_test);
% 
% figure;
% t0=1;
% t1=length(run_and_vel_pos); 
% figure; hold on;
% plot(run_and_vel_pos(1,(t0:t1))) %ball tracker
% plot(run_and_vel_pos(2, (t0:t1)),'r') %velocity
% 
% 
% %remove places where velocity is negative 
% 
% posvelcols = all(run_and_vel_pos>0, 1);
% run_and_vel_velpos = run_and_vel_pos(:, posvelcols);
% 
% figure;
% t0=1;
% t1=length(run_and_vel_velpos); 
% figure; hold on;
% plot(run_and_vel_velpos(1,(t0:t1))) %ball tracker
% plot(run_and_vel_velpos(2, (t0:t1)),'r') %velocity
% 
% %test = run_and_vel_velpos(2,:)./run_and_vel_velpos(1,:);
% %test_avg = mean(test);
% 
% threshcols = all(run_and_vel_velpos>0.1 & run_and_vel_velpos<0.2, 1); %find columns in run thresh
% 
% run_and_vel_thresh = run_and_vel_velpos(:,threshcols );
% 
% 
% %testthresh = run_and_vel_thresh(2,:)./run_and_vel_thresh(1,:)
% %testthresh_avg = mean(testthresh);
% 
% 
% 

end