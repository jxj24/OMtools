% ML_W_switch: (Mac ONLY) switch foreground application to either MATLAB
% or to its assistant MATLABWindow (responsible for all App Designer windows)
%  call with "ml"   to bring MATLAB to the front
%            "ml_w" to bring MATLABWindow to the front
% Requires the presence of the AppleScripts applications MLW_act and ML_act

% Written by Jonathan Jacobs
% September 5, 2017 - March 2018

function ML_W_switch(which)

if ~contains(computer,'MAC'), return; end
if nargin~=1
   return
end

olddir=pwd;
[supt_dir, ~, ~] = fileparts(mfilename('fullpath'));
cd(supt_dir)

switch lower(which)
   case 'ml'
      ! open "ML_act.app"
   case 'mlw'
      ! open "MLW_act.app"
   otherwise
      disp('ML_W_switch: unknown action.')
end
cd(olddir)

% could also use system('open ML(W)_act.app')