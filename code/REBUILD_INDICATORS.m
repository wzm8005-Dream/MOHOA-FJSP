% Read-only scoring of the compact final objective matrices.
root=fileparts(mfilename('fullpath'));addpath(root,fullfile(root,'common'));
data=fullfile(fileparts(root),'data');T=readtable(fullfile(data,'per_run.csv'),'TextType','char');
IGD=zeros(height(T),1);HV=IGD;
for problem=unique(T.Problem,'stable')'
 name=problem{1};Q=load(fullfile(data,'final_objectives',[name '.mat']));R=load(fullfile(data,'reference_fronts',[name '.mat']));
 ids=find(strcmp(T.Problem,name));
 for k=ids'
  key=sprintf('F_%s_r%02d',T.Algorithm{k},T.Repeat(k));F=Q.(key);F=F(study.Pop.front(F),:);
  score=study.Metric.score(F,R.R,R.lo,R.hi,R.ref);IGD(k)=score.IGD;HV(k)=score.HV;
 end
end
assert(max(abs(IGD-T.IGD)./max(1,abs(T.IGD)))<1e-8,'IGD differs from archived scores.');
assert(max(abs(HV-T.HV)./max(1,abs(T.HV)))<1e-8,'HV differs from archived scores.');
T.IGD=IGD;T.HV=HV;writetable(T,fullfile(data,'recomputed_indicators.csv'));
fprintf('Reproduced %d saved-run indicators.\n',height(T));
