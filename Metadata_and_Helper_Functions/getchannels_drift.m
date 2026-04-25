function [ch] = getchannels_drift(animal, shank, set)

%Get channel-brain region assignments depending on time period of recording - this is
%done to help account for drift 

%Inputs = animal ID string, shank number (1-8), set

%Other files needed within Matlab file path - 3 mat files with different sets of channels for different time periods.
%Each animal has 1, 2, or max 3 different channel sets. Set #4 contains DG
%and CA1 boundaries for full recording single unit analysis

%Each file contains a structure called ChannelSets

if isequal(set, 1)
    chlocations = load('ChannelSets_Early_010924');
elseif isequal(set, 2)
    chlocations = load('ChannelSets_Mid_010924');
elseif isequal(set, 3)
    chlocations =load('ChannelSets_Late_010924');
elseif isequal(set, 4)
    chlocations =load('ChannelSets_Spikes_010924');
end

chlocations = chlocations.ChannelSets;

ch=struct;

%just to handle when making template for HPC and EC
if shank == 'Mean'
    animalind = 2;
    
else

%animalind=find(strcmp(chlocations(:,1),animal)==1  & [0; cell2mat(chlocations(3:end,3))]==shank);

a = find(strcmp(chlocations(:,1),animal)==1);
b = find([0; cell2mat(chlocations(3:end,3))]==shank); %weirdly is 1 rows offset, need add 2 to array
b=b+1;
animalind = intersect(a,b);
clear a b;
end;


ch.group=chlocations{animalind,2};
ch.sex =chlocations{animalind, 33};
ch.age = chlocations{animalind,34};
ch.shank=chlocations{animalind,3};
ch.region=chlocations{animalind,4};
ch.MedLat=chlocations{animalind,5};
ch.MidPyr=chlocations{animalind,6};
ch.Or1=chlocations{animalind,7};
ch.Or2=chlocations{animalind,8};
ch.Pyr1=chlocations{animalind,9};
ch.Pyr2=chlocations{animalind,10};
ch.Rad1=chlocations{animalind,11};
ch.Rad2=chlocations{animalind,12};
ch.LM1=chlocations{animalind,13};
ch.LM2=chlocations{animalind,14};
ch.Mol1=chlocations{animalind,15};
ch.Mol2=chlocations{animalind,16};
ch.GC1=chlocations{animalind,17};
ch.GC2=chlocations{animalind,18};
ch.Hil1=chlocations{animalind,19};
ch.Hil2=chlocations{animalind,20};

ch.CA31=chlocations{animalind,21};
ch.CA32=chlocations{animalind,22};

ch.EC31=chlocations{animalind,23};
ch.EC32=chlocations{animalind,24};
ch.EC21=chlocations{animalind,25};
ch.EC22=chlocations{animalind,26};
ch.EC11=chlocations{animalind,27};
ch.EC12=chlocations{animalind,28};

ch.CA1up=chlocations{animalind,29};
ch.CA1low=chlocations{animalind,30};
ch.DGup=chlocations{animalind,31};
ch.DGlow=chlocations{animalind,32};


    
    ch.MidPyr(ch.MidPyr==0)=[];
    ch.Or1(ch.Or1==0)=[];
    ch.Or2(ch.Or2==0)=[];
    ch.Pyr1(ch.Pyr1==0)=[];
    ch.Pyr2(ch.Pyr2==0)=[];
    ch.Rad1(ch.Rad1==0)=[];
    ch.Rad2(ch.Rad2==0)=[];
    ch.LM1(ch.LM1==0)=[];
    ch.LM2(ch.LM2==0)=[];
    ch.Mol1(ch.Mol1==0)=[];
    ch.Mol2(ch.Mol2==0)=[];
    ch.GC1(ch.GC1==0)=[];
    ch.GC2(ch.GC2==0)=[];
    ch.Hil1(ch.Hil1==0)=[];
    ch.Hil2(ch.Hil2==0)=[];


ch.CA31(ch.CA31==0)=[];
ch.CA32(ch.CA32==0)=[];

ch.EC31(ch.EC31==0)=[];
ch.EC32(ch.EC32==0)=[];
ch.EC21(ch.EC21==0)=[];
ch.EC22(ch.EC22==0)=[];
ch.EC11(ch.EC11==0)=[];
ch.EC12(ch.EC12==0)=[];
