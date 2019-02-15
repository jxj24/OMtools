% edf2bin.m: convert an EDF file to a MATLAB-readable binary formatted file.
% usage:  numrecs = edf2bin(fn,pn,options)
% OUTPUT: numrecs = number of distinct recordings in the EDF file
% INPUT:  fn,pn: name and path of the EDF file to be read.
%         (fn can incorporate the path, leaving pn empty.)
%         options: 'pupil' will save pupil data. Data is saved into a
%         separate file based on the name (and subrecord) of the EDF file.
% NOTE:   Input arguments are optional. If no file/path is specified, you'll  
%         be prompted to select the EDF file using a "Get File" dialog.
%
% As a default, data is arranged in the following column order: [lh rh lv rv],
% but other configurations (including pupil data) are possible.
%
% Exporting data from EDF format requires the 'edf2asc' program from SR Research.
% It is freely available to registered users from their support website at:
% https://www.sr-support.com/forums/index.php
% Select the 'EyeLink Display Software' topic and from there download the 
% Developers Kit for your computer's operating system. 
%
% This program directly commands edf2asc to export the data to a '.bin'
% file with the same name as the original .EDF file, and in the same directory. 
% It is done using the following command: edf2asc xxxx.edf -s -y -miss NaN
%
% Dropped sample points are saved as 'NaN' (IEEE-speak for 'Not a Number').
% Eye-movement events (saccades, fixations and blinks), and other useful
% Eyelink configuration (e.g., screen size and pixels/deg) are saved into a 
% MATLAB file with the same name as the EDF plus '_extras.mat'.
% Similarly, pupil samples are saved as '_pupil.mat'.

% Written by:  Jonathan Jacobs
%              August 2000 - February 2019 (last mod: 02/03/19)

% 05 Apr 12 -- EDF files containing multiple trials will now be properly saved
%              in .bin format
%              Can now deal with channels in different order than default
% 09 Apr 12 -- Now can directly read .EDF files without requiring user 
%              intervention and modifications of intermediate .ASC file.
% 15 Apr 13 -- Fixed for case when EDF time (col 1) changes from 6 digits to 7
% 31 Jan 17 -- Oh so many new things!
% 03 Jul 17 -- Fixed for when there is more than 1 record, find the
%              h_pix_deg & v_pix_deg for each record.
%			      Saccades, fixations, blinks, and video frames are also now 
%			      separated by record and saved in the proper _extras.mat file
% 07 Jul 17 -- Calls to edf2asc executable should now work for Linux and maybe Windows.
%              Detects if Eyelink Dev Kit has installed edf2asc and directs user to
%              SR-support website if platform-appropriate edf2asc was not present.
% 24 Jul 18 -- Now properly handles EDFs with multiple sub-recordings that have
%              different channels in each record
% 03 Feb 19 -- Added option to save pupil data to a file

function numfiles = edf2bin(varargin)

curdir = pwd;
cd(findomtools); cd('rd')

% directory containing the edf2asc binary:
% OS X:   /Applications/Eyelink/EDF_Access_API/Example/
% Windoz: "C:\Program Files (x86)\SR Research\EyeLink\EDF_Access_API\Example"
% Linux:  /usr/share/edfapi/EDF_Access_API/Example
fsp = filesep;
bindir_err=0; binfile_err=0;
if isunix
   if ismac
      bindir='/Applications/Eyelink/EDF_Access_API/Example/';
   else
      bindir='/usr/share/edfapi/EDF_Access_API/Example';
   end
elseif ispc
   bindir='C:\Program Files (x86)\SR Research\EyeLink\EDF_Access_API\Example';
end

try    cd(bindir)
catch, bindir_err=1;
end
if (exist('edf2asc','file') ~= 2), binfile_err=1; end
if bindir_err==1 || binfile_err==1
   disp(['The directory ' bindir ' does not exist.'])
   disp('Make sure that you have installed the Eyelink Developers Kit for')
   disp('for your platform. Login to the SR Support web site at:')
   disp('https://www.sr-support.com/forum/downloads/eyelink-display-software')
   return
end

% special OS X exception for modified edf2asc that properly handles
% video ett stuff. (Built by Peggy Skelly and Jonathan Jacobs 2017.)
[rdp,~,~] = fileparts(which(mfilename));
if exist([rdp fsp 'edf2asc'],'file')
   binfile=[rdp fsp 'edf2asc ']; % Note the trailing space!
else
   binfile=[bindir 'edf2asc ']; % Note the trailing space!
end

try cd(curdir); catch, cd(matlabroot); end

savepupils=0;
if nargin==0
   fn=[];pn=[];
else
   savepupils=find(contains(lower(varargin),'pupil'));
   is_pn = find(contains(varargin,filesep));
   is_fn = find(contains(varargin,'.'));

   if is_fn, fn=varargin{is_fn};
   else,     fn=[];
   end
   
   if is_pn, pn=varargin{is_pn};
   else,     pn=pwd;
   end
   
   if all(is_pn==is_fn) && any(is_fn)
      % do we care?
   end
end

if isempty(fn)
   [fn,pn]=uigetfile({'*.edf; *.EDF'}, 'Select an EDF file to load');
   if fn==0, disp('Aborted.'); return, end
end

tic
fname = strtok(fn,'.');


% stripped_uscore = 0;
subjstr=fname;
% if subjstr(end)=='_'
%     subjstr = subjstr(1:end-1);
%     stripped_uscore = 1;
% end
inputfile = pathsafe( ['' pn fn ''] );
msgsfile  = pathsafe( ['' pn fname '_msgs' ''] );
datafile  = pathsafe( ['' pn fname '_data' ''] );
eventfile = pathsafe( ['' pn fname '_events' ''] );

% for Scenelink info edf2asc must be called in the same folder that also
% has the *.ett file. That's just edf2asc.
cd(findomtools); cd('rd')
cd(pn)

%{
disp('')
disp('Export samples as [G]aze (eye in space) or [H]REF (eye in head)?')
horg = input('-> ','s');
if strcmpi(horg,'h')
   disp('Exporting HREF data')
   exp = ' -sh ';
   samptype = 'HREF';
elseif strcmpi(horg,'g')
   disp('Exporting Gaze data')
   exp = ' -sg ';
   samptype = 'GAZE';
end
%}

% HREF is not supported yet, so I'm commenting out the option to ask for it
exp = ' -sg ';
samptype = 'GAZE';

sc_flag = '';
ett_file = strrep(fn,'.EDF', '0.ett');
if exist(ett_file, 'file') % matching the file name is case sensitive!
   sc_flag = ' -scenecam';
end

% search the EDF file for sampling frequency and recorded eye channel(s)
% This is what an entry looks like:  MSG	3964147 RECCFG CR 1000 2 1 LR
a=[binfile inputfile ' ' msgsfile exp sc_flag ' -neye -ns -y '];
system(a);
a=[binfile inputfile ' ' eventfile exp ' -nmsg -ns -y '];
system(a);
disp('EDF messages exported.')
disp('Searching for channel and frequency information.')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Search the MESSAGES file for important keywords
%  "START", "RECCFG", "END", "DISPLAY", "RES", "VFRAME"
% Use carriage return as delimiter. Each line of msgs is a single MSG.
ind = 0; ind2 = 1; sfpos=NaN(); sf=NaN();
msgs = importdata([pn fname '_msgs.asc'],char(13));
eyes=cell(1); chname=cell(1);
v_found=1; %gaze = 0; href = 0;
vf = struct;
fix = struct;
sacc = struct;
blink = struct;
v_pix_deg = zeros(); h_pix_deg = zeros();
start_time = zeros(); end_time = zeros();
%filestops = zeros(); filestarts = zeros();

h_pix_d=NaN; v_pix_d=NaN;
h_pix_g=NaN; v_pix_g=NaN;
for ii = 1:length(msgs)
   % find START
   str_temp = strfind(msgs{ii}, 'START');
   if str_temp==1
      [~, temp]=strtok(msgs{ii});
      [temp,~]=strtok(temp);
      start_time(ind2)=str2double( temp );
   end
   % e.g. DISPLAY_COORDS 0 0 1279 1023
   disp_coords = strfind(msgs{ii}, 'DISPLAY_COORDS');
   if disp_coords
      %get last two entries in line
      [disp_words,~] = proclinec( msgs{ii} );
      h_pix_d = (str2double(disp_words{end-1})+1)/2;
      v_pix_d = (str2double(disp_words{end} )+1)/2;
   end
   gaze_coords = strfind(msgs{ii}, 'GAZE_COORDS');
   if gaze_coords
      %get last two entries in line
      [disp_words,~] = proclinec( msgs{ii} );
      h_pix_g = (str2double(disp_words{end-1})+1)/2;
      v_pix_g = (str2double(disp_words{end} )+1)/2;
   end
   % find sampling frequency
   k=strfind( msgs{ii},'RECCFG' );
   if k~=0
      ind=ind+1;
      %cfglines(ind) = ii; cfgpos(ind)=k;
      % if the sampling freq number is also in the time, then it finds the
      % number in the time string. Only look in the msg string after k
      % (index to start of 'RECCFG') - samp freq must be after 'RECCFG'
      % Look at p(end) because it is possible that "500" (or other string)
      % could appear earlier in the line, prob as part of the time string.
      p=strfind(msgs{ii},'2000');
      if ~isempty(p) && p(end)>k, sf(ind)=2000; sfpos(ind)=p(end); end
      p=strfind(msgs{ii},'1000');
      if ~isempty(p) && p(end)>k, sf(ind)=1000; sfpos(ind)=p(end); end
      p=strfind(msgs{ii},'500');
      if ~isempty(p) && p(end)>k, sf(ind)=500;  sfpos(ind)=p(end); end
      p=strfind(msgs{ii},'250');
      if ~isempty(p) && p(end)>k, sf(ind)=250;  sfpos(ind)=p(end); end

      temp = msgs{ii}(sfpos(ind):end);
      [~, pos_type] = strtok(temp);
      [~, eye_code] = strtok(pos_type);

      eyes{ind} = 'none';
      % eyes can be encoded either by l,r, or 1,2,3.
      if contains(eye_code,'1'), eyes{ind}='l'; end
      if contains(eye_code,'2'), eyes{ind}='r'; end
      if contains(eye_code,'3'), eyes{ind}='lr'; end

      if contains(eye_code,'L') && ~contains(eye_code,'R'), eyes{ind}='l'; end
      if contains(eye_code,'R') && ~contains(eye_code,'L'), eyes{ind}='r'; end
      if contains(eye_code,'LR'), eyes{ind}='lr'; end      
   end % if k

   % find pixel resolution
   pixres = ~isempty(strfind(msgs{ii},'RES')) && strcmp(msgs{ii}(1:3),'END' );
   if pixres
      %get last two entries in line
      [pix_words,~] = proclinec( msgs{ii} );
      disp(['Vertical pixels/deg: ' pix_words{end}])
      disp(['Horizontal pixels/deg: ' pix_words{end-1}])
      v_pix_deg(ind2) = str2double(pix_words{end-1} );
      h_pix_deg(ind2) = str2double(pix_words{end} );
   end
   vframe = ~isempty(strfind(msgs{ii},'VFRAME'));
   if vframe
      [vframe_words,~] = proclinec(msgs{ii} );
      vf(ind2).framenum(v_found)  = str2double(vframe_words{4});
      vf(ind2).frametime(v_found) = str2double(vframe_words{2});
      v_found=v_found+1;
   end
   str_temp = strfind(msgs{ii}, 'END');
   if str_temp == 1
      [~, temp] = strtok(msgs{ii});
      [temp,~]  = strtok(temp);
      end_time(ind2) = str2double(temp);
      ind2 = ind2+1;
   end
end % for ii

if length(start_time) ~= length(end_time)
   disp('The number of recording stop times does not equal')
   disp('the number of recording start times!')
   disp('The EDF file may be damaged.')
   return
end

% Display coords SHOULD have been set. If not, take a chance & use GAZE coords
if isnan(v_pix_d)|| isnan(h_pix_d)
   h_pix_z = h_pix_g;
   v_pix_z = v_pix_g;
else
   h_pix_z = h_pix_d;
   v_pix_z = v_pix_d;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse the EVENTS file for saccades, fixations, blinks, GAZE and/or HREF
events = importdata([pn fname '_events.asc'],char(13)); % '13' is CR char.
% f_found=1; s_found=1; b_found=1;
f_found=0; s_found=0; b_found=0;
%out_found=0;
out_type = 'not found';
recnum = 0; % no records yet, 'START' will indicate a new record
for jj = 1:length(events)
   %disp(events{jj})
   if length(events{jj})>=17
      split_line = proclinec(events{jj});

	  switch split_line{1}	% examine the 1st word in the line
		  case 'START'
			  recnum = find(start_time <= str2double(split_line{2}),1,'last');
			  f_found=0; s_found=0; b_found=0;
		  case 'EVENTS'
			  out_type = lower(split_line{2});
		  case 'EFIX'
			  f_found = f_found+1;
			  fix(recnum).eye{f_found}=split_line{2};
			  fix(recnum).start(f_found) = str2double(split_line{3});
			  fix(recnum).end(f_found)  = str2double(split_line{4});
			  fix(recnum).dur(f_found)  = str2double(split_line{5});
			  fix(recnum).xpos(f_found) = str2double(split_line{6});
			  fix(recnum).ypos(f_found) = str2double(split_line{7});
			  fix(recnum).pupi(f_found) = str2double(split_line{8});
			  if length(split_line) > 8
				  fix(recnum).xres(f_found) = str2double(split_line{9});
				  fix(recnum).yres(f_found) = str2double(split_line{10});
			  end

		  case 'ESACC'
			  s_found=s_found+1;
			  sacc(recnum).eye{s_found}=split_line{2};
			  sacc(recnum).start(s_found) = str2double(split_line{3});
			  sacc(recnum).end(s_found) = str2double(split_line{4});
			  sacc(recnum).dur(s_found) = str2double(split_line{5});
			  sacc(recnum).xpos(s_found) = str2double(split_line{6});
			  sacc(recnum).ypos(s_found) = str2double(split_line{7});
			  sacc(recnum).xposend(s_found) = str2double(split_line{8});
			  sacc(recnum).yposend(s_found) = str2double(split_line{9});
			  sacc(recnum).ampl(s_found) = str2double(split_line{10});
			  sacc(recnum).pvel(s_found) = str2double(split_line{11});
			  if length(split_line) > 11
				  sacc(recnum).xres(s_found) = str2double(split_line{12});
				  sacc(recnum).yres(s_found) = str2double(split_line{13});
			  end

		  case 'EBLINK'
			  b_found=b_found+1;
			  blink(recnum).eye{b_found} = split_line{2};
			  blink(recnum).start(b_found) = str2double(split_line{3});
			  blink(recnum).end(b_found) = str2double(split_line{4});
			  blink(recnum).dur(b_found) = str2double(split_line{5});

	  end % switch case first word of the line
   end % if length of line is long enough to bother looking at
end %jj EVENTS scan loop


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% now export the samples.
disp('')
a=[binfile inputfile ' ' datafile exp ' -s -t -y -nflags -miss NaN'];
system(a);
disp('EDF to ASCII conversion completed.')
disp('Importing converted data into MATLAB. Patience is a virtue.')
raw = importdata([pn fname '_data.asc'],'\t');
if isempty(raw)
   disp('No eye-movement data found. Aborting.')
   return
end
cd(curdir)

% chop off everything after the final tab to remove the non-numeric last column.
disp('Data successfully loaded. Converting to numeric values. Tick tock, tick tock.')
%rawlen = length(raw);
%numcols = zeros(rawlen,1);
%datatxt = cell(rawlen,1);

%tic
timecol = raw(:,1);
data    = raw(:,2:end);
%{
for i = 1:rawlen
   temp = raw{i};
   rawtabs = find(temp == 9);
   numcols(i) = length(rawtabs);
   timecol{i} = raw{i}(1:rawtabs(1)-1);
   rest = raw{i}( rawtabs(1):rawtabs(end) );
   tabs = find(rest == 9);   
   for j = 1:length(tabs)-1
      data(i,j) = str2double( rest(tabs(j)+1:tabs(j+1)) );
   end   
end
toc

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
      block{j} = cell2mat(datatxt( blockstarts(j):blockstops(j) ,:));
   end
else
  block{1} = data;
  blockstarts = 1;
  blockstops = rawlen;
end
numblocks=length(block);
disp('')
%}

block{1} = data;
numblocks=length(block);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(pn)
files = 0;
%filestarts = NaN(1,length(block));
%filestops = NaN(1,length(block));
for z = 1:length(block)
   data = block{z}; % because str2double gives 'NaN' for array

   % display the number of channels, ask whether user wants to view them
   % or simply enter/verify channel order.
   [numsamps,numcols] = size(data);
   disp(' ')
   disp(['Block ' num2str(z) ' of ' num2str(numblocks) ])
   disp([ '  ' num2str(numcols)  ' columns detected.'])
   disp([ '  ' num2str(numsamps) ' samples detected.'])

   % use slower str2double because cell2mat chokes when
   % 6-digit time becomes 7-digit time during recording session.
   %times_str = timecol(blockstarts(z):blockstops(z),1);
   %t=zeros(size(times_str,1),size(times_str,2));
   t_el=timecol; %%%str2double(times_str);
   % For multiple records in a single EDF file, there will be gaps in time 
   % between each experiment. Use them to separate the experiments.
   tdiff = t_el(2:end) - t_el(1:end-1);
   filestops = find(tdiff > 30);	% changed 100 to 30
   filestops = cat(1, filestops,numsamps);
   %filestarts = cat(1, 1,filestops(1:end-1)+1);
   numfilestops = length(filestops);

   if isempty(filestops) || length(filestops)==1
      % if there are no record separator lines, just
      % use the last row of the data as the end point
      disp('  Only 1 trial detected.')
      % no need for '_x' in file name
      singleton = 1;
      filestarts = 1;
      filestops = numsamps;
   else
      disp(['  ' num2str(numfilestops) ' trials detected.'])
      disp(['  Separations at lines: ' mat2str(filestops)] )
      %septrials = 'y';
      septrials = input('  Treat as individual records? (y/n) ','s');
      if  contains( septrials, 'y' )
         filestarts = [1; (filestops+1)];
         singleton = 0;
      else
         filestarts = 1;
         filestops = numsamps;
         singleton=1;
      end
   end

   % default chan vals coming FROM edf2asc
   % lh_chan=1; lv_chan=2; rh_chan=4; rv_chan=5;
   % out_chans is the order data will be SAVED in the .BIN file
   numfilestops = length(filestops);
   out_chans=cell(numfilestops,1); 
   for x = 1:numfilestops
      clear rh_chan rv_chan lh_chan lv_chan
      disp(' ')
      disp( [' Record ' num2str(files+x)] )
      disp( ['   Samples: ' num2str(filestops(x)-filestarts(x))] )
      disp( ['   Starting time: ' num2str(start_time(x)) ])
      disp( ['   Sampling frequency: ' num2str( sf(files+1) ) ])
      switch numcols
         case 7
            disp( 'Default EDF->ASC export assumption: ' )
            disp( '   1) time, 2) lh, 3) lv, 4) lp (pupil), 5) rh, 6) rv, 7) rp' )
            disp( '   Will save in this order: [lh rh lv rv]' )
            ch_err_flag=1;
            commandwindow
            yorn = input('Is this correct? (y/n) ','s');
            if strcmpi(yorn,'y')
               lh_chan=2; lv_chan=3; lp_chan=4; rh_chan=5; rv_chan=6; rp_chan=7;
               %out_chans = {'lh';'rh';'lv';'rv'};
               ch_err_flag = 0;
            end

         case 6
            %disp( 'Default EDF->ASC export assumption: ' )
            %disp( '   1) lh, 2) lv, 3) lp (pupil), 4) rh, 5) rv, 6) rp' )
            disp( '   Will save in this order: [lh rh lv rv]' )
            ch_err_flag=1;
            %yorn = input('Is this correct? (y/n) ','s');
            yorn='y';
            if strcmpi(yorn,'y')
               lh_chan=1; lv_chan=2; lp_chan=3; rh_chan=4; rv_chan=5; rp_chan=6;
               %out_chans = {'lh';'rh';'lv';'rv'};
               ch_err_flag = 0;
            end

         case 5
            disp( 'Default EDF->ASC export assumption: ' )
            disp( '   1) lh, 2) lv, 3) lp (pupil), 4) rh, 5) rv' )
            disp( '   Will save in this order: [lh rh lv rv]' )
            ch_err_flag=1;
            commandwindow
            yorn = input('Is this correct? (y/n) ','s' );
            if strcmpi(yorn,'y')
               lh_chan=1; lv_chan=2; rh_chan=4; rv_chan=5;
               %out_chans = {'lh';'rh';'lv';'rv'};
               ch_err_flag = 0;
            end

         case 3
            %ch_err_flag = 1;
            if strcmpi( eyes{files+1}, 'l' )
               lh_chan=1; lv_chan=2; lp_chan=3;
               %out_chans = {'lh';'lv'};
               disp( '   Left eye only.' )
               disp( '   Will save in this order: [ lh lv ]')
            elseif strcmpi( eyes{files+1}, 'r')
               rh_chan=1; rv_chan=2; rp_chan=3;
               %out_chans = {'rh';'rv'};
               disp( '   Right eye only.' )
               disp( '   Will save in this order: [ rh rv ]')
            end
            ch_err_flag = 0;

         otherwise
            disp( 'I do not know the order of the channels here.' )
            ch_err_flag = 1;
            clear rh_chan rv_chan lh_chan lv_chan
      end %switch numcols

      % If none of the known cases exist, prompt for the channel names.
      % Needed if data were taken in an unusual way, e.g., monocularly.
      strarray = [ {'lh'},{'rh'},{'lv'},{'rv'},{'lp'},{'rp'} ];
      % name the channels
      if ch_err_flag
         sampfreq = sf(files+1);
         for i=1:numcols
            chtemp = data(:,i); t=maket(chtemp,sampfreq);
            figure; plot(t,chtemp)
            commandwindow
            chname{i} = input(['Enter a name for channel ' num2str(i) ...
               '. Enter "-" to ignore it: '],'s');
            chpos = strcmp(chname{i}, strarray);
            if chpos
               eval( [strarray{chpos} '_chan = i;'])
               %disp(['   Assigning channel ' str2num(i) ' as ' chname{i} '.'] )
            end
         end
      end

      clear temp
      if singleton, temp{x} = subjstr;
      else,         temp{x} = [subjstr '_' num2str(files+x)]; end

      % save all the accessory data
      % h_pix_deg, v_pix_deg, start_timess sacc, fix, blink
      if exist('fix','var'),   extras.fix  = fix(x);   end
      if exist('sacc','var'),  extras.sacc = sacc(x);  end
      % if there is more than 1 record, and no blinks in any of the records,
      % then blink is an empty struc and accessing blink(2) causes an error
      if exist('blink','var') && x<=length(blink)  
		  extras.blink = blink(x);
      end
      if exist('vf','var') && x<=length(vf) % ~isempty(vf)
         extras.vf = vf(x);
      else
         extras.vf = [];
      end
      extras.start_times = start_time(x);
      extras.end_times   = end_time(x); % actually 1ms AFTER final sample!!!!!
      extras.out_type = out_type;

      extras.numsamps = filestops(x)-filestarts(x)+1; % samples in this record
      extras.samptype = samptype;
      extras.sampfreq = sf(x);
      extras.h_pix_z = h_pix_z;
      extras.v_pix_z = v_pix_z;
      extras.h_pix_deg = h_pix_deg(x);	% each trial has its own resolution
      extras.v_pix_deg = v_pix_deg(x);
      extras.t_el.first = t_el(1);
      extras.t_el.last  = t_el(end);
      %extras.vf = vf;
      eval( [temp{x} '_extras = extras;'] )
      save([temp{x} '_extras.mat'],[temp{x} '_extras'] )

      % Conversion from EL GAZE values to degrees:
      dat_out = [];
      c=0;
      seg = filestarts(x):filestops(x);
      if exist('lh_chan','var') && ~all(isnan(data(seg,lh_chan)))
         dat_out = ( data(seg,lh_chan)-h_pix_z )/h_pix_deg(x);
         c=c+1;
         out_chans{x}{c}='lh';
      end
      if exist('rh_chan','var') && ~all(isnan(data(seg,rh_chan)))
         dat_out = cat(1,dat_out,( data(seg,rh_chan)-h_pix_z )/h_pix_deg(x));
         c=c+1;
         out_chans{x}{c}='rh';
      end
      if exist('lv_chan','var') && ~all(isnan(data(seg,lv_chan)))
         dat_out = cat(1,dat_out, -( data(seg,lv_chan)-v_pix_z )/v_pix_deg(x));
         c=c+1;
         out_chans{x}{c}='lv';
      end
      if exist('rv_chan','var') && ~all(isnan(data(seg,rv_chan)))
         dat_out = cat(1,dat_out, -( data(seg,rv_chan)-v_pix_z )/v_pix_deg(x));
         c=c+1;
         out_chans{x}{c}='rv';
      end
      % pupils get saved in _pupil.mat file
      if savepupils
         goodpupil=0;
         if exist('rp_chan','var') && ~all(isnan(data(seg,rp_chan)))
            pupil.r = data(seg,rp_chan);
            goodpupil=1;
         end
         if exist('lp_chan','var') && ~all(isnan(data(seg,lp_chan)))
            pupil.l = data(seg,lp_chan);
            goodpupil=1;
         end
         if goodpupil
            eval( [temp{x} '_pupil = pupil;'] )
            save([temp{x} '_pupil.mat'],[temp{x} '_pupil'] )
         end
      end

      % look for st,sv data?
      stsv=0;
      %disp(' ')
      %yorn=input('Do you want to try to add target data (y/n)? ','s');
      yorn='y';
      if strcmpi(yorn,'y')
         [st,sv] = tgt_recon([pn temp{x}]);
         if ~isempty(st)
            dat_out=cat(1,dat_out,st);
            c=c+1;
            out_chans{x}{c}='st';
            stsv=1;disp('   st data added');
         end
         if ~isempty(sv)
            dat_out=cat(1,dat_out,sv);
            c=c+1;
            out_chans{x}{c}='sv';
            stsv=1;disp('   sv data added');
         end
      end
      % Conversion from EL HREF values to degrees:
      %%%%% someday maybe?

      % write the EM data to file
      fid = fopen([temp{x} '.bin'], 'w', 'n');
      fwrite(fid, dat_out, 'float');
      fclose(fid);
      disp([' Data saved as ' pn temp{x} '.bin' ])
   end
   files = files + length(filestops);
end % for z

try cd(curdir); catch, cd(matlabroot); end

delete([pn fname '_data.asc'])

disp(' ')
toc
%disp(['Horizontal pixels/deg: ' num2str(v_pix_deg)])
%disp(['Vertical pixels/deg: '   num2str(h_pix_deg)])
%disp(' ')

% because why would you record several records, each w/separate sampfreq?
edfbiasgen(fname,pn,sf(1),files,out_chans,stsv);
numfiles = files;
if nargout<1, clear numfiles; end

disp('If you don''t like the bias file, delete it and recreate it by running')
disp('"biasgen" yourself. You will need to know the sampling frequency')
disp('used to take the data, as well as which channels were recorded.')
disp('Biasgen should offer a simple choice "Imported from EDF (binocular)". If not,')
disp('use the following parameters: Method is (V)ideo, Format is (B)inary,')
disp('Calibration is (N)ormal, and Channel Structure is (C)ontiguous.')
