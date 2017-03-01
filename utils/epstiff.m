% epstiff.m: save a figure as Encapsulated Postscript with a high-quality TIFF preview that won't
% cause MS Word 2004 to vomit and die, the way ones with MATLAB-generated TIFF previews will.
% Why should you care?  Because without any preview, an EPS figure will not show up in Word, which
% is nearly useless.  An EPS figure with a high-quality TIFF preview will look good on the
% screen and when printed, rather than being all fuzzy and pixelated.  
% Reviewers like figures that don't look like crap.  Don't piss them off.
%
% The preview will be greyscale, because color previews are the work of Satan, apparently.
%
% You can call epstiff with a figure number, but if you don't, it will simply use the
% frontmost figure window.
%
% This program requires that 'epstool' be installed.  For Mac OS X users, the easiest way to do 
% this is to use the MacPorts package manager 'Porticus' (http://porticus.alittledrop.com/), once
% you have downloaded and installed MacPorts (http://trac.macports.org/browser/downloads/).
% Finally, note that you must have Apple's free XCode developer tools installed.
%
% After installing epstool, you should verify that these lines have been added to your 
% '.profile' file in your home directory (~/.profile):
% export PATH=$PATH:/opt/local/bin
% export DISPLAY=:0.0 
% (see http://www.tech-recipes.com/rx/2618/os_x_easily_edit_hidden_configuration_files_with_textedit
% for help doing this.)

% Written by:  Jonathan Jacobs
%              September 2008 - March 2010  (last mod 03/16/10)

function epstiff(fig)

compy = computer;
if ~strcmp(compy(1:3), 'MAC')
	disp('''epstiff'' was written for Mac OS X.')
	return
end

if isempty( get(0,'CurrentFigure') )
	disp('''epstiff'' requires an open figure to run.')
	return
end
if exist('findhotw')==2
   if ~exist('fig'), fig = findhotw; end
 else
   if ~exist('fig'), fig = gcf; end
end

% if the file already has a name, we will find it and use it.
file_and_path = get(gcf,'Filename');
if ~isempty(file_and_path)
	fn_start = strfind(file_and_path,'/');
	fn_start = fn_start(end)+1;
	filename = file_and_path(fn_start:end);
	exten_pos = strfind(filename,'.');
	exten_pos = exten_pos(end);
	filename = [filename(1:exten_pos) 'eps'];
  else
    filename = 'figure.eps';
end

% check to see if MacPorts directory exists
if ~isdir('/opt/local/bin')
   disp('You have not installed MacPorts.  Type ''help epstiff'' for more information.')
   return
end

% if it's there, but not already on the PATH, add it.
% http://www.mathworks.de/matlabcentral/newsreader/view_thread/171203
initpath=getenv('PATH');
if isempty( findstr(initpath, 'opt/local/bin') )
	setenv('PATH', [initpath ':/opt/local/bin']);
end

% Now see if epstool was installed.
epstool_installed = exist('/opt/local/bin/epstool');
if epstool_installed ~= 2
   disp('You have not installed epstool.  Type ''help esptiff'' for more information.')
   return
end

% if FIGURE or ANY AXIS has a NON-WHITE background, give user chance to invert it for export
figBGcolor=get(fig,'Color'); figBGflag=0; noneFlag=0;
if isstr(figBGcolor)
	figBGflag=1;		%% color = 'none'
	noneFlag = 1;
 else
	if ~all(figBGcolor==1)
		figBGflag=1;
	end
end

% the 'noneflag' should probably apply only to the figure bg color.
children=get(fig,'Children'); axBGflag=0;
for i=1:length(children)
	if strcmp(get(children(i),'Type'),'axes')
		axBGcolor = get(children(i),'color');
		if isstr(axBGcolor)
			axBGflag=1;		%% color = 'none'
			noneFlag = 1;
		 else
			if ~all(axBGcolor==1)
				axBGflag=1;
			end
		end
	end %%if isstr
end %% for i

% this should probably apply only to the figure bg color.
if noneFlag == 1
	disp('*** One or more of the figure or axis background colors is set to ''none''.')
	disp('*** This can cause problems.  Use ''axisedit'' to select an appropriate')
	disp('*** background color that is less likely to confuse export.')
	disp('   ')
end

if (figBGflag==1) | (axBGflag==1)
	disp('*** This figure has a NON-WHITE background.  ')
	disp('*** Do you wish to force it to white when exporting it?  (y/n)')
	yorn=lower(input('-> ','s'));
	if strcmp(yorn,'y')
		set(fig,'InvertHardCopy','on')
	  else	
		set(fig,'InvertHardCopy','off')
	end
end

[fn, pn] = uiputfile('*.eps', 'Save the figure as:', filename);
if fn == 0
	disp('Canceled.')
	return
end

% make sure that file name ends in '.eps'
[tok, rem] = strtok(fn, '.');
fn = [tok '.eps'];   

% FINALLY, the actual work.  Save the file as an .eps, and then call epstool
% to add a high-quality TIFF preview and overwrite the original file.
eval( ['print -depsc2 ' ['''' pn fn ''''] ]) 
eval( ['!/opt/local/bin/epstool -t6p --device bmpgray --dpi 300 ' ...
				['"' pn fn '"'] ' ' ['"' pn fn '"'] ] )
