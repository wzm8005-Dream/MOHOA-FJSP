function value=signature(root)
% Freeze executable model/algorithm code; output files and documentation excluded.
files=[dir(fullfile(root,'*.m'));dir(fullfile(root,'algorithms','**','*.m'));dir(fullfile(root,'common','**','*.m'));dir(fullfile(root,'+study','*.m'));dir(fullfile(root,'vendor','**','*.m'));dir(fullfile(root,'data','**','*.fjs'))];
names=arrayfun(@(f)fullfile(f.folder,f.name),files,'UniformOutput',false);names=sort(names);
md=java.security.MessageDigest.getInstance('SHA-256');
for i=1:numel(names)
 fid=fopen(names{i},'rb');assert(fid>=0);b=fread(fid,Inf,'*uint8');fclose(fid);
 if ~isempty(b),md.update(typecast(b(:),'int8'));end
end
value=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
