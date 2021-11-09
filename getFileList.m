% Extract filename from files for downstream analysis
% Written by Brian Cheung
% Version: 20180916
% This program gives you a list of filenames, fullFileName, stored in a directory.
% imageArray denotes the full list of files in the directory.

function FileNamePattern = getFileList(directory, which)

myFolder = directory;
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.tif'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

k = which;

  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  % Now do whatever you want with this file name,
  % such as reading it in as an image array with imread()
  imageArray = imread(fullFileName);
  imshow(imageArray);  % Display image.
  drawnow; % Force display to update immediately.

  FileNamePattern = baseFileName; % remove file number and '.tif'