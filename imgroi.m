function [image_roi,BW,s,edge] = imgroi(image)
%% function to set areas around are of interest to zero
% select center of ROI
% draw ellipse around ROI
%% Input:
%image      - image
%% Output:
%image_roi  - new image (areas outside ROI set to zero
%BW         - mask for ellipse (for cropping of subsequent frames)
%s          - cropped size
%edge       - crop position

%% select center
im=imshow(image);
d=datacursormode;
pause;
pos=getCursorInfo(d);
position1=pos.Position;
close;
%% draw ellipse
figure; imshow(image);
h = imellipse;
position = wait(h);

%%create mask
BW=createMask(h);
BW(:,:,2)=BW;
BW(:,:,3)=BW(:,:,1);

%% set pixels outside ROI to zero
image_roi=image;
image_roi(BW==0)=0;

%% determine size and position of cropped image from ellipse size
ellipse=getPosition(h);
s=max(ellipse(3:4));
s_crop=s-rem(s,2^5)+2^5;
edge=[position1(1)-s_crop/2,position1(2)-s_crop/2];

%% crop image and mask
image_roi=imcrop(image_roi,[edge,(s_crop-1),(s_crop-1)]);
BW=imcrop(BW,[edge,(s_crop-1),(s_crop-1)]);
s=s_crop;
close;

end
