%Script to find bad channels based on theta coherence matrices - 
%loops through each animal, finds bad channels for each shank based on
%where coherence matrix shows an individual channel deviating from its
%neighbors by more than a certain threshold 

%Inputs: currently set to expect 8 shanks and take LV's probe layout, so users of different types of
%probes will need to adapt that. 

%Output: saves a .mat file with bad channels for each shank/animal that can
%be referenced in later analyses 

%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' '3xTg123' '3xTg132' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-44-1' 'AD-WT-1-0' '3xTg1-1' '3xTg1-2' 'WT159' 'WT105-0' 'WT69-1' 'WT181' 'WT173' '3xTg165' '3xTg177' '3xTg148-1'};


function find_bad_ch_batch(animals, out_dir)   
%make a cell array to store bad channels in 
bad_chans_all_animals = cell(length(animals),8);

for anim =1:length(animals)
animal = animals_all(anim); %get animal from list of animals
exp_dir=get_exp(animal); %get location of that animal's files

if strcmp(animal,'3xTg1-2')==1 %load probe layout
load('ECHIP512_3xTg1-2.mat')
else
load('ECHIP512.mat');
end 

for shank = 1:8;
%loop through each shank
%get theta coherence matrix for a given shank (loading in other frequencies
%too in case I want to play around with them)
load([exp_dir '\CoherenceALLchannels_matrix_shank' num2str(shank) '.mat'],'cohMATRIX','phaseMATRIX', 'SmnMATRIX','SmmMATRIX', 'fpass1', 'fpass2','freq','coh_gamma','coh_theta','coh_fastgamma','coh_slowgamma','phase_gamma','phase_theta','phase_fastgamma', 'phase_slowgamma');

%uncomment this if you want to see original coherence plot

% % figure;
% % imagesc(flipud(coh_theta)); title([animal ' coh plot shank # ' num2str(shank)]);
% % caxis([0.4 1]);

%use mean() to get avg value for each column in coh matrix (only half)
%splitting in half because averaging across everything loses a lot of
%info  

theta_col_means_1 = mean(coh_theta(1:32,:));

%plot mean for each column
% % figure;
% % plot(theta_col_means_1);  title([animal ' theta col means ch1-32 shank # ' num2str(shank)]);

%other half
theta_col_means_2 = mean(coh_theta(33:64,:));
% % figure;
% % plot(theta_col_means_2);  title([animal ' theta col means ch33-64 shank # ' num2str(shank)]);

%full
theta_col_means_full = mean(coh_theta);
% % figure;
% % plot(theta_col_means_full);  title([animal ' theta col means ch1-64 shank # ' num2str(shank)]);

%Get rolling mean

M1 = movmean(theta_col_means_1, 9); %get average for each group of 7 channels
% % figure;
% % plot(M1);  title([animal ' theta col means ch1-32 smoothed shank # ' num2str(shank)]);
normalized_1 = theta_col_means_1-M1; %normalize by subtracting smoothed mean value from each value
% % figure;
% % plot(normalized_1); title([animal ' theta col means ch1-32 raw - smoothed shank # ' num2str(shank)]);
norm_mean_1 = mean(normalized_1); %find mean of normalized values
threshold_1 = norm_mean_1 - 0.05; %set threshold for what is a deviation from that mean 


M2 = movmean(theta_col_means_2, 9); %get average for each group of 7 channels
% % figure;
% % plot(M2);  title([animal ' theta col means ch33-64 smoothed shank # ' num2str(shank)]);
normalized_2 = theta_col_means_2-M2; %normalize by subtracting smoothed mean value from each value
% % figure;
% % plot(normalized_2); title([animal ' theta col means ch33-64 raw - smoothed shank # ' num2str(shank)]);
norm_mean_2 = mean(normalized_2);
threshold_2 = norm_mean_2 - 0.05;


Mfull = movmean(theta_col_means_full, 9); %get average for each group of 7 channels
% % figure;
% % plot(Mfull);  title([animal ' theta col means ch1-64 smoothed shank # ' num2str(shank)]);
normalized_full = theta_col_means_full-Mfull; %normalize by subtracting smoothed mean value from each value
% % figure;
% % plot(normalized_full); title([animal ' theta col means ch1-64 raw - smoothed shank # ' num2str(shank)]);
norm_mean_full = mean(normalized_full);
threshold_full = norm_mean_full - 0.05;

%find the ones that stick out in any of these plots
bad_chans = find(normalized_2 < threshold_2 | normalized_1 < threshold_1 | normalized_full < threshold_full);

%add to cell array
bad_chans_all_animals(anim, shank) = {bad_chans};  

%replot with those channels out 
coh_theta_new = coh_theta;

%plot(coh_theta_new(6,:))  %test plot for one channel

%plot original
[HIPshank, ECshank] = getshankECHIP_LV(animal);
shanks = [HIPshank, ECshank];
if ismember(shank, shanks)
figure;
imagesc(flipud(coh_theta)); title([animal ' coh plot old shank # ' num2str(shank)]);
caxis([0.4 1]);

%replot theta coherence with bad channels out
coh_theta_new([bad_chans], :) = [];
coh_theta_new(:, [bad_chans]) = [];
figure;
imagesc(flipud(coh_theta_new)); title([animal ' coh plot new shank # ' num2str(shank)]);
caxis([0.4 1]);
end

%test - replot theta coherence averaged across all columns with bad channels out
% % theta_col_means_new = mean(coh_theta_new);
% % figure;
% % plot(theta_col_means_new);  title([animal ' theta col means new ch1-64 shank # ' num2str(shank)]);

%test - replot rolling mean with bad channels out
% % Mnew = movmean(theta_col_means_new, 9); %get average for each group of 7 channels  
% % figure;
% % plot(Mnew);  title([animal ' theta col means ch1-64 new smoothed shank # ' num2str(shank)]);

end 

end 
%save as mat file 
all_animals = animals';
bad_chans_table=table(all_animals,bad_chans_all_animals);
 
cd(out_dir);
save('bad_chans_table.mat', 'bad_chans_table');
%index like this: t.bad_chans_all_animals(1,3)
end