function result=run_one(s,name,method,probability,seed)
cfg=s.Base;
if ~strcmp(method,'NSGA3_PlatEMO')
 cfg.MutationProbability=probability;
 % Call the unchanged original MOHOA function through its existing runner.
 result=study.run_one(s.Root,cfg,name,'MOHOA',seed);
 result.Algorithm=method;result.Info.MutationProbability=probability;
 result.Info.HikingAngleUnit='radians: tan(theta), theta in integer 0:50';
 assert(all(result.Info.CauchyChildren+result.Info.HikingChildren==cfg.Population));
 if probability==1,assert(all(result.Info.HikingChildren==0));end
else
 oldpath=path;cleanup=onCleanup(@()path(oldpath)); %#ok<NASGU>
 restoredefaultpath;addpath(s.Root,fullfile(s.Root,'common'),s.Home);
 p=study.problem(s.Root,name,cfg);rng(seed,'twister');study.history('init');timer=tic;
 [F,X,Info]=round2.native_nsga3(s.Root,s.Home,p,cfg);
 seconds=toc(timer);history=study.history('get');randomState=rng;
 assert(isreal(F)&&~isempty(F)&&all(isfinite(F),'all'));
 assert(size(X,1)==size(F,1)&&size(X,2)==p.D);
 check=study.evaluate(X,p);
 assert(max(abs(check-F),[],'all')<=1e-8*max(1,max(abs(F),[],'all')),'Objective/decision mismatch.');
 result=struct('Problem',name,'Algorithm',method,'Seed',seed,'Iterations',cfg.Iterations, ...
  'F',F,'X',X,'History',{history},'Info',Info,'Seconds',seconds, ...
  'Definition',p,'Config',cfg,'RNGEnd',randomState);
 if strcmp(p.Suite,'FJSP'),result.ObjectiveOrder={'Cmax','Energy','TotalWorkload'};
 else,result.ObjectiveOrder=arrayfun(@(i)sprintf('f%d',i),1:p.M,'UniformOutput',false);end
 result.Execution=struct('Mode','serial','MATLAB',version,'Computer',computer, ...
  'Host',getenv('COMPUTERNAME'),'Timestamp',datestr(now,30));
end
result.SupplementVersion=s.Version;
end
