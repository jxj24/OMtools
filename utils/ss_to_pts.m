function [re, le] = ss_to_pts(fixmat,emData)

eye = fixmat.eye;
start = fixmat.start;
stop = fixmat.end;
samp_freq = emData.samp_freq;
start_times = emData.start_times;
datalen = emData.numsamps;

re.ptslist = NaN(datalen,1);
le.ptslist = NaN(datalen,1);
%re.start = zeros(length(start),1);
%le.start = re.start;
%re.stop = re.start;
%le.stop = le.start;
r=0;l=0;

for i = 1:length(start)
   if strcmpi(eye{i},'r')
      r=r+1;
      re.start(r) = fix((start(i)-start_times)* samp_freq/1000)+1;
      re.stop(r)  = fix((stop(i)-start_times)* samp_freq/1000)+1;
      re.ptslist( re.start(r) : re.stop(r) ) = 1;
   end
   if strcmpi(eye{i},'l')
      l=l+1;
      le.start(l) = fix((start(i)-start_times)* samp_freq/1000)+1;
      le.stop(l)  = fix((stop(i)-start_times)* samp_freq/1000)+1;
      le.ptslist( le.start(l) : le.stop(l) ) = 1;
   end
end