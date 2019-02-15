function omtoolspath = findomtools

% written by:  Jonathan Jacobs
%              February 2011

% Does 'OMtools' folder exist? It can exist in a number of places:
% original location: matlabroot.  No longer a good idea, but will allow it.
% other locations: inside folder containing MATLAB; inside toolbox
% or even in home directory 'MATLAB' folder.

sep = filesep;

oldpath = pwd;
cd(matlabroot); cd ..
matlabdir = pwd;

comp = lower( computer('arch') );
if strcmp(comp(1),'m') || strcmp(comp(1),'g')
   homedir = getenv('HOME');
   documents = 'documents';
   sharedir = '/Users/Shared/MATLAB';
elseif strcmp(comp(1),'p')|| strcmp(comp(1),'w')
   homedir = getenv('USERPROFILE');
   documents = 'My Documents';
   sharedir = 'C:\Program Files\Common Files';
end

locations = {
   {'matlabdir'}; ...
   {'matlabroot'}; ...
   {'matlabroot', 'toolbox'}; ...
   {'sharedir'}; ...
   {'homedir', 'documents', 'MATLAB'}; ...
   {'homedir', 'documents', 'MATLAB','Add-Ons','toolboxes'}; ...
   };

omtf=0;								%% omtools folders found
omtoolspath=[];
for j=1:length(locations)   
   dir_err=0;
   temp=eval( char(locations{j}(1)) );
   if ~exist( temp, 'dir')
      %disp( ['dir not present: ' char(locations{j}) ...
      %   ' (' eval('sharedir') ')'] );
      continue;
   end
   cd(temp)
   
   % if there are subdirectories, navigate through them.
   numsubdir = length(locations{j});
   if numsubdir > 1
      dir_err=0;
      for k=2:numsubdir
         temp=char( locations{j}(k) ); %#ok<*NASGU>
         eval('cd(temp)','dir_err=1;') %#ok<*EVLC>
      end % for k
   end %if numsubdir
   
   if ~dir_err
      dirfiles = dir;
      for i = 1:length(dirfiles)
         temp = deblank(lower(dirfiles(i).name));
         if strcmp( temp, 'omtools')
            omtf = omtf+1;
            omtoolspath{omtf} = [pwd sep 'OMtools']; %#ok<*AGROW>
         end
      end %for i
   end %if ~dir_err
end %for j

if length(omtoolspath) > 1
   for m = 1:length(omtoolspath)
      disp([num2str(m) ': ' char(omtoolspath{m}) ] )
   end
   omtp=0;
   while omtp <1 || omtp > length(omtoolspath)
      commandwindow
      omtp = input('Select which OMtools you want to use: ');
   end
   omtoolspath = char(omtoolspath{omtp});
else
   omtoolspath = char(omtoolspath);
end

cd(oldpath)
return