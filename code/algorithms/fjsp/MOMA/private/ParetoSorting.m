function [mayflies, F]=ParetoSorting(mayflies)
nPop=numel(mayflies);
for i=1:nPop
    mayflies(i).DominationSet=[]; mayflies(i).DominatedCount=0;
end
F{1}=[];
for i=1:nPop
    for j=i+1:nPop
        p=mayflies(i); q=mayflies(j);
        if Dominates(p,q)
            p.DominationSet=[p.DominationSet j];
            q.DominatedCount=q.DominatedCount+1;
        end
        if Dominates(q.Cost,p.Cost)
            q.DominationSet=[q.DominationSet i];
            p.DominatedCount=p.DominatedCount+1;
        end
        mayflies(i)=p; mayflies(j)=q;
    end
    if mayflies(i).DominatedCount==0
        F{1}=[F{1} i]; mayflies(i).Rank=1;
    end
end
k=1;
while true
    Q=[];
    for i=F{k}
        p=mayflies(i);
        for j=p.DominationSet
            q=mayflies(j); q.DominatedCount=q.DominatedCount-1;
            if q.DominatedCount==0
                Q=[Q j]; %#ok
                q.Rank=k+1;
            end
            mayflies(j)=q;
        end
    end
    if isempty(Q)
        break;
    end
    F{k+1}=Q; %#ok
    k=k+1;
end
end