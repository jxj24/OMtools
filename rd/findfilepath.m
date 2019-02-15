% findfilepath.m: search macOS filesystem for path of requested file
% usage: [pathname,filename] = findfilepath(searchname)
% where searchname is a text string of the file's name
%
% If there are multiple results, you will be prompted to select the desired
% file from a displayed list.
%
% Currently Mac ONLY, because it uses the OS X shell command 'mdfind'
% Windows probably would use the WHERE /R command

% Written by: Jonathan Jacobs
% January 8 2018

function [pn, fn] = findfilepath(fn, start_dir)

if ~contains(computer,'MAC')
   disp('Sorry, "findfilepath" is Mac ONLY')
   pn=[];
   return
end
pn = [];

switch nargin
	case 0
		help findfilepath
		return
	case 1
		srchstr = ['mdfind -name ' fn];
	case 2
		srchstr = ['mdfind -name ' fn ' -onlyin ' start_dir];
	otherwise
		return
end

[~,res] = system(srchstr);
if isempty(res)
	disp('No matching files found')
	return
end

linends=find(res==10);

if length(linends)==1
   which=1;
   fname{1}=res;
else
   disp('0) Cancel')
   fname=cell(length(linends));
   for i=1:length(linends)
      [fname{i},res]=strtok(res,10); %#ok<STTOK>
      disp([num2str(i),') ' fname{i}])
   end
   disp(' ')
   disp('Use which file? ');
   which=-1;
   while which<0||which>length(linends)
      which = input(' -> ');
   end
   if which==0,disp('Canceled.');return;end
end

res=fname{which};
seps = find(res==filesep);
pn = res(1: seps(end));
fn = res(seps(end)+1:end-1);