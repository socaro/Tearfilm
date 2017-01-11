close all;
clear all;
clc;
File='Julie1202-1';
SaveFile = strcat(File,'filtered');
codec = 'Uncompressed AVI';
v = VideoReader(strcat(File,'.avi'));
% Define the video writer object

%v.CurrentTime = 3.5;
%image = readFrame(v);
%video = read(v,[2 20]);
im= read(v,5);
[BW1,BW2,s,edge]=imgroi(im);

Vid = VideoWriter(SaveFile,codec);
Vid.FrameRate=v.FrameRate;
open(Vid)
%%
for n=1:20
im=read(v,n);
[image_roi]=imagecrop(im,BW1,BW2,s,edge);
image_d=zeros(size(image_roi));
wdec=zeros(s,s,16,3);
for i=1:3
    imagetemp=double(image_roi(:,:,i));
    [image_d(:,:,i),wdec(:,:,:,i)]=func_denoise_sw2d(imagetemp);
end
image_d=uint8(image_d);
imshow(image_d);
writeVideo(Vid,image_d);
end
        
close(Vid)