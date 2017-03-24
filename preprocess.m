function optimalvideo = preprocess(video)

%% correction of light movement for an eye recording
% cutting and sectioning video according to blink cycles
% and simultaneous automatic cropping of region of interest
% 
% Sophie Lohmann & Maximilian Enthoven, Stanford University (03/22/2017)

% input: video: file name (e.g. 'sophie0131-1430_compressed')
% output: optimized video files according to blink cycles saved into same
% directory

%% setup parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
warning off
dir = '../../';
approxrad = 250; tol = 15;

rint = 45;
rext = approxrad;

codec = 'Uncompressed AVI';
%codec = 'Uncompressed AVI';

%% processing video

disp('processing video...')
input = VideoReader(fullfile(dir,strcat(video,'.avi')));
output = VideoWriter(fullfile(dir,strcat(video,'-opt.avi')),codec);
output.FrameRate = input.FrameRate;
open(output)

firstFrame = readFrame(input);
input.CurrentTime = 0;
        
%[firstFrame,rect] = imcrop(firstFrame);
%hold off; imshow(firstFrame); close;

imcurr = firstFrame;
gimcurr = rgb2gray(imcurr);

disp('finding contact lens...')
[c_contact_f,r_contact_f] = imfindcircles(gimcurr,[approxrad-tol approxrad+tol],...
 'ObjectPolarity','bright','Sensitivity',0.99,'EdgeThreshold',0.01);

if isempty(c_contact_f)
    error('the contact lens could not be found!')
end

c_contact_f = c_contact_f(1,:); 
r_contact_f = r_contact_f(1,:);

imshow(imcurr); hold on;
viscircles(c_contact_f,r_contact_f,'EdgeColor','b');
rect = rectangle('Position',[c_contact_f(1)-3.5*r_contact_f c_contact_f(2)+1.5*r_contact_f ...
                                7*r_contact_f 1.3*r_contact_f]);
rectpos = rect.Position;
delete(rect);

%immove = imcrop(imfixed,rect);                            
                            
rfirstFrame = imcrop(imcurr,rectpos);
grfirstFrame = rgb2gray(rfirstFrame);

aoi = rectangle('Position',[c_contact_f(1)-1.5*r_contact_f c_contact_f(2)-1.5*r_contact_f ...
                                3*r_contact_f 3*r_contact_f]);
aoi.LineWidth = 3; aoi.EdgeColor = 'red'; aoi.LineStyle = '--';

disp('please check figure...')
choice = questdlg('is this area of interest acceptable?', ...
	'dialog','hell yes','hell no','hell yes');
switch choice
    case 'hell yes'
        croparea = aoi.Position;
        close all;
    case 'hell no'
        close all; figure; 
        title('please crop area of interest and double click to enter:','FontSize',18); 
        hold on; [~,croparea] = imcrop(imcurr);
        close;
end

disp('working...')
input.CurrentTime = 0; 
counter = 1; 
h = waitbar(0,'preprocessing video...');

while hasFrame(input)
    
    %% align
    
    imcurr = readFrame(input);
    imrect = imcrop(imcurr,rectpos);
    gimrect = rgb2gray(imrect);

    [optimizer,metric] = imregconfig('monomodal');
    tform = imregtform(gimrect, grfirstFrame, 'translation', optimizer, metric);
    close all;

    eye_moving = imcrop(imcurr,croparea);
    imcurr = imtranslate(eye_moving,tform.T(3,1:2));
    %figure; imshowpair(eye_r,eye_moving);
    
    
    %% crop
    
    imsize = size(imcurr);
    
    if mean(mean(imcurr(:,:,1))) > 115 % estimated lower threshold for red channel
        imcurr = uint8(zeros(imsize2));
        waitbar(input.currentTime/input.Duration,h);
        fprintf('frame %i processed\n',counter);
        counter = counter + 1;
        writeVideo(output,imcurr);
        continue;
    end
    
    %imshow(image)
    %hold on
    
    % circular hough transform
    try
        [cin,rin] = imfindcircles(imcurr,[rint-tol rint+tol],'ObjectPolarity','dark',...
                                  'Sensitivity',0.99,'EdgeThreshold',0.05);
        [cout,rout] = imfindcircles(imcurr,[rext-tol-5 rext+tol+5],'ObjectPolarity','bright',...
                                  'Sensitivity',0.99,'EdgeThreshold',0.05);
        if or(isempty(cin),isempty(cout))
            error('area of interest could not be detected!')
        end                                           
    catch
        [cin,rin] = imfindcircles(imcurr,[rint-tol rint+tol],'ObjectPolarity','dark',...
                                  'Sensitivity',0.99,'EdgeThreshold',0.01);
        [cout,rout] = imfindcircles(imcurr,[rext-tol-5 rext+tol+5],'ObjectPolarity','bright',...
                                  'Sensitivity',0.99,'EdgeThreshold',0.01);
    end
    
    if or(isempty(cin),isempty(cout))
        error('area of interest could not be detected!')
    end
    
    cout = cout(1,:); rout = rout(1,:);
    cin = cin(1,:); rin = rin(1,:); % choose strongest radius
    viscircles([cout;cin],[rin;rout],'EdgeColor','b');
    
    [xxout,yyout] = ndgrid((1:imsize(1))-cout(2),(1:imsize(2))-cout(1));
    [xxin,yyin] = ndgrid((1:imsize(1))-cout(2),(1:imsize(2))-cin(1));
    mask = and((xxout.^2 + yyout.^2) < rout^2-1,(xxin.^2 + yyin.^2) > rin^2+1);
    mask = uint8(mask);
    
    crimg = uint8(zeros(imsize));
    
    for jj = 1:3
        crimg(:,:,jj) = imcurr(:,:,jj).*mask;
    end
    
    %% denoise
    
    dictionary = load('dict.mat');
    crimg_denoised = denoise_image(crimg,dictionary);    
    
    %% write to video
    
    imsize2 = size(crimg_denoised);
    fprintf('frame %i processed\n',counter);
    counter = counter + 1;
    writeVideo(output,crimg_denoised);
    waitbar(input.CurrentTime/input.Duration,h);
end

close(output);
delete(h);
disp('preprocessing successful!')


end

