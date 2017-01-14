function [x_rec,a,G] = matching_pursuit(x,D)
    %% Matching pursuit algorithm
    % Input:
    % x              - the signal, a column vector
    % D              - [Optional] the dictionary, each column of the dictionary represents an atom
    %
    % Output:
    % x_rec          - the reconstructed signal
    % a              - the coefficient for each iteration
    % G              - the atom for each iteration
    
    % default dictionary
    if nargin < 2
        D = wmpdictionary(size(x,1));
    end
    
    % normalize the dictionary
    D = normc(D);
    
    % number of iterations equals dictionary size
    H = size(D,2);

    R = x;
    a = zeros(1,H);
    G = zeros(size(D,1),H);
    for k=1:1:H
        p = D'*R;
        [~,d] = max(abs(p));
        G(:,k) = D(:,d);
        a(k) = p(d);
        R = R-a(k)*G(:,k);
    end

    % recover signal
    x_rec = zeros(size(R));
    for i=1:H
        x_rec = x_rec + a(i)*G(:,i);
    end
end
