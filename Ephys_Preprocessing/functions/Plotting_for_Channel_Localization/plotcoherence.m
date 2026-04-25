function plotcoherence(animal,probetype)

exp_dir=get_exp(animal);

if strcmp(probetype,'ECHIP512')==1
    numchans=512; %
    numshanks=8;
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512.mat');
elseif strcmp(probetype,'ECHIP512_3xTg1-2')==1
    numshanks=8;
    numchans=512;
    load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\ECHIP512_3xTg1-2.mat')
elseif strcmp(probetype,'probe128A_bottom')==1
    numchans=128;
    numshanks=2;
load('F:\Ephys Analysis\VLSE neuro 4-4 - HPC2\probe_data\probe128A_bottom.mat')
elseif strcmp(probetype,'probe_256BiHipp')==1
    numshanks=4;
    pershank=64;
    numchans=256;
    load('F:\Tristan\VLSE neuro 4-4\probe_data\probe256BiHipp.mat')
end



for shank=1:numshanks

load([exp_dir '\CoherenceALLchannels_matrix_shank' num2str(shank) '.mat'],'cohMATRIX','phaseMATRIX', 'SmnMATRIX','SmmMATRIX', 'fpass1', 'fpass2','freq','coh_gamma','coh_theta','coh_fastgamma','coh_slowgamma','phase_gamma','phase_theta','phase_fastgamma', 'phase_slowgamma');

figure;
   subplot(3,2,1);
   imagesc(flipud(coh_theta)); title([animal ' shank #' num2str(shank)]);
   caxis([0.4 1]);
   subplot(3,2,3);
   imagesc(flipud(coh_gamma)); 
   caxis([0.4 1]);
   subplot(3,2,5);
   imagesc(flipud(coh_fastgamma)); 
   caxis([0.4 1]);
  

   subplot(3,2,2);
   imagesc(flipud(phase_theta)); 
   caxis([-pi pi]);
   subplot(3,2,4);
   imagesc(flipud(phase_gamma)); 
   caxis([-pi pi]);
   subplot(3,2,6);
   imagesc(flipud(phase_fastgamma)); 
   caxis([-pi pi]);


end














end