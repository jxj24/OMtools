% PWnew.m: Pulse width for new PGen

function   y = PWnew( u )

if abs(u)<1
   y = 7.5*abs(u)+5.0;
 elseif (abs(u)<=2)
   y = u*12.5;
 elseif (abs(u)>2) & (abs(u)<5)
   y = sign(u)*((abs(u)-2)*(5/3) + 25);
 elseif (abs(u)>=5) & (abs(u)<50)
   y = sign(u)*(abs(u)*2 + 20);
 else
   y = sign(u)*120;  %% saturation???

end

y=y/1000;