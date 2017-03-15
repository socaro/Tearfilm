function [meanRGB, areas, numberOfBlobs] = MeasureBlobs(maskImage, redBand, greenBand, blueBand)
% Measure the mean intensity and area of each blob in each color band.
% ------------------------------
% Part of the "SimpleColorDetection.m function"
% by Image Analyst
% 20 Jan 2010 (Updated 19 Aug 2010) 
% http://www.mathworks.ch/matlabcentral/fileexchange/26420-simplecolordetection/all_files
% ------------------------------

	[labeledImage numberOfBlobs] = bwlabel(maskImage, 8);     % Label each blob so we can make measurements of it
	if numberOfBlobs == 0
		% Didn't detect any yellow blobs in this image.
		meanRGB = [0 0 0];
		areas = 0;
		return;
	end
	% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
	blobMeasurementsR = regionprops(labeledImage, redBand, 'area', 'MeanIntensity');   
	blobMeasurementsG = regionprops(labeledImage, greenBand, 'area', 'MeanIntensity');   
	blobMeasurementsB = regionprops(labeledImage, blueBand, 'area', 'MeanIntensity');   
	
	meanRGB = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	meanRGB(:,1) = [blobMeasurementsR.MeanIntensity]';
	meanRGB(:,2) = [blobMeasurementsG.MeanIntensity]';
	meanRGB(:,3) = [blobMeasurementsB.MeanIntensity]';
	
	% If redBand etc. are double, the intensities will be in the range of 0-1.
	% Multiply by 255 to get them back into the uint8 range of 0-255.
	if ~strcmpi(class(redBand), 'uint8')
		meanRGB = meanRGB * 255.0;
	end
	
	% Now assign the areas.
	areas = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	areas(:,1) = [blobMeasurementsR.Area]';
	areas(:,2) = [blobMeasurementsG.Area]';
	areas(:,3) = [blobMeasurementsB.Area]';

	%return; % from MeasureBlobs()