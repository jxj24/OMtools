% ph2sacc.m: for a given pulse height, what was the saccade that
% generated it?  used (with PW new) to determine the duration of the
% pulse.  this is needed to correctly set the refractory period in the
% pulse generator.

function dur = p2sacc(ph)

phSign = sign(ph);
ph = abs(ph);

if ph > 82
   sacc = 45;
   dur = 110;
 elseif ph > 80.2
   sacc = 40;
   dur = 100;
 elseif ph > 77.5
   sacc = 35;
   dur = 90;
 elseif ph > 74.59
   sacc = 30;
   dur = 80;
 elseif ph > 71.34
   sacc = 25;
   dur = 70;
 elseif ph > 67.0
   sacc = 20;
   dur = 60;
 elseif ph > 60.5
   sacc = 15;
   dur = 50;
 elseif ph > 55.77
   sacc = 12.5;
   dur = 45;
 elseif ph > 49.76
   sacc = 10;
   dur = 40;
 elseif ph > 42.12
   sacc = 7.5;
   dur = 35;
 elseif ph > 32.5
   sacc = 5;
   dur = 30;
 elseif ph > 20.5
   sacc = 2.5;
   dur = 25;
 elseif ph > 16.2
   sacc = 1.5;
   dur = 19;
 elseif ph > 15.8
   sacc = 1;
   dur = 12.5;
 else
   sacc = 0.5;
   dur = 10;
end

dur=dur/1000;  % convert to milliseconds