clear all;
close all;
clc;
images=dir('traindata/*.tif');
s=8;
traindata=[];
for i=1:length(images)
    image=imread(fullfile('traindata',images(i).name));
    imcol=[im2col(double(image(:,:,1)),[s s],'distinct') im2col(double(image(:,:,2)),[s s],'distinct') im2col(double(image(:,:,3)),[s s],'distinct')];
    traindata=[traindata imcol];
end
dict=dictlearn(traindata,s,50,10);
save('learneddict.m','dict');