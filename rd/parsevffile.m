function data = parsevffile(data)

fn = data.filename; fn=strtok(fn,'.');
a = load([fn '_extras.mat']);
field_name = cell2mat( fieldnames(a) );
extras = eval([ 'a.' field_name] );
vf = extras.vf;
if isempty(vf)
	return
end
% numvf=length(vf.framenum);

% for i=1:numvf
   data.vframes = vf;
% end %for i
