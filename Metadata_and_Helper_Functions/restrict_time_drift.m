
function [ks_t0, ks_t1, anim_windows_sec] = restrict_time_drift(animal, shank, ks_times, tracks, metadata_dir)
%all outputs in seconds

load([metadata_dir '\ChannelSetsByTrack_forSpikes_V2']); %load file containing time window information
%load(['F:\Ephys Analysis\ChannelSetsByTrack_forSpikes_V2']);  
%removed any time windows that go beyond valid kilosort times
%version 2 of this file removed additional chunks from WT47 and 3xTg49-1

rows = find(strcmp(ChannelSetsByTrack(:,1), animal)); %find rows for current animal

time_windows = ChannelSetsByTrack(rows,:); 

%pull out only rows for desired tracks, or all tracks 
if strcmp(tracks, 'all')   %if all tracks are desired, keep all rows
   anim_windows = time_windows; 
else %find rows that contain tracks of interest
    anim_windows = [];
    for t=1:length(tracks)
        track = tracks{t};
        track_rows = find(contains(time_windows(:,2), track));
        anim_windows = [anim_windows; time_windows(track_rows,:)];
    end
end


shankname = ['shank' num2str(shank)];
sample_rate = 25000;

%find info about start and end kilosort times for this animal/shank - in
%seconds
a = find(strcmp(ks_times(:,1),animal)==1);
b = find(strcmp(ks_times(:,2),shankname)==1);
animalind = intersect(a,b);
clear a b;
 
ks_t0 = ks_times{animalind, 3};
ks_t1 = str2num(ks_times{animalind, 4});


anim_windows_sec = anim_windows;

end




    
    
    



%in main script
% 
% for r = 1:length(anim_windows);
%     track = anim_windows(r,2);
%     t0 = anim_windows(r,3);
%     t1 = anim_windows(r, 4);
%     set = anim_windows(r,5);
% end 
%[ch] = getchannels_drift(animal, shank, set)


