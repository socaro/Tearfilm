function [dict, imagedict] = createdict(s,name)

images=dir('traindata/*.tif');
%images=dir('traindata/*.jpg');
traindata=cell(3);
tic;
for i=1:length(images)
    image=imread(fullfile('traindata',images(i).name));
    image=imadjust(image,findlim(image,5,95),[0;1]);
    for i=1:3
    imcol=im2col(double(image(:,:,i)),[s s],'distinct');
    imcol=imcol(:,randperm(length(imcol(1,:)),50));
    traindata{i}=[traindata{i} imcol];
    end  
end
toc;

for i=1:3
dict(:,:,i)=dictlearn(traindata{i},s,50,100);
imagedict(:,:,i)=col2im(dict(:,:,i),[s s],size(dict),'distinct');
imagedict(:,:,i)=imadjust(abs(imagedict(:,:,i)),stretchlim(abs(imagedict(:,:,i))),[0; 1]);
end
imshow(imagedict,'InitialMagnification','fit');
save(strcat(name,'.mat'),'dict');
end
