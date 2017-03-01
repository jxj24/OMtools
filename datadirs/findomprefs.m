function omprefpath = findomprefs

% written by:  Jonathan Jacobs
%              February 2011

% Does 'omprefs' folder exist? It can exist in a number of places:
% original location: matlabroot.  No longer a good idea, but will allow it.
% ideal location: inside OMtools folder.
% -- leads to secondary question: where is OMtools?  'omdir' points to it.
%    original location: matlabroot.  See above note.
%    other location: toolbox.
%	  best (?) location: in folder containing MATLAB application

[sep, sep2] = getsep;

comp = lower( computer('arch') );
if strcmp(comp(1),'m') | strcmp(comp(1),'g')
	homedir = getenv('HOME');
	documents = 'documents';
 elseif strcmp(comp(1),'p')| strcmp(comp(1),'w')
   homedir = getenv('USERPROFILE');
   documents = 'My Documents';
end 

oldpath = pwd;
cd(matlabroot)
cd ..
matlabdir = pwd;

% known locations for OS X as of ML2010b
locations = {
				  {'matlabdir'}; ...
              {'matlabdir', 'omtools'}; ...
				  {'matlabroot'}; ...
				  {'matlabroot', 'omtools'}; ...
				  {'matlabroot', 'toolbox', 'omtools'}; ...
			     {'matlabroot', 'toolbox'};...
			     {'homedir', 'documents', 'MATLAB'}; ...
			     {'homedir', 'documents', 'MATLAB', 'omtools'}; ...
			   };

ompf=0; omtf=0;						%% omprefs folders found, omtools folders found
for j=1:length(locations)
	dir_err=0;	
   temp=eval(char( locations{j}(1) ));
   if ~exist( temp, 'dir')    
       disp( ['dir_error: ' locations{j}] );
       continue;
   end
   cd(temp)
	
	% if there are subdirectories, navigate to them.
	numsubdir = length(locations{j});
	if numsubdir > 1
		dir_err=0;
		for k=2:numsubdir
			temp=char( locations{j}(k) );
			eval('cd(temp)','dir_err=1;')
		end % for k
	end %if numsubdir
	
	if ~dir_err			% we have found a valid omtools folder
		omtf = omtf+1;
		omtoolspath{omtf} = pwd;
		dirfiles = dir;
		for i = 1:length(dirfiles)
			  temp = lower( deblank(dirfiles(i).name) );
			if strcmp( temp, 'omprefs')				%% we have found a valid omprefs folder
				ompf=ompf+1;
				omprefpath{ompf} = [pwd sep 'omprefs'];				
				%return
			end
		end %for i
	end %if ~dir_err	

end %for j

if ompf<1
	disp('Could not find any omprefs folder.  ')
	disp('I will create one in the OMtools folder.')
	if omtf == 1 % unlikely that omtf=0 since we are running a program from OMtools
		omtoolspath = char(omtoolspath{1});
		cd(omtoolspath)
		mkdir('omprefs')
		omprefpath = [omtoolspath sep 'omprefs'];
		cd('omprefs')
	  elseif omtf > 1
	   omprefpath = '';
	   disp('Multiple OMtools folders found. You should only have one OMtools folder')
	   disp('on your MATLAB path. Please remove or rename all redundant OMtools folders.')
	   error('Cannot create a folder for OMtools preferences. Aborting.')
	end
 elseif ompf == 1
 	omprefpath = char(omprefpath{1});
 elseif ompf >1
   disp('Multiple omprefs folders found:')
   for m=1:ompf
   	disp( char(omprefpath{m}) )
   end	
end	