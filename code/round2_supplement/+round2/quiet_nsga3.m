function result=quiet_nsga3(s,name,method,probability,seed)
% Display policy only. No change to native operators or numerical fallback.
assert(strcmp(method,'NSGA3_PlatEMO'));
ids={'MATLAB:singularMatrix','MATLAB:nearlySingularMatrix'};
previous=cell(size(ids));
for k=1:numel(ids),previous{k}=warning('query',ids{k});end
cleanup=onCleanup(@()restore_warnings(previous)); %#ok<NASGU>
for k=1:numel(ids),warning('off',ids{k});end
result=round2.run_one(s,name,method,probability,seed);
result.Info.SuppressedWarningIDs=ids;
end
function restore_warnings(previous)
for j=1:numel(previous),warning(previous{j});end
end
