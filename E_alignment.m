%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Alignment code
%%
%%  This codes requires:
%%
%%  1) Shade and flatfield corrected cell images: scCFP.tif, scFRET.tif.
%%
%%  2) Cropped (from insideoutcrop.m) Bead images (Both CFP and FRET channel)
%%
%%  The code utilizes a built-in feature-matching-based algorithm,
%%  and affine transformation (x-y translation, rotation, scale, shear) to align bead images.
%%
%%  The alignment result from bead images are carried to cell images for alignment.
%%
%%  Files are saved in a new folder 'Aligned' under the same directory.
%%
%%  Written by Brian Cheung
%%  Version 20190315
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

workdirectory = input('Enter the directory of split images: ', 's');
beaddirectory = input('Enter the directory of bead images: ', 's');
CFPnamae = "scCFP_";
FRETnamae = "scFRET_";
many = input('How many pairs of CFP/FRET files? ');
beadCFPname = "beadCFP";
beadFRETname = "beadFRET";
beadCFPfile = strcat(beaddirectory, slash, beadCFPname, '.tif');
beadFRETfile = strcat(beaddirectory, slash, beadFRETname, '.tif');

outputFolder = fullfile(workdirectory, 'Aligned');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This section runs alignment on bead image, the registration information will be transferred to cell images for alignment.

FIXED = imread(beadFRETfile);
MOVING = imread(beadCFPfile);

% Default spatial referencing objects
fixedRefObj = imref2d(size(FIXED));
movingRefObj = imref2d(size(MOVING));

% Detect SURF features
fixedPoints = detectSURFFeatures(FIXED,'MetricThreshold',515.625000,'NumOctaves',4,'NumScaleLevels',6);
movingPoints = detectSURFFeatures(MOVING,'MetricThreshold',515.625000,'NumOctaves',4,'NumScaleLevels',6);

% Extract features
[fixedFeatures,fixedValidPoints] = extractFeatures(FIXED,fixedPoints,'Upright',false);
[movingFeatures,movingValidPoints] = extractFeatures(MOVING,movingPoints,'Upright',false);

% Match features
indexPairs = matchFeatures(fixedFeatures,movingFeatures,'MatchThreshold',99.652778,'MaxRatio',0.996528);
fixedMatchedPoints = fixedValidPoints(indexPairs(:,1));
movingMatchedPoints = movingValidPoints(indexPairs(:,2));
MOVINGREG.FixedMatchedFeatures = fixedMatchedPoints;
MOVINGREG.MovingMatchedFeatures = movingMatchedPoints;

% Apply transformation - Results may not be identical between runs because of the randomized nature of the algorithm
tform = estimateGeometricTransform(movingMatchedPoints,fixedMatchedPoints,'affine');
MOVINGREG.Transformation = tform;
MOVINGREG.RegisteredImage = imwarp(MOVING, movingRefObj, tform, 'OutputView', fixedRefObj, 'SmoothEdges', false);

% Nonrigid registration
[MOVINGREG.DisplacementField,MOVINGREG.RegisteredImage] = imregdemons(MOVINGREG.RegisteredImage,FIXED,500,'AccumulatedFieldSmoothing',1.0,'PyramidLevels',3);

% Store spatial referencing object
MOVINGREG.SpatialRefObj = fixedRefObj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j = 1:many
    
    index = num2str(j);
    CFPfile = strcat(workdirectory, slash, CFPnamae, index, '.tif');
    FRETfile = strcat(workdirectory, slash, FRETnamae, index, '.tif');
    
    total = size(imfinfo(FRETfile),1);
    
    CFP_base = sprintf('%s.tif', strcat('aligned_CFP_', index));
    CFP_newName = fullfile(outputFolder, CFP_base);
    FRET_base = sprintf('%s.tif', strcat('aligned_FRET_', index));
    FRET_newName = fullfile(outputFolder, FRET_base);
    
    %% This section takes the alignment result from bead images to align cells.
    
    for i = 1:total
        
        CFP = imread(CFPfile, i);
        FRET = imread(FRETfile, i);
        CellRefObj = imref2d(size(CFP(:,:,1)));
        CellFRETRefObj = imref2d(size(FRET(:,:,1)));
        
        newCFP(:,:,i) = imwarp(CFP, CellRefObj, tform, 'OutputView', CellFRETRefObj, 'SmoothEdges', false);
        
        fprintf('%i/%i images in file %s (of %i) are processed.\n', i, total, index, many)
        
    end
    
    for i = 1:total
        
        imwrite(newCFP(:,:,i), CFP_newName, 'WriteMode', 'append', 'Compression', 'none');
        
    end
    
    for i = 1:total
        
        FRET = imread(FRETfile, i);
        imwrite(FRET, FRET_newName, 'WriteMode', 'append', 'Compression', 'none');
        
    end
    
end