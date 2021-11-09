%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Shade and flatfield correction code
%%
%%  This codes requires:
%%
%%  1) 10-frame averaged shade images, CFPshade.tif and FRETshade.tif, of illuminated culture
%%     medium with same exposure time as experiment.
%%
%%  2) Dark current images, CFPdc.tif and FRETdc.tif, with no illumination and closed shutter
%%     of same exposure time as experiment (again, 10-frame averaged).
%% 
%%  3) Raw image of CFP and FRET channel, CFP_n.tif and FRET_n.tif
%%
%%  Corrected images are computed using the following equation:
%%                          __                __
%%  Corrected = (Raw - DC + DC)/(Shade - DC + DC)
%%  
%%  Files are saved in a new folder 'Shaded' under the same directory.
%%
%%  Written by Brian Cheung
%%  Version 20190226
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

if ismac || isunix
    slash = '/';
elseif ispc
    slash = '\';
else
    disp('Platform not supported');
end

workdirectory = input('Enter the directory of images including shade and DC: ', 's');
many = input('How many files (stacks) to process? ');
sf = input('Scaling factor to bring image back to 16-bit range after correction? (Recommended: 1000) ');
shadefolder = fullfile(workdirectory, 'Shade Corrected');

if ~exist(shadefolder, 'dir')
    mkdir(shadefolder);
end

CFPshade = im2double(imread(strcat(workdirectory, slash, 'shadeCFP.tif')));
FRETshade = im2double(imread(strcat(workdirectory, slash, 'shadeFRET.tif')));

CFPdc = im2double(imread(strcat(workdirectory, slash, 'dcCFP.tif')));
FRETdc = im2double(imread(strcat(workdirectory, slash, 'dcFRET.tif')));    

CFPdcbar = mean(mean(CFPdc));
FRETdcbar = mean(mean(FRETdc));

for j = 1:many
    
    index = num2str(j);
    filename = strcat(workdirectory, slash, 'FRET_', index, '.tif');
    total = size(imfinfo(filename),1);
    
    parfor i = 1:total
    
    CFP(:,:,i) = im2double(imread(strcat(workdirectory, slash, 'CFP_', index, '.tif'), i));
    FRET(:,:,i) = im2double(imread(strcat(workdirectory, slash, 'FRET_', index, '.tif'), i));
    
    CFPcorrected(:,:,i) = im2uint16(sf/65535*((CFP(:,:,i) - CFPdc + CFPdcbar)./(CFPshade - CFPdc + CFPdcbar)));
    FRETcorrected(:,:,i) = im2uint16(sf/65535*((FRET(:,:,i) - FRETdc + FRETdcbar)./(FRETshade - FRETdc + FRETdcbar)));
    
    end

    CFP_base = sprintf('%s.tif', strcat('scCFP_', index));
    CFP_newName = fullfile(shadefolder, CFP_base);
    
    FRET_base = sprintf('%s.tif', strcat('scFRET_', index));
    FRET_newName = fullfile(shadefolder, FRET_base);
    
    for k = 1:total
        
        imwrite(CFPcorrected(:,:,k), CFP_newName, 'WriteMode', 'append', 'Compression', 'none');
        imwrite(FRETcorrected(:,:,k), FRET_newName, 'WriteMode', 'append', 'Compression', 'none');    
        
    end
    
end