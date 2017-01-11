clear all;
close all;
clc;

im=imread('Sophie1216-3.tif');
[im,BW,ims,edge] = imgroi(im);
%%
dictnew=load('traineddict.mat');
dict=dictnew.dict;
s=8;
 %im=imagecrop(imtest,BW,ims,edge);

%%
sizeim=size(im);
sizeim(1:2)=sizeim(1:2)+s/2;
im1=double(im);
im_new1=zeros(sizeim);

image_d=zeros(size(im1));
wdec=zeros(s,s,16,3);
[image_d,wdec]=func_denoise_sw2d(im1);


%%

border=[2 2];
for i=1:3
    fun = @(block_struct) usedict(block_struct.data,dict,block_struct.blockSize,block_struct.border,block_struct.location);
    im_new=blockproc(double(image_d(:,:,i)),[s-2*border(1) s-2*border(2)],fun,'BorderSize',border,'PadPartialBlocks',true);
    im_new1(1:length(im_new(:,1)),1:length(im_new(:,2)),i)=im_new;
end
%%
image_d=uint8(image_d);
figure;
imshow(im);
figure;
imshow(image_d);
figure;
imshow(uint8(im_new1));