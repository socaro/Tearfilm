clear all;
close all;
clc;


colormap=load('colormap.mat');
colormap=colormap.colormap;
%%
for i=1:100
colormap_image(:,i,:)=colormap;
end

%%
% v=VideoReader('videos/Sophie1216-3.avi');
% v.CurrentTime=1.5;
% im=readFrame(v);
%im=imread('videos/Sophie1216-3-wdict.tif');
im=imread('C:\Users\oneye\Documents\MATLAB\image_denoised.tif');
%[im,~,~,~] = imgroi(im);
%%
lowin=min(min(min(colormap_image)));
lowout=max(max(max(colormap_image)));
cimnew=imadjust(colormap_image,[lowin; lowout],[0; 1]);
imnew=imadjust(im1,findlim(im,5,95),[0; 1]);