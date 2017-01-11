function block_new = usedict(block,dict,s,border,location)
X = sprintf('location: %d %d blocksize: %d %d\n',location,size(block));
disp(X);
column=reshape(block,[(s(1)+2*border(1))*(s(2)+2*border(2)) 1]);
column_mean=sum(column)/length(column)*ones(length(column),1);
column_c=column-column_mean;
column_new_c=wmpalg('BMP',column_c,dict,'itermax',15);
column_new=column_new_c+column_mean;
block_new=reshape(column_new,[(s(1)+2*border(1)) (s(2)+2*border(2))]);
end