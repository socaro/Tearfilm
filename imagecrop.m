function image_roi=imagecrop(image,BW,s_crop,edge)
image_roi=imcrop(image,[edge,(s_crop-1),(s_crop-1)]);
image_roi(BW==0)=0;
end