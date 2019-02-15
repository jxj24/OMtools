% dataroot: find or change the root data directory (previously 'setroot.m')% Usage: datapathroot = dataroot(mode)% where mode = 'r' (read), or 'w' (write)% written by:  Jonathan Jacobs%              February 1997 - January 2018  (last mod: 1/30/18)% 21 March 2003: added '/' as sep character for MATLAB 6.5 (OS X, yay!)% 3 March 2017: renamed. now can read or write the data root directory% 17 August 2017: use GUI to set new dataroot path% 30 January 2018: can now recover from a specifying a bad directory as datarootfunction datarootpath = dataroot(mode)if nargin==0, mode='r';endcurdir=pwd;sep = filesep;% OMroot.txt and dataroot.txt live in omprefs diromprefpath = findomprefs;if ~isempty(omprefpath)   cd(omprefpath)else   disp('I can not find an omprefs folder.')   cd(curdir)   returnendswitch mode   case 'r'      % find the root directories for the data files.      fid = fopen( 'dataroot.txt', 'r' );      if fid > 0         datarootpath = fread(fid,'*char')';         datarootpath=strtok(datarootpath,[10 13]);         if strcmp( datarootpath(end),sep )            datarootpath=datarootpath(1:end-1);         end                  % make sure it is a good path         if ~exist(datarootpath,'dir')            disp('Bad path for ''dataroot''. Choose a new directory.')            datarootpath = dataroot('w');         end                  fclose(fid);      else         comp = lower( computer('arch') );         if strcmp(comp(1),'m') || strcmp(comp(1),'g')            homedir = getenv('HOME');            documents = 'documents';         elseif strcmp(comp(1),'p') || strcmp(comp(1),'w')            homedir = getenv('USERPROFILE');            documents = 'My Documents';         end                  fid=fopen('dataroot.txt','w');         fwrite(fid, matlabroot, 'char');         fclose(fid);         datarootpath = [homedir filesep documents];         disp('<<< dataroot.m >>>')         disp('"dataroot.txt" was missing from your omprefs folder.')         disp('I have created a new file, initialized to your home directory.')         disp('Feel free to modify it by calling "dataroot(''w'')".')         disp(' ')      end   case 'w'      fid = fopen( 'dataroot.txt', 'w' );      if fid > 0         disp('Select your new data directory')         ddir = uigetdir([],'Select your new data directory');         fwrite(fid, ddir, 'char');         fclose(fid);         datarootpath = ddir;      end   otherwise      endcd(curdir)