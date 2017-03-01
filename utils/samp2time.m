% "t" is specified in seconds.

function t = samp2time(s)

global samp_freq

if isempty(samp_freq)
   samp_freq = input('Enter sampling frequency: ');
end

t = s * 1000/samp_freq; % sample number * ms per sample
 