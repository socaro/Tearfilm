function fringe = cluster()





imraw=imread('im_d/Ben0202-1-crpupil.tif');
imshow(imraw);


im=double(rgb2lab(imraw));
im=add_coord(im);
c=ceil(length(im(1,:,1))/3);
pos=auto_pos(imraw,c);
cm=cm_c(imraw,c);
for i=1:100;cim(:,i,:)=uint8(cm);end
%pos_cursor=get_pos_cursor(imraw);


block_r=3; %block radius

for i=6:6
    col=1;
    pos_col=pos{col}.';
    pos_m=pos_col(i,:);
    fringe{i}=cluster_fringe(im,pos_m,block_r);
    cm_sparse=cm_sparse(cm,col);
    imshowpair(imraw,fringe{i},'montage');
    d{i}=corr_fringe(imraw,cm_sparse,fringe{i});
end
    
end

function pos_cursor = get_pos_cursor(imraw)
        imshow(imraw);
        d=datacursormode;
        pause;
        position=getCursorInfo(d);
        pos=position.Position;
        pos_cursor(1)=pos(2);
        pos_cursor(2)=pos(1);
        close;
end
    
function [dist,pos] = dist_color(pos_cursor,s,im)
        %% determine seucledian distance to nearest peak in color
        %% s = block radius
         s=s;
         block=im(pos_cursor(1)-s:pos_cursor(1)+s,pos_cursor(2)-s:pos_cursor(2)+s,:);
         ab=squeeze(im(pos_cursor(1),pos_cursor(2),2:3)).';
         col=reshape(block,[],5);
         dist_all=squareform(pdist(col(:,2:3),'seuclidean'));
         norm=sqrt(sum(dist_all.^2,2));
         [~,mid_pix]=min(norm);
         dist_mid=sort(dist_all(mid_pix,:));
         dist=1.5*mean(dist_mid(1:20));
         pos=squeeze(col(mid_pix,4:5));
%          [~,dist]=knnsearch(col(:,2:3),ab,'K',49,'Distance','seuclidean');
%          dist=1.17*median(dist);%1/2*(max(dist));%+mean(dist))/2;
end
    
function im = add_coord(im)
       sizeim=size(im);
        im(:,:,4:5)=zeros(sizeim(1),sizeim(2),2);
        for s=1:sizeim(1)
            for j=1:sizeim(2)
                im(s,j,4)=s;
                im(s,j,5)=j;
            end
        end      
end


function pos = auto_pos(im,c)
    im=double(im);
    pos=cell(3);
    sizeim=size(im);
%     for i=1:3
%         [~,peaks]=findpeaks(smooth(im(:,c,i)),'MinPeakProminence',5,'MinPeakDistance',10);
%         pos{i}=[peaks,c*ones(size(peaks))];
%     end
for i=1:3    
peaks_v=zeros(sizeim(1),sizeim(2));
peaks_h=zeros(sizeim(1),sizeim(2));

for l=1:2:length(im(1,:,1)) %determine peaks vertically (along rows)
        [pks,locs]=findpeaks(smooth(im(:,l,i)),'MinPeakProminence',15);
        peaks_v(locs,l,i)=1;
end
for l=1:2:length(im(:,1,1)) %determine peaks horizontally (along columns)
        [pks,locs]=findpeaks(smooth(im(l,:,i)),'MinPeakProminence',15);
        peaks_h(l,locs,i)=1;
end
peaks=peaks_v+peaks_h;
 peaks(peaks==1)=0;
% peaks(peaks==2)=1;
[pos{i}(1,:),pos{i}(2,:)]=find(peaks==2);
end
end

function cm = cm_c(im,c)
    colormap=load('colormap.mat');
    cm=colormap.colormap;
%     cm=reshape(cm,[],1,3);
%     limin=stretchlim(cm);
%     cm=squeeze(cm);
%     limout=find_lim(im,0.1,99.9);
%     cm=imadjust(cm,limin,limout).*256;
    for i=1:3;cm(:,i)=cm(:,i)*mean(nonzeros(double(im(:,c,i))))./mean(cm(130:300,i));end 
end

function [lim] = find_lim(image,limlow,limhigh)
if max(image(:))<=1
    image=image*256;
end
for i=1:3
    [x,y]=imhist(image(:,:,i));
    x(1)=0;x(256)=0;
    z=100*cumsum(x)/sum(x);
    [~,indlow]=min(abs(z-limlow));
    [~,indhigh]=min(abs(z-limhigh));
    lim(1,i)=y(indlow);
    lim(2,i)=y(indhigh);
end
lim=lim./256;
end

function fringe = cluster_fringe(im,pos_cursor,s)
sizeim=size(im);
fringe=zeros(sizeim(1),sizeim(2));

[dist_thresh,pos_init] = dist_color(pos_cursor,s,im);

b=im(pos_init(1)-1:pos_init(1)+1,pos_init(2)-1:pos_init(2)+1,4:5);
current_search=reshape(b,[],2);

ab=squeeze(im(pos_init(1),pos_init(2),2:3)).';

while true
    new_search=[];
    if ~isempty(current_search)
    for c=1:length(current_search(:,1))
        new_search=[new_search;block_search(current_search(c,:))];
    end
    else
        break
    end
    current_search=new_search;
end

    
   function this_search=block_search(pos)
         this_search=[];
         block=im(pos(1)-s:pos(1)+s,pos(2)-s:pos(2)+s,:);
         col=reshape(block,[],5);
         %rgb=squeeze(im(pos(1),pos(2),2:3)).';
         %fprintf('a and b of ref: %d, %d \n',rgb);
         [ind,dist]=knnsearch(col(:,2:3),ab,'K',20,'Distance','seuclidean');
         I=find(dist<dist_thresh);
         for x=2:length(I)
             r_ab=col(ind(I(x)),4);
             c_ab=col(ind(I(x)),5);
             if fringe(r_ab,c_ab)==0&&im(r_ab,c_ab,2)~=0&&im(r_ab,c_ab,3)~=0 
                fringe(r_ab,c_ab)=1;
                fprintf('a and b of new pix: %d, %d \n',squeeze(im(r_ab,c_ab,2:3)).');
                this_search=[this_search;r_ab,c_ab];
             end
         end
   end
end

function cm_sparse = cm_sparse(cm,i)
        [~,locs]=findpeaks(cm(:,i));
        locs1=[locs;locs+1;locs+2;locs+3;locs-1;locs-2;locs-3];
        locs1=sort(locs1);
        cm_sparse=zeros(size(cm));
        cm_sparse(locs1,:)=cm(locs1,:);
end
    
function d = corr_fringe(imraw,cm,fringe)
        ind=find(fringe==1);
        im_col=reshape(imraw,[],3);
        colors=double(im_col(ind,:));
%         c=fitgmdist(colors(:,1:3),1);
%         dist=mahal(c,cm(:,1:3));
%         [~,d]=min(dist(130:300));
%         d=d+129;
        dist=pdist2(colors,cm(:,1:3),'seuclidean');
        dist_m=mean(dist,1);
        [~,d]=min(dist(130:300));
        d=d+129;
    end