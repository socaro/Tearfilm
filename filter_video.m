function filter_video(File,dictname)
%% function to filter video using sparse representation with learned dictionary 
%% requires function usedict.m
%% input: 
%% file = file name (e.g. File='sophie0131-1236';
%% dictname = name of dictionary to be used, must be saved in same directory (e.g. 'traineddict.mat')
%% output:
%% video is saved using suffix '_filtered'


dir='C:\Users\oneye\Documents\videos';
SaveFile = strcat(File,'_filtered');
codec = 'Uncompressed AVI';
v=VideoReader(fullfile(dir,strcat(File,'.avi')));

% Define the video writer object
Vid = VideoWriter(fullfile(dir,strcat(SaveFile,'.avi')),codec);
Vid.FrameRate=v.FrameRate;
open(Vid)

%v.CurrentTime = 3.5;
%image = readFrame(v);
%video = read(v,[2 20]);
v.CurrentTime=5;
im=readFrame(v);
[~,BW1,sroi,edge]=imgroi(im);


%%
dictnew=load(dictname);
dict=full(dictnew.dict);
s=sqrt(length(dict(:,1)));

v.currentTime=0;
while hasFrame(v)
    im=readFrame(v);
    im=imagecrop(im,BW1,sroi,edge);
    sizeim=size(im);
    sizeim(1:2)=sizeim(1:2)+s;
    %im=imadjust(im,findlim(im,5,95),[0;1]);
    %imshow(im);
    im=double(im);
    im_new1=zeros(sizeim);
    border=[2 2];
    for i=1:3
        fun = @(block_struct) usedict(block_struct.data,dict(:,:,i),block_struct.blockSize,block_struct.border,block_struct.location,10);
        im_new=blockproc(double(im(:,:,i)),[s-2*border(1) s-2*border(2)],fun,'BorderSize',border,'PadPartialBlocks',true);
        im_new1(1:length(im_new(:,1)),1:length(im_new(1,:)),i)=im_new;
    end
    im_new1=uint8(im_new1);
    imshow(im_new1);
    writeVideo(Vid,im_new1);
end


% for n=1:20
% im=read(v,n);
% [image_roi]=imagecrop(im,BW1,BW2,s,edge);
% image_d=zeros(size(image_roi));
% wdec=zeros(s,s,16,3);
% for i=1:3
%     imagetemp=double(image_roi(:,:,i));
%     [image_d(:,:,i),wdec(:,:,:,i)]=func_denoise_sw2d(imagetemp);
% end
% image_d=uint8(image_d);
% imshow(image_d);
% writeVideo(Vid,image_d);
% end
%         
close(Vid)
end