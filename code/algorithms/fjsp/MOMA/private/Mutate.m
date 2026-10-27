function y=Mutate(x,mu,LowerBound,UpperBound)
nVar=numel(x); nmu=ceil(mu*nVar);
j=randsample(nVar,nmu);
sigma(1:nVar)=0.1*(UpperBound-LowerBound);
y=x;
y(j)=x(j)+sigma(j).*(randn(size(j))');
y=max(y,LowerBound); y=min(y,UpperBound);
end