function run(repository,group)
% Public serial launcher. Search implementations remain unchanged.
root=fullfile(repository,'code');addpath(root,fullfile(root,'common'),fullfile(root,'addons','HSGA'));
cfg=config_study();problems=cfg.Problems;algorithms=cfg.Algorithms;
switch group
 case 'functions',problems=problems(~startsWith(problems,'Mk'));
 case 'fjsp',problems=problems(startsWith(problems,'Mk'));
 case 'ablation',algorithms=[{'MOHOA'},cfg.Ablations];
 case 'hsga',problems=problems(startsWith(problems,'Mk'));algorithms={'HSGA_Paper'};
 otherwise,error('Unknown experiment group.');
end
% Keep the exact historical indices, including the removed NSGA-II slot.
slots={'MOHOA','NSGA2','MOPSO','MODA','MOGOA','MOMA','NSGA3','MOEAD', ...
 'MOHOA_NoGPS','MOHOA_NoCauchy','MOHOA_Crowding','MOHOA_Base','HSGA_Paper'};
folder=fullfile(repository,'rerun_results');if ~isfolder(folder),mkdir(folder);end
signature=study.signature(root);addonSignature=hsga_fingerprint(fullfile(root,'addons','HSGA'));
settings=hsga_settings();total=numel(problems)*numel(algorithms)*cfg.Repeats;done=0;
save(fullfile(folder,['configuration_' group '.mat']),'cfg','settings','slots','signature','addonSignature','problems','algorithms');
for pi=1:numel(problems)
 name=problems{pi};pid=sum(double(name).*(1:numel(name)));
 for ai=1:numel(algorithms)
  algorithm=algorithms{ai};index=find(strcmp(algorithm,slots));assert(isscalar(index));
  for repeat=1:cfg.Repeats
   done=done+1;seed=cfg.SeedBase+pid*10000+index*100+repeat;
   file=fullfile(folder,sprintf('%s_%s_r%02d.mat',name,algorithm,repeat));
   if isfile(file)
    s=load(file,'result','signature','addonSignature');
    assert(isfield(s,'signature')&&strcmp(s.signature,signature)&& ...
     isfield(s,'addonSignature')&&strcmp(s.addonSignature,addonSignature), ...
     'Source changed. Use a separate fresh rerun_results folder.');
    assert(strcmp(s.result.Problem,name)&&strcmp(s.result.Algorithm,algorithm)&& ...
     s.result.Seed==seed&&s.result.Repeat==repeat&&isequaln(s.result.Config,cfg), ...
     'Saved task/settings mismatch.');
    fprintf('[%d/%d] Existing %s %s repeat=%d skipped.\n',done,total,name,algorithm,repeat);continue;
   end
   fprintf('[%d/%d] %s %s repeat=%d seed=%d\n',done,total,name,algorithm,repeat,seed);
   if strcmp(algorithm,'HSGA_Paper')
    result=hsga_run_one(root,cfg,settings,name,seed);
   else
    result=study.run_one(root,cfg,name,algorithm,seed);
   end
   result.Repeat=repeat;tmp=[file '.partial'];
   save(tmp,'result','signature','addonSignature','-v7.3');
   assert(~isfile(file),'Another process has saved this task.');
   [ok,msg]=movefile(tmp,file);assert(ok,'%s',msg);
   fprintf('  Saved %.2f s (%.5f s/iteration).\n',result.Seconds,result.Seconds/cfg.Iterations);
  end
 end
end
fprintf('Completed. Fresh runs: %s\nArchived paper data remain in data/.\n',folder);
end
