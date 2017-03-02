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

    %L=6*s^2;
    u=rand([s^2 6*s^2]); %using a randomly initialized dictionary
    u=normc(u);
    %u=wmpdictionary(s^2,'lstcpt',{{'haar',2},{'sym4',5},{'wpsym4',5},'dct','sin'});
    %u=wmpdictionary(s^2,'lstcpt',{{'haar',2},{'haar',2},{'haar',2},{'haar',2}}); %using a set of level 5 Haar wavelets as dicitonary
    u=full(u);
    imagedict=col2im(u,[s s],size(u),'distinct');
    imagedict=imadjust(imagedict,stretchlim(imagedict),[0; 1]);
    figure;imshow(imagedict);
    L=length(u(1,:));
    u_new=u;
    u_new1=u;
    [~,N]=size(traindata);
    traindata=(traindata-mean(traindata(:)));%/(std(traindata(:))*sqrt(N));
    traindata=normc(traindata);
    for i=1:iteration
        z_new=zeros(L,N);
        tic;
        for n=1:N
            %[Yfit,R,COEFF,IOPT]=wmpalg('BMP',traindata(:,n),u,'itermax',mpiteration);%'maxerr',{'L2',sigma*100});
            %[Yfit,R,COEFF,IOPT]=wmpalg('BMP',traindata(:,n),u,'maxerr',{'L2',5});
            [x_rec,a,d] = matching_pursuit(traindata(:,n),u,mpiteration);
            for x=1:length(a)
                z_new(d(x),n)=z_new(d(x),n)+a(x);
            end
%             for x=1:length(IOPT)
%                 z_new(IOPT(x),n)=z_new(IOPT(x),n)+COEFF(x);
%             end
        end
        toc;
        close;
        tic;
        for l=1:L
           if ~isempty(find(z_new(l,:), 1))
           u_temp=u;
           u_temp(:,l)=zeros(s^2,1);
           Rt_l=u_temp*z_new;
           R_l=traindata-Rt_l;
%            tic;
%            [U,~,~]=svd(R_l,'econ');
            [U2,~,~]=svds(R_l);
            if norm(R_l-U2(:,1)*z_new(l,:))<norm(R_l+U2(:,1)*z_new(l,:))
                u_new(:,l)=U2(:,1);
            else 
                u_new(:,l)=-U2(:,1);
            end
%            toc; 
%            tic;
%           [U1,~]=eig(R_l*ctranspose(R_l));
%           for k=1:length(U1(1,:));no1(k)=norm(R_l+U1(:,k)*z_new(l,:));end
%           for k=1:length(U(1,:));no(k)=norm(R_l-U(:,k)*z_new(l,:));end
%           for k=1:length(U2(1,:));no2(k)=norm(R_l-U2(:,k)*z_new(l,:));end
%           Ucomp = [U(:,1) U1(:,end) U2(:,1)];
%           [min(no),min(no1),min(no2)]
           %u_new(:,l)=-U1(:,length(U1(1,:)));
% 	       toc;
           %disp(fprintf('i: %d, l: %d\n',i,l));
           else 
               Rempt=traindata-u*z_new;
               [~,Iempt]=max(norm(Rempt));
               u(:,l)=traindata(:,Iempt)/norm(traindata(:,Iempt));
           end
        end 
        toc;
        i
        u=u_new;
        imagedict=col2im(u,[s s],size(u),'distinct');
        imagedict=imadjust(abs(imagedict),stretchlim(abs(imagedict)),[0; 1]);
        figure;imshow(imagedict);
    end
    dict=u_new;
end
