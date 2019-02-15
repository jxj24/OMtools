function out = poslimiter(in, lim)

if ~exist('lim','var'), lim = 50; end

in(abs(in)>lim) = NaN;

out = in;