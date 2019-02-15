function clip_figdata(ax)

if nargin==0, ax=gca; end

xlo = ax.XLim(1);
xhi = ax.XLim(2);
ch = ax.Children;
llist = cell(1,length(ch));
for x=1:length(ch)
   if strcmpi(ch(x).Type,'Line')
      llist{x}=ch(x);
   end
end

for k=1:length(llist)
   xdat = llist{k}.XData;
   datlo = find(xdat<=xlo); %#ok<*MXFND>
   if isempty(datlo),datlo=1;end
   datlo = datlo(end);
   
   dathi = find(xdat>=xhi);
   if isempty(dathi), dathi=length(xdat); end
   dathi = dathi(1);
   
   kept = datlo:dathi;
   temp = xdat(kept);
   llist{k}.XData = [];
   llist{k}.XData = temp;

   ydat = llist{k}.YData;
   if ~isempty(ydat)
      temp = ydat(kept);
      llist{k}.YData = [];
      llist{k}.YData = temp;
   end
   
   zdat = llist{k}.ZData;
   if ~isempty(zdat)
      temp = zdat(kept);
      llist{k}.ZData = [];
      llist{k}.ZData = temp;
   end
end