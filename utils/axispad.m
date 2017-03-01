% axispad.m: takes min and max values and recalculates a margin around
% them suitable for setting as axis limits, so that a plot will have
% a little space between the data extremes and the borders of the axes.

% written by:  Jonathan Jacobs
%              May 2005  (last mod: 05/13/05)


function [mincalc, maxcalc] = axispad(lowlim, highlim, padding)

if nargin<2,  help axispad; return; end
if nargin==2  padding=0.05; end
if padding<0, padding=0; end

% the ol' switcharoo
if lowlim>highlim, temp=lowlim; lowlim=highlim; highlim=temp; end

% can't have low==high
if lowlim==highlim, lowlim=lowlim-eps; highlim=highlim+eps; end 

%   
range = highlim-lowlim;
mincalc = lowlim  - padding*range;
maxcalc = highlim + padding*range;

return