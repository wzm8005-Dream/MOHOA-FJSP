function [mayflies, F]=SortSolutions(mayflies)
% Sort Based on Crowding Distance
[~, CD]=sort([mayflies.CrowdingDistance],'descend'); mayflies=mayflies(CD);
[~, SO]=sort([mayflies.Rank]); mayflies=mayflies(SO);
Ranking=[mayflies.Rank];
MxRnks=max(Ranking);
F=cell(MxRnks,1);
for r=1:MxRnks
    F{r}=find(Ranking==r);
end
end