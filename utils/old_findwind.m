% findwind.m: Search open windows by title name.

% Written by:  Jonathan Jacobs
%              September 1997  (last mod: 09/10/97)

function winH = findwind(name)

winH = -1;

ch = get(0,'Children');
if isempty(ch)
   return
end

% check the children for the given string
for ii = 1:length(ch)
   if strcmpi(ch(ii).Name,name)
      winH = ch(ii);
      return
   end
end
