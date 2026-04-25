%get experiment directory for the current animal
function [exp_dir] = get_exp(animal)
if strcmp(animal, '3xTg1-1')==1
   exp_dir='H:\data analysis\3xTgAD\3xTg1-1\190830\Recording\';
elseif strcmp(animal, '3xTg1-2')==1
   exp_dir='H:\data analysis\3xTgAD\3xTg1-2\190905\Recording\';
elseif strcmp(animal, 'AD-WT-1-0') == 1
    exp_dir = 'H:\data analysis\3xTgAD\AD-WT-1-0\190820\Recording\';
elseif strcmp(animal, 'AD-WT-2-2') == 1
    exp_dir = 'H:\data analysis\3xTgAD\AD-WT-2-2\190822\Recording\';   
elseif strcmp(animal, '3xTg48-0') == 1
    exp_dir = 'J:\data analysis\3xTgAD\3xTg48-0\201022\Recording\';   
elseif strcmp(animal, '3xTg49-2') == 1
    exp_dir = 'J:\data analysis\3xTgAD\3xTg49-2\201112\Recording\';   
elseif strcmp(animal, '3xTg49-1') == 1
    exp_dir = 'J:\data analysis\3xTgAD\3xTg49-1\201115\Recording\';   
elseif strcmp(animal, 'WT47-0') == 1
    exp_dir = 'G:\data analysis\3xTgAD\WT47-0\201201\Recording\';     
elseif strcmp(animal, 'WT45-1') == 1
    exp_dir = 'J:\data analysis\3xTgAD\WT45-1\201208\Recording\';   
elseif strcmp(animal, 'WT45-2') == 1
    exp_dir = 'J:\data analysis\3xTgAD\WT45-2\201210\Recording\';   
elseif strcmp(animal, 'AD-WT-44-1') == 1
    exp_dir = 'F:\data analysis\3xTgAD\AD-WT-44-1\201117\Recording\';   
elseif strcmp(animal, 'WT78-0') == 1
    exp_dir = 'J:\data analysis\3xTgAD\WT78-0\210331\Recording\';   
elseif strcmp(animal, '3xTg79-0') == 1
    exp_dir = 'K:\data analysis\3xTgAD\3xTg79-0\210416\Recording\';   
elseif strcmp(animal, 'WT77-0') == 1
    exp_dir = 'K:\data analysis\3xTgAD\WT77-0\210413\Recording\';   
elseif strcmp(animal, '3xTg75-1') == 1
    exp_dir = 'G:\data analysis\3xTgAD\3xTg75-1\210404\Recording\';   
elseif strcmp(animal, 'WT89-0') == 1
    exp_dir = 'K:\data analysis\3xTgAD\WT89-0\210428\Recording\';   
elseif strcmp(animal, 'WT69-1') == 1
    exp_dir = 'K:\data analysis\3xTgAD\WT69-1\210514\Recording\';
elseif strcmp(animal, 'WT98-0') == 1
    exp_dir = 'K:\data analysis\3xTgAD\WT98-0\210609\Recording\';   
elseif strcmp(animal, '3xTg77-1') == 1
    exp_dir = 'G:\data analysis\3xTgAD\3xTg77-1\210611\Recording\';   
elseif strcmp(animal, 'WT105-0') == 1
    exp_dir = 'K:\data analysis\3xTgAD\WT105-0\211012\Recording\';   
elseif strcmp(animal, 'WT126') == 1
    exp_dir = 'K:\data analysis\3xTgAD\WT126\220301\Recording\';   
elseif strcmp(animal, '3xTg132') == 1
    exp_dir = 'K:\data analysis\3xTgAD\3xTg132\220415\Recording\';                                                                                           
elseif strcmp(animal, '3xTg123') == 1
    exp_dir = 'W:\data analysis\3xTgAD\3xTg123\220303\Recording\';                                                                    
elseif strcmp(animal, 'WT157') == 1
    exp_dir = 'H:\data analysis\3xTgAD\WT157\220405\Recording\';                                                                    
elseif strcmp(animal, 'WT158') == 1
    exp_dir = 'H:\data analysis\3xTgAD\WT158\220510\Recording\';                                                                    
elseif strcmp(animal, '3xTg125') == 1
    exp_dir = 'H:\data analysis\3xTgAD\3xTg125\220519\Recording\';                                                                    
elseif strcmp(animal, 'WT153') == 1
    exp_dir = 'F:\data analysis\3xTgAD\WT153\220525\Recording\';                                                                    
elseif strcmp(animal, 'WT159') == 1
    exp_dir = 'F:\data analysis\3xTgAD\WT159\220623\Recording\';   
elseif strcmp(animal, '3xTg136') == 1
    exp_dir = 'W:\data analysis\3xTgAD\3xTg136\220726\Recording\';   
elseif strcmp(animal, 'WT162') == 1
    exp_dir = 'W:\data analysis\3xTgAD\WT162\220804\Recording\';   
elseif strcmp(animal, 'WT173') == 1
    exp_dir = 'W:\data analysis\3xTgAD\WT173\220908\Recording\';   
elseif strcmp(animal, '3xTg148-1') == 1
    exp_dir = 'W:\data analysis\3xTgAD\3xTg148-1\220915\Recording\';   
elseif strcmp(animal, 'WT181') == 1
    exp_dir = 'W:\data analysis\3xTgAD\WT181\220906\Recording\';   
elseif strcmp(animal, '3xTg177') == 1
    exp_dir = 'W:\data analysis\3xTgAD\3xTg177\221025\Recording\';  
elseif strcmp(animal, '3xTg165') == 1
    exp_dir = 'W:\data analysis\3xTgAD\3xTg165\221101\Recording\';  
end
