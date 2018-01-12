% getEMD.m: select EM data structure from base memory.
% usage: EMD = getEMD;

% Written by Jonathan Jacobs
% January 2018 (last mod: 07 January 2018)

function EMD = getEMD

% check for emData struct in memory. if only one, assume it.
temp=evalin('base','whos');
cnt=0;
tlen=length(temp);
a=cell(tlen,1);
for i=1:tlen
   if strcmpi(temp(i).class,'emData')
      cnt=cnt+1;
      a{cnt}=temp(i).name;
   end
end

switch cnt
   case 0
      disp('No data in memory. You need to load a file using "rd".')
      return
   case 1
      EMD = evalin('base', a{1});
      fprintf('%s selected\r',a{1});
   case num2cell(2:100)
      % prompt for which one
      disp('0) Cancel')
      for i=1:cnt
         disp([num2str(i) ') ' a{i}] )
      end
      which=-1;
      while which<0 || which>cnt
         which=input('Which data do you want to use? ');
      end
      if which==0,disp('Canceled.');return;end
      EMD = evalin('base', a{which});
end %switch
