function [lim] = findlim(image, limlow, limhigh)
if max(image)>1
    image=image./256;
end
for i=1:3
    [x,y]=imhist(image(:,:,i));
    x(1)=0;x(256)=0;
    z=100*cumsum(x)/sum(x);
    [~,indlow]=min(abs(z-limlow));
    [~,indhigh]=min(abs(z-limhigh));
    lowinrgb(i)=y(indlow);
    lowoutrgb(i)=y(indhigh);
end
lim=[min(lowinrgb);max(lowoutrgb)];
end