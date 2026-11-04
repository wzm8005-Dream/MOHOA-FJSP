function R=reference(name,M,pool)
% Dense analytic fronts for benchmark functions; empirical union front for MK.
if startsWith(name,'Mk'),R=pool(study.Pop.front(pool),:);return;end
n=2001;t=linspace(0,1,n)';
switch name
 case {'ZDT1','ZDT4'},R=[t,1-sqrt(t)];
 case 'ZDT2',R=[t,1-t.^2];
 case 'ZDT3'
  t=linspace(0,1,10001)';R=[t,1-sqrt(t)-t.*sin(10*pi*t)];R=R(study.Pop.front(R),:);
 case 'ZDT6',t=linspace(.2807753191,1,n)';R=[t,1-t.^2];
 case {'DTLZ1','DTLZ2','DTLZ3','DTLZ4'}
  assert(M==3);H=50;R=[];
  for i=0:H,for j=0:H-i,R(end+1,:)=[i,j,H-i-j]/H;end,end
  if strcmp(name,'DTLZ1'),R=R/2;else,R=R./sqrt(sum(R.^2,2));end
 case {'DTLZ5','DTLZ6'}
  theta=linspace(0,pi/2,n)';R=[cos(theta)/sqrt(2),cos(theta)/sqrt(2),sin(theta)];
 case 'DTLZ7'
  u=[linspace(0,.251412,50),linspace(.631627,.859401,50)];[x,y]=ndgrid(u,u);
  R=[x(:),y(:),6-x(:).*(1+sin(3*pi*x(:)))-y(:).*(1+sin(3*pi*y(:)))];
  R=R(study.Pop.front(R),:);
 otherwise,error('No reference definition for %s',name);
end
R=unique(R,'rows');
end
