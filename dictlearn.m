function dict = dictlearn(traindata, s, iteration,mpiteration)
    %%SVD algorithm to train a dictionary using input traindata
    %Input:
    %traindata      - matrix containing one image patch [s s] per column, thus has
    %                 s^2 rows
    %s              - size of image patches
    %iteration      - number of iteration loops
    %mpiteration    - number of iterations for matching pursuit
    %Output:
    %dict           - learned dictionary

    L=6*s^2;
    u=rand([s^2 L]); %using a randomly initialized dictionary
    %u=wmpdictionary(s^2,'lstcpt',{{'haar',2},{'haar',2},{'haar',2},{'haar',2}}); %using a set of level 5 Haar wavelets as dicitonary
    %L=length(u(1,:));
    u_new=u;
    [~,N]=size(traindata);
%     traindata_mean=zeros(size(traindata));
%     for n=1:N
%         traindata_mean(:,n)=sum(traindata(:,n))/length(traindata(:,n))*ones(size(traindata(:,n)));
%     end
%     traindata=traindata-traindata_mean;
%     for n=1:N
%         traindata(:,n)=traindata(:,n)-mean(traindata(:,n));
%     end
    traindata=(traindata-mean(traindata(:)))/(std(traindata(:))*sqrt(N));
    for i=1:iteration
        z_new=zeros(L,N);
        tic;
        for n=1:N
            %[Yfit,R,COEFF,IOPT]=wmpalg('BMP',traindata(:,n),u,'itermax',mpiteration);%'maxerr',{'L2',sigma*100});
            %[Yfit1,R1,COEFF1,IOPT1]=wmpalg('BMP',traindata(:,n),u,'itermax',100);
            [Yfit,R,COEFF,IOPT]=wmpalg('BMP',traindata(:,n),u,'maxerr',{'L2',5});
            z_new(IOPT,n)=COEFF;
            z_new2=z_new(IOPT,n);
            [~,I]=sort(IOPT);
            z_new1=COEFF(I);
        end
        toc;
        tic;
        for l=1:L
           u_temp=u;
           u_temp(:,l)=zeros(s^2,1);
           Rt_l=u_temp*z_new;
           R_l=traindata-Rt_l;
%            tic;
%            [U,~,~]=svd(R_l,'econ');
%            toc;
           [U1,~]=eig(R_l*ctranspose(R_l));
           u_new(:,l)=-U1(:,length(U1(1,:)));
	       %disp(fprintf('i: %d, l: %d\n',i,l));
        end 
        toc;
        i
        u=u_new;
        imagedict=col2im(u,[s s],[s^2*3 s^2*2],'distinct');
        imshow(imagedict);
    end
    dict=u_new;
end
