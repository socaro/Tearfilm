function cm = calibrate_cm()
%% different attempts to generate colormap using optimized parameters instead of csv data

lambda=[629.4 518.1 464.7];
%im=load(strcat(file,'.tif'));
% data=csvread(strcat(file,'_data.csv'));
n=[1,1.33,1.4];
colormap=load('colormap.mat');
colormap=colormap.colormap;

optics=csvread('optics.csv');
optics(:,2)=optics(:,2)./100;

% for i=1:3
% % ind=(lambda(i)*10-3999);
% % eta(i)=optics(ind,2)*optics(ind,3)*optics(ind,i+3);
% I=zeros(length(optics(:,1)),1);
%         for j=1:length(optics(:,1))
%             I(j)=optics(j,2)*optics(j,3)*optics(j,i+3);
%         end
%         eta(i)=trapz(I)/length(I);
% end

calibrationdata=load('calibration.mat');
xdata=calibrationdata.x';
ydata=double(calibrationdata.y);

%x0(1:3)=lambda;
%x0(4:(length(xdata)+3))=xdata;

for i=1:3
    x0(i)=0;
    x0(i+3)=10000;
    x0(i+6)=0;
end

x01=[0.6 1.33 1.6 3e5];

%fun=@(x)ffull(x,ydata,lambda,n,eta);
fun=@(x)ffull1(x,ydata,n,xdata,optics);
%fun=@(n)ffull2(n,ydata,xdata,optics);

options = optimoptions(@lsqnonlin,'Display','iter','MaxIteration',1000,'MaxFunctionEvaluation',100000,'FunctionTolerance',1e-8);
%options=optimoptions('lsqnonlin','Display','iter','Algorithm','levenberg-marquardt','FunctionTolerance',1e-10);

%problem = createOptimProblem('lsqnonlin','x0',x01,'objective',fun,'options',options);
%ms=MutliStart;
%x=run(gs,problem,20);
x=fminsearch(fun,x0);
%[x,resnorm]=lsqnonlin(fun,x01,[],[],options);
%cm=gen_cm(lambda,x(1:3),n,eta);
cm=gen_cm1(x,optics,n);
%cm=gen_cm2(x,optics);
cim=gen_cim1(cm);
imshow(cim);
end



function Ffull = ffull(x,ydata,lambda,n,eta)
for j=1:length(ydata(:,1))
    Ffull(j,:)=gen_cm(lambda,x(1:3),n,eta,x(j+3))-ydata(j,:);
end
end

function Ffull = ffull1(x,ydata,n,xdata,optics)
for j=1:length(ydata(:,1))
    Ffull(j,:)=gen_cm1(x,optics,n,xdata(j))-ydata(j,:);
end
end

function Ffull = ffull2(n,ydata,xdata,optics)
for j=1:length(ydata(:,1))
    Ffull_matrix(j,:)=(gen_cm2(n,optics,xdata(j))-ydata(j,:))^2;
end
Ffull=sum(Ffull_matrix(:));
end

function [t,rgb]=pick(im,cmold,n)
for i=1:100
colormap_image(:,i,:)=cmold;
end
lowin=min(min(min(colormap_image)));
lowout=max(max(max(colormap_image)));
disp_cm=uint8(imadjust(colormap_image,[lowin; lowout],[0; 1]).*256);
for i=1:n
i
d_cm=datacursormode(disp_cm);
pause;
pos_cm=getCursorInfo(d_cm);
position_cm=pos_cm.Position
x(i)=position_cm(2);
d_im=datacursormode(disp_im);
pause;
pos_im=getCursorInfo(d_im);
position_im=pos_im.Position


y(i,:)=image(position_im(1),position_im(2),:);
end
end

function cm = gen_cm(lambda,lambdafit,n,eta,t)
if nargin<5
    t=0;
    s=501;
else
    s=1;
end
r(1)=(n(1)-n(2))/(n(1)+n(2));
r(2)=(n(2)-n(3))/(n(1)+n(2));
R0=r(1)^2+r(2)^2;
gamma=abs(2*r(1)*r(2))/(r(1)^2+r(2)^2);
cm=zeros(s,3);
if nargin<5
for d=0:500
    for i=1:3
        cm(d+1,i)=R0*eta(i)*(1+gamma*cos(4*pi*n(2)*d*10/lambda(i))*exp(-lambdafit(i)/lambda(i)));
    end
end
else
    for i=1:3
        cm(1,i)=R0*eta(i)*(1+gamma*cos(4*pi*n(2)*t*10/lambda(i))*exp(-lambdafit(i)/lambda(i)));
    end
end
end

function colormap = gen_cm1(x,optics,n,d)
%input: 
%optics - csv file of sensor and camera spectral information
%n - refractive indices n0,n1,n2
%output: colormap - colormap for thicknesses of 0-5 micrometers

r(1)=(n(1)-n(2))/(n(1)+n(2));
r(2)=(n(2)-n(3))/(n(2)+n(3));
R0=r(1)^2+r(2)^2;
gamma=abs(2*r(1)*r(2))/(r(1)^2+r(2)^2);
if nargin <4
    colormap=zeros(501,3);
for d=0:500
    for i=1:3
        I=zeros(length(optics(:,1)),1);
        cm=I;
        for j=1:length(optics(:,1))
            %R(j)=1-((8*n(1)*n(2)^2*n(3))/((n(1)^2+n(2)^2)*(n(2)^2+n(3)^2)+4*n(1)*n(2)^2*n(3)+(n(1)^2-n(2)^2)*(n(2)^2-n(3)^2)*cos(4*pi*n(2)*d*10/optics(j,1))));
            cm(j)=R0*(1+gamma*cos(4*pi*n(2)*d*10/optics(j,1)));
            I(j)=cm(j)*optics(j,2)*optics(j,3)*optics(j,i+3);
        end
        colormap(d+1,i)=(x(i+6)*d^2+x(i)*d+x(i+3))*trapz(I)/length(I);
    end
end
else
    colormap=zeros(1,3);
    for i=1:3
        I=zeros(length(optics(:,1)),1);
        cm=I;
        for j=1:length(optics(:,1))
            %R(j)=1-((8*n(1)*n(2)^2*n(3))/((n(1)^2+n(2)^2)*(n(2)^2+n(3)^2)+4*n(1)*n(2)^2*n(3)+(n(1)^2-n(2)^2)*(n(2)^2-n(3)^2)*cos(4*pi*n(2)*d*10/optics(j,1))));
            cm(j)=R0*(1+gamma*cos(4*pi*n(2)*d*10/optics(j,1)));
            I(j)=cm(j)*optics(j,2)*optics(j,3)*optics(j,i+3);
        end
        colormap(i)=(x(i+6)*d^2+x(i)*d+x(i+3))*trapz(I)/length(I);
    end
end

    
end

function colormap = gen_cm2(n,optics,d)
%input: 
%optics - csv file of sensor and camera spectral information
%n - refractive indices n0,n1,n2
%output: colormap - colormap for thicknesses of 0-5 micrometers

r(1)=(n(1)-n(2))/(n(1)+n(2));
r(2)=(n(2)-n(3))/(n(2)+n(3));
R0=r(1)^2+r(2)^2;
gamma=abs(2*r(1)*r(2))/(r(1)^2+r(2)^2);
if nargin <3
    colormap=zeros(501,3);
for d=0:500
    for i=1:3
        I=zeros(length(optics(:,1)),1);
        cm=I;
        for j=1:length(optics(:,1))
            %R(j)=1-((8*n(1)*n(2)^2*n(3))/((n(1)^2+n(2)^2)*(n(2)^2+n(3)^2)+4*n(1)*n(2)^2*n(3)+(n(1)^2-n(2)^2)*(n(2)^2-n(3)^2)*cos(4*pi*n(2)*d*10/optics(j,1))));
            cm(j)=R0*(1+gamma*cos(4*pi*n(2)*d*10/optics(j,1)));
            I(j)=cm(j)*optics(j,2)*optics(j,3)*optics(j,i+3);
        end
        colormap(d+1,i)=n(4)*trapz(I)/length(I);
    end
end
else
    colormap=zeros(1,3);
    for i=1:3
        I=zeros(length(optics(:,1)),1);
        cm=I;
        for j=1:length(optics(:,1))
            %R(j)=1-((8*n(1)*n(2)^2*n(3))/((n(1)^2+n(2)^2)*(n(2)^2+n(3)^2)+4*n(1)*n(2)^2*n(3)+(n(1)^2-n(2)^2)*(n(2)^2-n(3)^2)*cos(4*pi*n(2)*d*10/optics(j,1))));
            cm(j)=R0*(1+gamma*cos(4*pi*n(2)*d*10/optics(j,1)));
            I(j)=cm(j)*optics(j,2)*optics(j,3)*optics(j,i+3);
        end
        colormap(i)=n(4)*trapz(I)/length(I);
    end
end

    
end

function cim = gen_cim(cm)
for i=1:100
cim(:,i,:)=cm;
end
if max(cm(:))>1
    cim=cim/256;
end
lowin=min(cim(:));
lowout=max(cim(:));
cim=uint8(imadjust(cim,[lowin; lowout],[0; 1]).*256);
end