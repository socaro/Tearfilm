function block_new = usedict(block,dict,location,iteration)
X = sprintf('location: %d %d blocksize: %d %d\n',location,size(block));
disp(X);
if sum(block(:))~=0
column=reshape(block,[length(block(1,:))*length(block(2,:)) 1]);
column_mean=mean(column)*ones(length(column),1);
column_c=column-column_mean;
column_norm=norm(column_c);
column_nc=normc(column_c);
%column_new_c=wmpalg('BMP',column_c,dict,'itermax',10);
[column_new_nc,~,~]=matching_pursuit(column_nc,dict,iteration);
column_new_c=column_new_nc*column_norm;
column_new=column_new_c+column_mean;
block_new=reshape(column_new,size(block));
else
    block_new=block;
end

end