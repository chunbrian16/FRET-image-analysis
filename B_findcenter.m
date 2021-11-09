% This program is used for extrapolating the intersection point of the
% calibration cross
% Written by Brian Cheung
% Version 1.1

% First, we generate the linear equations for the two lines.

close all
 
long_left_pt = input('What is the middle point for long_left profile? ');
long_right_pt = input('What is the middle point for long_right profile? ');
long_top_pt = input('What is the middle point for long_top profile? ');
long_low_pt = input('What is the middle point for long_low profile? ');

short_left_pt = input('What is the middle point for short_left profile? ');
short_right_pt = input('What is the middle point for short_right profile? ');
short_top_pt = input('What is the middle point for short_top profile? ');
short_low_pt = input('What is the middle point for short_low profile? ');

mh_long = -(long_right_pt - long_left_pt)/nl;   % Slope of Long wavelength horizontal line.
mh_short = -(short_right_pt - short_left_pt)/ns;    % Slope of Short wavelength horizontal line.
mv_long = ml/(long_top_pt - long_low_pt);   % Slope of Long wavelength vertical line.
mv_short = ms/(short_top_pt - short_low_pt);    % Slope of Short wavelength vertical line.

ch_long = long_left_pt; % y-intercept of Long wavelength horizontal line.
ch_short = short_left_pt;   % y-intercept of Short wavelength horizontal line.
cv_long = 1 - mv_long*long_top_pt;  % y-intercept of Long wavelength vertical line.
cv_short = 1 - mv_short*short_top_pt;   % y-intercept of Long wavelength vertical line.

% The four equations

x = 1:nl;
yh_long = mh_long*x + ch_long;
yh_short = mh_short*x + ch_short;
yv_long = mv_long*x + cv_long;
yv_short = mv_short*x + cv_short;

% Calculate the intersection point.

center_x_long = (ch_long - cv_long)/(mv_long - mh_long);
center_x_short = (ch_short - cv_short)/(mv_short - mh_short);
center_y_long = mh_long*center_x_long + ch_long;
center_y_short = mh_short*center_x_short + ch_short;

subplot(1,2,1)
plot(x, yh_long);
hold on
plot(x, yv_long);
hold on

subplot(1,2,2)
plot(x, yh_short);
hold on
plot(x, yv_short);
hold on

fprintf('Center for long wavelength image is at (%.1f, %.1f)\n', center_x_long, center_y_long);
fprintf('Center for short wavelength image is at (%.1f, %.1f)\n', center_x_short, center_y_short);