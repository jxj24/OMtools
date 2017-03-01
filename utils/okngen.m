% okngen.m:  Generate an optokinetic stimulus
%     usage:  okngen(numstripes, numsteps)
%  where numstripes is the number of dark stripes that will appear in the pattern
%    and numsteps is the number of frames it will take for a stripe to step off the screen.
%
% You can generate horizontal or vertical stripes, that can move in either direction in
% their plane.  (Working on adding options to specify aspect ratio of the stimulus, and
% the ability to enclose them in a black border so that full-screen display doesn't require
% filling the screen with moving stripes.)
%
% Written by:  Jonathan Jacobs
%   last mod:  1 October 2012

function okngen(numstripes, numsteps)

if nargin <2
   numstripes = 5;
   numsteps = 5;
end

%% x_full and y_full are the boundaries for the full-sized patch.
y_full = [0 0 1 1 1];
x_full = [0 1 1 0 0];

%% Size and/or aspect ratio of the target screen?
%disp(' ')
%disp('What is the resolution of the target display? ')
%disp(' 1)   1024 x 768')
%disp(' 2)    800 x 600')
%% 
%% when showing stim full screen using QT, it is blown up until one dimension maxes out vs
% screen dimension.  we would like to be able to show stimuli full screen without doing that.
% by banding the top and bottom of the stimulus (for hor, or l/r for vrt) we can force an
% upper limit on how much fullscreen presentation blows things up.

%% Vertical or horizontal?
h_flag=0; v_flag=0;
stimdir = lower( input('Make a (h)orizontal or a (v)ertical stimulus? ','s') );
if strcmp(stimdir,'v'), v_flag=1; end
if strcmp(stimdir,'h'), h_flag=1; end
if ~v_flag && ~h_flag
   disp('Invalid selection.  Run ''okngen'' again.')
   return
end

%% a stripe is numsteps wide.  These are the number of steps that it takes for the stripe
%% to disappear off the edge of the screen once it first reaches the border.  As the stripe
%% disappears from one side, the exact missing area will reappear at the opposite edge.
stepsize = 1/numsteps;

%% numstripes is the number of BLACK stripes that appear in the stimulus.  Since each
%% full stripe (black or white) is one unit wide, we need to set the x-axis limit to
%% 2*numstripes.
oknfig = figure;
set(gcf,'pos', [707 560 1280 1024])
box
set(gca,'xtick',[])
set(gca,'ytick',[])

%% draw the rest of the stripes. They are separated by an equivalent amount of white space.
%% we draw an extra stripe off screen so that we can scroll through it without having to
%% draw an additional stripe during the animation.
if h_flag
   set(gca,'xlim', [0 2*numstripes])
   for k = -1:numstripes+1
      patch( x_full + 2*k , y_full,'k')
   end
 elseif v_flag
   set(gca,'ylim', [0 2*numstripes])
   for k = -1:numstripes+1
      patch( y_full , x_full + 2*k,'k')
   end
end


%% Left-to-right (up-to-down) or right-to-left (down-to-up)?
if h_flag
   movedir = lower(input('Move stripes (r)ightward or (l)eftward? ','s'));
 elseif v_flag
   movedir = lower(input('Move stripes (u)pward or (d)ownward? ','s'));
end 

if strcmp(movedir,'r') || strcmp(movedir, 'u')
    vect = 1:numsteps*2;
  elseif strcmp(movedir,'l') || strcmp(movedir, 'd')
    vect = numsteps*2:-1:1;
end

framenum=1;
for k=vect
   if h_flag
      xlow = -stepsize*k;
      xhigh = 2*numstripes - stepsize*k;
      set(gca, 'xlim', [xlow xhigh]);
    elseif v_flag
      ylow = -stepsize*k;
      yhigh = 2*numstripes - stepsize*k;
      set(gca, 'ylim', [ylow yhigh]);
   end 
   oknmovie(framenum) = getframe;
   oknframe{framenum} = frame2im(getframe);
   framenum=framenum+1;
end
movie(oknmovie)
movie(oknmovie)
movie(oknmovie)

yorn = lower( input('Do you want to save this stimulus? ','s') );
if ~strcmp(yorn, 'y'), return; end

[fn,pn] = uiputfile('.tiff','Save the stimulus as ','test');
if pn == 0, return; end

fn = strtok(fn,'.');

for k=1:numsteps*2
   imagename = [[pn fn] num2str(k) '.tiff'];
   imwrite( oknframe{k}, imagename, 'TIFF' )
end

disp([ num2str(numsteps*2) ' files saved in ' pn ])
disp('To make a QuickTime movie of this stimulus, use the ')
disp('"Open Image Sequence..." choice from the "File" menu in')
disp('QuickTime version 7 ')