function im_d = denoise_image(File,dictname,t)
%% function to filter one frame using sparse representation with learned dictionary 
%% requires function usedict.m
%% input: 
%% file = file name (e.g. File='sophie0131-1236';
%% dictname = name of dictionary to be used, must be saved in same directory (e.g. 'traineddict.mat')
%% t = time of frame

dir='C:\Users\oneye\Documents\videos';
v=VideoReader(fullfile(dir,strcat(File,'.avi')));

dictnew=load(dictname);
dict=full(dictnew.dict);
s=sqrt(length(dict(:,1)));


v.CurrentTime=t;
im=readFrame(v);
[im1,~,~,~]=imgroi(im);
sizeim=size(im1); 
sizeim(1:2)=sizeim(1:2)+s;
%im=imadjust(im,findlim(im,5,95),[0;1]);
    %imshow(im);
    im1=double(im1);
    im_d=zeros(sizeim);
    border=[2 2];
    for i=1:3
        fun = @(block_struct) usedict(block_struct.data,dict(:,:,i),block_struct.location,10);
        im_new=blockproc(double(im1(:,:,i)),[s-2*border(1) s-2*border(2)],fun,'BorderSize',border,'PadPartialBlocks',true,'TrimBorder',false,'PadMethod','replicate');
        im_d(1:length(im_new(:,1)),1:length(im_new(1,:)),i)=im_new;
    end
    im_d=uint8(im_d);
    imshow(im_d);


end