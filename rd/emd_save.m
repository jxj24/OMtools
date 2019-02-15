function emd_save

varlist = evalin('base','whos');

candidate = cell(length(varlist),1);

x=0;
for i=1:length(varlist)
   if strcmpi(varlist(i).class, 'emData')
      x=x+1;
      candidate{x} = varlist(i).name;
   end
end

if x == 1
   j=1;
else
   disp('Which eye-movement data structure do you want to save?')
   for i=1:x
      disp( [num2str(i) ': ' char(candidate{i})] )
   end
   j=0;
   while j<1 || j>x
      j=input('--> ');
   end
end

[filename, pathname] = uiputfile('*.mat','Save as:',[char(candidate{j}) '.mat']);
if filename == 0
   disp('Canceled')
else
   disp(['Saved as ' [pathname filename] ])
   savestr = ['save(' ['''' pathname filename ''''] ',' ['''' char(candidate{j}) ''''] ')' ];
   evalin('base', savestr)
end
   