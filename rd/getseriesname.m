function seriesname = getseriesname(shortname)

us=strfind(shortname,'_');

if isempty(us)
	seriesname = shortname;
	return
end

lastus = us(end);
if lastus>1
   if all(isdigit(shortname(lastus+1:end)))
      seriesname=[shortname(1:us(end)) '_'];
   else
      seriesname=shortname;
   end
end

% is this still necessary?
while isdigit(seriesname(end))
   seriesname = seriesname(1:end-1);
end