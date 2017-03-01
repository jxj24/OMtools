% PWfunc.m: Used by 'PG(new)' to determine pulse width.

% Written by:  Jonathan Jacobs
%              November 1997  (last mod: 11/04/97)

function y = PWfunc( u )

if (abs(u)<=1)
   y = 69.275*abs(u);
 elseif (abs(u)>1) & (abs(u) <= 5)
   y = 197.5*abs(u);
 elseif (abs(u)>5) & (abs(u) <= 10)
   y = 152.50*abs(u);
 elseif (abs(u)>10) & (abs(u) <= 20)
   y = 67.50*abs(u);
 elseif (abs(u)>20) & (abs(u) <= 30)
   y = 40.0*abs(u);
 elseif (abs(u)>30) & (abs(u) <= 40)
   y = 30.0*abs(u);
 else
   y = 22.50*abs(u);
end


