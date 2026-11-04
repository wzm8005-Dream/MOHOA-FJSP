% Click Run in MATLAB. This executes ONE saved-study configuration.
root=fileparts(mfilename('fullpath'));
addpath(root,fullfile(root,'common'),fullfile(root,'round2_supplement'),fullfile(root,'addons','HSGA'));
problem='Mk01';algorithm='MOHOA';repeat=1;
cfg=config_study();T=readtable(fullfile(fileparts(root),'data','per_run.csv'),'TextType','char');
ix=find(strcmp(T.Problem,problem)&strcmp(T.Algorithm,algorithm)&T.Repeat==repeat);
assert(numel(ix)==1,'Choose an algorithm/problem/repeat present in data/per_run.csv.');seed=T.Seed(ix);
if strcmp(algorithm,'NSGA3_PlatEMO')||strcmp(algorithm,'MOHOA_CauchyOnly')||startsWith(algorithm,'MOHOA_p')
 s=struct('Root',root,'Home',fullfile(root,'round2_supplement'),'Base',cfg,'Version','paper-round2');
 probability=NaN;
 if strcmp(algorithm,'MOHOA_CauchyOnly'),probability=1;
 elseif startsWith(algorithm,'MOHOA_p'),probability=str2double(algorithm(end-2:end))/100;end
 if strcmp(algorithm,'NSGA3_PlatEMO'),result=round2.quiet_nsga3(s,problem,algorithm,probability,seed);
 else,result=round2.run_one(s,problem,algorithm,probability,seed);end
elseif strcmp(algorithm,'HSGA_Paper')
 result=hsga_run_one(root,cfg,hsga_settings(),problem,seed);
else
 result=study.run_one(root,cfg,problem,algorithm,seed);
end
result.Repeat=repeat;save(fullfile(root,'example_result.mat'),'result','-v7.3');
fprintf('Example saved: %s, %s, repeat %d\n',problem,algorithm,repeat);
