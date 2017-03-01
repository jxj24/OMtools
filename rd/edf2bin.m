% edf2bin.m: convert an EDF file to a MATLAB-readable binary formatted file.
% As a default, data is arranged in the following column order: [lh rh lv rv],
% but other configurations (including pupil data) are possible.
%
% Exporting data from EDF format requires the 'edf2asc' program from SR Research.
% It is freely available to registered users from their support website at:
% https://www.sr-support.com/forums/index.php
% Select the 'EyeLink Display Software' topic and from there download the version
% for your computer's operating system. Place a copy of the 'edf2asc' executable in
% your OMtools/rd directory to enable this program (edf2bin) to perform the conversion.
%
% This program directly commands edf2asc to export the data to a '.bin' file that has
% the same name as the original .EDF file, and in the same directory.  It is done using
% the following command: edf2asc xxxx.edf -s -y -miss NaN
% Dropped sample points are saved as 'NaN' (the IEEE representation for 'Not a Number').
% Eye-movement events (saccades, fixations and blinks), and other useful EyeLink
% configuration (e.g., screen size and pixels/deg) are saved into a MATLAB
% file with the same name as the EDF plus '_extras.mat'.

% Written by:  Jonathan Jacobs
%              August 2000 - February 2017 (last mod: 02/01/17)

% 05 Apr 12 -- edf files containing multiple trials will now be properly saved
%              in .bin format
%              Can now deal with channels in different order than default
% 09 Apr 12 -- Now can directly read .EDF files without requiring user intervention
%              and modifications of intermediate .ASC file.
% 15 Apr 13 -- Fixed for case when EDF time index (column 1) changes from 6 digits to 7
% 31 Jan 17 -- Oh so many new things!

function edf2bin(~)

curdir = pwd;
cd(findomtools); cd('rd')

if (exist('edf2asc','file') ~= 2)
   disp('To use this version of edf2bin, you need to have a copy of the SR Research')
   disp('executable EyeLink file "edf2asc" installed in the OMtools "rd" directory.')
   disp('If you have registered an account with SR, go to their support website at')
   disp('https://www.sr-support.com/forums/index.php and download the EyeLink Display Software')
   disp('for your platform (Mac, Mac OS X, Windows or Linux.  This will contain the needed file.')
   return
end

try cd(curdir); catch, cd(matlabroot)
end

[fn, pn]=uigetfile({'*.edf'}, 'Select an EDF file to load');
if fn == 0, disp('Aborted.'); return, end
fname = lower(strtok(fn,'.'));

% stripped_uscore = 0;
subjstr=fname;
% if subjstr(end)=='_'
%     subjstr = subjstr(1:end-1);
%     stripped_uscore = 1;
% end

inputfile = ['''' pn fn ''''];
msgsfile =  ['''' pn fname '_msgs' ''''];
datafile =  ['''' pn fname '_data' ''''];
eventfile = ['''' pn fname '_events' ''''];

cd(findomtools); cd('rd')

% search the EDF file for sampling frequency and recorded eye channel(s)
% This is what an entry looks like:  MSG	3964147 RECCFG CR 1000 2 1 LR
eval( [ '! ./edf2asc ' inputfile ' ' msgsfile '  -neye -ns -y ' ] )
eval( [ '! ./edf2asc ' inputfile ' ' eventfile '  -nmsg -ns -y ' ] )
disp('EDF messages exported.')
disp('Searching for channel and frequency information.')
% Use carriage return as delimiter. Each line of msgs is a single MSG.

% Search the MESSAGES file for important keywords
% "START", "RECCFG", "END", "DISPLAY", "RES"
ind = 0; ind2 = 0; sfpos=NaN(); sf=NaN();
msgs = importdata([pn fname '_msgs.asc'],char(13)); % '13' is CR char.
v_pix_deg=1; h_pix_deg=1;eyes=cell(1); start_times=[]; %start_times=cell(1);

%gaze = 0; href = 0;
for ii = 1:length(msgs)
   
   str_temp = strfind( msgs{ii}, 'START');
   if str_temp == 1
      ind2 = ind2 + 1;
      [~, temp] = strtok(msgs{ii});
      [temp,~] = strtok(temp);
      start_times(ind2) = str2double( temp );
   end
   
   k=strfind( msgs{ii},'RECCFG' );
   if k~=0
      ind=ind+1;
      %cfglines(ind) = ii; cfgpos(ind)=k;
      p = strfind( msgs{ii}, '2000');
      if p, sf(ind) = 2000; sfpos(ind)= p; end
      p = strfind( msgs{ii}, '1000');
      if p, sf(ind) = 1000; sfpos(ind)= p; end
      p = strfind( msgs{ii},  '500');
      if p, sf(ind) =  500; sfpos(ind)= p; end
      p = strfind( msgs{ii},  '250');
      if p, sf(ind) =  250; sfpos(ind)= p; end
      
      temp = msgs{ii}(sfpos(ind):end);
      [~, pos_type] = strtok( temp );
      [~, eye_code] = strtok( pos_type );
      
      eyes{ind} = 'none';
      % eyes can be encoded either by l,r, or 1,2,3.
      if strfind(eye_code, '1'), eyes{ind} = 'l'; end
      if strfind(eye_code, '2'), eyes{ind} = 'r'; end
      if strfind(eye_code, '3'), eyes{ind} = 'lr'; end
      
      if strfind(eye_code, 'LR'), eyes{ind} = 'lr'; end
      if ~isempty(strfind(eye_code, 'L')) && isempty(strfind(eye_code, 'R'))
         eyes{ind} = 'l';
      end
      if ~isempty(strfind(eye_code, 'R')) && isempty(strfind(eye_code, 'L'))
         eyes{ind} = 'r';
      end
   end % if k
   
   % e.g. DISPLAY_COORDS 0 0 1279 1023
   disp_coords = strfind( msgs{ii}, 'DISPLAY_COORDS');
   if disp_coords
      %get last two entries in line
      [disp_words,~] = proclinec( msgs{ii} );
      h_pix_z = (str2double( disp_words{end-1})+1)/2;
      v_pix_z = (str2double( disp_words{end} )+1)/2;
   end
   
   pixres = ~isempty(strfind( msgs{ii},'RES')) && strcmp( msgs{ii}(1:3), 'END' );
   if pixres
      %get last two entries in line
      [pix_words,~] = proclinec( msgs{ii} );
      disp(['Vertical pixels/deg: ' pix_words{end}])
      disp(['Horizontal pixels/deg: ' pix_words{end-1}])
      v_pix_deg = str2double( pix_words{end-1} );
      h_pix_deg = str2double( pix_words{end} );
   end
end % for ii


% Now parse the EVENTS file for saccades, fixations, blinks, GAZE and/or HREF
events = importdata([pn fname '_events.asc'],char(13)); % '13' is CR char.
f_found=1; s_found=1; b_found=1;
out_found=0; out_type = 'not found';
for jj = 1:length(events)
   
   str_temp = strfind( events{jj}, 'EVENTS');
   if isempty(str_temp), str_temp = 0; end
   if str_temp == 1 && out_found == 0
      if strfind( events{jj}, 'GAZE');
         out_type = 'gaze';
         out_found = 1;
      elseif strfind( events{jj}, 'HREF');
         out_type = 'href';
         out_found = 1;
      else
         %out_type = 'unknown';
      end
   end
   
   % find fixations
   str_temp = strfind( events{jj}, 'EFIX');
   if str_temp
      [fix_words, numwords]=proclinec(events{jj});
      fix.eye{f_found}=fix_words{2};
      fix.start(f_found) = str2double(fix_words{3});
      fix.end(f_found) = str2double(fix_words{4});
      fix.dur(f_found) = str2double(fix_words{5});
      fix.xpos(f_found) = str2double(fix_words{6});
      fix.ypos(f_found) = str2double(fix_words{7});
      fix.pupi(f_found) = str2double(fix_words{8});
      if numwords > 8
         fix.xres(f_found) = str2double(fix_words{9});
         fix.yres(f_found) = str2double(fix_words{10});
      end
      f_found = f_found+1;
   end
   % find saccades
   str_temp = strfind( events{jj}, 'ESACC');
   if str_temp
      [sac_words, numwords]=proclinec(events{jj});
      sacc.eye{s_found}=sac_words{2};
      sacc.start(s_found) = str2double(sac_words{3});
      sacc.end(s_found) = str2double(sac_words{4});
      sacc.dur(s_found) = str2double(sac_words{5});
      sacc.xpos(s_found) = str2double(sac_words{6});
      sacc.ypos(s_found) = str2double(sac_words{7});
      sacc.xposend(s_found) = str2double(sac_words{8});
      sacc.yposend(s_found) = str2double(sac_words{9});
      sacc.ampl(s_found) = str2double(sac_words{10});
      sacc.pvel(s_found) = str2double(sac_words{11});
      if numwords > 11
         sacc.xres(s_found) = str2double(sac_words{12});
         sacc.yres(s_found) = str2double(sac_words{13});
      end
      s_found=s_found+1;
   end
   %find blinks
   str_temp = strfind( events{jj}, 'EBLINK');
   if str_temp
      [blink_words, ~]=proclinec(events{jj});
      blink.eye{b_found} = blink_words{2};
      blink.start(b_found) = str2double(blink_words{3});
      blink.end(b_found) = str2double(blink_words{4});
      blink.dur(b_found) = str2double(blink_words{5});
      b_found=b_found+1;
   end
end %jj


% now we'll export the samples.
eval([ '! ./edf2asc ' inputfile  ' ' datafile ' -s -y -miss NaN' ] )
disp('EDF to ASCII conversion completed.')
disp('Importing converted data into MATLAB.  Patience is a virtue.')
raw = importdata([pn fname '_data.asc']);
if isempty(raw)
   disp('No eye movement data found. Aborting')
   return
end

%assignin('base','raw', raw)
cd(curdir)

% chop off everything after the final tab.  This will remove the non-numeric last coluumn.
disp('Data successfully loaded.  Converting to numeric values.  Tick tock, tick tock.')
rawlen = length(raw);
timecol = cell(rawlen,1);
numcols = zeros(rawlen,1);
out = cell(rawlen,1);

for i = 1:rawlen
   temp = raw{i};
   tabs = find(temp == 9);
   numcols(i) = length(tabs);
   timecol{i} = raw{i}(1:tabs(1)-1);
   out{i,:} = raw{i}(tabs(1): tabs(end)-1);
end

% check num of entries in each line, because number of channels
% can change between subtrials.
temp = numcols(1:end-1)-numcols(2:end);
chan_chg = find(temp~=0) + 1;
if chan_chg
   disp(['The number of channels changed following trial(s): ' num2str(chan_chg)])
   blockstarts = [1 chan_chg];
   blockstops  = [chan_chg-1 rawlen];
   block=cell(length(blockstarts));
   for j = 1:length(blockstarts)
      block{j} = cell2mat(out( blockstarts(j):blockstops(j) ,:));
   end
else
   block{1} = cell2mat(out);
   blockstarts = 1;
   blockstops = rawlen;
end
numblocks=length(block);
disp('')

cd(pn)
files = 0;
%filestarts = NaN(1,length(block));
%filestops = NaN(1,length(block));
for z = 1:length(block)
   temp = block{z};
   out = str2num(temp); % because str2double gives 'NaN' for array
   
   % display the number of channels, ask whether user wants to view them
   % or simply enter/verify channel order.
   [numsamps,numcols] = size(out);
   disp(' ')
   disp(['Block ' num2str(z) ' of ' num2str(numblocks) ])
   disp([ '  ' num2str(numcols) ' channels detected.'])
   disp([ '  ' num2str(numsamps) ' samples detected.'])
   
   % use slower str2double because cell2mat chokes when
   % 6-digit time becomes 7-digit time during recording session.
   times_str = timecol(blockstarts(z):blockstops(z),1);
   %t=zeros(size(times_str,1),size(times_str,2));
   t=str2double(times_str);
   % For multiple records in a single EDF file, there will be gaps in time between
   % each experiment. Use them to separate the experiments.
   tdiff=t(2:end) - t(1:end-1);
   filestops = find(tdiff > 100 )';
   filestops =  [ filestops numsamps ];
   filestarts = [ 1 filestops(1:end-1)+1];
   numfilestops = length(filestops);
   
   if isempty(filestops) || length(filestops)==1
      % if there are no record separator lines, just
      % use the last row of the data as the end point
      disp( '  Only 1 trial detected.' )
      % no need for '_x' in file name
      singleton = 1;
      filestarts = 1;
      filestops = numsamps;
   else
      disp([ '  ' num2str(numfilestops) ' trials detected.'])
      disp([ '  Separations at lines: ' num2str(filestops)] )
      septrials = 'y';
      %septrials = input('  Treat as individual trials? (y/n) ','s');
      if  strfind( septrials, 'y' )
         filestarts = [1, (filestops+1)];
      else
         filestarts = 1;
         filestops = numsamps;
      end
      singleton = 0;
   end
   
   % default chan vals coming FROM edf2asc
   %lh_chan=1; lv_chan=2; rh_chan=4; rv_chan=5;
   numfilestops = length(filestops);
   for x = 1:numfilestops
      clear rh_chan rv_chan lh_chan lv_chan
      disp(' ')
      disp( [' Record ' num2str(files+x)] )
      disp( ['  Starting time: ' num2str(start_times(x)) ])
      disp( ['  Sampling frequency: ' num2str( sf(files+1) ) ])
      switch numcols
         case 7
            disp( 'Default EDF->ASC export assumption: ' )
            disp( '   1) time, 2) lh, 3) lv, 4) lp (pupil), 5) rh, 6) rv, 7) rp' )
            disp( '   Will save in this order: [lh rh lv rv]' )
            ch_err_flag=1;
            yorn = input('Is this correct? (y/n) ','s');
            if strcmpi(yorn,'y')
               lh_chan=2; lv_chan=3; rh_chan=5; rv_chan=6;
               ch_err_flag = 0;
            end
            
         case 6
            %disp( 'Default EDF->ASC export assumption: ' )
            %disp( '   1) lh, 2) lv, 3) lp (pupil), 4) rh, 5) rv, 6) rp' )
            disp( '  Will save in this order: [lh rh lv rv]' )
            ch_err_flag=1;
            %yorn = input('Is this correct? (y/n) ','s');
            yorn='y';
            if strcmpi(yorn,'y')
               lh_chan=1; lv_chan=2; rh_chan=4; rv_chan=5;
               ch_err_flag = 0;
            end
            
         case 5
            disp( 'Default EDF->ASC export assumption: ' )
            disp( '   1) lh, 2) lv, 3) lp (pupil), 4) rh, 5) rv' )
            disp( '   Will save in this order: [lh rh lv rv]' )
            ch_err_flag=1;
            yorn = input('Is this correct? (y/n) ','s' );
            if strcmpi(yorn,'y')
               lh_chan=1; lv_chan=2; rh_chan=4; rv_chan=5;
               ch_err_flag = 0;
            end
            
         case 3
            %ch_err_flag = 1;
            if strcmpi( eyes{files+1}, 'l' )
               lh_chan=1; lv_chan=2;
               disp( '  Left eye only.' )
               disp( '  Will save in this order: [ lh lv ]')
            elseif strcmpi( eyes{files+1}, 'r')
               rh_chan=1; rv_chan=2;
               disp( '  Right eye only.' )
               disp( '  Will save in this order: [ rh rv ]')
            end
            ch_err_flag = 0;
            
         otherwise
            disp( 'I do not know the order of the channels here.' )
            ch_err_flag = 1;
            clear rh_chan rv_chan lh_chan lv_chan
      end %switch numcols
      
      % If none of the known cases exist, prompt the user for the channel names.
      % might need this if the data were taken in an unusual form, e.g., monocularly.
      strarray = [ {'lh'},{'rh'},{'lv'},{'rv'},{'lp'},{'rp'} ];
      % name the channels
      if ch_err_flag
         sampfreq = sf(files+1);
         for i=1:numcols
            chtemp = out(:,i); t=maket(chtemp,sampfreq);
            figure; plot(t,chtemp)
            commandwindow
            chname{i} = input(['Enter a name for channel ' num2str(i) '.  Enter "-" to ignore it: '],'s');
            chpos = strcmp(chname{i}, strarray);
            if chpos
               eval( [strarray{chpos} '_chan = i;'])
               %disp(['   Assigning channel ' str2num(i) ' as ' chname{i} '.'] )
            end
         end
      end
      
      % time to write out to file(s)
      clear temp
      dat = NaN();
      if exist('lh_chan','var')
         dat = -(out(filestarts(x):filestops(x),lh_chan)-h_pix_z) / h_pix_deg;
      end
      if exist('rh_chan','var')
         dat = [dat,-(out(filestarts(x):filestops(x),rh_chan)-h_pix_z) / h_pix_deg];
      end
      if exist('lv_chan','var')
         dat = [dat, (out(filestarts(x):filestops(x),lv_chan)-v_pix_z) / v_pix_deg];
      end
      if exist('rv_chan','var')
         dat = [dat, (out(filestarts(x):filestops(x),rv_chan)-v_pix_z) /v_pix_deg];
      end
      if singleton
         temp{x} = [subjstr '.bin'];
      else
         temp{x} = [subjstr '_' num2str(files+x) '.bin'];
      end
      fid = fopen(temp{x}, 'w', 'n');
      fwrite(fid, dat, 'float');
      fclose(fid);
      disp(['  Saved as ' '''' pn temp{x} ''''])
   end
   files = files + length(filestops);
end % for z

% save all the accessory data
% h_pix_deg, v_pix_deg, start_timess sacc, fix, blink
if exist('fix','var')
   assignin('base','fix',fix);     extras.fix = fix;
end
if exist('sacc','var')
   assignin('base','sacc',sacc);   extras.sacc = sacc;
end
if exist('blink','var')
   assignin('base','blink',blink); extras.blink = blink;
end

extras.start_times = start_times;
extras.out_type = out_type;
extras.numsamps = numsamps;
extras.h_pix_z = h_pix_z;
extras.v_pix_z = v_pix_z;
extras.h_pix_deg = h_pix_deg;
extras.v_pix_deg = v_pix_deg;
eval( [fname '_extras = extras;'] )
save([fname '_extras.mat'],[fname '_extras'] )

try cd(curdir); catch, cd(matlabroot); end

disp(' ')
disp(['Horizontal pixels/deg: ' num2str(v_pix_deg)])
disp(['Vertical pixels/deg: '   num2str(h_pix_deg)])
disp(' ')

% because why would you record several records, each w/separate sampfreq?
edfbiasgen(fname,pn,sf(1),files)

disp('If you don''t like the bias file, delete it and recreate it by running')
disp('"biasgen" yourself. You will need to know the sampling frequency')
disp('used to take the data, as well as which channels were recorded.')
disp('Biasgen should offer a simple choice "Imported from EDF (binocular)". If not,')
disp('use the following parameters: Method is (V)ideo, Format is (B)inary,')
disp('Calibration is (N)ormal, and Channel Structure is (C)ontiguous.')