% PWnew.m: Called by 'PG(simp)' to determine the pulse width
% This is a simple example of how to use an m-file from within SIMULINK
  
% Written by:  Jonathan Jacobs
%              November 1997 

function y = PWnew( u )

if abs(u) < 2
   y = 12.5*abs(u);
 elseif (abs(u) >= 2) & (abs(u)<5)
   y = (abs(u)-2)*(5/3) + 25;
 elseif (abs(u) >= 5)
   y = 2*abs(u)+20;
end

y = y/1000;  %% output as seconds