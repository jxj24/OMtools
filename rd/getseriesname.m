function seriesname = getseriesname(shortname)

seriesname = shortname;
if ~isempty(strfind(shortname,'_'))
   seriesname=strtok(shortname,'_');
end

while isdigit(seriesname(end))
   seriesname = seriesname(1:end-1);
end