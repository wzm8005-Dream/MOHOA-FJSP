function [F,X,Info]=MOHOA_fjsp(p,cfg,options)
% Single offspring per parent: Cauchy with probability 0.70, otherwise HOA.
N=cfg.Population;D=p.D;M=p.M;lb=p.Lower;ub=p.Upper;
if nargin<3,options=struct;end
if ~isfield(options,'NoGPS'),options.NoGPS=false;end
if ~isfield(options,'Crowding'),options.Crowding=false;end
if ~isfield(options,'MutationProbability'),options.MutationProbability=cfg.MutationProbability;end
if options.NoGPS,X=lb+rand(N,D).*(ub-lb);else,X=gps_initialization(N,D,ub,lb);end
F=study.evaluate(X,p);[Z,~]=UniformPoint(N,M);ideal=min(F,[],1);
Info=struct('InitialX',X,'InitialF',F,'CauchyChildren',zeros(cfg.Iterations,1), ...
 'HikingChildren',zeros(cfg.Iterations,1),'ActualPopulation',N,'ReferenceDirections',size(Z,1));
for iteration=1:cfg.Iterations
 % Select from the first nondominated front of the current population.
 [front,~]=NDSort(F,1);ids=find(front==1);leader=ids(randi(numel(ids)));
 target=X(leader,:);child=zeros(N,D);
 for i=1:N
  if rand<options.MutationProbability
   r=rand;m=2*sin(r+pi/2);cauchy=tan((rand(1,D)-.5)*pi);
   if rand<rand
    child(i,:)=X(i,:)+cauchy.*(X(i,:)-target);
   else
    child(i,:)=X(i,:)+cauchy.*(target-m.*X(i,:));
   end
   Info.CauchyChildren(iteration)=Info.CauchyChildren(iteration)+1;
  else
   theta=randi([0 50],1,1);s=tan(theta);SF=randi([1 3],1,1);
   velocity=6.*exp(-3.5.*abs(s+.05));
   newVelocity=velocity+rand(1,D).*(target-SF.*X(i,:));
   child(i,:)=X(i,:)+newVelocity;
   Info.HikingChildren(iteration)=Info.HikingChildren(iteration)+1;
  end
  over=child(i,:)>=ub;under=child(i,:)<=lb;
  child(i,:)=(child(i,:).*(~(over+under)))+ub.*over+lb.*under;
 end
 pool=unique([X;child],'rows');poolF=study.evaluate(pool,p);ideal=min([ideal;poolF],[],1);
 if options.Crowding
  ids=study.Pop.select(poolF,N,'crowding',[],[]);X=pool(ids,:);
 else
  X=EnvironmentalSelection(poolF,pool,N,Z,ideal);
 end
 [found,ids]=ismember(X,pool,'rows');assert(all(found));F=poolF(ids,:);
 assert(size(X,1)==N,'Insufficient distinct candidates to maintain population.');
 study.history('add',F);
end
assert(all(Info.CauchyChildren+Info.HikingChildren==N));
end
