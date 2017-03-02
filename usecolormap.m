clear all;
close all;
clc;

%%
colormap=load('colormap.mat');
colormap=colormap.colormap;

for i=1:100
colormap_image(:,i,:)=colormap;
end

%%
% v=VideoReader('videos/Sophie1216-3.avi');
% v.CurrentTime=1.5;
% im=readFrame(v);
%im=imread('videos/Sophie1216-3-wdict.tif');
%im=imread('C:\Users\oneye\Documents\MATLAB\image_denoised.tif');
im=imread('Image_denoised_SR_contrast.tif');
im=imcrop(im);
%[im,~,~,~] = imgroi(im);
%%
s=5;
border=[2,2];
lowin=min(min(min(colormap_image)));
lowout=max(max(max(colormap_image)));
cimnew=uint8(imadjust(colormap_image,[lowin; lowout],[0; 1]).*256);
%cimlab=rgb2lab(cimnew);
%imlab=rgb2lab(im);
% fun = @(block_struct) det_thickness(block_struct.data, squeeze(cimnew(1:300,1,:)));
% thickness=blockproc(double(im),[s-2*border(1) s-2*border(2)],fun,'BorderSize',border);
% 
% fun1 = @(block_struct) color_adjust(block_struct.data, squeeze(cimnew(1:300,1,:)));
% imnew=blockproc(double(im),[s-2*border(1) s-2*border(2)],fun1,'BorderSize',border);

%imshow(cimlab);figure;imshow(imlab);
imshow(cimnew);figure;imshow(im);
%imnew=imadjust(im,findlim(im,5,95),[0; 1]);