%% Correct photobleaching of masked cell images using double exponential decay model.

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

workdirectory = input('Enter the directory of ratio FRET images: ', 's');
FRETnamae = "ratioFRET_";
many = input('How many files? ');

bleachfolder = fullfile(workdirectory, 'debleached');

if ~exist(bleachfolder, 'dir')
    mkdir(bleachfolder);
end


for j = 1:many
    
    index = num2str(j);
    FRETfile = strcat(workdirectory, slash, FRETnamae, index, '.tif');
    
    if exist(FRETfile, 'file')
        
    total = size(imfinfo(FRETfile),1);
    f = zeros(total,2);
    
    for i = 1:total
        
        FRET(:,:,i) = im2double(imread(FRETfile, i));
        temp = FRET(:,:,i);
        
        meanFRET = mean(mean(temp(temp~=0)));
        
        f(i,1) = i;
        f(i,2) = meanFRET;
        
    end
    
    FRETcurv = fit(f(:,1), f(:,2), 'exp2');
    parameters = coeffvalues(FRETcurv);
    a = parameters(1);
    b = parameters(2);
    c = parameters(3);
    d = parameters(4);
    
    bleach = zeros(total,1);
    
    for i = 1:total
        
        bleach(i) = a*exp(b*i) + c*exp(d*i);
        
    end
    
    factor = bleach/bleach(1);
    
    for i = 1:total
        
        nFRET(:,:,i) = im2double(imread(FRETfile, i));
        
        FRETblch(:,:,i) = nFRET(:,:,i)*(1/factor(i));
        
        realFRET(:,:,i) = im2uint16(FRETblch(:,:,i));
        
    end
    
        de_FRETbase = sprintf('%s.tif', strcat('debleach_FRET_', index));
        de_FRETfullName = fullfile(bleachfolder, de_FRETbase);
        
        for k = 1:total
            
        imwrite(realFRET(:,:,k), de_FRETfullName, 'WriteMode', 'append', 'Compression', 'none');
        
        end
    
    else
        
    end
    
end