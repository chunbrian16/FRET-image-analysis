close all
clear all
clc

if ismac || isunix
    slash = '/';
elseif ispc
    slash = '\';
else
    disp('Platform not supported');
end

workdirectory = input('Enter the directory of aligned images: ', 's');
maskdirectory = input('Enter the directory of masks: ', 's');
CFPnamae = "aligned_CFP_";
FRETnamae = "aligned_FRET_"
many = input('How many pairs of CFP/FRET files? ');
maskname = input('Name of mask file (excluding ".tif" and the last number): ', 's');
bgCFPname = input('Name of CFP background csv file (excluding ".csv" and the last number): ', 's');
bgFRETname = input('Name of FRET background csv file (excluding ".csv" and the last number): ', 's');

ratiofolder = fullfile(workdirectory, 'ratioFRET');

if ~exist(ratiofolder, 'dir')
    mkdir(ratiofolder);
end

for j = 1:many
    
    
    index = num2str(j);
    
    CFPfile = strcat(workdirectory, slash, CFPnamae, index, '.tif');
    FRETfile = strcat(workdirectory, slash, FRETnamae, index, '.tif');
    maskfile = strcat(maskdirectory, slash, maskname, index, '.tif');
    bgCFPfile = strcat(workdirectory, slash, bgCFPname, index, '.csv');
    bgFRETfile = strcat(workdirectory, slash, bgFRETname, index, '.csv');
    
    if exist(maskfile,'file') && exist(bgCFPfile,'file') && exist(bgFRETfile,'file')
    
    bgCFP = csvread(bgCFPfile, 1, 1);
    bgFRET = csvread(bgFRETfile, 1, 1);
    
    total = size(imfinfo(FRETfile),1);
        
    for i = 1:total
        
        CFP(:,:,i) = im2double(imread((CFPfile), i)) - bgCFP(i,1)/65535;
        FRET(:,:,i) = (im2double(imread((FRETfile), i)) - bgFRET(i,1)/65535)/2;
        Mask(:,:,i) = im2double(imread((maskfile), i));
        ratio(:,:,i) = (Mask(:,:,i).*FRET(:,:,i))./(Mask(:,:,i).*CFP(:,:,i))*3000/65535;    %   To bring the ratios back to the 16-bit domain, ratios are multiplied by a scaling factor of 3000.
        modratio(:,:,i) = medfilt2(ratio(:,:,i), [2 2]);
        
        [x,y] = size(FRET(:,:,i));
        
        for m = 1:x
            for n = 1:y
                if isnan(modratio(m,n,i)) || modratio(m,n,i) == inf
                    modratio(m,n,i) = 0;
                end
            end
        end
        
%         new(:,:,i) = ratio(:,:,i)/(max(max(ratio(:,:,i))));
        new2(:,:,i) = im2uint16(modratio(:,:,i)); %% ratio->new
        
    end
    
    FRET_base = sprintf('%s.tif', strcat('ratioFRET_', index));
    FRET_fullName = fullfile(ratiofolder, FRET_base);
    
    for k = 1:total
        
        imwrite(new2(:,:,k), FRET_fullName, 'WriteMode', 'append', 'Compression', 'none');
        
    end
    
    else
        
    end
    
end