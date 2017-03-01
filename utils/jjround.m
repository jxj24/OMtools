function out = jjround(in, prec)

if isempty(prec), prec=0; end

in = in .* 10^prec;
in = round(in);
out = in ./ 10^prec;