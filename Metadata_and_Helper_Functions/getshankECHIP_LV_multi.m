function  [HIPshanks, ECshanks]=getshankECHIP_LV_multi(animal)



if strcmp(animal, '3xTg1-1')==1
    HIPshanks=[2,3];%2
    ECshanks=5; %5
elseif strcmp(animal, '3xTg1-2')==1
    HIPshanks=4;%3
    ECshanks=6;
elseif strcmp(animal, 'WT45-2') == 1
    HIPshanks =[3,4];
    ECshanks =5;
elseif strcmp(animal, 'AD-WT-1-0') == 1
    HIPshanks =3;
    ECshanks =7;  
elseif strcmp(animal, '3xTg48-0') == 1
    HIPshanks =[2,3];
    ECshanks =7;
elseif strcmp(animal, '3xTg49-2') == 1
    HIPshanks =[3,4]; 
    ECshanks =7;
elseif strcmp(animal, 'WT47-0') == 1
    HIPshanks =[3,4];
    ECshanks =6;
elseif strcmp(animal, '3xTg49-1') == 1
    HIPshanks =[3,4];
    ECshanks =7;
elseif strcmp(animal, 'WT45-1') == 1
    HIPshanks = [2,3];
    ECshanks = 8;   %need to fix bad chans before using this
elseif strcmp(animal, 'AD-WT-44-1') == 1
    HIPshanks = [2,3];
    ECshanks = 0; %find a way for this to not throw an error  
elseif strcmp(animal, 'WT78-0') == 1
    HIPshanks =[1,2];
    ECshanks =8;
elseif strcmp(animal, '3xTg75-1') == 1
    HIPshanks =3;
    ECshanks =[5,6];
elseif strcmp(animal, 'WT77-0') == 1
    HIPshanks =[2,3];
    ECshanks =8;
elseif strcmp(animal, '3xTg79-0') == 1
    HIPshanks =[2,3];
    ECshanks =[6,7];
elseif strcmp(animal, 'WT89-0') == 1
    HIPshanks =[2,3];
    ECshanks =[5,6];
elseif strcmp(animal, 'WT98-0') == 1
    HIPshanks =4;
    ECshanks =6;
elseif strcmp(animal, '3xTg77-1') == 1
    HIPshanks =3;
    ECshanks =6;
elseif strcmp(animal, 'WT158') == 1
    HIPshanks =[3,4];
    ECshanks =[6];  %removed 5 
elseif strcmp(animal, 'WT157') == 1
    HIPshanks =3;
    ECshanks =5;
elseif strcmp(animal, 'WT153') == 1
    HIPshanks =2;
    ECshanks =6;
elseif strcmp(animal, '3xTg125') == 1
    HIPshanks =3;
    ECshanks =8;
elseif strcmp(animal, 'WT126') == 1
    HIPshanks =3;
    ECshanks =8;
elseif strcmp(animal, '3xTg123') == 1
    HIPshanks =3;
    ECshanks =6;
elseif strcmp(animal, '3xTg132') == 1
    HIPshanks =4;
    ECshanks =0;
elseif strcmp(animal, 'WT159') == 1
    HIPshanks =2;
    ECshanks =7;
elseif strcmp(animal, '3xTg136') == 1
    HIPshanks =[2,3];
    ECshanks =[6,7];
elseif strcmp(animal, 'WT162') == 1
    HIPshanks =2;
    ECshanks =7;
elseif strcmp(animal, 'WT105-0') == 1
    HIPshanks =3;
    ECshanks =6;
elseif strcmp(animal, 'WT69-1') == 1
    HIPshanks =[2,3];
    ECshanks =8;
elseif strcmp(animal, 'WT181') == 1
    HIPshanks =4;
    ECshanks =7;  %not 100% confident 
elseif strcmp(animal, 'WT173') == 1
    HIPshanks =3;
    ECshanks =6;  %7 could also be good
elseif strcmp(animal, '3xTg148-1') == 1
    HIPshanks =4;
    ECshanks =7;
elseif strcmp(animal, '3xTg177') == 1
    HIPshanks =[3,4];
    ECshanks =[5,6,7];
elseif strcmp(animal, '3xTg165') == 1
    HIPshanks =3;
    ECshanks =[6,7];  %maybe 7 has layer 3
else
    disp('no shanks assigned')
end
   
   
   
   
   
end