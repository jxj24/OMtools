% getEMD.m: select EM data structure from base memory.
% usage: EMD = getEMD;

% Written by Jonathan Jacobs
% January 2018 (last mod: 07 January 2018)

function [EMD,emd_info] = getEMD(emd_name)

EMD = [];
% check for emData struct in memory. if only one, assume it.
temp=evalin('base','whos');
cnt=0;
tlen=length(temp);
name=cell(tlen,1);

for i=1:tlen
   if strcmpi(temp(i).class,'emData')
      if nargin==0
         cnt=cnt+1;
         name{cnt}=temp(i).name;
      else
         if strcmpi( strtok(emd_name,'.'),temp(i).name )
            name{1}=temp(i).name;
            cnt=1;
            break
         end
      end
   elseif strcmpi(temp(i).class,'char')

   end
end

switch cnt
   case 0
      disp('No data in memory. You need to load a file using "rd".')
      EMD=[];
      emd_info = [];
      return
   case 1
      EMD = evalin('base',name{1});
      %evalin('base', ['tempEMD=' a{1} ';']);
      if nargin==1
      else
         fprintf('%s selected\r',name{1});
      end
   case num2cell(2:100)
      % can we look at candidate paths and match to existing f_info from
      % datstat GUI window UserData properties?
      winH = findwind('EM Data Manager');  % find emdm
      if ishandle(winH)
         f_info = winH.UserData.f_info;
         for i=1:cnt
            for j=1:length(f_info)
               if strcmpi(name{i},f_info(j).filename)
                  EMD = evalin('base',name{i});
                  if strcmpi(EMD.pathname,f_info(j))
                     % bingo!
                     break
                  else
                     %
                  end
               end %if strcmpi(name
            end
         end %for i
         
      else % prompt for which one
         disp('0) Cancel')
         for i=1:cnt
            disp([num2str(i) ') ' name{i}] )
         end
         which=-1;
         while which<0 || which>cnt
            which=input('Which data do you want to use? ');
         end
         if which==0,disp('Canceled.');return;end
         EMD = evalin('base',name{which});
         %evalin('base', ['tempEMD=' a{which} ';']);
      end
end %switch

emd_info.filename = EMD.filename;
emd_info.pathname = EMD.pathname;
emd_info.chan_names = EMD.chan_names;
emd_info.samp_freq = EMD.samp_freq;
emd_info.numsamps = EMD.numsamps;

end % function getEMD

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function winH = findwind(name)
winH = -1;
ch = get(0,'Children');
for i=1:length(ch)
   if strcmpi(ch(i).Name, name)
      winH = ch(i);
      break
   end
end
end %function
