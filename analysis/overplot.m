% overplot.m: plot the foveation window points over the
% data array from which they were determined.
% Usage: overplot(positionArray, fovWindowPts)

% Written by:  Jonathan Jacobs
%              April 1998  (last mod:  04/03/98)

function overplot(posArray, fovWinPts)

t = maket(posArray);

% initialize the over-plotting arrays
pLimArray = NaN*ones(length(posArray),1);

% then fill them with only the appropriate pts
pLimArray(fovWinPts) = posArray(fovWinPts);

hold on
p1 = plot(t,posArray,'y');
p2 = plot(t,pLimArray,'r');
set(p2,'LineWidth',1);
set(p2,'LineStyle','*');
set(p2,'MarkerSize',3);