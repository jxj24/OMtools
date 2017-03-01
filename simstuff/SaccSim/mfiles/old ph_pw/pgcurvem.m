% PGcurveM.m: manual tuning of PG amplitude.

tic;
maglist = [];
st = 2.1;

if st <= 0.1
   maglist = [3.2 3.3 3.4 3.5];
 elseif st <= 0.2
   maglist = [5.6 5.7 5.75 5.8];
 elseif st <= 0.3
   maglist = [8.5 8.55 8.6 8.65];
 elseif st <= 0.4
   maglist = [9.9 9.95 10 10.5];
 elseif st <= 0.5
   maglist = [11.6 11.65 11.7 11.75];
 elseif st <= 0.6
   maglist = 12.7;
 elseif st <= 0.7
   maglist = 14.1;
 elseif st <= 0.8
   maglist = 14.5;
 elseif st <= 0.9
   maglist = 15.5;
 elseif st <= 1
   maglist = [5 10 15.25 20 25 30]; %% for phasic gain = 5.0, best: 15.25
 elseif st <= 2.5
   maglist=[16.0 16.1 16.2 16.3 16.4]; %% for phasic gain = 5.0, best: 15.85
 elseif st <= 5
   maglist=[25 30 33.75 35 40]; %% for phasic gain = 5.0, best: 33.75
 elseif st <= 10
   maglist=[40 45 49.9202 55 60 65 70]; %% for phasic gain = 5.0, best: 49.9202
 elseif st <= 15
   maglist=[55 61.50 65 70];  %% for phasic gain = 5.0, best: 61.5
 elseif st <= 20
   maglist=[60 65 67 70 75];  %% for phasic gain = 5.0, best: 67
 elseif st <= 25
   maglist=[60 65 70 72.5 75 80 90];  %% for phasic gain = 5.0, best: 72.5
 elseif st <= 30
   maglist=[65 70 75 80 85 90];  %% for phasic gain = 5.0, best: 75.0
 elseif st <= 35
   maglist=[75 77.25 80 82.5 85 87.5];  %% for phasic gain = 5.0, best: 77.25
 elseif st <= 40
   maglist=[77.5 81 83.5 85 87.5];  %% for phasic gain = 5.0, best: 81
 elseif st <= 45
   maglist=[80 82.8 85 87.5 90];  %% for phasic gain = 5.0, best: 82.8
 elseif st <= 50
   maglist=[80 82.5 84.5 87.5 90 92.5 95];  %% for phasic gain = 5.0, best: 84.5
end

stimdur = PWnew3(st);
stoptime = 2.0;  % run the simulation this long (seconds)
ss=[]; peak=[];
figure;hold on
for i =1:length(maglist)
   stimamp=maglist(i);
   [a,b,c]=rk45('testbed', stoptime, [], [1e-3, 0.0, 0.001]);
   peak(i)=max(out);
   ss(i) = out(length(out));
   plot(t,out)
end

toc
title(['stimdur: ' num2str(1000*stimdur) 'ms    mags (bot to top): ' mat2str(maglist)])
xlabel('Time (sec)')
ylabel('Eye Pos (deg)')

[maglist' peak' ss']
