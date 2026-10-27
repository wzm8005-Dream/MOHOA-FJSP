function view_saved(root)
% Inspect saved results and redraw selected fronts/Gantt charts only.
T=readtable(fullfile(root,'data','tables','all_summary.csv'),'VariableNamingRule','preserve');
disp(T(strcmp(T.Algorithm,'MOHOA'),:));
runs=readtable(fullfile(root,'data','per_run.csv'),'VariableNamingRule','preserve');
names={'MOHOA','MOPSO','NSGA3','MODA','MOGOA','MOMA','MOEAD'};
labels={'MOHOA','MOPSO','NSGA-III','MODA','MOGOA','MOMA','MOEA/D'};
colors=lines(8);shapes={'*','o','s','^','d','v','p','h'};
for problem={'ZDT2','DTLZ7','Mk10'}
 p=problem{1};algs=names;lab=labels;
 if startsWith(p,'Mk'),algs{end+1}='HSGA_Paper';lab{end+1}='HSGA';end
 ref=load(fullfile(root,'data','reference_fronts',[p '.mat']));
 raw=load(fullfile(root,'data','final_objectives',[p '.mat']));
 span=ref.Upper-ref.Lower;span(span<=1e-12)=1;R=(ref.R-ref.Lower)./span;M=size(R,2);
 figure('Name',[p ' saved fronts'],'Color','w');
 for panel=1:2
  subplot(1,2,panel);hold on;
  if M==2,plot(R(:,1),R(:,2),'k.','MarkerSize',4);else,plot3(R(:,1),R(:,2),R(:,3),'k.','MarkerSize',4);end
  for a=1:numel(algs)
   g=runs(strcmp(runs.Problem,p)&strcmp(runs.Algorithm,algs{a}),:);
   g=sortrows(g,'Repeat');[~,i]=min(abs(g.HV-mean(g.HV)));repeat=g.Repeat(i);
   F=raw.(sprintf('F_%s_r%02d',algs{a},repeat));F=F(study.Pop.front(F),:);Y=(F-ref.Lower)./span;
   if panel==2,Y=Y(all(Y>=-.05&Y<=1.05,2),:);end
   if M==2,plot(Y(:,1),Y(:,2),shapes{a},'Color',colors(a,:),'MarkerSize',6);
   else,plot3(Y(:,1),Y(:,2),Y(:,3),shapes{a},'Color',colors(a,:),'MarkerSize',6);end
  end
  grid on;xlabel('Normalized f_1');ylabel('Normalized f_2');
  if M==3,zlabel('Normalized f_3');view(45,25);end
  if panel==2,xlim([-.05 1.05]);ylim([-.05 1.05]);if M==3,zlim([-.05 1.05]);end;title('Detail view');else,title('Full range');end
  legend([{'Reference'},lab],'Location','best','Interpreter','none');
 end
end
O=readtable(fullfile(root,'data','tables','MK10_operations.csv'),'VariableNamingRule','preserve');
Q=readtable(fullfile(root,'data','tables','MK10_extreme_objectives.csv'),'VariableNamingRule','preserve');
jobColors=lines(max(O.Job));
for c=1:height(Q)
 criterion=Q.Criterion{c};A=O(strcmp(O.Criterion,criterion),:);
 figure('Name',['MK10 ' criterion],'Color','w');hold on;
 for i=1:height(A)
  rectangle('Position',[A.Start(i),A.Machine(i)-.35,A.End(i)-A.Start(i),.7], ...
   'FaceColor',jobColors(A.Job(i),:),'EdgeColor','w');
 end
 xline(Q.Cmax(c),'--k','Cmax');ylim([.5 15.5]);yticks(1:15);grid on;
 xlabel('Time (h)');ylabel('Machine');title(['MK10: ' criterion],'Interpreter','none');
 xlim([0 Q.Cmax(c)*1.04]);
 handles=gobjects(20,1);for j=1:20,handles(j)=plot(nan,nan,'s','MarkerFaceColor',jobColors(j,:),'Color',jobColors(j,:));end
 legend(handles,arrayfun(@(j)sprintf('J%d',j),1:20,'UniformOutput',false),'Location','eastoutside');
end
fprintf('Saved data only. No optimization experiments executed.\n');
end
