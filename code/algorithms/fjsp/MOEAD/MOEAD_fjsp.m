function [F,X,Info]=MOEAD_fjsp(p,cfg,options)
% Native PlatEMO MOEA/D; weight generation, PBI and search operators unchanged.
global STUDY_PROBLEM_DEFINITION
STUDY_PROBLEM_DEFINITION=p;
problem=StudyProblem('N',cfg.Population,'maxFE',1e12);
[~,actualN]=UniformPoint(cfg.Population,p.M);
% PlatEMO internally terminates using its native counter; not exported as data.
problem.maxFE=actualN*(cfg.Iterations+1);
algorithm=MOEAD('save',cfg.Iterations+1,'outputFcn',@snapshot);
algorithm.Solve(problem);
last=algorithm.result{end,2};F=last.objs;X=last.decs;
Info=struct('ActualPopulation',problem.N,'Aggregation','native default PBI');
end
function snapshot(algorithm,problem)
% First callback is initialization; following callbacks are completed generations.
if problem.FE>problem.N
 study.history('add',algorithm.result{end,2}.objs);
end
end
