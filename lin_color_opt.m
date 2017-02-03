lambda=[629.4 518.1 464.7];
%im=load(strcat(file,'.tif'));
n=[1,1.33,1.4];
colormap=load('colormap.mat');
colormap=colormap.colormap;
calibrationdata=load('calibration.mat');
xdata=calibrationdata.x';
ydata=double(calibrationdata.y);

for i=1:length(xdata)
    for j=1:3
        C(i,2*j-1)=1;
        C(i,2*i)=cos(4*pi*n(2)*xdata(i)*10/lambda(j));
    end
    d(i)=sum(ydata(i,:));
end

