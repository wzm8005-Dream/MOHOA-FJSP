classdef Pop
% Toolbox-free population utilities, independent implementation.
methods(Static)
function yes=dominates(a,b)
yes=all(a<=b,2)&any(a<b,2);
end
function r=rank(F)
n=size(F,1);D=true(n);strict=false(n);
for q=1:size(F,2),D=D&(F(:,q)<=F(:,q)');strict=strict|(F(:,q)<F(:,q)');end
D=D&strict;r=zeros(n,1);left=true(n,1);k=0;
while any(left)
    k=k+1;front=left & ~any(D(left,:),1)';
    assert(any(front),'Non-dominated sorting failed');r(front)=k;left(front)=false;
end
end
function ids=front(F)
% Incremental first front: bounded memory for pooled reference fronts.
if isempty(F),ids=[];return;end
[U,ia]=unique(F,'rows','stable');[~,ord]=sortrows(U,1:size(U,2));keep=zeros(size(U,1),1);n=0;
for z=ord'
    f=U(z,:);
    if n>0 && any(all(U(keep(1:n),:)<=f,2)),continue;end
    n=n+1;keep(n)=z;
end
ids=ia(keep(1:n));
end
function c=crowd(F)
n=size(F,1);c=zeros(n,1);if n<=2,c(:)=inf;return;end
for q=1:size(F,2)
    [v,o]=sort(F(:,q));span=v(end)-v(1);if span<=0,continue;end
    c(o([1 end]))=inf;c(o(2:end-1))=c(o(2:end-1))+(v(3:end)-v(1:end-2))/span;
end
end
function ids=select(F,N,kind,Z,ideal)
N=min(N,size(F,1));r=study.Pop.rank(F);ids=[];
for level=1:max(r)
    g=find(r==level);
    if numel(ids)+numel(g)<=N,ids=[ids;g];else
        k=N-numel(ids);
        if strcmp(kind,'reference')
            Y=F([ids;g],:)-ideal;span=study.Pop.intercepts(Y);Y=Y./span;
            Z=Z./sqrt(sum(Z.^2,2));projection=Y*Z';
            distance=sqrt(max(0,sum(Y.^2,2)-projection.^2));
            [near,assoc]=min(distance,[],2);rho=accumarray(assoc(1:numel(ids)),1,[size(Z,1) 1]);
            ag=assoc(numel(ids)+1:end);dg=near(numel(ids)+1:end);available=true(numel(g),1);active=true(size(Z,1),1);chosen=[];
            while numel(chosen)<k
                slots=find(active);assert(~isempty(slots));lowest=min(rho(slots));slots=slots(rho(slots)==lowest);j=slots(randi(numel(slots)));
                candidates=find(available & ag==j);
                if isempty(candidates),active(j)=false;continue;end
                if rho(j)==0,[~,t]=min(dg(candidates));else,t=randi(numel(candidates));end
                pick=candidates(t);chosen(end+1,1)=g(pick);available(pick)=false;rho(j)=rho(j)+1;
            end
            ids=[ids;chosen];
        else
            c=study.Pop.crowd(F(g,:));[~,o]=sort(c,'descend');ids=[ids;g(o(1:k))];
        end
        break
    end
    if numel(ids)==N,break;end
end
end
function a=intercepts(Y)
q=size(Y,2);fallback=max(Y,[],1);a=fallback;
if size(Y,1)>=q
    ex=zeros(q,1);
    for j=1:q,w=ones(1,q)*1e-6;w(j)=1;[~,ex(j)]=min(max(Y./w,[],2));end
    A=Y(ex,:);
    if numel(unique(ex))==q && rcond(A)>1e-12
        v=A\ones(q,1);candidate=1./v';
        if all(isfinite(candidate)&candidate>1e-12),a=candidate;end
    end
end
a(~isfinite(a)|a<=1e-12)=1;
end
end
end
