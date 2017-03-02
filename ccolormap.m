function colormap=ccolormap()
%% function to generate theoretical colormap from csv data on hardware 
%% colormap = rows are rgb values of color for specific thickness. Thickness is the (row index - 1)*10 nm (e.g. row 100 corresponds to 990 nm).

optics=csvread('optics.csv');
optics(:,2)=optics(:,2)./100;
n=[1,1.33,1.4];
colormap=gen_cm(optics,n);
cim=gen_cim(colormap);
imshow(cim);
end

function colormap = gen_cm(optics,n)
%input: 
%optics - csv file of sensor and camera spectral information
%n - refractive indices n0,n1,n2
%output: colormap - colormap for thicknesses of 0-5 micrometers
colormap=zeros(5001,3);
r(1)=(n(1)-n(2))/(n(1)+n(2));
r(2)=(n(2)-n(3))/(n(1)+n(2));
R0=r(1)^2+r(2)^2;
gamma=abs(2*r(1)*r(2))/(r(1)^2+r(2)^2);
for d=0:5000
    for i=1:3
        I=zeros(length(optics(:,1)),1);
        cm=I;
        for j=1:length(optics(:,1))
            %R(j)=1-((8*n(1)*n(2)^2*n(3))/((n(1)^2+n(2)^2)*(n(2)^2+n(3)^2)+4*n(1)*n(2)^2*n(3)+(n(1)^2-n(2)^2)*(n(2)^2-n(3)^2)*cos(4*pi*n(2)*d*10/optics(j,1))));
            cm(j)=R0*(1+gamma*cos(4*pi*n(2)*d/optics(j,1)));
            I(j)=cm(j)*optics(j,2)*optics(j,3)*optics(j,i+3);
        end
        colormap(d+1,i)=trapz(I)/length(I);
    end
end
end

function cim = gen_cim(cm)
for i=1:500
cim(:,i,:)=cm;
end
lowin=min(cim(:));
lowout=max(cim(:));
cim=uint8(imadjust(cim,[lowin; lowout],[0; 1]).*256);
end