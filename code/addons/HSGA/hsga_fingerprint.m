function value=hsga_fingerprint(folder)
% Add-on fingerprint. The original study.signature is deliberately unchanged.
files=dir(fullfile(folder,'**','*.m'));
names=arrayfun(@(f)fullfile(f.folder,f.name),files,'UniformOutput',false);
names=sort(names);md=java.security.MessageDigest.getInstance('SHA-256');
for k=1:numel(names)
 relative=names{k}(numel(folder)+2:end);relative=strrep(relative,'\','/');
 md.update(typecast(uint8(unicode2native(relative,'UTF-8')),'int8'));
 md.update(int8(0));
 fid=fopen(names{k},'rb');assert(fid>=0,'Cannot read add-on source.');
 b=fread(fid,Inf,'*uint8');fclose(fid);
 if ~isempty(b),md.update(typecast(b(:),'int8'));end
 md.update(int8(0));
end
value=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
