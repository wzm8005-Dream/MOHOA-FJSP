function [F,X,Info]=HSGA_fjsp(p,cfg,s)
% HSGA_Paper: independent paper-based reproduction, adapted to this study.
% Hao, Zou & Liang, C&IE 200 (2025) 110829.
% Not author code and not a claim of numerical equivalence to that code.
% Discrete OS/MS operators remain discrete. The continuous vector is ONLY a
% lossless adapter to the existing common decoder/evaluator and result format.
if nargin<3,s=hsga_settings();end
assert(strcmp(p.Suite,'FJSP')&&p.M==3,'HSGA_Paper is FJSP-only.');
N=cfg.Population;G=cfg.Iterations;L=sum(p.operaNumVec);
assert(N>=2&&G>=1&&p.D==2*L,'Invalid HSGA problem dimensions.');
assert(s.SparseParentCount==1&&s.NeighborhoodPasses==1, ...
 'This documented reproduction uses one sparse parent and one neighborhood pass.');
model=make_model(p,L);
[OS,MS,counts]=initialize_population(model,N,s);
[F,X]=evaluate_native(OS,MS,p,model);
Info=struct('Implementation','Independent paper-based adaptation; not author code', ...
 'PaperDOI',s.PaperDOI,'Parameters',s,'ActualPopulation',N, ...
 'ObjectiveOrder',{{'Cmax','Energy','TotalWorkload'}}, ...
 'InitialX',X,'InitialF',F,'InitializationCounts_GS_LS_RS',counts, ...
 'CrossoverProbability',zeros(G,1),'MutationProbability',zeros(G,1), ...
 'ClusterSSE',zeros(G,1),'MinimumDensity',zeros(G,1), ...
 'NeighborhoodCandidates',zeros(G,1));
for generation=1:G
 pc=s.CrossoverMax-generation/G*(s.CrossoverMax-s.CrossoverMin);
 pm=s.MutationMax-generation/G*(s.MutationMax-s.MutationMin);
 % Algorithm 3 line 5: select parents from different decision-space clusters.
 [labels,sse]=cluster_population([OS,MS],s);
 parentIds=cluster_mating(labels,N);
 parentOS=OS(parentIds,:);parentMS=MS(parentIds,:);parentF=F(parentIds,:);
 % Algorithm 3 line 6: resolve the self-reference by filtering P'_i (see text).
 [sparse,density]=sparse_parent(parentF,s.DensityRadius);
 neighborOS=repmat(parentOS(sparse,:),3,1);
 neighborMS=repmat(parentMS(sparse,:),3,1);
 for strategy=1:3
  neighborOS(strategy,:)=os_neighborhood(neighborOS(strategy,:),strategy);
  neighborMS(strategy,:)=shortest_time_mutation(neighborMS(strategy,:),model,s.MutationGeneCount);
 end
 [neighborF,~]=evaluate_native(neighborOS,neighborMS,p,model);
 keep=study.Pop.front(neighborF);
 % Algorithm 3 lines 7-8: combine P'_i and the neighborhood front, then truncate.
 poolOS=[parentOS;neighborOS(keep,:)];poolMS=[parentMS;neighborMS(keep,:)];
 poolF=[parentF;neighborF(keep,:)];
 selected=study.Pop.select(poolF,N,'crowding',[],[]);
 OS=poolOS(selected,:);MS=poolMS(selected,:);
 [OS,MS]=crossover_mutation(OS,MS,pc,pm,model,s);
 [F,~]=evaluate_native(OS,MS,p,model);
 % No added external archive, post-crossover elitism, or extra local search.
 study.history('add',F);
 Info.CrossoverProbability(generation)=pc;
 Info.MutationProbability(generation)=pm;
 Info.ClusterSSE(generation)=sse;
 Info.MinimumDensity(generation)=density;
 Info.NeighborhoodCandidates(generation)=size(neighborF,1);
end
Info.FinalPopulationF=F;
front=study.Pop.front(F);F=F(front,:);
Info.FinalOS=OS(front,:);Info.FinalMS=MS(front,:);
X=to_common_vector(Info.FinalOS,Info.FinalMS,p,model);
end

function model=make_model(p,L)
model.L=L;model.J=p.jobNum;model.M=p.MachineNum;
model.Operations=p.operaNumVec;model.Offset=[0,cumsum(p.operaNumVec)];
model.BaseOS=repelem(1:p.jobNum,p.operaNumVec);
model.Candidates=cell(1,L);model.Times=cell(1,L);model.Shortest=cell(1,L);
model.Counts=zeros(1,L);
for j=1:p.jobNum
 for h=1:p.operaNumVec(j)
  q=model.Offset(j)+h;c=p.candidateMachine{j,h};t=p.jobInfo{j}(h,c);
  model.Candidates{q}=c;model.Times{q}=t;model.Counts(q)=numel(c);
  model.Shortest{q}=find(t==min(t));
 end
end
assert(all(model.Counts>=1),'An operation has no eligible machine.');
assert(all(p.Lower==-p.jobNum)&&all(p.Upper==p.jobNum), ...
 'The lossless adapter expects the original FJSP bounds [-n,n].');
end

function [OS,MS,counts]=initialize_population(model,N,s)
weights=s.InitialWeights/sum(s.InitialWeights);
raw=N*weights;counts=floor(raw);[~,order]=sort(raw-counts,'descend');
for k=1:N-sum(counts),counts(order(k))=counts(order(k))+1;end
types=repelem(1:3,counts);types=types(randperm(N));
OS=zeros(N,model.L);MS=zeros(N,model.L);
for i=1:N
 OS(i,:)=model.BaseOS(randperm(model.L));
 if types(i)==3
  for q=1:model.L,MS(i,q)=randi(model.Counts(q));end
 else
  load=zeros(1,model.M);
  if types(i)==1,jobs=randperm(model.J);else,jobs=1:model.J;end
  for j=jobs
   if types(i)==2,load(:)=0;end
   for h=1:model.Operations(j)
    q=model.Offset(j)+h;c=model.Candidates{q};t=model.Times{q};
    score=load(c)+t;best=find(score==min(score));pick=best(randi(numel(best)));
    MS(i,q)=pick;load(c(pick))=load(c(pick))+t(pick);
   end
  end
 end
end
end

function [F,X]=evaluate_native(OS,MS,p,model)
X=to_common_vector(OS,MS,p,model);F=study.evaluate(X,p);
end

function X=to_common_vector(OS,MS,p,model)
% The common decoder applies INVERSE ranks to BaseOS, not a sorted-key order.
% Assign disjoint ranks from each job's block in BaseOS to its occurrences.
N=size(OS,1);L=model.L;ranks=zeros(N,L);
for j=1:model.J
 mask=OS==j;occurrence=cumsum(mask,2);
 assert(all(sum(mask,2)==model.Operations(j)),'Invalid OS job multiplicity.');
 ranks(mask)=model.Offset(j)+occurrence(mask);
end
assert(all(MS>=1 & MS<=model.Counts,'all')&&all(MS==round(MS),'all'), ...
 'Invalid machine-selection index.');
osKeys=-p.jobNum+2*p.jobNum*(ranks-.5)/L;
msKeys=zeros(N,L);variable=model.Counts>1;
msKeys(:,variable)=-p.jobNum+2*p.jobNum*(MS(:,variable)-1)./(model.Counts(variable)-1);
X=[osKeys,msKeys];
end

function [bestLabels,bestSSE]=cluster_population(genotypes,s)
N=size(genotypes,1);K=min(s.Clusters,N);
assert(K>=2,'Cross-cluster mating requires at least two clusters.');
low=min(genotypes,[],1);span=max(genotypes,[],1)-low;span(span==0)=1;
Y=(genotypes-low)./span;bestSSE=inf;bestLabels=[];
for rep=1:s.KMeansRestarts
 centers=zeros(K,size(Y,2));chosen=false(N,1);id=randi(N);
 centers(1,:)=Y(id,:);chosen(id)=true;
 for k=2:K
  d=min(distance_squared(Y,centers(1:k-1,:)),[],2);d(chosen)=0;
  if sum(d)>0
   id=find(cumsum(d)>rand*sum(d),1);
  else
   choices=find(~chosen);id=choices(randi(numel(choices)));
  end
  centers(k,:)=Y(id,:);chosen(id)=true;
 end
 labels=zeros(N,1);
 for iteration=1:s.KMeansMaxIterations
  distances=distance_squared(Y,centers);[nearest,newLabels]=min(distances,[],2);
  % Singleton repair is only a numerical convention for empty clusters.
  for k=1:K
   if ~any(newLabels==k)
    sizes=accumarray(newLabels,1,[K,1]);eligible=sizes(newLabels)>1;
    work=nearest;work(~eligible)=-inf;[~,id]=max(work);
    assert(isfinite(work(id)),'Cannot repair empty cluster.');
    newLabels(id)=k;nearest(id)=0;
   end
  end
  for k=1:K,centers(k,:)=mean(Y(newLabels==k,:),1);end
  same=isequal(newLabels,labels);labels=newLabels;if same,break;end
 end
 residual=Y-centers(labels,:);sse=sum(residual.^2,'all');
 if sse<bestSSE,bestSSE=sse;bestLabels=labels;end
end
end

function d=distance_squared(A,B)
d=max(0,sum(A.^2,2)+sum(B.^2,2)'-2*(A*B'));
end

function ids=cluster_mating(labels,N)
groups=unique(labels)';ids=zeros(N,1);next=1;
while next<=N
 pair=groups(randperm(numel(groups),2));
 for k=1:2
  members=find(labels==pair(k));ids(next)=members(randi(numel(members)));
  next=next+1;if next>N,break;end
 end
end
end

function [id,value]=sparse_parent(F,radius)
low=min(F,[],1);span=max(F,[],1)-low;span(span==0)=1;
Y=(F-low)./span;d2=distance_squared(Y,Y);inside=d2<=radius^2;
inside(1:size(F,1)+1:end)=false;
density=sum(inside,2)/max(1,size(F,1)-1);value=min(density);
ids=find(density==value);id=ids(randi(numel(ids)));
end

function y=os_neighborhood(x,strategy)
y=x;if numel(x)<2,return;end
points=randperm(numel(x),2);a=points(1);b=points(2);
switch strategy
 case 1 % DSS: swap.
  y([a b])=y([b a]);
 case 2 % EIS: move the gene at a immediately after the gene at b.
  value=y(a);y(a)=[];if a<b,b=b-1;end
  y=[y(1:b),value,y(b+1:end)];
 case 3 % SRS: reverse the inclusive interval.
  points=sort(points);y(points(1):points(2))=fliplr(y(points(1):points(2)));
 otherwise,error('Unknown HSGA neighborhood.');
end
end

function y=shortest_time_mutation(x,model,count)
y=x;points=randperm(model.L,min(count,model.L));
for q=points
 shortest=model.Shortest{q};y(q)=shortest(randi(numel(shortest)));
end
end

function [OS,MS]=crossover_mutation(OS,MS,pc,pm,model,s)
N=size(OS,1);order=randperm(N);
for k=1:2:N-1
 a=order(k);b=order(k+1);
 if rand<pc
  jobs=randperm(model.J);split=randi(model.J-1);subset=jobs(1:split);
  if rand<s.POXProbability
   OSa=order_child(OS(a,:),OS(b,:),subset);
   OSb=order_child(OS(b,:),OS(a,:),subset);
  else
   complement=jobs(split+1:end);
   OSa=order_child(OS(a,:),OS(b,:),subset);
   OSb=order_child(OS(b,:),OS(a,:),complement);
  end
  OS(a,:)=OSa;OS(b,:)=OSb;
  swap=rand(1,model.L)<.5;temp=MS(a,swap);MS(a,swap)=MS(b,swap);MS(b,swap)=temp;
 end
end
for i=1:N
 if rand<pm
  points=randperm(model.L,min(s.MutationGeneCount,model.L));
  if numel(points)>1,OS(i,points)=OS(i,points([end,1:end-1]));end
  MS(i,:)=shortest_time_mutation(MS(i,:),model,s.MutationGeneCount);
 end
end
end

function child=order_child(keepParent,fillParent,subset)
mask=ismember(keepParent,subset);child=zeros(size(keepParent));
child(mask)=keepParent(mask);child(~mask)=fillParent(~ismember(fillParent,subset));
end
