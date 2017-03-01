% newPH.m:  make new PG ampl function.

% this is our gold standard
stm=[1 2 5 10 15 20 25 30 40 50]';
goldamp=[60 90 200 300 350 400 425 450 480 500]';

for i = 1:length(stm)
  testamp(i)=PHfuncX(stm(i));
end

hold on
plot(stm, goldamp, 'g--')
plot(stm, testamp, 'c')
xlabel('Stim amplitude')
ylabel('Pulse magnitude')
