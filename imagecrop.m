function image_roi=imagecrop(image,BW,s,edge)
image=imcrop(image,[edge,(s-1),(s-1)]);
image_roi=image;
image_roi(BW==0)=0;
end