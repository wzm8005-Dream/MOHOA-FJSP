classdef Round2Problem < PROBLEM
% Interface only: unchanged shared objective evaluator and scheduling decoder.
properties
 Definition
end
methods
 function Setting(obj)
  global ROUND2_PROBLEM_DEFINITION
  obj.Definition=ROUND2_PROBLEM_DEFINITION;
  obj.M=obj.Definition.M;obj.D=obj.Definition.D;
  obj.lower=obj.Definition.Lower;obj.upper=obj.Definition.Upper;
  obj.encoding=ones(1,obj.D);
 end
 function F=CalObj(obj,X),F=study.evaluate(X,obj.Definition);end
 function R=GetOptimum(obj,~),R=zeros(1,obj.M);end
 function R=GetPF(~),R=[];end
end
end
