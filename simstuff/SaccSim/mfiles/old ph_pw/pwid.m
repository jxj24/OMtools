%% pwid.m: find the width of the output

function dur = pwid( in, t )

wid = find( in ~= 0 );

dur = t(wid(length(wid))) - t(wid(1)-1);

