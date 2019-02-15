% emd_extract: extract data from emData structure and place into base workspace

% written by: Jonathan Jacobs
% January 2017 - January 2019

% 01/25/19: Explicitly write empty data arrays to base if no valid data

function emd_extract(emd_name)

global dataname samp_freq

if nargin==0,emd_name='';end

% take from structure already in memory
varlist = evalin('base','whos');
candidate = cell(length(varlist),1);
x=0;
for i=1:length(varlist)
   if strcmpi(varlist(i).class, 'emData')
      x=x+1;
      candidate{x} = varlist(i).name;      
      if strcmpi(emd_name,varlist(i).name)
         break
      end      
   end
end

if x == 0
   disp('No eye-movement data structures found in memory.')
   disp('Would you like to load a saved one from disk?')
   commandwindow
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
   emd = evalin('base',char(candidate{1}) );
else
   curr_name = strtok(emd_name,'.');
   match=0;
   for i=1:x
      if strcmpi(curr_name,char(candidate{i}))
         match=i;
         break
      end
   end
   if ~match
      for i=1:x
         disp( [num2str(i) ': ' char(candidate{i})] )
      end
      disp('Which eye-movement data do you want to extract?')
      while match<1 || match>x
         commandwindow
         match=input('--> ');
      end
   end
   emd = evalin('base',char(candidate{match}) );
end

digdata   = emd.digdata;   assignin('base','digdata'  ,digdata);
dataname  = emd.filename;  assignin('base','dataname' ,dataname);
samp_freq = emd.samp_freq; assignin('base','samp_freq',samp_freq);
numsamps  = emd.numsamps;  
t = (1:numsamps)/samp_freq;assignin('base','t',t');

if ~isempty(emd.start_times)
   global start_times %#ok<*TLEV>
   start_times = emd.start_times;
   assignin('base','start_times',start_times);
end

disp([emd_name ': Channels saved to base workspace: '])

if ~isempty(emd.rh.pos) && ~all(isnan(emd.rh.pos))
   global rh; global rhv;
   rh =emd.rh.pos; 
   rhv=d2pt(emd.rh.pos,3,samp_freq);
   disp([sprintf('\b'),' rh']);
   assignin('base','rh',rh);
   assignin('base','rhv',rhv);
else
   clear global rh rhv
end

if ~isempty(emd.lh.pos) && ~all(isnan(emd.lh.pos))
   global lh; global lhv;
   lh =emd.lh.pos;
   lhv=d2pt(emd.lh.pos,3,samp_freq);
   disp([sprintf('\b'),' lh']);
   assignin('base','lh',lh);
   assignin('base','lhv',lhv);
else
   clear global lh lhv
end

if ~isempty(emd.rv.pos) && ~all(isnan(emd.rv.pos))
   global rv; global rvv;
   rv =emd.rv.pos; 
   rvv=d2pt(emd.rv.pos,3,samp_freq);
   disp([sprintf('\b'),' rv']);
   assignin('base','rv',rv);
   assignin('base','rvv',rvv);
else
   clear global rv rvv
end

if ~isempty(emd.lv.pos) && ~all(isnan(emd.lv.pos))
   global lv; global lvv;
   lv =emd.lv.pos;
   lvv=d2pt(emd.lv.pos,3,samp_freq);
   disp([sprintf('\b'),' lv']);
   assignin('base','lv',lv);
   assignin('base','lvv',lvv);
else
   clear global lv lvv
end

if ~isempty(emd.rt.pos) && ~all(isnan(emd.rt.pos))
   global rt; global rtv;
   rt =emd.rh.pos;
   rtv=d2pt(emd.rt.pos,3,samp_freq);
   disp([sprintf('\b'),' rt']);
   assignin('base','rt',rt);
   assignin('base','rtv',rtv);
else
   clear global rt rtv
end

if ~isempty(emd.lt.pos) && ~all(isnan(emd.lt.pos))
   global lt; global ltv;
   lt =emd.lh.pos;
   ltv=d2pt(emd.lt.pos,3,samp_freq);
   disp([sprintf('\b'),' lt']);
   assignin('base','lt',lt);
   assignin('base','ltv',ltv);
else
   clear global lt ltv
end

if ~isempty(emd.st.pos) && ~all(isnan(emd.st.pos))
global st; 
   st=emd.st.pos; 
   disp([sprintf('\b'),' st']);
assignin('base','st',st);
else
   clear global st
end

if ~isempty(emd.sv.pos) && ~all(isnan(emd.sv.pos))
   global sv;
   sv=emd.sv.pos; 
   disp([sprintf('\b'),' sv']);
   assignin('base','sv',sv);
else
   clear global sv
end

if ~isempty(emd.ds.pos) && ~all(isnan(emd.ds.pos))
   global ds
   ds=emd.ds.pos; 
   disp([sprintf('\b'),' ds']);
   assignin('base','ds',ds);
else
   clear global ds
end

if ~isempty(emd.tl.pos) && ~all(isnan(emd.tl.pos))
   global tl;
   tl=emd.tl.pos; 
   disp([sprintf('\b'),' tl']);
   assignin('base','tl',tl);
else
   clear global tl
end

if ~isempty(emd.hh.pos) && ~all(isnan(emd.hh.pos))
   global hh;
   hh=emd.hh.pos; 
   disp([sprintf('\b'),' hh']);
   assignin('base','hh',hh);
else
   clear global hh;
end

if ~isempty(emd.hv.pos) && ~all(isnan(emd.hv.pos))
   global hv
   hv=emd.hv.pos; 
   disp([sprintf('\b'),' hv']);
   assignin('base','hv',hv);
else
   clear global hv
end
