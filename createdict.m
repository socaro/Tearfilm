clear all;
close all;
clc;
images=dir('traindata/*.tif');
%images=dir('traindata/*.jpg');
s=8;
traindata=cell(3);
tic;
for i=1:length(images)
    image=imread(fullfile('traindata',images(i).name));
    image=imadjust(image,findlim(image,5,95),[0;1]);
    for i=1:3
    imcol=im2col(double(image(:,:,i)),[s s],'distinct');
    imcol=imcol(:,randperm(length(imcol(1,:)),300));
    traindata{i}=[traindata{i} imcol];
    end  
end
toc;
for i=1:3
dict(:,:,i)=dictlearn(traindata{i},s,50,10);
dim=size(dict(:,:,i));
imagedict=col2im(dict(:,:,i),[s s],[s^2*3 s^2*2],'distinct');
imshow(imagedict);
end
save('learneddicttest.mat','dict');
