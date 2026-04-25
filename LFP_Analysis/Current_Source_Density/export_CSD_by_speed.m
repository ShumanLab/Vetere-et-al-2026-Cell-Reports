% 
% animals = {'3xTg136' 'WT162' 'WT78-0' '3xTg75-1' 'WT77-0' '3xTg79-0' 'WT89-0' 'WT98-0' '3xTg77-1' 'WT158' 'WT153' 'WT157' '3xTg125' 'WT126' 'WT45-1' 'WT45-2' 'WT47-0' '3xTg48-0' '3xTg49-2' '3xTg49-1' 'AD-WT-1-0' '3xTg1-1' 'WT159' 'WT105-0' 'WT69-1' 'WT173' '3xTg165' '3xTg177' '3xTg148-1' 'AD-WT-44-1' '3xTg132' 'WT181' '3xTg123' '3xTg1-2'};
% filters = { 'theta'};
% region = 'HIPP';
%binsstart = 0; 
%speedbinsize = 0.1; 

function export_CSD_by_speed(animals, filters, region, binsstart, speedbinsize)

table_row = 1; 

for filt = 1:length(filters)
    filter = filters{filt};

        for anim =1:length(animals)
            animal = animals{anim};
            exp_dir = get_exp(animal);
            
            
            stim_dir=[exp_dir 'stimuli\'];
    
            run_speed = load([stim_dir 'running.mat']);
            run_speed = downsample(run_speed.running,25); %maybe downsample even more - this is now 1000Hz 
            run_bl = mode(run_speed);
            run_speed = run_speed - run_bl; 
            min_speed = binsstart;
            max_speed = max(run_speed); 

            speed_bins = min_speed:speedbinsize:max_speed;

            for b = 1:length(speed_bins)-1
                mins = speed_bins(b);
                maxs = speed_bins(b+1);

                csd_data = load([exp_dir '/' animal '_' filter '_' region '_CSDrun_' num2str(mins) '_' num2str(maxs) '.mat']);

                csd_data = csd_data.csd_struct;
            
                group = csd_data.group;
                sex = csd_data.sex;
                age = csd_data.age;


                avgmagbylyr = csd_data.avgmagbylyr;
                maxmagbylyr = csd_data.maxmagbylyr ;
                avgmagbylyr_cycle = csd_data.avgmagbylyr_cycle;
                maxmagbylyr_cycle = csd_data.maxmagbylyr_cycle;
                numtroughs = csd_data.numtroughs;
            
                csd_types = {'avgbylyr', 'maxbylyr', 'avgbylyr_cycle', 'maxbylyr_cycle'};
            
            for t = 1:length(csd_types)
                type = csd_types{t};
                
                %Put everything into variables that will form a table at the end
                Animal{table_row} = animal;
                Group{table_row} = group;
                Sex{table_row} = sex;
                Age{table_row} = age;
                Region{table_row} = region;              
                Filter{table_row} = filter;
                DataType{table_row} = type;
                Binmin{table_row} = mins;
                Binmax{table_row} = maxs; 
                Binsize{table_row} = speedbinsize; 
                Numtroughs{table_row} = numtroughs;
                
                if strcmp(type, 'avgbylyr')
                    Hil{table_row} = avgmagbylyr(1);
                    GC{table_row} = avgmagbylyr(2);
                    Mol{table_row} = avgmagbylyr(3);
                    LM{table_row} = avgmagbylyr(4);
                    Rad{table_row} = avgmagbylyr(5);
                    Pyr{table_row} = avgmagbylyr(6);
                    Or{table_row} = avgmagbylyr(7);
                elseif  strcmp(type, 'maxbylyr')
                    Hil{table_row} = maxmagbylyr(1);
                    GC{table_row} = maxmagbylyr(2);
                    Mol{table_row} = maxmagbylyr(3);
                    LM{table_row} = maxmagbylyr(4);
                    Rad{table_row} = maxmagbylyr(5);
                    Pyr{table_row} = maxmagbylyr(6);
                    Or{table_row} = maxmagbylyr(7);
                elseif  strcmp(type, 'avgbylyr_cycle')
                    Hil{table_row} = avgmagbylyr_cycle(1);
                    GC{table_row} = avgmagbylyr_cycle(2);
                    Mol{table_row} = avgmagbylyr_cycle(3);
                    LM{table_row} = avgmagbylyr_cycle(4);
                    Rad{table_row} = avgmagbylyr_cycle(5);
                    Pyr{table_row} = avgmagbylyr_cycle(6);
                    Or{table_row} = avgmagbylyr_cycle(7);
                elseif  strcmp(type, 'maxbylyr_cycle')
                    Hil{table_row} = maxmagbylyr_cycle(1);
                    GC{table_row} = maxmagbylyr_cycle(2);
                    Mol{table_row} = maxmagbylyr_cycle(3);
                    LM{table_row} = maxmagbylyr_cycle(4);
                    Rad{table_row} = maxmagbylyr_cycle(5);
                    Pyr{table_row} = maxmagbylyr_cycle(6);
                    Or{table_row} = maxmagbylyr_cycle(7);
                end  
                  
              
                %Total_time(table_row) = total_time; 
            
                table_row = table_row + 1;
            end    
                disp(['done with ' animal ' ' filter])
            end


             disp(['done with '  filter])
        end
            
   
    
    Table = table(Animal', Group', Sex', Age', Region', Filter', DataType', Hil', GC' ,Mol', LM', Rad', Pyr', Or', Binmin', Binmax', Binsize', Numtroughs', 'VariableNames',{'Animal', 'Group', 'Sex', 'Age', 'Region', 'Filter', 'DataType', 'Hil', 'GC' ,'Mol', 'LM', 'Rad', 'Pyr', 'Or', 'Binmin', 'Binmax', 'Binsize', 'Numtroughs'});
           
    out_dir = 'W:\data analysis';
    cd(out_dir);
    writetable(Table,['CSDrunoutput_byspeed_HIPP.csv'])  %Region 
end 