function fringe = cluster()
imraw=imread('sophie0131-1236-9.tif');
im=double(rgb2lab(imraw));
sizeim=size(im);
im(:,:,4:5)=zeros(sizeim(1),sizeim(2),2);
for i=1:sizeim(1)
    for j=1:sizeim(2)
        im(i,j,4)=i;
        im(i,j,5)=j;
    end
end


imshow(imraw);
d=datacursormode;
pause;
position=getCursorInfo(d);
pos=position.Position;
% d1=datacursormode;
% pause;
% position1=getCursorInfo(d1);
% pos1=position1.Position;
close;
% [~,diff]=knnsearch(squeeze(im(pos(2),pos(1),2:3)).',squeeze(im(pos1(2),pos1(1),2:3)).','Distance','mahalanobis');
fringe=zeros(sizeim(1),sizeim(2));
b=im(pos(2)-1:pos(2)+1,pos(1)-1:pos(1)+1,4:5);
current_search=reshape(b,[],2);

while true
    new_search=[];
    if ~isempty(current_search)
    for c=1:length(current_search(:,1))
        new_search=[new_search;block_search([current_search(c,1),current_search(c,2)])];
    end
    else
        break
    end
    current_search=new_search;
    close;
    imshow(fringe);
end


    function new_search=block_search(pos)
         new_search=[];
         block=im(pos(1)-3:pos(1)+3,pos(2)-3:pos(2)+3,:);
         col=reshape(block,[],5);
         rgb=squeeze(im(pos(1),pos(2),2:3)).';
         [ind,dist]=knnsearch(col(:,2:3),rgb,'K',10,'Distance','seuclidean');
         for x=2:length(ind)
             if dist(x)<0.45&&fringe(col(ind(x),4),col(ind(x),5))==0
                fringe(col(ind(x),4),col(ind(x),5))=1;
                new_search=[new_search;col(ind(x),4),col(ind(x),5)];
             end
         end
     end




end