% PGcurveA.m: Iteratively find the best(?) pulse amplitude to make a saccade.
%            You can substitute different pulse duration functions below

% Written by:  Jonathan Jacobs
%              November 1997  (last mod:  11/10/97)

tic;
disp(['     goal      peak     ss       PW (ms)    PH        tries    %error'])
disp(['    ------------------------------------------------------------------'])

iterLim = 60;   % How many times will we try before raising the error limit.
index=0;
pcterror = [];
errlist=[];
finalstim=[];
stimdurlist=[];
stimlist=[];
%countlist=[];
ss=[]; peak=[]; 

for st = [0.1:0.1:2.0];%, 1:1:50];
   index=index+1;
   % define starting points for the iterations  %% for phasic gain = 5.0 %%%%

   if st <= 0.1
      startpt = 3.4; 
    elseif st <= 0.2
      startpt = 5.75;
    elseif st <= 0.3
      startpt = 8.65;
    elseif st <= 0.4
      startpt = 10.0;
    elseif st <= 0.5
      startpt = 11.75;
    elseif st <= 0.6
      startpt = 12.7;
    elseif st <= 0.7
      startpt = 14.1;
    elseif st <= 0.8
      startpt = 14.55;
    elseif st <= 0.9
      startpt = 15.7;
    elseif st <= 1
      startpt = 16.0;
    elseif st <= 2
      startpt = 16.0;
    elseif st <= 5
      startpt = 33.75;
    elseif st <= 10
      startpt = 49.9202;
    elseif st <= 15
      startpt = 61.50;
    elseif st <= 20
      startpt = 67;
    elseif st <= 25
      startpt = 72.5;
    elseif st <= 30
      startpt = 75;
    elseif st <= 35
      startpt = 77.25;
    elseif st <= 40
      startpt = 81;
    elseif st <= 45
      startpt = 82.8;
    elseif st <= 50
      startpt = 84.5;
   end
   
   stimdur = PWnew3(st);   % 'stimdur' is read by testbed's 'Double Pulse' block 

   stimdurlist(index) = stimdur;
   stimlist(index) = st;
   stimamp = startpt;
   stoptime = 2.0;  % run the simulation this long (seconds)
   count=0;
   error = 100; 
   fiddle = 1.0; starterrlim = 0.001;
   errlim = starterrlim; resets = 0;

   while (abs(error) > errlim) & (count < 60);
      count=count+1;
      [a,b,c]=rk45('testbed', stoptime, [], [1e-3, 0.0, 0.001]);
      peak(index) = max(out);
      ss(index) = out(length(out));
      error = (ss(index) - st);
      errlist(count,index) = error;
      pcterror(index) = error/st;
      stimamp = stimamp - error*fiddle;
      finalstim(index) = stimamp;

      % If we've made it to the end of 'iterLim' trials without having found
      % a good solution, there's the possibility that we can't get that
      % close.  Perhaps we're oscillating, so let's try with a larger limit.
      % In these cases we will probably end up searching for the best solution
      % manually, but maybe we'll get lucky here, first...
      if (count == iterLim-1) 
         errlim = 1.1*min(abs(errlist(:,index)));
         count = 1;
         resets = resets + 1;
         if resets > 3
            errlim = errlim*2;  
            resets = 0;         
         end
         disp([' *****  New errlim: ' num2str(errlim) '  *****'])
         %screwed this next line up when we reset 'resets'
         %priorerrlists(:,resets) = errlist(:,index); 
      end
   end
   
   %disp(['Elapsed time: ' num2str(toc)])
   
   disp( [stimlist(index) peak(index) ss(index) stimdurlist(index)*1000 ...
                 finalstim(index) count pcterror(index)*100] );

end
disp(['Elapsed time: ' num2str(toc)])
