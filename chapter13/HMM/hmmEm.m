function [model, energy] = hmmEm(x, init)
% EM algorithm to fit the parameters of HMM model (a.k.a Baum-Welch algorithm)
%   x: 1 x n sequence of observations
%   init: model or k
% Written by Mo Chen (sth4nth@gmail.com).
n = size(x,2);
d = max(x);
X = sparse(x,1:n,1,d,n);

if isstruct(init)   % init with a model
    A = init.A;
    E = init.E;
    s = init.s;
elseif numel(init) == 1  % random init with latent k
    k = init;
    A = normalize(rand(k,k),2);
    E = normalize(rand(k,d),2);
    s = normalize(rand(k,1),1);
end
M = E*X;

tol = 1e-4;
maxIter = 100;
energy = -inf(1,maxIter);
for iter = 2:maxIter
%     E-step
    [gamma,alpha,beta,c] = hmmSmoother_(M,A,s);
    energy(iter) = sum(log(c(c>0)));
    if energy(iter)-energy(iter-1) < tol*abs(energy(iter-1)); break; end   % check likelihood for convergence
%     M-step 
    A = normalize(A.*(alpha(:,1:n-1)*bsxfun(@times,beta(:,2:n).*M(:,2:n),1./c(2:end))'),2);      % 13.19
    s = gamma(:,1);                                                                             % 13.18
    M = bsxfun(@times,gamma*X',1./sum(gamma,2))*X;                                          
end
energy = energy(2:iter);
model.A = A;
model.E = E;
model.s = s;


