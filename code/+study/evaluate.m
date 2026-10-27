function F=evaluate(X,p)
if strcmp(p.Suite,'Functions'),F=getMOFcn(p.Name,X,p.M);else
 F=zeros(size(X,1),3);
 for i=1:size(X,1)
  f=fitness(X(i,:),p.MachineNum,p.jobNum,p.jobInfo,p.operaNumVec,p.candidateMachine,p.Energy);F(i,:)=f{1};
 end
end
end
