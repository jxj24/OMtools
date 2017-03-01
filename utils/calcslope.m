% caclslope.m

function slope = calcslope;

global xyCur1Mat xyCur2Mat samp_freq

if xyCur1Mat(1,1) < xyCur2Mat(1,1)
	firstYpt = xyCur1Mat(end,2); 
	secondYpt = xyCur2Mat(end,2);
 else
	firstYpt = xyCur2Mat(end,2);
	secondYpt = xyCur1Mat(end,2);
end 

delta_x =  abs( xyCur1Mat(end,1)-xyCur2Mat(end,1) ) / samp_freq;
delta_y =  secondYpt-firstYpt;

slope = delta_y/delta_x;