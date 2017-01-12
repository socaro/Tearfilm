clear all;
close all;
clc;
images=dir('traindata/*.tif');
s=16;
traindata=[];
tic;
for i=1:length(images)
    image=imread(fullfile('traindata',images(i).name));
    image=imadjust(image,findlim(image,5,95),[0;1]);
    imcol=[im2col(double(image(:,:,1)),[s s],'distinct') im2col(double(image(:,:,2)),[s s],'distinct') im2col(double(image(:,:,3)),[s s],'distinct')];
    traindata=[traindata imcol];
end
toc;
dict=dictlearn(traindata,s,50,10);
save('learneddict.m','dict');
imagedict=col2im(dict,[s s],size(dict),'distinct');
imshow(imagedict);