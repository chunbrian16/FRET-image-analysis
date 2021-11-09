% This program is used for checking the center of the lines of the
% calibration cross.
% Written by Brian Cheung
% Version 1.1

clear all
clc
close all

directory = input('Please enter cross image directory: ', 's');

if ismac || isunix
    slash = '/';
elseif ispc
    slash = '\';
else
    disp('Platform not supported');
end

long = imread(strcat(directory, slash, 'long.tif'));
[ml,nl] = size(long);

long_left(:,1) = [1:ml];
long_left(:,2) = long(:,1)./4; % Since short wavelength is always dimmer, we scale down the long wavelength by a factor of 4 for easier observation.

long_right(:,1) = [1:ml];
long_right(:,2) = long(:,nl)./4;

long_top(:,1) = [1:nl];
long_top(:,2) = long(1,:)./4;

long_low(:,1) = [1:nl];
long_low(:,2) = long(ml,:)./4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

short = imread(strcat(directory, slash, 'short.tif'));
[ms,ns] = size(short);

short_left(:,1) = [1:ms];
short_left(:,2) = short(:,1);

short_right(:,1) = [1:ms];
short_right(:,2) = short(:,ns);

short_top(:,1) = [1:ns];
short_top(:,2) = short(1,:);

short_low(:,1) = [1:ns];
short_low(:,2) = short(ms,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(7,3,[4 16])
plot(long_left(:,2), long_left(:,1), 'r-', short_left(:,2), short_left(:,1), 'b-');
ylim([0 2048])
hold on

subplot(7,3,[6 18])
plot(long_right(:,2), long_right(:,1), 'r-', short_right(:,2), short_right(:,1), 'b-');
ylim([0 2048])
hold on

subplot(7,3,[1 3])
plot(long_top(:,1), long_top(:,2), 'r-', short_top(:,1), short_top(:,2), 'b-');

hold on

subplot(7,3,[19 21])
plot(long_low(:,1), long_low(:,2), 'r-', short_low(:,1), short_low(:,2), 'b-');

hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Extract four points of the crosses
%% First, extract a part of the intensity profile for Gaussian fit
%% Observe the intensity profile to determine which part to crop out for G. fitSSS

toplow_start = input('Which pixel to start zooming in top/low edge? '); %% starting pixel for crop at top edge and low edge
toplow_stop = input('Which pixel to stop zooming in top/low edge? '); %% stopping pixel for crop at left edge and right edge
leftright_start = input('Which pixel to start zooming in left/right edge? (low to high) '); %% starting pixel for crop at top edge and low edge
leftright_stop = input('Which pixel to stop zooming in left/right edge? (low to high) '); %% stopping pixel for crop at left edge and right edge

%% Create cropped profile from original profile (Zoom in)

new_long_left_pix = long_left(leftright_start:leftright_stop,1);
new_long_right_pix = long_right(leftright_start:leftright_stop,1);
new_long_left_read = long_left(leftright_start:leftright_stop,2);
new_long_right_read = long_right(leftright_start:leftright_stop,2);
new_short_left_pix = short_left(leftright_start:leftright_stop,1);
new_short_right_pix = short_right(leftright_start:leftright_stop,1);
new_short_left_read = short_left(leftright_start:leftright_stop,2);
new_short_right_read = short_right(leftright_start:leftright_stop,2);

new_long_top_pix = long_top(toplow_start:toplow_stop,1);
new_long_low_pix = long_low(toplow_start:toplow_stop,1);
new_long_top_read = long_top(toplow_start:toplow_stop,2);
new_long_low_read = long_low(toplow_start:toplow_stop,2);
new_short_top_pix = short_top(toplow_start:toplow_stop,1);
new_short_low_pix = short_low(toplow_start:toplow_stop,1);
new_short_top_read = short_top(toplow_start:toplow_stop,2);
new_short_low_read = short_low(toplow_start:toplow_stop,2);

fprintf('Now Go to App-> Curve fitting to find out the central points. _pix is x-axis, _read is y-axis.\n')