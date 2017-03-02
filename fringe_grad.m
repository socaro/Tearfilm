%% script to test automatic correlation by using fringe peaks and peaks in colormap

clear all;
close all;
clc;

%% load colormap
colormap=load('colormap.mat');
cm=colormap.colormap;
%% load image and crop do smaller size
im=imread('Image_denoised_contrast.tif');
imcr=double(imcrop(im));
close;
%% scale colormap intensity according to image
%cm=cm*max(imcr(:))./max(cm(:)); %scale by max intensity of any color
%channel
for i=1:3;cm(:,i)=cm(:,i)*mean(imcr(:,i))./mean(cm(130:300,i));end %scale by mean of every channel
for i=1:100;cim(:,i,:)=cm;end

imshow(uint8(imcr));figure;imshow(uint8(cim));

%% find minima and maxima in image
p_maxima=find_p(imcr);
p_minima=find_p(-imcr);

%% determine location of peaks
[row_max,col_max]=find(p_maxima(:,:,1)==1);
%[~,Pos_max(:,1),Pos_max(:,2)]=unique([J_max,I_max],'rows');

%% determine scaled image and colormap (intensity of two channels is scaled to intensity of primary channel)
[cm_sparse, cmred]=cm_scale_grad(cm,1);
imred=im_scale_grad(imcr,1);

%% determine position in colormap for peak n - test different search algorithms
n=2; % peak nr
loc=[row_max(n),col_max(n)]; % peak location in image
rgbred=squeeze(imred(row_max(n),col_max(n),1:3)).'; % scaled rgb at loc
rgb=squeeze(imcr(row_max(n),col_max(n),1:3)).'; % unscaled rgb at loc
d=dsearchn(cmred(100:300,1:3),rgbred(1:3))+99; % test dsearchn
[d1,dist]=knnsearch(cmred(100:300,1:3),rgbred(1:3),'K',4,'Distance','correlation'); %test knnsearch with scaled rgb
[d2,dist2]=knnsearch(cm_sparse(100:230,1:3),rgb(1:3),'K',4,'Distance','seuclidean'); %test knnsearch with unscaled rgb


%% plot one column in image and colormap for comparison
%figure;plot([smooth(imcr(:,9,1)) smooth(imcr(:,9,2)), smooth(imcr(:,9,3))])
%figure; plot([cm(:,1),cm(:,2),cm(:,3)])

function rgb = find_rgb(im,row,col)
counter = 0;
for i=-2:2
    for j=-2:2
        rgb=rgb+squeeze(im(row+i,col+j,1:3)).';
        counter=counter+1;
    end
end
rgb=rgb./counter;
end

function peaks=find_p(imcr)
peaks_v=zeros(size(imcr));
peaks_h=zeros(size(imcr));

for l=1:length(imcr(1,:,1)) %determine peaks vertically (along rows)
    for i=1:3
        [pks,locs]=findpeaks(smooth(imcr(:,l,i)),'MinPeakProminence',15);
        peaks_v(locs,l,i)=1;
    end
end
for l=1:length(imcr(:,1,1)) %determine peaks horizontally (along columns)
    for i=1:3
        [pks,locs]=findpeaks(smooth(imcr(l,:,i)),'MinPeakProminence',15);
        peaks_h(l,locs,i)=1;
    end
end
peaks=peaks_v+peaks_h;
peaks(peaks==1)=0; %comment out for union of peaks
peaks(peaks==2)=1;
end

function imcolor = im_scale_grad(im,i) %scale 2 channels of image to primary channel
%% im = image
%% i = primary channel
if i==1
    ii=2;iii=3;
elseif i==2
    ii=1;iii=3;
else
    ii=1;iii=2;
end
im=double(im);        
imcolor=zeros(length(im(:,1,1)),length(im(1,:,1)),6);
imcolor(:,:,i)=im(:,:,i); 
imcolor(:,:,ii)=im(:,:,ii)*100./im(:,:,i);
imcolor(:,:,iii)=im(:,:,iii)*100./im(:,:,i);
imgrad=gradient(imcolor(:,:,1:3));
imcolor(:,:,4:6)=imgrad;
end

function [cm_sparse,cmcolor_p] = cm_scale_grad(cm,i) %scale 2 channels of colormap to primary channel, also return sparse unscaled colormap
%% cm = colormap
%% i = primary channel
%% cm_sparse = unscaled, sparse colormap (all values except for peaks of primary channel are 0
%% cmcolor_p = scaled, sparse colormap (""")
if i==1
    ii=2;iii=3;
elseif i==2
    ii=1;iii=3;
else
    ii=1;iii=2;
end
[~,locs]=findpeaks(cm(:,i));
cmcolor=zeros(length(cm(:,1)),6);
cmcolor(:,i)=cm(:,i); 
cmcolor(:,ii)=cm(:,ii)*100./cm(:,i);
cmcolor(:,iii)=cm(:,iii)*100./cm(:,i);
cmgrad=gradient(cmcolor(:,1:3));
cmcolor(:,4:6)=cmgrad;
cmcolor_p=zeros(size(cmcolor));
cmcolor_p(locs,:)=cmcolor(locs,:);


cm_sparse=zeros(size(cm));
cm_sparse(locs,:)=cm(locs,:);
end