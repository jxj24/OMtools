% findfilepath.m: search macOS filesystem for path of requested file
% usage: pn = findfilepath(fn)
% where fn is a text string of the file's name

% Written by: Jonathan Jacobs
% January 2018

function pn = findfilepath(fn)

if isempty(fn),return;end

srchstr = ['mdfind -name ' fn];

[~,res] = system(srchstr);
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
seps = find(res=='/');
pn = res(1: seps(end));
