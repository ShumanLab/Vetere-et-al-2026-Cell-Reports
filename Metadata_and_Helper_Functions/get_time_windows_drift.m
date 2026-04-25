%The goal of this function is to the time windows that have been manually selected as good/usable for
%a given animal and that match the tracks of interest.
%Also will collect info about which channel sets are best to use for each
%of those time windows (Value of 1, 2, 3 will indicate which of the
%three spreadsheets to pull channel sets from later)

function [anim_windows] = get_time_windows_drift(animal, tracks)

%inputs = animal IDs, cell array containing desired tracks (ex. A1,
% B1, A2, B2, 'A', 'B', all) 

load(['F:\Ephys Analysis\ChannelSetsByTrack']);  %load file containing time window information

a = find(strcmp(ChannelSetsByTrack(:,1), animal)); %find rows for current animal

time_windows = ChannelSetsByTrack(a,:); 

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


