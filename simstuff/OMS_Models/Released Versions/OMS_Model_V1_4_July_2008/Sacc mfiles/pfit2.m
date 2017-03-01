% pfit.m: find and test the polynomial fits for the pulse amplitude

% Written by:  Jonathan Jacobs
%              May 1998  (last mod: 05/26/98)


% precision of num2str for display
prec = 10;

% find where we go from close spacing to wide spacing between
% the stimulus array.
a = [stimlist 0];
b = [0 stimlist];
c = a - b;
d = find(c>2*c(1));

breakpt = d(1)-1;
loEnd = 1:breakpt;
hiEnd = breakpt:length(stimlist);

order = input('What order fit? ');

% calc the polynomial coefficients
[coeffLo, errmatLo] = polyfit(stimlist(loEnd), finalstim(loEnd), order);
[coeffHi, errmatHi] = polyfit(stimlist(hiEnd), finalstim(hiEnd), order);

% calculate the curves from the coefficients
[reconLo, deltalo] = polyval(coeffLo, stimlist(loEnd), errmatLo);
[reconHi, deltahi] = polyval(coeffHi, stimlist(hiEnd), errmatHi);

for i = 1:order+1
   %disp(['Low-range coefficient ' num2str(i) ' = ' num2str(coeffLo(i))])
   disp(['coeffLo(' num2str(i) ') = ' num2str(coeffLo(i),prec) ';'])
end
disp(' ')
for i = 1:order+1
   %disp(['High-range coefficient ' num2str(i) ' = ' num2str(coeffHi(i))])
   disp(['coeffHi(' num2str(i) ') = ' num2str(coeffHi(i),prec) ';'])
end

% see how well they correspond
figure
subplot(2,1,1);
hold on
plot(stimlist(loEnd), finalstim(loEnd), 'y')
plot(stimlist(loEnd), reconLo, 'c--')
ylabel('Pulse Amplitude')
title(['Yellow: data,  Cyan: polynomial of order ' num2str(order)]) 

subplot(2,1,2)
hold on
plot(stimlist(hiEnd), finalstim(hiEnd), 'y')
plot(stimlist(hiEnd), reconHi, 'c--')
ylabel('Pulse Amplitude')
xlabel('Saccade Magnitude')