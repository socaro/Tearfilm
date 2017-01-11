function [image_roi,BW,s,edge] = imgroi(image)
%Input:
%image      - image
%Output:
%BW         - mask for outer ellipse
%BW2        - mask for inner ellipse
%s          - cropped size
%edge       - crop position

im=imshow(image);

d=datacursormode;
pause;
pos=getCursorInfo(d);
position1=pos.Position;
figure; imshow(image);
h = imellipse;
position = wait(h);
BW=createMask(h);
BW(:,:,2)=BW;
BW(:,:,3)=BW(:,:,1);
image_roi=image;
image_roi(BW==0)=0;
ellipse=getPosition(h);
s=max(ellipse(3:4));
s_crop=s+rem(s,2^5)+4*2^5;
edge=[position1(1)-s_crop/2,position1(2)-s_crop/2];
image=imcrop(image,[edge,(s_crop-1),(s_crop-1)]);
BW=imcrop(BW,[edge,(s_crop-1),(s_crop-1)]);
s=s_crop;
end
