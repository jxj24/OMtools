% "t" is specified in msec.

function s = time2samp(t)

global samp_freq

if isempty(samp_freq)
   samp_freq = input('Enter sampling frequency: ');
end

s = t/1000 * samp_freq; % num seconds * samp_freq

numfracts = sum(find(s~=fix(s)));
if numfracts
   disp(['WARNING: ' num2str(numfracts) 'non-integer indices calculated.'])
end