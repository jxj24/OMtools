function vidstimgen(dist_to_subj,mirror)

% REMEMBER TO ADD DIST TO MIRROR TO DIST TO SUBJ
if ~exist('dist_to_subj','var'), dist_to_subj = 330; end
if ~exist('mirror','var'), mirror = 1; end

old_dir=pwd;

% what screens are available for making the movie?
temp = get(0);
mon_pos = temp.MonitorPositions;
[numscreens, ~] = size(mon_pos);
disp('Local screen dimensions')
sXoff=NaN*ones(numscreens,1);  sYoff=NaN*ones(numscreens,1);
swid=NaN*ones(numscreens,1);  shgt=NaN*ones(numscreens,1);

for j=1:numscreens
    sXoff(j) = mon_pos(j,1);
    sYoff(j) = mon_pos(j,2);
    swid(j)  = mon_pos(j,3);
    shgt(j)  = mon_pos(j,4);
    disp( ['Screen ' num2str(j) ': ' num2str(swid(j)) ' by ' num2str(shgt(j))] )
end

whichmon=1;
if numscreens>1
    whichmon = -1;
    disp('Make the movie on which monitor?')
    while (whichmon < 0) || (whichmon > numscreens)
        whichmon = input(  ' -> ');
    end
end

monXO = sXoff(whichmon);   monYO = sYoff(whichmon);
monWid = swid(whichmon);   monHgt = shgt(whichmon);

% What screen will the movie be played on? 
% What are its physical and display dimensions?
% Use these values to calculate how many degrees the monitor spans
% and how many pixels equal one degree.
tgtmon = -1;
disp(' ')
disp('What screen do you want the movie to play on? ("0" to cancel) ')
disp('1. Apple Cinema HD          (1920 x 1200 pix; 490 x 310 mm)')
disp('2. SyncMaster 2443          (1920 x 1200 pix; 517 x 325 mm)')
disp('3. Monoprice 28" 4K HDI     (2560 x 1440 pix; 620 x 340 mm)')
disp('4. iMac 5K, 28"             (2560 x 1440 pix; 593 x 336 mm)')
disp('5. Retina Macbook Pro 2015  (1440 x  900 pix; 331 x 208 mm)')
disp('6. iPad Air (mirroring MBP) (1440 x  900 pix; 197 x 123 mm)')
disp('7. iPad Air (native HDI)    (1024 x  768 pix; 197 x 147 mm)')  % is this correct?
disp('8. BenQ                     (1920 x 1080 pix; 503 x 300 mm)')
while tgtmon < 0 || tgtmon > 8
    tgtmon = input(' -> ');
end

% Monitors' actual DISPLAYABLE screen sizes in MILLIMETERS.
switch tgtmon
    case 1
        % Apple Cinema HD dimensions.
        scr_pix_wid = 1920; scr_pix_hgt = 1200;  % PIXELS
        scr_phys_wid = 490; scr_phys_hgt = 310;  % MILLIMETERS
    case 2
        % SyncMaster 2443.
        scr_pix_wid = 1920; scr_pix_hgt = 1200;  % PIXELS
        scr_phys_wid = 517; scr_phys_hgt = 325;  % MILLIMETERS
    case 3
        % Monoprice 28" 4K
        scr_pix_wid = 2560; scr_pix_hgt = 1440;  % PIXELS
        scr_phys_wid = 620; scr_phys_hgt = 340;  % MILLIMETERS
    case 4
        % iMac 5K, 28"
        scr_pix_wid = 1440; scr_pix_hgt =  900;  % PIXELS
        scr_phys_wid = 593; scr_phys_hgt = 336;  % MILLIMETERS
    case 5
        % Retina MacBook Pro 15"
        scr_pix_wid = 1440; scr_pix_hgt =  900;  % PIXELS
        scr_phys_wid = 331; scr_phys_hgt = 208;  % MILLIMETERS
    case 6
        % iPad Air, when MIRRORING rMBP15 (ignoring pixel doubling)
        scr_pix_wid = 1440; scr_pix_hgt =  900;  % PIXELS
        scr_phys_wid = 197; scr_phys_hgt = 123;  % MILLIMETERS
    case 7
        % iPad Air, native (ignoring pixel doubling)
        scr_pix_wid = 1024; scr_pix_hgt =  768;  % PIXELS
        scr_phys_wid = 197; scr_phys_hgt = 148;  % MILLIMETERS
    case 8
        % BenQ
        scr_pix_wid = 1920; scr_pix_hgt = 1080;  % PIXELS
        scr_phys_wid = 503; scr_phys_hgt = 300;  % MILLIMETERS
    otherwise
        disp('Canceling.')
        return
end

%%%%% ML titlebar + OS X menubar = 45 pixels
%%%%% ML titlebar + OS X menubar + large dock = 140 pixels
%%%%% Solution: HIDE dock while making movie.
mov_pix_hgt = scr_pix_hgt;
mov_pix_wid = scr_pix_wid;

wasted_hgt = 45;
scr_pix_hgt = scr_pix_hgt - wasted_hgt;
monHgt = monHgt-wasted_hgt;

% If at all possible, try to create the movie on a screen that is at least
% as large as the screen it will be played on. Otherwise we need to scale
% the movie size so it can be created with the proper aspect ratio.

scale = 1.0;
if mov_pix_wid>monWid || mov_pix_hgt>monHgt
    disp('Movie dimension(s) are larger than local rendering screen.')
    %disp('add some details about sizes options here?')
    disp('0. Cancel.')
    disp('1. Scale the movie down to fit the rendering screen.')
    choice=-1;
    while choice < 0 || choice > 1
        choice = input(' -> ');
    end
    switch choice
        case 0
            disp('Canceling.')
            return
        case 1
            scale = min( monWid/mov_pix_wid, monHgt/mov_pix_hgt );
            scale = scale * 0.9;
            disp(['Will scale by ' num2str(scale)])
            %offer chance to manually set scaling?
    end
end

%aspect = scr_pix_wid / scr_pix_hgt;
mov_pix_wid = scale * mov_pix_wid;
mov_pix_hgt = scale * mov_pix_hgt;

% geometry is our friend. When we do it correctly.
% at distance D from the screen, what are dimensions in DEGREES?
temp = atan((scr_phys_wid*0.5) / dist_to_subj); % in RADIANS
half_alpha_hor = temp*180/pi; % degrees
temp = atan((scr_phys_hgt*0.5) / dist_to_subj); % in RADIANS
half_alpha_vrt = temp*180/pi; % degrees

% use these values to convert between MOVIE pixels and degrees
hpix_per_deg = mov_pix_wid / (2 * half_alpha_hor);
vpix_per_deg = mov_pix_hgt / (2 * half_alpha_vrt);

disp('');disp('Select a stimulus text file:')
[stimfile, stimpath] = uigetfile('*.txt','Select a stimulus text file');
if stimfile==0, disp('Canceled.'); return; end
cd(stimpath)
target = readVSgen(stimfile);

%%% Each stim element can have unique duration. Find lowest common mult
%%% of all instantaneous frame rates: 'frate = lcm(sym( 1./listdur ));'
%%% Works, but 'sym' is from symbolic toolbox. Can't assume it's present.
%%% So why not write our own semi-symbolic lcm that handles vects, and
%%% as a bonus, non-integer values...
listdur = NaN(size(target));
for i=1:length(target)
   listdur(i)=target{i}.dur;
end
moviedur = sum(listdur);
frate = lcmvect( 1./listdur );
extend = round(frate .* listdur);

% can save each frame as its own image file, and also directly as AVI
disp('');disp('Save the stimulus image/movie as:')
[filename, pathname] = uiputfile( {'*.jpg';'*.png';'*.pdf';'*.tiff';'*.bmp'}, ...
    'Save the stimulus movie as: ');
if filename==0, disp('Cancelled'); return;end

[filename, ~] = strtok(filename,'.');
cd(pathname)
% comment out to disable saving each frames as individual file
%mkdir(filename); cd(filename)

omdir; cd utils
! open hidedock.app
cd(old_dir)

% center the movie on the rendering screen
movXO = monXO + abs(mov_pix_wid - monWid)/2;
movYO = monYO + abs(mov_pix_hgt - monHgt)/2;
fig = figure('Position',[movXO, movYO, mov_pix_wid, mov_pix_hgt]);
set(fig, 'color','k', 'menubar','none')
set(fig,'Units','normalized')
%set(fig,'Position',[(1-scale)/2, (1-scale)/2, scale, scale])
set(fig,'PaperPositionMode','auto')
set(fig,'InvertHardCopy', 'off');
set(fig,'Units','pixels')

ax = gca;
set(ax,'Units','normalized')
%set(ax,'OuterPosition', [0 0 1 1])
set(ax,'Position', [0 0 1 1])
box off; hold on
axis off; axis equal tight
set(ax,'Units','pixels')
set(ax,'Xlim',[-mov_pix_wid/2, mov_pix_wid/2])
set(ax,'Ylim',[-mov_pix_hgt/2, mov_pix_hgt/2])

stim_mov = VideoWriter( [pathname filename] );
stim_mov.FrameRate = frate;
stim_mov.Quality = 100;
open(stim_mov)

% Add an extra frame to the front bec Experiment Builder appears to skip
% the first frame when playing movie
F = getframe; writeVideo(stim_mov, F);

renderstart=tic;
for k = 1:length(target)
    % first four line entries are same for all tgt types:
    % xpos,ypos in degrees, dur in seconds
    xpos = target{k}.x*hpix_per_deg;
    ypos = target{k}.y*vpix_per_deg;
    targ_type = target{k}.type;
    
    switch targ_type
        case 'circ'
            circ_dia = target{k}.dia * hpix_per_deg;
            circ_color = target{k}.color;
            vect = -0.1:0.1:2*pi;
            x = circ_dia*cos(vect) + xpos;
            y = circ_dia*sin(vect) + ypos;
            tgtHand = fill(x,y,[1 1 1]);
            set(tgtHand,'facecolor',circ_color);
            
        case 'pict'
            % 'pict_data' and 'pict_map' are the actual image&cmap matrices
            tgt_wid = target{k}.wid * hpix_per_deg; % change from deg->pixels
            tgt_hgt = target{k}.hgt * vpix_per_deg;
            pict_angle = target{k}.angle;
            pict_data = target{k}.pdata;  % the actual image matrix
            pict_map = target{k}.cmap;     % the actual colormap matrix
            pict_fname = target{k}.fname;
            
            %get image info (hgt wid of unmod pic, scale and set new val
            pict_info = imfinfo(pict_fname); %pixels
            pict_wid = double(pict_info.Width); % pix->deg
            pict_hgt = double(pict_info.Height); % pix->deg
            hscale = tgt_wid/pict_wid; % ratio, in pixels
            vscale = tgt_hgt/pict_hgt;
            pict_data = imresize(pict_data,'Scale',[vscale,hscale] );
            pict_data = imrotate(pict_data,pict_angle);
            
            % place CENTER of picture at (x,y)
            xpos = xpos - (pict_wid*hscale)/2; 
            ypos = ypos - (pict_hgt*vscale)/2; 
                      
            colormap(pict_map);
            tgtHand = image( xpos, ypos, pict_data );
            
        case 'text'
            text_str   = target{k}.text;
            text_hgt   = target{k}.hgt * vpix_per_deg;
            text_color = target{k}.color;
            text_angle = target{k}.angle;
            tgtHand = text(xpos, ypos, text_str);
            tgtHand.Color = text_color;
            hgt=0;
            targetHand.FontSize = 6; % about smallest possible legible
            while (hgt < text_hgt)
                extent = tgtHand.Extent; %extent is in pixels
                hgt = extent(4);
                tgtHand.FontSize = tgtHand.FontSize * 1.25;
            end %while
            tgtHand.Rotation = text_angle;
    end % switch shape
    
    %pause(0.25)
    for i=1:extend(k)
        % commented to disable saving individual frames as separate files
        %print( [filename '_' num2str(temp) ext], '-djpeg', '-r0' )  
        F = getframe;
        if mirror
            F.cdata = fliplr(F.cdata);
        end
        writeVideo(stim_mov, F);
    end
    %saveas(fig, [filename '_' num2str(k) ext] )
    delete(tgtHand)
end
renderdur = toc(renderstart);
disp(' ')
disp(['Movie made: ' filename ' in ' pwd '. Duration: ' ... 
                     num2str(moviedur) 'sec. Frame rate: ' num2str(frate) ] )
disp(['Time to make movie: ' num2str(renderdur) ' sec.'])
omdir; cd utils
! open showdock.app
cd(old_dir)
close(stim_mov)
close(fig)
