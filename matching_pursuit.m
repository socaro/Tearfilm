function [x_rec,a,d] = matching_pursuit(x,D,H)
    %% Matching pursuit algorithm
    % Input:
    % x              - the signal, a column vector
    % D              - [Optional] the dictionary, each column of the dictionary represents an atom
    % H              - 
    %
    % Output:
    % x_rec          - the reconstructed signal
    % a              - the coefficient for each iteration
    % d              - the atom for each iteration
    
    % default dictionary
    if nargin < 2
        D = wmpdictionary(size(x,1));
    elseif nargin < 3
        H=size(D,2);   % number of iterations equals dictionary size
    end
    
    % normalize the dictionary
    D = normc(D);
    
  
 

    R = x;
    a = zeros(1,H);
    G = zeros(size(D,1),H);
    d = zeros(1,H);
    for k=1:H
        p = D'*R;
        [~,d(k)] = max(abs(p));
        G(:,k) = D(:,d(k));
        a(k) = p(d(k));
        R = R-a(k)*G(:,k);
    end

    % recover signal
    x_rec = zeros(size(R));
    for i=1:H
        x_rec = x_rec + a(i)*G(:,i);
    end
end
