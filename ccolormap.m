function colormap = ccolormap(optics,n)
%input: 
%optics - csv file of sensor and camera spectral information
%n - refractive indices n0,n1,n2
%output: colormap - colormap for thicknesses of 0-5 micrometers
colormap=zeros(501,3);
for d=0:500
    for i=1:3
        I=zeros(length(optics(:,1)),1);
        R=I;
        for j=1:length(optics(:,1))
            R(j)=1-((8*n(1)*n(2)^2*n(3))/((n(1)^2+n(2)^2)*(n(2)^2+n(3)^2)+4*n(1)*n(2)^2*n(3)+(n(1)^2-n(2)^2)*(n(2)^2-n(3)^2)*cos(4*pi*n(2)*d*10/optics(j,1))));
            I(j)=R(j)*optics(j,2)*optics(j,3)*optics(j,i+3);
        end
        colormap(d+1,i)=trapz(I)/length(I);
    end
end
end