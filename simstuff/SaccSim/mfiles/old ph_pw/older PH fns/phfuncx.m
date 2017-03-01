% PHfuncX.m: Called by 'PG(new)' to determine the pulse height
% This is a simple example of how to use an m-file from within SIMULINK

% Written by:  Jonathan Jacobs
%              November 1997 

function y = PHfuncX( u )

if abs(u) <= 0.25
   y = 0;
 else
   y = 555*u/(7.5+abs(u));
end