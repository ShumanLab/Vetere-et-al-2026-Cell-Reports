%animals = {'WT98-0', '3xTg77-1', '3xTg49-2', 'WT45-2'}
%animals = {'3xTg136', '3xTg48-0', '3xTg49-1', '3xTg148-1', '3xTg165'}
function plot_CSD_examplefigs(animals, filter, region)


for anim = 1: length(animals)
    animal = animals{anim};
    
    disp(['starting ' animal])
    exp_dir = get_exp(animal);
    %get lfp data and theta trough times for current animal
    [lfp, events, group, sex, age, channels_by_layer_csd, remove_chans_csd] = pre_CSD(animal, filter, region);
    
    %get layer borders for plotting 
    
    if strcmp(region, 'HIPP')
        if ~isempty(channels_by_layer_csd{7}) %deal with one animal missing oriens
        csd_lyr_borders = [channels_by_layer_csd{2}(1) channels_by_layer_csd{3}(1) channels_by_layer_csd{4}(1) channels_by_layer_csd{5}(1) channels_by_layer_csd{6}(1) channels_by_layer_csd{7}(1)] - 0.5;
        else
        csd_lyr_borders = [channels_by_layer_csd{2}(1) channels_by_layer_csd{3}(1) channels_by_layer_csd{4}(1) channels_by_layer_csd{5}(1) channels_by_layer_csd{6}(1) ] - 0.5;
        end
    elseif strcmp(region, 'MEC')
       if isempty(channels_by_layer_csd{2}) %deal with animals missing MEC2
        csd_lyr_borders = [channels_by_layer_csd{1}(1) channels_by_layer_csd{1}(end)+1] - 0.5;
        else
        csd_lyr_borders = [channels_by_layer_csd{1}(1) channels_by_layer_csd{2}(1) channels_by_layer_csd{2}(end)+1] - 0.5;
        end
    end 
    
    
    %calculate CSD and plot for each animal
    [csd, lfpAvg] = bz_eventCSD_lv_forexamplefigs(lfp, events, animal, group, filter, csd_lyr_borders, region);
    
    
    if ~isempty(remove_chans_csd) %remove rows surrounding any bad channels from averages
        csd.data(:, remove_chans_csd) = NaN; 
    end 


end
end