function align_video(file)
%% function to correct video for movement
%% input:
%% file = file name (e.g. 'sophie0131-1430')
%% output:
%% Video is saved in same directory as original with suffix '_aligned'

dir='C:\Users\oneye\Documents\videos';
v=VideoReader(fullfile(dir,strcat(file,'.avi')));
codec = 'Uncompressed AVI';
Vid = VideoWriter(fullfile(dir,strcat(file,'_aligned.avi')),codec);
Vid.FrameRate=v.FrameRate;
open(Vid)
v.CurrentTime=1.5;
imfixed=readFrame(v);

[imfixed_r, rect] = imcrop(imfixed);
imgray=rgb2gray(imfixed_r);
close;
[eye_r, eye_rect] = imcrop(imfixed);
close;
v.CurrentTime=0;
while hasFrame(v)%v.CurrentTime<5
v.CurrentTime
immoving=readFrame(v);
immoving_r = imcrop(immoving,rect);
immovinggray=rgb2gray(immoving_r);

[optimizer,metric] = imregconfig('monomodal');
%[movingRegisteredDefault, R_reg] = imregister(immovinggray, imgray, 'translation', optimizer, metric);
tform=imregtform(immovinggray, imgray, 'translation', optimizer, metric);
close all;
%figure; imshowpair(movingRegisteredDefault, imgray);
eye_moving = imcrop(immoving,eye_rect);
eye_trans=imtranslate(eye_moving,tform.T(3,1:2));
%figure; imshowpair(eye_r,eye_moving);
writeVideo(Vid,eye_trans);
end

close(Vid);
end