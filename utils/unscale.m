
function [e0 e_ss] = unscale;

global xyCur1Mat xyCur2Mat

e0_scaled   = xyCur1Mat(end,2); 
e_ss_scaled = xyCur2Mat(end,2);

e0   = (e0_scaled+30 ) / 4;
e_ss = (e_ss_scaled+30 ) / 4;

disp(['e0 = ' num2str(e0,3) ',  e_ss = ' num2str(e_ss,3)])