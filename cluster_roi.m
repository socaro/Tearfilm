function image_roi = cluster_roi(image)
%% function to set outside and center of image to zero
% draw ellipse around ROI
% draw ellipse around center non-ROI
%% Input:
%image      - image
%% Output:
%image_roi  - new image (areas outside ROI set to zero


%% draw ellipse
figure; imshow(image);
h = imellipse;
position = wait(h);

%%create mask
BW=createMask(h);
BW(:,:,2)=BW;
BW(:,:,3)=BW(:,:,1);

%% draw inner ellipse
close; figure; imshow(image);
h1 = imellipse;
position = wait(h1);

BW1=createMask(h1);
BW1(:,:,2)=BW1;
BW1(:,:,3)=BW1(:,:,1);

%% set pixels outside ROI to zero
image_roi=image;
image_roi(BW==0)=0;
image_roi(BW1~=0)=0;


close;

end
