% Ratiometric calcaltion for FRET analysis
% Written by Brian Cheung
% Version: 20190510
% Advice: The code has to work with function "getFileList".

close all
clearvars -except nl ml ns ms center_x_long center_y_long center_x_short center_y_short c y cshade yshade cDC yDC cbead ybead

if ismac || isunix
    slash = '/';
elseif ispc
    slash = '\';
else
    disp('Platform not supported');
end

% Generate a folder for storage of split images under the image folder.
directory = input('Please enter raw image directory: ', 's');
beaddir = input('Please enter bead image directory: ', 's');
namae = input('Root Name of the timelapse image (excluding ".tif", and last number): ', 's');
many = input('How many files (stacks) to process?');
shade = input('Name of the shade image (excluding ".tif"): ', 's');
DC = input('Name of the Dark Current image (excluding ".tif"): ', 's');
beads = input ('Name of beads image (excluding ".tif"): ', 's');
border = input('Crop Percentage? ');
x_offset = input('Offset of center for x? ');
y_offset = input('Offset of center for y? ');
ROI_CFP_leftcorner_x = input('What is the X value in ROI Manager for CFP channel? ');
ROI_FRET_leftcorner_x = input('What is the X value in ROI Manager for FRET channel? ');
ROI_CFP_leftcorner_y = input('What is the Y value in ROI Manager for CFP channel? ');
ROI_FRET_leftcorner_y = input('What is the Y value in ROI Manager for FRET channel? ');
width = input('What is the width value in ROI Manager for both channel? ');
height = input('What is the height value in ROI Manager for both channel? ');

outputFolder = fullfile(directory, 'crop');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

shadename = strcat(directory, slash, shade, '.tif');
DCname = strcat(directory, slash, DC, '.tif');
beadname = strcat(beaddir, slash, beads, '.tif');

center_long = [round(center_x_long)+x_offset round(center_y_long)+y_offset];
center_short = [round(center_x_short)+x_offset round(center_y_short)+y_offset];
testmin_long = [nl ml] - center_long;
testmin_short = [ns ms] - center_short;

xlimit = floor(border/100*(min([center_long(1) center_short(1) testmin_long(1) testmin_short(1)])));
ylimit = floor(border/100*(min([center_long(2) center_short(2) testmin_long(2) testmin_short(2)])));

xmin_long = center_long(1)-xlimit;
ymin_long = center_long(2)-ylimit;
xmin_short = center_short(1)-xlimit;
ymin_short = center_short(2)-ylimit;

nwidth = xlimit*2;
nheight = ylimit*2;


Ishade = imread(shadename);
shadeCFP = imcrop(Ishade, [ROI_CFP_leftcorner_x+1 ROI_CFP_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
shadeFRET = imcrop(Ishade, [ROI_FRET_leftcorner_x+1 ROI_FRET_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
cshade = imcrop(shadeCFP, [xmin_short ymin_short nwidth nheight]);
yshade = imcrop(shadeFRET, [xmin_long ymin_long nwidth nheight]);

IDC = imread(DCname);
DCCFP = imcrop(IDC, [ROI_CFP_leftcorner_x+1 ROI_CFP_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
DCFRET = imcrop(IDC, [ROI_FRET_leftcorner_x+1 ROI_FRET_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
cDC = imcrop(DCCFP, [xmin_short ymin_short nwidth nheight]);
yDC = imcrop(DCFRET, [xmin_long ymin_long nwidth nheight]);

beads = imread(beadname);
beadCFP = imcrop(beads, [ROI_CFP_leftcorner_x+1 ROI_CFP_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
beadFRET = imcrop(beads, [ROI_FRET_leftcorner_x+1 ROI_FRET_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
cbead = imcrop(beadCFP, [xmin_short ymin_short nwidth nheight]);
ybead = imcrop(beadFRET, [xmin_long ymin_long nwidth nheight]);

for j = 1:many
    
    index = num2str(j);
    filename = strcat(directory, slash, namae, index, '.tif');
    
    total = size(imfinfo(filename),1);
    
    parfor i = 1:total
        
        I = imread(filename,i);
        CFP(:,:,i) = imcrop(I, [ROI_CFP_leftcorner_x+1 ROI_CFP_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
        FRET(:,:,i) = imcrop(I, [ROI_FRET_leftcorner_x+1 ROI_FRET_leftcorner_y+1 width height]); %   ********** Find the dimensions of ROI in ImageJ. **********
        c(:,:,i) = imcrop(CFP(:,:,i), [xmin_short ymin_short nwidth nheight]);
        y(:,:,i) = imcrop(FRET(:,:,i), [xmin_long ymin_long nwidth nheight]);
        
    end
    
    short_base = sprintf('%s.tif', strcat('CFP_',index));
    long_base = sprintf('%s.tif', strcat('FRET_',index));
    short_fullName = fullfile(outputFolder, short_base);
    long_fullName = fullfile(outputFolder, long_base);
    
    for k = 1:total
        
        imwrite(c(:,:,k), short_fullName, 'WriteMode', 'append', 'Compression', 'none');
        imwrite(y(:,:,k), long_fullName, 'WriteMode', 'append', 'Compression', 'none');
        
    end
    
    shadeCFP_base = sprintf('%s.tif', 'shadeCFP');
    shadeFRET_base = sprintf('%s.tif', 'shadeFRET');
    DCCFP_base = sprintf('%s.tif', 'dcCFP');
    DCFRET_base = sprintf('%s.tif', 'dcFRET');
    beadCFP_base = sprintf('%s.tif', 'beadCFP');
    beadFRET_base = sprintf('%s.tif', 'beadFRET');
    
    shadeCFP_fullName = fullfile(outputFolder, shadeCFP_base);
    shadeFRET_fullName = fullfile(outputFolder, shadeFRET_base);
    DCCFP_fullName = fullfile(outputFolder, DCCFP_base);
    DCFRET_fullName = fullfile(outputFolder, DCFRET_base);
    beadCFP_fullName = fullfile(beaddir, beadCFP_base);
    beadFRET_fullName = fullfile(beaddir, beadFRET_base);
    
    imwrite(cshade, shadeCFP_fullName, 'Compression', 'none');
    imwrite(yshade, shadeFRET_fullName, 'Compression', 'none');
    imwrite(cDC, DCCFP_fullName, 'Compression', 'none');
    imwrite(yDC, DCFRET_fullName, 'Compression', 'none');
    imwrite(cbead, beadCFP_fullName, 'Compression', 'none');
    imwrite(ybead, beadFRET_fullName, 'Compression', 'none');
    
end