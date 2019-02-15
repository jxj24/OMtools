function ztprefpath = findztprefs

% written by:  Jonathan Jacobs
%              February 2011

ztprefpath=[];
sep = getsep;

% Does omprefs folder exist?  If it does, use zt preferences saved loose in omprefs folder.
% If it does not exist, use 'findztprefs' and use ztprefs folder in zoomtool folder.
% if there is no 'ztprefs' folder, create one in the zoomtools folder.

%if exist('omprefs','dir') == 7
%	cd(findomprefs)
%   ztprefpath=findomprefs;
%	return
%end

comp = lower( computer('arch') );
if strcmp(comp(1),'m') || strcmp(comp(1),'g')
   homedir = getenv('HOME');
   documents = 'documents';
   sharedir = '/Users/Shared';
elseif strcmp(comp(1),'p')|| strcmp(comp(1),'w')
   homedir = getenv('USERPROFILE');
   documents = 'My Documents';
   sharedir = 'C:\Program Files\Common Files';
end

oldpath = pwd;
cd(matlabroot)
cd ..
matlabdir = pwd;

% possible locations for zoomtool prefs as of ML2010b
locations = {
   {'matlabdir','omtools','zoomtool'}; ...
   {'matlabroot','omtools','zoomtool'}; ...
   {'matlabroot','toolbox','omtools', 'zoomtool'}; ...
   {'sharedir','documents','MATLAB','omtools_prefs'}; ...
   {'sharedir','documents','MATLAB','zoomtool'}; ...
   {'sharedir','documents','MATLAB','omtools','zoomtool'}; ...
   {'homedir','documents','MATLAB','omtools_prefs'}; ...
   {'homedir','documents','MATLAB','zoomtool'}; ...
   {'homedir','documents','MATLAB','omtools','zoomtool'}; ...
   {'homedir','documents','MATLAB','Add-Ons','toolboxes','omtools','code','zoomtool'}; ...
   };

ztf=0; ztpf=0;             %% zoomtool folders found, ztprefs folders found
for j=1:length(locations)
   dir_err=0;
   temp=eval(char( locations{j}(1) ));
   if ~exist( temp, 'dir')
      disp( ['dir_error: ' locations{j}] );
      continue;
   end
   cd(temp)
   
   % if there are given subdirectories, navigate to them.
   numsubdir = length(locations{j});
   if numsubdir > 1
      dir_err=0;
      for k=2:numsubdir
         temp=char( locations{j}(k) ); %#ok<*NASGU>
         eval('cd(temp)','dir_err=1;') %#ok<*EVLC>
      end % for k
   end %if numsubdir
   
   if ~dir_err   % we have found a valid zoomtools folder
      ztf = ztf+1;
      ztpath{ztf} = pwd;
      dirfiles = dir;
      for i = 1:length(dirfiles)
         temp = deblank(dirfiles(i).name);
         if strcmpi( temp, 'ztprefs')				% we have found a valid zt prefs folder
            ztpf = ztpf+1;
            ztprefpath{ztpf} = [pwd sep 'ztprefs']; %#ok<*AGROW>
            %return
         end
      end %for i
   end %if ~dir_err
   
end %for j

if ztpf<1
   disp('Could not find any zoomtool prefs location. ')
   disp('I will create a "ztprefs" folder.')
   disp('Where do you want me to make it?')
   disp(' 1. In your existing zoomtool folder.')
   disp([' 2. In ' homedir sep documents sep ' omtools_prefs (recommended)' ])
   disp([' 3. In ' sharedir sep 'omtools_prefs (if multiple user accounts run MATLAB)' ])
   commandwindow
   ztchoice = input('--> ');
   
   if ztchoice == 1
      if ztf == 1 % unlikely that ztf=0 since we are running a program from zoomtool
         ztpath = char(ztpath{1});
         cd(ztpath)
         mkdir('ztprefs')
         ztprefpath = [ztpath sep 'ztprefs'];
         cd('ztprefs')
      elseif ztf > 1
         %ztprefpath = '';
         disp('Multiple zoomtool folders found. You should only have one zoomtool folder')
         disp('on your MATLAB path. Please remove or rename all redundant zoomtool folders.')
         error('Cannot save zoomtool preferences. Aborting.')
      else
         disp('Could not find a zoomtool folder. Make sure it is on your MATLAB path.')
         error('Can not save zoomtool preferences. Aborting. [ztf==0]')
      end
      
   elseif ztchoice==2
      cd([homedir sep documents sep 'MATLAB'])
      if ~exist( [homedir sep documents sep 'MATLAB' sep 'omtools_prefs'],'dir' )
         mkdir('omtools_prefs')
      end
      cd('omtools_prefs')
      mkdir('ztprefs'); cd('ztprefs')
      ztprefpath = pwd;
      cd(oldpath)
   elseif ztchoice==3
      cd([sharedir sep 'MATLAB'])
      if ~exist( [sharedir 'MATLAB' sep 'omtools_prefs'],'dir' )
         mkdir('omtools_prefs')
      end
      cd('omtools_prefs')
      mkdir('ztprefs'); cd('ztprefs')
      ztprefpath = pwd;
      cd(oldpath)
   end
   
elseif ztpf == 1
   ztprefpath = char(ztprefpath{1});
elseif ztpf >1
   disp('Multiple zoomtool pref locations found:')
   for m=1:ztpf
      disp( [ num2str(m) ':  ' char(ztprefpath{m}) ] )
   end
   disp([char(13) 'Current best practice is to use one in your home directory.'])
   disp('(Or in the ''Shared'' directory for multiple accounts using MATLAB.)')
   disp('Which one would you like to use? ')
   choice = 0;
   while choice < 1
      commandwindow
      choice = input('--> ');
   end
   temp = char(ztprefpath{ztpf});
   disp('Would you like to inactivate the other preference directory? (y/n)')
   commandwindow
   yorn=input('--> ','s');
   if strcmpi(yorn,'y')
      for m=1:ztpf
         if choice == m
            % do nothing
         else
            % add an 'x' into the name of the other omtools folders
            a = strfind(ztprefpath{m}, 'ztprefs');
            b = [ ztprefpath{m}(1:a-1) 'zt_x_' ztprefpath{m}(a+2:end) ];
            movefile(ztprefpath{m}, b);
         end
      end
   end
   ztprefpath = char(ztprefpath{m});
end

try
   cd(oldpath)
catch
end