classdef StudyProblem < PROBLEM
properties
 Definition
end
methods
 function Setting(obj)
  global STUDY_PROBLEM_DEFINITION
  obj.Definition=STUDY_PROBLEM_DEFINITION;
  obj.M=obj.Definition.M;obj.D=obj.Definition.D;
  obj.lower=obj.Definition.Lower;obj.upper=obj.Definition.Upper;obj.encoding=ones(1,obj.D);
 end
 function F=CalObj(obj,X),F=study.evaluate(X,obj.Definition);end
 function R=GetOptimum(obj,N),R=zeros(1,obj.M);end
 function R=GetPF(obj),R=[];end
end
end
