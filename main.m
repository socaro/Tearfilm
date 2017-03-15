
clear all; 
close all; 
clc

%% general settings
fontSize = 12;
addpath('../jandj-master')

%% pick the image and load the image

[filename, pathname] = uigetfile( ...
       {'*.jpg;*.tif;*.tiff;*.png;*.bmp', 'all image files (*.jpg, *.tif, *.tiff, *.png, *.bmp)'; ...
        '*.*',                   'all files (*.*)'}, ...
        'pick a file');
f = fullfile(pathname, filename);

disp('reading image...')
rgbImage = imread(f);

[rows,columns,numberOfColorBands] = size(rgbImage);

%% If the image is monochrome (indexed), convert it to color. 
% Check to see if it's an 8-bit image needed later for scaling)

if strcmpi(class(rgbImage), 'uint8')
    % Flag for 256 gray levels.
    eightBit = true;
else
    eightBit = false;
end


%% Display the color image 
disp('displaying color original image...')
fig1 = figure(1);
subplot(3,4,1);
imshow(rgbImage);
    
if numberOfColorBands > 1 
    title('original color image', 'FontSize', fontSize); 
else 
    caption = sprintf('original indexed image\n(converted to true color with its stored colormap)');
    title(caption, 'FontSize', fontSize);
end
  
%% size of the picture - to occupy the whole screen

scnsize = get(0,'ScreenSize'); % - - width height
position = get(fig1,'Position'); % x-pos y-pos widht height
outerpos = get(fig1,'OuterPosition');
borders = outerpos - position;
edge = abs(borders(1))/2;
pos1 = [edge,...
    1/20*scnsize(4), ...
    9/10*scnsize(3),...
    9/10*scnsize(4)];
set(fig1,'OuterPosition',pos1) 

%% Explore RGB    
% Extract out the color bands from the original image
% into 3 separate 2D arrays, one for each color component.
redBand = rgbImage(:,:,1); 
greenBand = rgbImage(:,:,2); 
blueBand = rgbImage(:,:,3); 

subplot(3, 4, 2);
    imshow(redBand);
    title('red band', 'FontSize', fontSize);
subplot(3, 4, 3);
    imshow(greenBand);
    title('green band', 'FontSize', fontSize);
subplot(3, 4, 4);
    imshow(blueBand);
    title('blue band', 'FontSize', fontSize);

%% Compute and plot the red histogram
hR = subplot(3, 4, 6); 
[countsR, grayLevelsR] = imhist(redBand(redBand>0)); % ignoring all zero val's
maxGLValueR = find(countsR > 0, 1, 'last'); 
maxCountR = max(countsR); 
bar(countsR, 'r'); 
grid on; 
xlabel('gray levels'); 
ylabel('pixel count'); 
title('histogram of red band', 'FontSize', fontSize);

%% compute and plot the green histogram

hG = subplot(3, 4, 7); 
[countsG, grayLevelsG] = imhist(greenBand(greenBand>0)); % dito
maxGLValueG = find(countsG > 0, 1, 'last'); 
maxCountG = max(countsG); 
bar(countsG, 'g', 'BarWidth', 0.95); 
grid on; 
xlabel('gray levels'); 
ylabel('pixel count'); 
title('histogram of green band', 'FontSize', fontSize);

%% compute and plot the blue histogram

hB = subplot(3, 4, 8); 
[countsB, grayLevelsB] = imhist(blueBand(blueBand>0)); % dito
maxGLValueB = find(countsB > 0, 1, 'last'); 
maxCountB = max(countsB); 
bar(countsB, 'b'); 
grid on; 
xlabel('gray levels'); 
ylabel('pixel count'); 
title('histogram of blue band', 'FontSize', fontSize);

%% set all axes to be the same width and height

% This makes it easier to compare them.
maxGL = max([maxGLValueR,  maxGLValueG, maxGLValueB]);  
if eightBit
    maxGL = 255;
end
maxCount = max([maxCountR,  maxCountG, maxCountB]); 
axis([hR hG hB], [0 maxGL 0 maxCount]); 

%% plot all 3 histograms in one plot

subplot(3, 4, 5); 
plot(grayLevelsR, countsR, 'r', 'LineWidth', 2); 
grid on; 
xlabel('gray levels'); 
ylabel('pixel count'); 
hold on; 
plot(grayLevelsG, countsG, 'g', 'LineWidth', 2); 
plot(grayLevelsB, countsB, 'b', 'LineWidth', 2); 
title('histogram of all bands', 'FontSize', fontSize); 
maxGrayLevel = max([maxGLValueR, maxGLValueG, maxGLValueB]); 
% Trim x-axis to just the max gray level on the bright end. 
if eightBit 
    xlim([0 255]); 
else 
    xlim([0 maxGrayLevel]); 
end 

%% value for choosing orientation about colorbands            
prompt = {'RED color tolerance LOWER:','RED color tolerance UPPER:', ... 
   'GREEN color tolerance LOWER:','GREEN color tolerance UPPER:', ... 
   'BLUE color tolerance LOWER:','BLUE color tolerance UPPER:'};

figure(20)
    imshow(rgbImage);
    title('choose a characteristic coordinate for your region of interest')
    d = datacursormode;
    pause; position = getCursorInfo(d);
    pos = position.Position;
    row = pos(2); col = pos(1);
    close;

    
titledlg = sprintf('choose the tolerance for each channel of [R,G,B] = [%i,%i,%i]',...
                  rgbImage(row,col,1),rgbImage(row,col,2),rgbImage(row,col,3));
def = {'7','7','7','7','7','7'};
answer = inputdlg(prompt,titledlg,1,def);

% dlg_title = 'input';
% num_lines = 1;
% def = {'0','50', '150','255','0','100'}; % only green
% def = {'235','255','235','255','0','200'};% red

%def = {'60','75','75','90','55','70'}; % area 1 and 2
% def = {'190','255', '160','245','60','165'};% yellow + light brown + yellow-white
%answer = inputdlg(prompt,dlg_title,num_lines,def);
  
redThresholdLow = double(rgbImage(row,col,1))-str2num(answer{1});
redThresholdHigh = double(rgbImage(row,col,1))+str2num(answer{2});
greenThresholdLow = double(rgbImage(row,col,2))-str2num(answer{3});
greenThresholdHigh = double(rgbImage(row,col,2))+str2num(answer{4});
blueThresholdLow = double(rgbImage(row,col,3))-str2num(answer{5});
blueThresholdHigh = double(rgbImage(row,col,3))+str2num(answer{6});

% redThresholdLow = str2num(rgbImage(x,y,1)-rthresh);
% redThresholdHigh = str2num(rgbImage(x,y,1)+rthresh);
% greenThresholdLow = str2num(rgbImage(x,y,2)-gthresh);
% greenThresholdHigh = str2num(rgbImage(x,y,2)+gthresh);
% blueThresholdLow = str2num(rgbImage(x,y,3)-bthresh);
% blueThresholdHigh = str2num(rgbImage(x,y,1)+bthresh);

% %% Show the thresholds as vertical red bars on the histograms.
% 
% PlaceThresholdBars(1, 3,4, 6, redThresholdLow, redThresholdHigh, fontSize, max(countsR));
% PlaceThresholdBars(1, 3,4, 7, greenThresholdLow, greenThresholdHigh,fontSize, max(countsG));
% PlaceThresholdBars(1, 3,4, 8, blueThresholdLow, blueThresholdHigh,fontSize, max(countsB));
       
%% Now apply each color band's particular thresholds to the color band
	
redMask = (redBand >= redThresholdLow) & (redBand <= redThresholdHigh);
greenMask = (greenBand >= greenThresholdLow) & (greenBand <= greenThresholdHigh);
blueMask = (blueBand >= blueThresholdLow) & (blueBand <= blueThresholdHigh);

%% Display the thresholded binary images.

subplot(3, 4, 10);
    imshow(redMask, []);
    title('thresholded binary img RED', 'FontSize', fontSize);
subplot(3, 4, 11);
    imshow(greenMask, []);
    title('thresholded binary img GREEN', 'FontSize', fontSize);
subplot(3, 4, 12);
    imshow(blueMask, []);
    title('thresholded binary img BLUE', 'FontSize', fontSize);
	    
%% Combine the masks to find where all 3 are "true."

ObjectsMask = uint8(redMask & greenMask & blueMask);
subplot(3, 4, 9);
imshow(ObjectsMask, []);
caption = sprintf('mask of the objects with chosen color');
title(caption, 'FontSize', fontSize);
      
%% Histogram small areas 
% Measure the mean RGB and area of all the detected blobs.

	[meanRGB, areas, nblobs] = MeasureBlobs(ObjectsMask, redBand, greenBand, blueBand);
    F30 = figure(30);
    plot(areas(:,1))
    title('distribution of the areas of the blobs')

 pos2 = [1/4*scnsize(3),...
        1/20*scnsize(4), ...
        2/3*scnsize(3),...
        2/3*scnsize(4)];
 set(F30,'OuterPosition',pos2) 
 xlabel('Number of blobs/"islands"')
 ylabel('Area of the blobs [pixels]')
   
figure(31)
    XTickDescr = [0,5,10,20,50,100,200,300,500,1000,2000,3000];
    N = hist(areas(:,1), XTickDescr);
    bar(N)
    set(gca,'XTick',1:length(XTickDescr))
    set(gca,'XTickLabel',XTickDescr)
    xlhand = get(gca,'xlabel');
    set(xlhand,'string','X','fontsize',0.3) 
    xlabel('Size of the blobs [pixel]')
    ylabel('Number of blobs')
    zl = max(areas(:,1));


%% Insert the minimal area that will be counted
% Every blob smaller than this one will be ommited
prompt = {'minimal area [pixels] of the blob that will be kept:'};
dlg_title = 'min.area';
num_lines = 1;
def = {'100'};
answer2 = inputdlg(prompt,dlg_title,num_lines,def);
answer2 = str2num(answer2{1});
    
%% Ignore all small areas 
F70 = figure(70);
subplot(2,2,1)
 imshow(ObjectsMask, []);
 title('original mask', 'FontSize', fontSize)   
 set(F70,'OuterPosition',pos1) 
 
  ObjectsMask = uint8(bwareaopen(ObjectsMask,answer2));

  figure(70)
    subplot(2,2,2)
    imshow(ObjectsMask, []);
    title('filtered', 'FontSize', fontSize)   

%% Fill in any holes in the regions, since they are most likely red also.
message = sprintf('close the holes in the blobs?');
reply = questdlg(message, 'close holes?', 'Yes','No', 'Yes');
if strcmpi(reply, 'Yes')
	%figure(70)
%     subplot(1,2,1);
%         imshow(ObjectsMask, []);
%         title('Original mask', 'FontSize', fontSize)   
    subplot(2,2,3);
        ObjectsMask = uint8(imfill(ObjectsMask, 'holes'));
        imshow(ObjectsMask, []);
	title('mask with filled holes (imfill)', 'FontSize', fontSize);  
end  
     
%% Use the object mask to mask out the portions of the rgb image.
maskedImageR = ObjectsMask .* redBand;
maskedImageG = ObjectsMask .* greenBand;
maskedImageB = ObjectsMask .* blueBand;

% Concatenate the masked color bands to form the rgb image.
maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
    

%% Show the masked and original image.
f100 = figure(100);

subplot(1,2,1);
imshow(maskedRGBImage);
caption = sprintf('masked original image');
title(caption, 'FontSize', fontSize);	    

subplot(1,2,2);
imshow(rgbImage);
title('original image', 'FontSize', fontSize);
set(f100,'OuterPosition',pos1)                                

text_descr =  strcat('R_l =', num2str(redThresholdLow), ', R_u = ', num2str(redThresholdHigh), ...
                ', G_l =', num2str(greenThresholdLow), ', G_u = ', num2str(greenThresholdHigh), ...
                ', B_l =', num2str(blueThresholdLow), ', B_u = ', num2str(blueThresholdHigh))
text_descr2 =  strcat('Filled holes = ', reply, ', minimal counted area = ', num2str(answer2), ' [pixel]', ...
                ', max. blob size = ', num2str(max(areas(:,1))), ...
                ' [pixel], # of counted blobs = ', num2str(length(areas(:,1))));                        

%% Measure the mean RGB and area of all the detected blobs.
clear meanRGB
clear areas
clear numberOfBlobs

[meanRGB, areas, nblobs] = MeasureBlobs(ObjectsMask, redBand, greenBand, blueBand);
	if nblobs > 0
		fprintf(1, '\n----------------------------------------------\n');
		fprintf(1, 'blob #, area in pixels, mean R, mean G, mean B\n');
		fprintf(1, '----------------------------------------------\n');
		for blobNumber = 1 : nblobs
			fprintf(1, '#%5d, %14d, %6.2f, %6.2f, %6.2f\n', blobNumber, areas(blobNumber), ...
				meanRGB(blobNumber, 1), meanRGB(blobNumber, 2), meanRGB(blobNumber, 3));
		end
	else
		% Alert user that no  blobs were found.
        uiwait(msgbox('no blobs of given color were found in the image'), 'Error', 'error')      
    end      

origimagearea = rows*columns % pxls ... 100% 
AreaOfChosenColor = sum(areas(:,1)) % ... x %
area_percentage = (AreaOfChosenColor/origimagearea)*100

%% Displaying the end of the computation  
disp('*********************************************************')
disp('*                analysis has finished :)               *')
disp('*********************************************************')
