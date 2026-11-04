function out=history(action,F)
% Save one front per generation only; no evaluation counter or evaluation trace.
persistent fronts
out=[];
switch action
 case 'init',fronts={};
 case 'add',fronts{end+1}=F;
 case 'get',out=fronts;
 otherwise,error('Unknown history action');
end
end
