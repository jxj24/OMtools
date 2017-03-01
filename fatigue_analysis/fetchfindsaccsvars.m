function [ptlist,pv_pt,saccstart,saccstop,pvel,extend,dataName,thresh_v,...
            thresh_a,vel_stop,acc_stop] = fetchfindsaccsvars

% Workaround assignin from findsaccs
%
% TODO better header

% Get variables from base workspace
% NOTE: pvel (for example & among others) gets "assignin" to workspace from findsaccs!
% pull "assignin" variables from base workspace.
ptlist = evalin('base','ptlist');
pv_pt = evalin('base','pvlist');
saccstart = evalin('base','saccstart');
saccstop = evalin('base','saccstop');
pvel = evalin('base','pvel');
extend = evalin('base','extend');
dataName = evalin('base','dataName');
thresh_v = evalin('base','thresh_v');
thresh_a = evalin('base','thresh_a');
vel_stop = evalin('base','vel_stop');
acc_stop = evalin('base','acc_stop');