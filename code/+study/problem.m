function p=problem(root,name,cfg)
p.Name=name;p.Energy=cfg.Energy;
if startsWith(name,'ZDT')
 i=find(strcmp(name,{'ZDT1','ZDT2','ZDT3','ZDT4','ZDT6'}));[~,p.D,p.M,p.Lower,p.Upper]=GetProblemInfoZDT(i);p.Suite='Functions';
elseif startsWith(name,'DTLZ')
 [~,p.D,p.M,p.Lower,p.Upper]=GetProblemInfoDTLZ(str2double(name(5:end)));p.Suite='Functions';
else
 p.Suite='FJSP';fid=fopen(fullfile(root,'data','Brandimarte_Data',[name '.fjs']),'r');assert(fid>=0);clean=onCleanup(@()fclose(fid));
 head=sscanf(fgetl(fid),'%f');p.MachineNum=head(2);p.jobNum=head(1);p.jobInfo=cell(1,p.jobNum);p.operaNumVec=zeros(1,p.jobNum);p.candidateMachine={};
 for j=1:p.jobNum
  v=sscanf(fgetl(fid),'%f');p.operaNumVec(j)=v(1);k=2;times=inf(v(1),p.MachineNum);
  for o=1:v(1)
   n=v(k);k=k+1;for z=1:n,times(o,v(k))=v(k+1);k=k+2;end
   p.candidateMachine{j,o}=find(isfinite(times(o,:)));
  end
  p.jobInfo{j}=times;
 end
 p.D=2*sum(p.operaNumVec);p.M=3;p.Lower=-p.jobNum*ones(1,p.D);p.Upper=p.jobNum*ones(1,p.D);
end
end
