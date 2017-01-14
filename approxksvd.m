function dict = approxksvd(traindata, s, iteration,mpiteration)
    %%SVD algorithm to train a dictionary using input traindata
    %Input:
    %traindata      - matrix containing one image patch [s s] per column, thus has
    %                 s^2 rows
    %s              - size of image patches
    %iteration      - number of iteration loops
    %mpiteration    - number of iterations for matching pursuit
    %Output:
    %dict           - learned dictionary

    %L=6*s^2;
    u=rand([s^2 6*s^2]); %using a randomly initialized dictionary
    %u=wmpdictionary(s^2,'lstcpt',{{'haar',2},{'haar',2},{'haar',2},{'haar',2}}); %using a set of level 5 Haar wavelets as dicitonary
    %u=wmpdictionary(s^2,'lstcpt',{{'haar',2},{'sym4',5},{'wpsym4',5},'dct','sin'});

    u=full(u);
    imagedict=col2im(u,[s s],size(u),'distinct');
    figure;imshow(imagedict);
    L=length(u(1,:));
    [~,N]=size(traindata);
%     traindata_mean=zeros(size(traindata));
%     for n=1:N
%         traindata_mean(:,n)=sum(traindata(:,n))/length(traindata(:,n))*ones(size(traindata(:,n)));
%     end
%     traindata=traindata-traindata_mean;
%     for n=1:N
%         traindata(:,n)=traindata(:,n)-mean(traindata(:,n));
%     end
    traindata=(traindata-mean(traindata(:)));%/(std(traindata(:))*sqrt(N));
    for i=1:iteration
        z_new=zeros(L,N);
        tic;
        for n=1:N
            %[Yfit,R,COEFF,IOPT]=wmpalg('BMP',traindata(:,n),u,'itermax',mpiteration);%'maxerr',{'L2',sigma*100});
            %[Yfit1,R1,COEFF1,IOPT1]=wmpalg('BMP',traindata(:,n),u,'itermax',100);
            [Yfit,R,COEFF,IOPT]=wmpalg('BMP',traindata(:,n),u,'maxerr',{'L2',5});
            for x=1:length(IOPT)
                z_new(IOPT(x),n)=z_new(IOPT(x),n)+COEFF(x);
            end
        end
        toc;
        close;
        tic;
        for l=1:L
           I=find(z_new(l,:));
           u(:,l)=zeros(s^2,1);
           g=z_new(l,I)';
           R=traindata(:,I)-u*z_new(:,I);
           d=R*g/norm(R*g);
           %d=traindata(:,I)*g-(u*z_new(:,I))*g;
           %d=d/norm(d);
           %g=traindata(:,I)'*d-(u*z_new(:,I))'*d;
           g=R'*d;
           u(:,l)=d;
           z_new(l,I)=g';
	       %disp(fprintf('i: %d, l: %d\n',i,l));
        end 
        toc;
        i
        imagedict=col2im(u,[s s],size(u),'distinct');
        figure;imshow(imagedict);
    end
    dict=u;
end
