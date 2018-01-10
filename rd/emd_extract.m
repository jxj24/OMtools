function emd_extract(emd) % file_or_var)

global dataname samp_freq

if nargin<1
   % take from structure already in memory
   varlist = evalin('base','whos');
   candidate = cell(length(varlist),1);
   x=0;
   for i=1:length(varlist)
      if strcmpi(varlist(i).class, 'emData')
         x=x+1;
         candidate{x} = varlist(i).name;
      end
   end
   
   if x == 0
      disp('No eye-movement data structures found in memory.')
      disp('Would you like to load a saved one from disk?')
      yorn=input('--> ','s');
      if strcmpi(yorn,'y')
         [fn, pn] = uigetfile('*.mat','Select an eye movement .mat file');
         if fn==0,disp('Canceled.');return;end
         a=load([pn fn]);
         field_name = cell2mat( fieldnames(a) );
         emd = eval([ 'a.' field_name] );
      else
         return
      end
   elseif x==1
      j=1;
   else
      disp('Which eye-movement data do you want to extract?')
      for i=1:x
         disp( [num2str(i) ': ' char(candidate{i})] )
      end
      j=0;
      while j<1 || j>x
         j=input('--> ');
      end
   end
   emd = evalin('base',char(candidate{j}) );
end

dataname = emd.filename;       assignin('base','dataname',dataname);
samp_freq = emd.samp_freq;     assignin('base','samp_freq',samp_freq);

if ~isempty(emd.start_times)
   global start_times
   start_times = emd.start_times;
   assignin('base','start_times',start_times);
end

disp('Channels saved to base workspace: ')

if ~isempty(emd.rh.data)
   global rh; rh=emd.rh.data; assignin('base','rh',rh); disp([sprintf('\b'),' rh']);
end
if ~isempty(emd.lh.data)
   global lh; lh=emd.lh.data; assignin('base','lh',lh); disp([sprintf('\b'),' lh']);
end
if ~isempty(emd.rv.data)
   global rv; rv=emd.rv.data; assignin('base','rv',rv); disp([sprintf('\b'),' rv']);
end
if ~isempty(emd.lv.data)
   global lv; lv=emd.lv.data; assignin('base','lv',lv); disp([sprintf('\b'),' lv']);
end
if ~isempty(emd.rt.data)
   global rt; rt=emd.rt.data; assignin('base','rt',rt); disp([sprintf('\b'),' rt']);
end
if ~isempty(emd.lt.data)
   global lt; lt=emd.lt.data; assignin('base','lt',lt); disp([sprintf('\b'),' lt']);
end
if ~isempty(emd.st.data)
   global st; st=emd.st.data; assignin('base','st',st); disp([sprintf('\b'),' st']);
end
if ~isempty(emd.sv.data)
   global sv; sv=emd.sv.data; assignin('base','sv',sv); disp([sprintf('\b'),' sv']);
end
if ~isempty(emd.ds.data)
   global ds; ds=emd.ds.data; assignin('base','ds',ds); disp([sprintf('\b'),' ds']);
end
if ~isempty(emd.tl.data)
   global tl; tl=emd.tl.data; assignin('base','tl',tl); disp([sprintf('\b'),' tl']);
end
if ~isempty(emd.hh.data)
   global hh; hh=emd.hh.data; assignin('base','hh',hh); disp([sprintf('\b'),' hh']);
end
if ~isempty(emd.hv.data)
   global hv; hv=emd.hv.data; assignin('base','hv',hv); disp([sprintf('\b'),' hv']);
end

% ask to load 'extras' file?