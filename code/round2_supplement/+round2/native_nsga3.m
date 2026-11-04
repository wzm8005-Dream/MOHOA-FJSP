function [F,X,Info]=native_nsga3(root,home,p,cfg)
% Call the bundled native PlatEMO NSGAIII class without editing its source.
v=fullfile(root,'vendor','PlatEMO','PlatEMO');
folders={fullfile(v,'Problems'),fullfile(v,'Algorithms'), ...
 fullfile(v,'Algorithms','Utility functions'),fullfile(home,'common'), ...
 fullfile(v,'Algorithms','Multi-objective optimization','NSGA-III')};
for j=1:numel(folders),assert(isfolder(folders{j}));addpath(folders{j},'-begin');end
for name={'NSGAIII','OperatorGA','UniformPoint','NDSort','TournamentSelection','EnvironmentalSelection'}
 f=which(name{1});assert(startsWith(f,[v filesep]),'Wrong function on path: %s -> %s',name{1},f);
end
assert(exist('unifrnd','file')==2&&exist('pdist2','file')==2, ...
 'Native PlatEMO requires Statistics and Machine Learning Toolbox (unifrnd, pdist2).');
global ROUND2_PROBLEM_DEFINITION
ROUND2_PROBLEM_DEFINITION=p;
problem=Round2Problem('N',cfg.Population,'maxFE',1e12);
[~,nativeN]=UniformPoint(cfg.Population,p.M);
% Native OperatorGA creates 2*floor(N/2) offspring, including when N is odd.
% This termination translation gives exactly cfg.Iterations full generations.
offspringN=2*floor(nativeN/2);
problem.maxFE=nativeN+cfg.Iterations*offspringN;
algorithm=NSGAIII('save',cfg.Iterations+1,'outputFcn',@snapshot);
algorithm.Solve(problem);
last=algorithm.result{end,2};F=last.objs;X=last.decs;
h=study.history('get');assert(numel(h)==cfg.Iterations,'Native NSGA-III generation count mismatch.');
assert(problem.N==nativeN,'Unexpected native population size.');
Info=struct('Implementation','Bundled unmodified PlatEMO NSGAIII', ...
 'ActualPopulation',problem.N,'RequestedPopulation',cfg.Population, ...
 'CompletedGenerations',numel(h),'OffspringPerGeneration',offspringN, ...
 'SBXProbability',1,'SBXDistributionIndex',20, ...
 'PolynomialMutationExpectedVariables',1,'PolynomialMutationPerVariable',1/p.D, ...
 'PolynomialMutationDistributionIndex',20,'ReferenceDirections','native UniformPoint default', ...
 'NSGAIIISource',which('NSGAIII'),'OperatorSource',which('OperatorGA'));
ROUND2_PROBLEM_DEFINITION=[];
 function snapshot(a,pro)
  if pro.FE>nativeN,study.history('add',a.result{end,2}.objs);end
 end
end
