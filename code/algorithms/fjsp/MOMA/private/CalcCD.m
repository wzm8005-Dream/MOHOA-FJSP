function mayflies=CalcCD(mayflies,F)
nF=numel(F);
for k=1:nF
    Objectives=[mayflies(F{k}).Cost];
    Obj=size(Objectives,1); n=numel(F{k});
    d=zeros(n,Obj);
    for j=1:Obj
        [cj, so]=sort(Objectives(j,:)); d(so(1),j)=inf;
        for i=2:n-1
            d(so(i),j)=abs(cj(i+1)-cj(i-1))/abs(cj(1)-cj(end));
        end
        d(so(end),j)=inf;
    end
    for i=1:n
        mayflies(F{k}(i)).CrowdingDistance=sum(d(i,:));
    end
end
end