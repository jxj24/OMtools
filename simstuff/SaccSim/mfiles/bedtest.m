% bedtest.m: loop to present a model in 'testbed' with a set of stimuli.
% this model is basically a plant, with whatever other
% crap you feel is necessary.
% Usage: in "TESTBED:Double Pulse," set "Pulse 1 Magnitude" to "stimhgt"
% and "Pulse 1 Duration" to "stimdur"

if ~exist('pdelay')
   pdelay = input('Enter the delay for the test plant (in seconds): ');
end

disp(['     goal      peak      error'])
disp(['    ----------------------------'])

tic;
%stimlist=[(0.1:0.1:2), (3:1:50)];
stimlist=[(3:1:50)];
%stimlist=[(0.1:0.1:2)];
%stimlist=[(0.1)];
stoptime = 0.20;  % run the simulation this long (seconds)

stimdur = stoptime;

peak=[]; ss=[];
figure;hold on
lasttime=0; i=0;
for j = stimlist
   i=i+1;
   stimhgt=stimlist(i);

   % find the pulse width
   stoptime=0.2; % run 'pwtstbed' this long (seconds)
   goal = stimhgt;
   [a,b,c]=rk45('pwtstbed', stoptime, [], [1e-3, 0.001, 0.001, 0,0,2]);
   pts = find(pwout==0);
   stimdur = twClock(pts(2)-1) - twClock(pts(1));
   stimdurlist(i) = stimdur;
   %plot(t,pwout)
   %pause

   stoptime = stimdur + pdelay;  % run 'testbed' this long (seconds)
   [a,b,c]=rk45('testbed', stoptime, [], [1e-3, 0.001, 0.001,0,0,2]);
   peak(i)=max(out);
   %ss(i) = out(length(out));
   %disp([stimlist(i) peak(i) ss(i) stimlist(i)-ss(i)])
   disp([stimlist(i) peak(i) 100*(peak(i)-stimlist(i))/stimlist(i)])
   %disp(['Time for this iteration: ' num2str(toc-lasttime)])
   plot(t,out,'y',[0 stoptime],[goal goal],'g',...
           [stoptime stoptime],[0 1.0*goal],'g')
   drawnow
   lasttime=toc;
   %plot(a,b(:,1))
end

disp(['Total time: ' num2str(toc)])
%title(['Stims (bot to top): ' mat2str(stimlist)])
xlabel('Time (sec)')
ylabel('Eye Pos (deg)')