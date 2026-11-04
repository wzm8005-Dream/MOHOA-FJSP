classdef Metric
methods(Static)
function v=coverage(A,B)
% C(A,B): fraction of B strictly Pareto dominated by at least one point in A.
if isempty(B),v=NaN;return;end
hit=false(size(B,1),1);
for i=1:size(A,1),hit=hit|study.Pop.dominates(A(i,:),B);end
v=mean(hit);
end
function v=igd(F,R)
if isempty(F),v=Inf;return;end
sumD=0;
for start=1:256:size(R,1)
    r=R(start:min(end,start+255),:);
    d2=max(0,sum(r.^2,2)+sum(F.^2,2)'-2*r*F');sumD=sumD+sum(sqrt(min(d2,[],2)));
end
v=sumD/size(R,1);
end
function v=hv(F,ref)
% Exact union volume in 2/3 objectives. Fixed external reference point.
F=F(all(isfinite(F),2)&all(F<ref,2),:);if isempty(F),v=0;return;end
F=F(study.Pop.front(F),:);
if size(F,2)==2
    F=sortrows(F,1);top=ref(2);v=0;
    for i=1:size(F,1),if F(i,2)<top,v=v+(ref(1)-F(i,1))*(top-F(i,2));top=F(i,2);end,end
elseif size(F,2)==3
    x=unique(F(:,1));v=0;
    for i=1:numel(x)
        if i==numel(x),right=ref(1);else,right=x(i+1);end
        v=v+(right-x(i))*study.Metric.hv(F(F(:,1)<=x(i),2:3),ref(2:3));
    end
else,error('Revision:HV','Exact HV supports 2 or 3 objectives.');end
end
function s=score(F,R,lo,hi,ref)
span=hi-lo;span(span<=1e-12)=1;
Y=(F-lo)./span;P=(R-lo)./span;
s.IGD=study.Metric.igd(Y,P);s.HV=study.Metric.hv(Y,ref);
s.InReferenceCount=sum(all(Y<ref,2));s.FrontSize=size(F,1);
end
function r=tiedrank(x)
[v,o]=sort(x(:));r=zeros(size(v));i=1;
while i<=numel(v),j=i;while j<numel(v)&&v(j+1)==v(i),j=j+1;end;r(o(i:j))=(i+j)/2;i=j+1;end
end
function q=quantile(x,p)
x=sort(x(isfinite(x)));x=x(:)';if isempty(x),q=nan(size(p));return;end
% Explicit type-7 linear quantiles; same convention in every report.
t=1+(numel(x)-1)*p;low=floor(t);high=ceil(t);q=x(low).*(high-t)+x(high).*(t-low);same=low==high;q(same)=x(low(same));
end
function [p,delta]=ranksum(x,y)
% Two-sided normal approximation with tie variance and continuity correction.
x=x(:);y=y(:);n=numel(x);m=numel(y);allv=[x;y];r=study.Metric.tiedrank(allv);
U=sum(r(1:n))-n*(n+1)/2;delta=2*U/(n*m)-1;
[~,~,g]=unique(allv);t=accumarray(g,1);N=n+m;
varU=n*m/12*((N+1)-sum(t.^3-t)/(N*(N-1)));
if varU<=0,p=1;else,z=max(0,abs(U-n*m/2)-.5)/sqrt(varU);p=erfc(z/sqrt(2));end
end
function out=holm(p)
out=nan(size(p));valid=find(isfinite(p));[v,o]=sort(p(valid));m=numel(v);
adj=min(1,cummax(v(:).*(m:-1:1)'));out(valid(o))=adj;
end
function [p,stat,meanRanks]=friedman(values)
[n,k]=size(values);r=zeros(n,k);ties=0;
for i=1:n,r(i,:)=study.Metric.tiedrank(values(i,:));[~,~,g]=unique(values(i,:));t=accumarray(g(:),1);ties=ties+sum(t.^3-t);end
meanRanks=mean(r,1);stat=12*n/(k*(k+1))*sum(meanRanks.^2)-3*n*(k+1);
c=1-ties/(n*(k^3-k));if c<=0,stat=0;p=1;else,stat=max(0,stat/c);p=gammainc(stat/2,(k-1)/2,'upper');end
end
end
end
