function [im_adjust, thickness] = auto_tlab(image,colormap,s,t_high,bool)
%% function to automatically determine thickness profile using image in L*a*b space instead of RGB
%% input:
% image - image
% colormap - colormap (2 dimnesional, intensity adjusted)
% s - block size
% t_high - highest thickness in image in nm (for starting reference)
%% output
% im_adjust - image adjusted to matched color (determine whether output is
% realistic)
% thickness - thickness profile in nm
% bool - 1 if image and cm not in lab
if bool==1
image=rgb2lab(image);
for i=1:100
    cim(:,i,:)=colormap;
end
cimlab=rgb2lab(cim);
colormap=squeeze(cim(:,1,:));
end

kref=t_high/10-15; %create reference index for limiting colormap
k=kref;
counter=zeros(size(image(:,:,1))); %initialize counter to count how many times pixel is taken into account for averaging
im_adjust=zeros(size(image)); %initialize image
thickness=zeros(size(image(:,:,1))); %initialize thickness map
for i=1:(length(image(:,1,1))-s+1)
    for j=1:(length(image(1,:,1))-s+1)
        block=image(i:(i+s-1),j:(j+s-1),:); %create block of size s*s at position i,h=j
        block_new=zeros(size(block)); %initialize new block
        block_thickness=zeros(size(block(:,:,1))); %initialize thickness block
        counter(i:(i+s-1),j:(j+s-1))=counter(i:(i+s-1),j:(j+s-1))+1; %add 1 to counter for averaging
        update= true;
        for ii=1:3
            if length(find(block(:,:,ii)~=0))==0 %exclude NaN rgbs
            update=false;
            end
            lab(ii)=sum(sum(block(:,:,ii)))/length(find(block(:,:,ii)~=0));%exclude zeros from mean
        end
        if lab(1)<20
            update=false; %exclude boundary values
        end
        if update
            k=dsearchn(colormap((kref-50):(kref+50),2:3),lab(2:3));%create interval around reference signal
            k=k+kref-20; %adjust index to actual colormap
            t=(k-1)*10; %thickness in nm
            block_thickness=repmat(t,size(block_thickness)); %replicate t for all values of block
            for ii=1:length(block_new(1,:,:))
                for jj=1:length(block_new(:,1,:))
                    block_new(ii,jj,:)=colormap(k,:); %find color values from colormap for new block
                end
            end
        end
        im_adjust(i:(i+s-1),j:(j+s-1),:)=im_adjust(i:(i+s-1),j:(j+s-1),:)+block_new;
        thickness(i:(i+s-1),j:(j+s-1))=thickness(i:(i+s-1),j:(j+s-1))+block_thickness;
    end
    
    %% limit kref
    if k<(t_high/10*(1-i/length(image(:,1,1)))-20)
        k=t_high/10*(1-i/length(image(:,1,1)));
    elseif k<(t_high/10-15)
        kref=k;
    else
        kref=(t_high/10-15);
    end
end
%% determine averages for pixels that are part of several blocks (blocks are sliding)
for i=1:3
im_adjust(:,:,i)=im_adjust(:,:,i)./counter;
end
thickness=thickness./counter;

end