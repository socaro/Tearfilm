function t = auto_correlation_gradient()
%% test of automatic correlation of image to colormap using gradients

colormap=load('colormap.mat');
cm=colormap.colormap;


im=imread('Image_denoised_contrast.tif');
imcr=double(imcrop(im));

%% scale colormap and create colormpa image
cm=cm.*(max(imcr(:))/max(cm(:)));
for i=1:100;cim(:,i,:)=uint8(cm);end

%% compute gradient of colormap
[gradcm,~]=gradient(cm);

%% compute image gradients in x and y direction  
for i=1:3
[gradimx(:,:,i),gradimy(:,:,i)]=gradient(imcr(:,:,i));
end


%%
gradmean=zeros(size(gradimx));

%% correlate every pixel to color in colormap using average of area around pixel
for ii=4:length(imcr(:,1,1))-4
    for jj=4:length(imcr(1,:,1))-4
        d=grad_search(ii,jj);
        t(ii,jj)=d*10;
        imnew(ii,jj,:)=cm(d,:); %reconstruct image using correlated color for comparison
    end
end



function d = grad_search(ii,jj)
for i=1:3
gradx(i)=mean(mean(gradimx(ii-3:ii+3,jj-3:jj+3,i)));
grady(i)=mean(mean(gradimy(ii-3:ii+3,jj-3:jj+3,i)));
grad(i)=norm([gradx(i),grady(i)]);
gradmean(ii,jj,i)=grad(i);
end
d=dsearchn(abs(gradcm(130:350,:)),grad);
d=d+129;
end
% for i=1:length(cm(:,1))
%     for ii=1:3
%         grad(i,ii)=gradient(c
%     
% end
end