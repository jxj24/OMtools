% datadir:  set the root data directory
% Written by  Jonathan Jacobs
%             December 1996 - February 1997  (last mod: 02/18/97)

function datadir( whatdir )

global dataroot

if ~exist( 'dataroot' )
   % find the root directory for the data files.
   setroot
end

% go to the root directory for your data.
eval( ['cd ' '''' dataroot '''';] )

if nargin == 1
   eval( ['cd ' '''' whatdir '''' ;] )
end