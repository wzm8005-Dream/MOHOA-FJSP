function result=run_one(root,cfg,name,algorithm,seed)
oldpath=path;
cleanup=onCleanup(@()path(oldpath));
restoredefaultpath;
addpath(root,fullfile(root,'common'));
p=study.problem(root,name,cfg);
kind='functions';if strcmp(p.Suite,'FJSP'),kind='fjsp';end
base=algorithm;if startsWith(algorithm,'MOHOA'),base='MOHOA';end
folder=fullfile(root,'algorithms',kind,base);assert(isfolder(folder),'Algorithm folder missing.');
addpath(folder);
if strcmp(base,'MOEAD')
 vendor=fullfile(root,'vendor','PlatEMO','PlatEMO');
 addpath(fullfile(vendor,'Problems'),fullfile(vendor,'Algorithms'), ...
  fullfile(vendor,'Algorithms','Utility functions'), ...
  fullfile(vendor,'Algorithms','Multi-objective optimization','MOEA-D'));
end
options=struct('NoGPS',false,'Crowding',false, ...
 'MutationProbability',cfg.MutationProbability);
if ismember(algorithm,{'MOHOA_NoGPS','MOHOA_Base'}),options.NoGPS=true;end
if ismember(algorithm,{'MOHOA_NoCauchy','MOHOA_Base'}),options.MutationProbability=0;end
if ismember(algorithm,{'MOHOA_Crowding','MOHOA_Base'}),options.Crowding=true;end
rng(seed,'twister');study.history('init');
entry=str2func([base '_' kind]);timer=tic;
[F,X,Info]=entry(p,cfg,options);
seconds=toc(timer);history=study.history('get');randomState=rng;
assert(isreal(F)&&all(isfinite(F),'all')&&~isempty(F),'Invalid final objectives.');
if size(X,1)~=size(F,1)&&size(X,2)==size(F,1),X=X';end
assert(size(X,1)==size(F,1)&&size(X,2)==p.D,'Invalid decision/objective dimensions.');
assert(numel(history)==cfg.Iterations,'Expected exactly one history entry per generation.');
check=study.evaluate(X,p);
assert(max(abs(check-F),[],'all')<=1e-8*max(1,max(abs(F),[],'all')), ...
 'Returned decisions do not match returned objectives.');
result=struct('Problem',name,'Algorithm',algorithm,'Seed',seed, ...
 'Iterations',cfg.Iterations,'F',F,'X',X,'History',{history}, ...
 'Info',Info,'Seconds',seconds,'Definition',p,'Config',cfg,'RNGEnd',randomState);
if strcmp(kind,'fjsp'),result.ObjectiveOrder={'Cmax','Energy','TotalWorkload'};
else,result.ObjectiveOrder=arrayfun(@(i)sprintf('f%d',i),1:p.M,'UniformOutput',false);end
result.Execution=struct('Mode','serial','MATLAB',version,'Computer',computer, ...
 'Host',getenv('COMPUTERNAME'),'Timestamp',datestr(now,30));
end
