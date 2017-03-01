% pfit.m: test the polynomial fits for the pulse amplitude

% Written by:  Jonathan Jacobs
%              November 1997  (last mod: 11/07/97)

% here is the data we want to fit
stm = stimlist(11:59);
best = finalstim(11:59);

% let's generate polynomial fits for 2nd, 3rd and 4th order
%a2=polyfit(stm,best,2);
%a3=polyfit(stm,best,3);
a4=polyfit(stm,best,4);
%a5=polyfit(stm,best,5);

% test the coefficients
%for i=0:50
%   y2(i) = a2(1)*i^2 + a2(2)*i^1 + a2(3)*i^0; 
%   y3(i) = a3(1)*i^3 + a3(2)*i^2 + a3(3)*i^1 + a3(4)*i^0; 
%   y4(i+1) = a4(1)*i^4 + a4(2)*i^3 + a4(3)*i^2 + a4(4)*i^1 + a4(5)*i^0; 
%end

%figure
%hold on
%plot(stm,best,'y')
%plot(1:50,y2,'g:')
%plot(1:50,y3,'r-.')
%plot(0:50,y4,'c--')
%plot(stm, y4(stm)'-best, 'b--')

% same thing, but using MATLAB's built-in polynomial evaluator
%yy2 = polyval(a2, stm);
%yy3 = polyval(a3, stm);
yy4 = polyval(a4, stm);

figure
hold on
plot(stm,best,'y')
%plot(stm,yy2,'g:')
%plot(stm,yy3,'r-.')
plot(stm,yy4,'c--')
