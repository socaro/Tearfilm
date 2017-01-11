clear all;
close all;
clc;

optics=csvread('optics.csv');
optics(:,2)=optics(:,2)./100;
n=[1,1.33,1.4];
colormap=colormap(optics,n);
