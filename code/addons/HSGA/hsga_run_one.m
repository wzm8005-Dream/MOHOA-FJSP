function result=hsga_run_one(root,cfg,settings,name,seed)
% Same timing/check convention as study.run_one, without editing that file.
oldpath=path;cleanup=onCleanup(@()path(oldpath));
restoredefaultpath;
addpath(root,fullfile(root,'common'),fullfile(root,'addons','HSGA'));
p=study.problem(root,name,cfg);assert(strcmp(p.Suite,'FJSP'));
rng(seed,'twister');study.history('init');timer=tic;
[F,X,Info]=HSGA_fjsp(p,cfg,settings);
seconds=toc(timer);history=study.history('get');randomState=rng;
assert(isreal(F)&&~isempty(F)&&all(isfinite(F),'all'),'Invalid HSGA objectives.');
assert(size(X,1)==size(F,1)&&size(X,2)==p.D,'Invalid HSGA dimensions.');
assert(numel(history)==cfg.Iterations,'Incorrect HSGA history length.');
check=study.evaluate(X,p);
assert(max(abs(check-F),[],'all')<=1e-8*max(1,max(abs(F),[],'all')), ...
 'HSGA decisions and returned objective values do not match.');
result=struct('Problem',name,'Algorithm','HSGA_Paper','Seed',seed, ...
 'Iterations',cfg.Iterations,'F',F,'X',X,'History',{history}, ...
 'Info',Info,'Seconds',seconds,'Definition',p,'Config',cfg,'RNGEnd',randomState);
result.AddonConfig=settings;
result.ObjectiveOrder={'Cmax','Energy','TotalWorkload'};
result.Execution=struct('Mode','serial','MATLAB',version,'Computer',computer, ...
 'Host',getenv('COMPUTERNAME'),'Timestamp',char(datetime('now','Format','yyyyMMdd''T''HHmmss')));
end
