%% pgdurtst.m: test pgdur

stimlist = [1 2 3 4 5 10 15 20 25 30 35 40 45 50];

%%  Our mold standard.
danstm=[1 2 3 4 5 6 7 8 10 12 15 17 20 22 25 27 30 32 35 37 40 42 45 47 50]';
dandur=[12 13 14 16 17 18 20 21 24 26 30 33 38 40 43 46 49 53 56 59 63 66 69 73 75]';

%% Our gold standard -- need to enter correct dur values
goldstm=[01 02 05 10 15 20 25 30 35  40  45  50]';
golddur=[13 25 30 40 50 60 70 80 90 100 110 120]';

for i = 1:length(stimlist)
   pgdtstim = stimlist(i);
   [a,b,c] = rk45('testbed', 0.25);
   dur(i) = pwid(out,t);
end

dur = dur*1000;  %% put it in msec

hold on
plot(stimlist, dur, 'c')
plot(danstm, dandur,'g.')
plot(goldstm, golddur,'r--')
title('test PW: solid,   Dan''s PW: dotted,   Real PW: dashed')
xlabel('Stim (deg)')
ylabel('Pulse Duration (ms)')