%This script takes output from coherence calculation function and exports
%into a table that can be imported in R

%Inputs: Cell array of animal IDs, cell array of filter names, cell array
%of run states (options: 'runall' 'runthresh' 'nonrun' 'all'
%'diff_runVSnon' 'diff_threshVSnon'), seg (= to size of bins used in
%coherence calculation ex. seg = 1 for 1 second bins), out_dir = where to save your table. 

%Outputs: Table in out_dir where each row represents a pair of regions in a
%given running state for a given animal and contains coherence values. 

%example inputs: 
%animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};
%filters = { 'slow_gamma'};
%run_states = {'runall' 'runthresh' 'nonrun' 'all' 'diff_runVSnon' 'diff_threshVSnon'};
%seg = 1;
%out_dir = 'W:\data analysis';

function coh_data_export_forR(animals, filters, run_states, seg, out_dir)
 
table_row = 1; 

for s = 1:length(run_states)
    state = run_states{s};
    
    for filt = 1:length(filters)
        filter = filters{filt};

        for anim =1:length(animals)
            animal = animals{anim};
            exp_dir = get_exp(animal);

            coh_data = load([ exp_dir '\' animal '_' filter '_' num2str(seg) 'sbins_cohmat_byrunning_drift_Atracks.mat']);

            coh_data = coh_data.coh_struct;
            
            group = coh_data.group;
            sex = coh_data.sex;
            age = coh_data.age;
            %num_bins = coh_data.num_bins;
            runthresh_low = coh_data.runthresh_low;
            runthresh_high = coh_data.runthresh_high;
            run_bl = coh_data.baseline; 

            avg_run_speed = coh_data.avg_run_speed; 
            avg_run_speed_w_thresh = coh_data.avg_run_speed_w_thresh; 
            avg_speed_non_run = coh_data.avg_speed_non_run; 

            length_run_time= coh_data.length_run_time; 
            length_nonrun_time= coh_data.length_nonrun_time; 
            length_thresh_run_time= coh_data.length_thresh_run_time; 
            length_full= coh_data.length_full; 
            total_time = coh_data.length_full;
            
            %get coherence across time windows of interest based on running
            %behavior
            if strcmp(state, 'runall')
                coh_matrix = coh_data.coh_run_all;
                phase_matrix = coh_data.phase_run_all; 
            elseif strcmp(state, 'runthresh')
                coh_matrix = coh_data.coh_run_in_thresh;
                phase_matrix = coh_data.phase_run_in_thresh; 
            elseif strcmp(state, 'nonrun')
                coh_matrix = coh_data.coh_non_run;
                phase_matrix = coh_data.phase_non_run; 
            elseif strcmp(state, 'all') 
                coh_matrix = coh_data.coh_all;
                phase_matrix = coh_data.phase_all;  
            elseif strcmp(state, 'diff_runVSnon')
                coh_matrix = coh_data.diff_threshVSnon; 
                 phase_matrix = NaN;
            elseif strcmp(state, 'diff_thresh_3sminVSnon')
                coh_matrix = coh_data.diff_thresh_3sminVSnon;  
                 phase_matrix = NaN;
            elseif strcmp(state, 'diff_threshVSnon')
                coh_matrix = coh_data.diff_threshVSnon; 
                 phase_matrix = NaN;
            end 
           

            Hil_ind= (1:11);  %bottom
            GC_ind = (12:15);
            Mol_ind = (16:23);
            LM_ind = (24:31);
            Rad_ind = (32:43);
            Pyr_ind = (44:50);
            Or_ind = (51:58);

            MEC2_ind = (59:77);%bottom 
            MEC3_ind = (78:92);

            %coherence + phase matrices
            coh_matrix_small(1,:) = mean(coh_matrix(Hil_ind(1):Hil_ind(end),:), 'omitnan'); %find all hilus rows, take the average
            coh_matrix_small(2,:) =  mean(coh_matrix(GC_ind(1):GC_ind(end),:), 'omitnan');
            coh_matrix_small(3,:) =  mean(coh_matrix(Mol_ind(1):Mol_ind(end),:), 'omitnan');
            coh_matrix_small(4,:) =  mean(coh_matrix(LM_ind(1):LM_ind(end),:), 'omitnan');
            coh_matrix_small(5,:) =  mean(coh_matrix(Rad_ind(1):Rad_ind(end),:), 'omitnan');
            coh_matrix_small(6,:) =  mean(coh_matrix(Pyr_ind(1):Pyr_ind(end),:), 'omitnan');
            coh_matrix_small(7,:) =  mean(coh_matrix(Or_ind(1):Or_ind(end),:), 'omitnan');
            coh_matrix_small(8,:) =  mean(coh_matrix(MEC2_ind(1):MEC2_ind(end),:), 'omitnan');
            coh_matrix_small(9,:) =  mean(coh_matrix(MEC3_ind(1):MEC3_ind(end),:), 'omitnan');

            coh_matrix_final = zeros(9,9);
            
            if length(phase_matrix) ~= 1   %will be true if a full matrix exists 
            phase_matrix_small(1,:) = mean(phase_matrix(Hil_ind(1):Hil_ind(end),:), 'omitnan');  %this might not be best way to do this?? 
            phase_matrix_small(2,:) =  mean(phase_matrix(GC_ind(1):GC_ind(end),:), 'omitnan');
            phase_matrix_small(3,:) =  mean(phase_matrix(Mol_ind(1):Mol_ind(end),:), 'omitnan');
            phase_matrix_small(4,:) =  mean(phase_matrix(LM_ind(1):LM_ind(end),:), 'omitnan');
            phase_matrix_small(5,:) =  mean(phase_matrix(Rad_ind(1):Rad_ind(end),:), 'omitnan');
            phase_matrix_small(6,:) =  mean(phase_matrix(Pyr_ind(1):Pyr_ind(end),:), 'omitnan');
            phase_matrix_small(7,:) =  mean(phase_matrix(Or_ind(1):Or_ind(end),:), 'omitnan');
            phase_matrix_small(8,:) =  mean(phase_matrix(MEC2_ind(1):MEC2_ind(end),:), 'omitnan');
            phase_matrix_small(9,:) =  mean(phase_matrix(MEC3_ind(1):MEC3_ind(end),:), 'omitnan');

            phase_matrix_final = zeros(9,9);
            
            else
            phase_matrix_small = NaN;
            phase_matrix_final = NaN;
            end
            
            for lyra = 1:length(coh_matrix_final)
                for lyrb = 1:length(coh_matrix_final)
                    if lyrb == 1
                        chan_start = Hil_ind(1);
                        chan_end = Hil_ind(end);
                    elseif lyrb == 2
                        chan_start = GC_ind(1);
                        chan_end = GC_ind(end);
                    elseif lyrb== 3
                        chan_start = Mol_ind(1);
                        chan_end = Mol_ind(end);
                    elseif lyrb == 4
                        chan_start = LM_ind(1);
                        chan_end = LM_ind(end);
                    elseif lyrb == 5
                        chan_start = Rad_ind(1);
                        chan_end = Rad_ind(end);
                    elseif lyrb == 6
                        chan_start = Pyr_ind(1);
                        chan_end = Pyr_ind(end);
                    elseif lyrb == 7
                        chan_start = Or_ind(1);
                        chan_end = Or_ind(end);
                    elseif lyrb == 8
                        chan_start = MEC2_ind(1);
                        chan_end = MEC2_ind(end);
                    elseif lyrb == 9
                        chan_start = MEC3_ind(1);
                        chan_end = MEC3_ind(end);
                    end 
                coh_matrix_final(lyra,lyrb) = mean(coh_matrix_small(lyra,chan_start:chan_end), 'omitnan');
                
                if length(phase_matrix) ~= 1 
                phase_matrix_final(lyra, lyrb) = mean(phase_matrix_small(lyra, chan_start:chan_end), 'omitnan');
                end
                    
                end
            end


            if length(phase_matrix) ~= 1 
            phase_matrix_final = phase_matrix_final;
            else
            phase_matrix_final = NaN(9,9);
            end

            regions = {'Hil', 'GC', 'Mol', 'LM', 'Rad', 'Pyr', 'Or', 'MEC2' 'MEC3'}; 
            %regions2 = flip(regions);
            
            for r = 1:length(regions)
                reg = regions{r};   
                for r2 = 1:length(regions)
                    reg2 = regions{r2}; 
                    coh_pair = coh_matrix_final(r, r2);
                    phase_pair = phase_matrix_final(r, r2);
                    
                    Coh(table_row) = coh_pair; 
                    Phase(table_row) = phase_pair; 
                    
                %Put everything into variables that will form a table at the end
                Animal{table_row} = animal;
                Group{table_row} = group;
                Sex{table_row} = sex;
                Age{table_row} = age;
                Region1{table_row} = reg;
                Region2{table_row} = reg2;
                Runthresh_low(table_row) = runthresh_low;
                Runthresh_high(table_row) = runthresh_high;
                Run_bl(table_row) = run_bl; 
                %Num_bins(table_row) = num_bins;

                Filter{table_row} = filter;
                Run_state{table_row} = state;

                %Time_0(table_row) = t0; 
                %Time_1(table_row) = t1;
                Total_time(table_row) = total_time; 
            
                   if strcmp(state, 'runall')
                     Avg_speed(table_row) = avg_run_speed; 
                     Time_in_state(table_row) = length_run_time; 
                   elseif strcmp(state, 'runthresh')
                     Avg_speed(table_row) = avg_run_speed_w_thresh;
                     Time_in_state(table_row) = length_thresh_run_time;
                   elseif strcmp(state, 'nonrun')
                     Avg_speed(table_row) =  avg_speed_non_run;
                     Time_in_state(table_row) = length_nonrun_time;
                   elseif strcmp(state, 'all') 
                     Avg_speed(table_row) = NaN ;  %didn't calculate this this time - not necessarily meaningful on its own
                     Time_in_state(table_row) =  length_full ;
                   elseif strcmp(state, 'diff_runVSnon')
                     Avg_speed(table_row) = NaN ;
                     Time_in_state(table_row) = NaN ; 
                   elseif strcmp(state, 'diff_threshVSnon')
                     Avg_speed(table_row) = NaN ;
                     Time_in_state(table_row) = NaN ;
                   end 


                table_row = table_row + 1;
                end     
            end


             disp(['done with ' animal ' ' filter])
        end
        disp(['done with '  filter])    
    end   
       disp(['done with '  state]) 
    end  
  

    
    Table = table(Animal', Group', Sex', Age', Region1', Region2', Filter', Coh' , Phase', Run_state',  Runthresh_low', Runthresh_high', Run_bl', Total_time', Avg_speed', Time_in_state', 'VariableNames',{'Animal', 'Group', 'Sex', 'Age', 'Region1', 'Region2', 'Filter', 'Coh', 'Phase', 'Run_state',  'Runthresh_low', 'Runthresh_high', 'Run_bl', 'Total_time',  'Avg_speed', 'Time_in_state'});

    %out_dir = 'W:\data analysis';
    cd(out_dir);
    writetable(Table,['Coherence_average_by_layer_' num2str(seg) 's_' track 'track_' filter '.csv'])
end 