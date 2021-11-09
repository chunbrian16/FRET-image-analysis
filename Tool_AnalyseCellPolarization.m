%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                                                                                      %%
%%  Inside your directory which contains intensity and XY coordinates (generated from ImageJ),                                          %%
%%  it should have numbered files representing each ROI and 'centroidAR.csv'.                                                           %%
%%                                                                                                                                      %%
%%  Output is a .txt file that contains the following:                                                                                  %%
%%  1)  Aspect Ratio                                                                                                                    %%
%%  2)  Angle                                                                                                                           %%
%%  3)  Polarization in x-direction                                                                                                     %%
%%  4)  Polarization in y-direction                                                                                                     %%
%%  5)  Normalized Polarization Magnitude (in A.U.)                                                                                     %%
%%  6)  Polarization Angle                                                                                                              %%
%%                                                                                                                                      %%
%%                                                                                                                                      %%
%%  Results will be saved as 'results.txt' under the same directory.                                                                    %%
%%  It can be opened in Microsoft Excel for conversion to .csv or .xls.                                                                 %%
%%                                                                                                                                      %%
%%  Written by Brian Cheung, Cornell University                                                                                         %%
%%  Version 20210414                                                                                                                    %%
%%                                                                                                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

if ismac || isunix
    slash = '/';
elseif ispc
    slash = '\';
else
    disp('Platform not supported');
end

directory = input('Enter the directory of Summary.csv: ', 's');
name = 'Summary';
image = 'Coordinate';
imagenumber = input('How many images to analyse? ');
frame = input('How many frames are there for each image? ');

w = input('Width of image? ');
L = input('Length of image? ');

sf = input('What scaling factor was used? ');

tic


for i = 1:imagenumber
    
    filename = strcat(directory, slash, name, '_', num2str(i), '.csv'); %   filename = Summary_n.csv
    
    if exist(filename,'file')
    
    tempcsv = importdata(filename); %   Import Summary_n.csv file as 'tempcsv'
    
    [row col] = size(tempcsv.data);
    
%     for z = 1:row
% 
%         tempcsv.data(z,9) = tempcsv.data(z,4)*cosd(tempcsv.data(z,8)) - (L - tempcsv.data(z,5))*sind(tempcsv.data(z,8));      %   ROTATED x-coordinate of centroid x: x'*cos(theta) - (L-y')*sin(theta)
%         tempcsv.data(z,10) = tempcsv.data(z,4)*sind(tempcsv.data(z,8)) + (L - tempcsv.data(z,5))*cosd(tempcsv.data(z,8));     %   ROTATED y-coordinate of centroid y: x'*sin(theta) + (L-y')*cos(theta)
%         
%     end
        
        cent{1,i} = tempcsv.data;       %   Summary_n.csv
        [row col] = size(cent{1,i});
        cellnumber = row/frame;
        out = zeros(1);
        
        %   cent{1,i}(:,1:10) is the same as Summary_.csv file.
        
        cent{1,i}(:,11) = 0;      % Initialize for Px
        cent{1,i}(:,12) = 0;     % Initialize for Py
        cent{1,i}(:,13) = 0;     % Initialize for Pnet
        cent{1,i}(:,14) = 0;     % Initialize for Pangle
        cent{1,i}(:,15) = 0;     % Initialize for Aspect Ratio
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cent{1,i}(:,16) = tempcsv.data(:,4)+1;     % Initialize for ROTATED x-coordinate of centroid      ********** 9  +1 to bring imageJ coordinates back to Cartesian plane.
        cent{1,i}(:,17) = L - (tempcsv.data(:,5) + 1);     % Initialize for ROTATED y-coordinate of centroid     ********** 10  L - (y+1) = flipped y-coordinate (from imageJ matrix to Cartesian plane)
        cent{1,i}(:,18) = 0;     % Initialize for ROTATED Minor Polarization (x)
        cent{1,i}(:,19) = 0;     % Initialize for ROTATED Major Polarization (y)
        cent{1,i}(:,20) = tempcsv.data(:,2);    %%%%%%   Area of cell
    
        for j = 1:cellnumber
            
            for k = 1:frame
                
                temp = {};
                
                coor_file = strcat(directory, slash, image, '_', num2str(i), '_', num2str(k), '_', num2str(j), '.csv');
                
                if exist(coor_file,'file')
                    
                temp = importdata(coor_file);
                emp = zeros(length(temp.data),7);
                emp(:,1:3) = temp.data;                 % emp(:,1) are x coordinates of pixels; emp(:,2) are y coordinates of pixels; emp(:,3) are grayvalues of pixels
                emp(:,1:2) = emp(:,1:2) + 1;    %   Since imageJ coordinates start from zero, this brings imageJ coordinates back to the Cartesian coordinate system.
                
                for m = 1:length(temp.data)
                    
%                     cent{1,i}(j+(k-1)*cellnumber,11) = cent{1,i}(j+(k-1)*cellnumber,11) + (emp(m,3)/65535)*(emp(m,1) - cent{1,i}(j+(k-1)*cellnumber,4));
%                     cent{1,i}(j+(k-1)*cellnumber,12) = cent{1,i}(j+(k-1)*cellnumber,12) + (emp(m,3)/65535)*(emp(m,2) - cent{1,i}(j+(k-1)*cellnumber,5));

                    angle = cent{1,i}(frame*(j-1)+k,8);
                    
                    if angle > 90
                        
                        angle = angle - 180;    %   imageJ calculates angle by computing the tilt of the major axis relative to horizontal x-axis, this allows the rotated coordinates stay within the quardrants.
                    
                    end

                    % Rotated Polarization   -cent{1,i}(j+(k-1)*cellnumber,8)
                    emp(m,4) = (emp(m,1) - cent{1,i}(frame*(j-1)+k,16))*cosd(angle) + (L - emp(m,2) - cent{1,i}(frame*(j-1)+k,17))*sind(angle);   %   Rotated x moment arm of the pixel
                    emp(m,5) = -(emp(m,1) - cent{1,i}(frame*(j-1)+k,16))*sind(angle) + (L - emp(m,2) - cent{1,i}(frame*(j-1)+k,17))*cosd(angle);  %   Rotated y moment arm of the pixel
                    emp(m,6) = (emp(m,3)/65535)*emp(m,4)*(6.5/60);    %   major-torque converted to microns (6.5 microns per pixel, 60x objective)
                    emp(m,7) = (emp(m,3)/65535)*emp(m,5)*(6.5/60);    %   minor-torque converted to microns (6.5 microns per pixel, 60x objective)
                    
                    %   Testing: output coordinates for checking rotation.
                    
                    if j == 1 && k == 2 && i == 16
                        
                        testcoordinate = emp(:,4:5);
                        
                    end
                    
                end
                
                cent{1,i}(frame*(j-1)+k,15) = (cent{1,i}(frame*(j-1)+k,6)) / (cent{1,i}(frame*(j-1)+k,7));
                cent{1,i}(frame*(j-1)+k,18) = sum(emp(:,6));%sum(emp(:,6))/cent{1,i}(j+(k-1)*cellnumber,6)/2/(cent{1,i}(j+(k-1)*cellnumber,20));%%%%%%% P-Major************ 7 
                cent{1,i}(frame*(j-1)+k,19) = sum(emp(:,7));%sum(emp(:,7))/cent{1,i}(j+(k-1)*cellnumber,7)/2/(cent{1,i}(j+(k-1)*cellnumber,20));%%%%%%% P-Minor************ 6
                cent{1,i}(frame*(j-1)+k,13) = sqrt( abs( (cent{1,i}(frame*(j-1)+k,18))^2 + (cent{1,i}(frame*(j-1)+k,19))^2 ) ); %%%%%% P-net
                cent{1,i}(frame*(j-1)+k,14) = acosd( (cent{1,i}(frame*(j-1)+k,18)) / (cent{1,i}(frame*(j-1)+k,13)) );  %   P-angle (not absolute)
                
                %   Get the absolute angle of polarization vector away from long axis of cell                
                if cent{1,i}(frame*(j-1)+k,14) > 90
                    
                    cent{1,i}(frame*(j-1)+k,14) = 180 - cent{1,i}(j+(k-1)*cellnumber,14);
                    
                end
                    
                end
            
            end
        
        end
        
        for j = 1:cellnumber
            
            for k = 1:frame
                
                out(k+(j-1)*frame, 1) = cent{1,i}(frame*(j-1)+k,15);       % Column 1 is Aspect Ratio
                out(k+(j-1)*frame, 2) = cent{1,i}(frame*(j-1)+k,3)/65535;	% Column 2 is Mean FRET ratio
                out(k+(j-1)*frame, 3) = cent{1,i}(frame*(j-1)+k,8);        % Column 3 is Angle
                out(k+(j-1)*frame, 4) = cent{1,i}(frame*(j-1)+k,13)/sf;       % Column 4 is Pnet    (ratio*um)
                
                if acosd( (cent{1,i}(frame*(j-1)+k,18)) / (cent{1,i}(frame*(j-1)+k,13)) ) > 90          % Column 5 is Absolute angle between polarization and long axis
                    
                    out(k+(j-1)*frame, 5) = 180 - acosd( (cent{1,i}(frame*(j-1)+k,18)) / (cent{1,i}(frame*(j-1)+k,13)) );
                    
                else
                    
                    out(k+(j-1)*frame, 5) = acosd( (cent{1,i}(frame*(j-1)+k,18)) / (cent{1,i}(frame*(j-1)+k,13)) );
                    
                end
                
                out(k+(j-1)*frame, 6) = cent{1,i}(frame*(j-1)+k,18)/sf;       % Column 6 is Polarization along Major-axis (ratio*um)
                out(k+(j-1)*frame, 7) = cent{1,i}(frame*(j-1)+k,19)/sf;       % Column 7 is Polarization along Minor-axis (ratio*um)
                
            end
            
        end
        
        t = ["Aspect Ratio" "Mean FRET Ratio" "Angle" "Pnet (AU um)" "delta theta (P and long axis)" "Major-polarization (AU um)" "Minor-polarization (AU um)"];
        
        fid = fopen(strcat(directory, slash, 'results_', num2str(i), '.txt'), 'wt');   %   Output is a text file
        
        fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n', t(1),t(2),t(3),t(4),t(5),t(6),t(7));
        
        [row col] = size(out);
        
        
        for n = 1:row
            fprintf(fid,'%g\t',out(n,:));
            fprintf(fid,'\n');
        end
        
        fclose(fid);
        
        fprintf('Still Running...\n');

    else
        
    end
    
end

toc
