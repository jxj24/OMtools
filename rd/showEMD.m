% showEMD.m: select EM data structure from base memory.
% usage: EMD = getEMD;

% Written by Jonathan Jacobs
% January 2018 (last mod: 07 January 2018)

function showEMD

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
      disp('No data in memory. Use "rd" to read in data.')
   otherwise
      for i=1:cnt
         disp([num2str(i) ') ' a{i}] )
      end
end %switch
