function  [HIPshank, ECshank]=getshankECHIP_LV(animal)



if strcmp(animal, '3xTg1-1')==1
    HIPshank=3;%2
    ECshank=5; %5
elseif strcmp(animal, '3xTg1-2')==1
    HIPshank=4;%3
    ECshank=6;
elseif strcmp(animal, 'WT45-2') == 1
    HIPshank =3;
    ECshank =5;
elseif strcmp(animal, 'AD-WT-1-0') == 1
    HIPshank =3;
    ECshank =7;  
elseif strcmp(animal, '3xTg48-0') == 1
    HIPshank =2;
    ECshank =7;
elseif strcmp(animal, '3xTg49-2') == 1
    HIPshank =4;
    ECshank =7;
elseif strcmp(animal, 'WT47-0') == 1
    HIPshank =3;
    ECshank =6;
elseif strcmp(animal, '3xTg49-1') == 1
    HIPshank =4;
    ECshank =7;
elseif strcmp(animal, 'WT45-1') == 1
    HIPshank = 3;
    ECshank = 8;   %need to fix bad chans before using this
elseif strcmp(animal, 'AD-WT-44-1') == 1
    HIPshank = 2;
    ECshank = 0; %find a way for this to not throw an error  
elseif strcmp(animal, 'WT78-0') == 1
    HIPshank =1;
    ECshank =8;
elseif strcmp(animal, '3xTg75-1') == 1
    HIPshank =3;
    ECshank =5;
elseif strcmp(animal, 'WT77-0') == 1
    HIPshank =2;
    ECshank =8;
elseif strcmp(animal, '3xTg79-0') == 1
    HIPshank =3;
    ECshank =7;
elseif strcmp(animal, 'WT89-0') == 1
    HIPshank =2;
    ECshank =6;
elseif strcmp(animal, 'WT98-0') == 1
    HIPshank =4;
    ECshank =6;
elseif strcmp(animal, '3xTg77-1') == 1
    HIPshank =3;
    ECshank =6;
elseif strcmp(animal, 'WT158') == 1
    HIPshank =3;
    ECshank =6;
elseif strcmp(animal, 'WT157') == 1
    HIPshank =3;
    ECshank =5;
elseif strcmp(animal, 'WT153') == 1
    HIPshank =2;
    ECshank =6;
elseif strcmp(animal, '3xTg125') == 1
    HIPshank =3;
    ECshank =8;
elseif strcmp(animal, 'WT126') == 1
    HIPshank =3;
    ECshank =8;
elseif strcmp(animal, '3xTg123') == 1
    HIPshank =3;
    ECshank =6;
elseif strcmp(animal, '3xTg132') == 1
    HIPshank =4;
    ECshank =0;
elseif strcmp(animal, 'WT159') == 1
    HIPshank =2;
    ECshank =7;
elseif strcmp(animal, '3xTg136') == 1
    HIPshank =2;
    ECshank =7;
elseif strcmp(animal, 'WT162') == 1
    HIPshank =2;
    ECshank =7;
elseif strcmp(animal, 'WT105-0') == 1
    HIPshank =3;
    ECshank =6;
elseif strcmp(animal, 'WT69-1') == 1
    HIPshank =2;
    ECshank =8;
elseif strcmp(animal, 'WT181') == 1
    HIPshank =4;
    ECshank =7;  %not 100% confident 
elseif strcmp(animal, 'WT173') == 1
    HIPshank =3;
    ECshank =6;  %7 could also be good
elseif strcmp(animal, '3xTg148-1') == 1
    HIPshank =4;
    ECshank =7;
elseif strcmp(animal, '3xTg177') == 1
    HIPshank =4;
    ECshank =6;
elseif strcmp(animal, '3xTg165') == 1
    HIPshank =3;
    ECshank =6;  %maybe 7 has layer 3
else
    disp('no shanks assigned')
end
   
   
   
   
   
end