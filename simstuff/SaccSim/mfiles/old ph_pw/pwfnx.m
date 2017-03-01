%%%  PWfnx.m:

function y = PWfnx( u )

if abs(u) <= 1
   y = 67.275*abs(u);
 elseif abs(u) <= 5
   y = 195*abs(u);
 elseif abs(u) <= 10
   y = 125*abs(u);
 elseif abs(u) <= 25
   y = 50*abs(u);
 elseif abs(u) <= 45
   y = 25*abs(u);
 else
   y = 10*abs(u);
end

%%  Our gold standard.
%%  stm=[1 2 3 4 5 6 7 8 10 12 15 17 20 22 25 27 30 32 35 37 40 42 45 47 50]';
%%  pw_meas=[12 13 14 16 17 18 20 21 24 26 30 33 38 40 43 46 49 53 56 59 63 66 69 73 75]';