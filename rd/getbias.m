% getbias.m:  % Load the adjustments for the data, either from file or from user input.

% written by: Jonathan Jacobs
%             February 2004 - January 2007 (last mod: 01/31/07)

% 'readbias.m' reads in 'samp_freq' (for ASCII & ASD files), 'chName' and
% 'z_adj' (coil) or 'z_adj', 'max_adj' and 'min_adj' (IR)

% 'rectype' is created in either 'readbias' or 'inputbias'

% let's find the name of the active adjustbias file.  it is one of two possibilities:
% 1) 'adjbias.txt', the original name, left in for historical purposes;
% 2) 'adjbias_' + subject's initials (designator used for data file names) + '.txt'
% priority: #1 will be used if #2 can not be found.
% anything else will be ignored as before, allowing multiple files to be created, but
% only one to be used at a time.

% data file names can be of two forms: xxx#.yyy or xxx#_#.yyy, (where xxx can have
% an underscore in it in addition to the one that is used to separate digits)
% the first case is more common, representing the first series of recordings for a
% particular subject, while the second case represents subsequent recording sessions.

% 'adj_fname' will be used in readbias.m (and possibly elsewhere)

% because the series name might have an underscore in it as well (i.e., underscore
% is not only used to separate series name from trial number, e.g. jbj_vrg1.lab, or
% even worse: jbj_vrg2_1.lab!) we will work BACKWARDS from the end of the filename
% and strip away digits until we reach either an underscore or letters.  If letters,
% we are done.  If an underscore remove it and then we are done.

%function samp_freq = getbias(shortname);

tempfname=shortname;

numcand = 0;
adj_cand = [];
adjlist = dir('adjbias*');
numfiles = length(adjlist);
for j = 1:numfiles
   adjfilename = adjlist(j).name;
   adjfilename = strtok(adjfilename,'.');
   [temp,adjfilename] = strtok(adjfilename,'_');
   adjfilename = adjfilename(2:end);
   
   if strfind( lower(shortname),lower(adjfilename) ) == 1
      numcand = numcand + 1;
      adj_cand{numcand} = adjlist(j).name;
   end
end

[r,c]=size(adj_cand);
if c==1
   adj_fname = adj_cand{1};
 else
   adj_fname = '';
end

% case 1 -- remove series number, i.e. the 1 or two digits at the end of name
% and then strip the underescore.
%while isdigit(tempfname(end))
%   tempfname = tempfname(1:end-1);
%end	
%if strcmp(tempfname(end),'_')
%   tempfname = tempfname(1:end-1);   
%end

% case 1 and case 2
%adj_fname = lower(['adjbias_' tempfname '.txt']);
%clear tempfname

% plan b...
if ~exist(adj_fname,'file'), adj_fname = 'adjbias.txt'; end

adjbias_err_flag = 1;
if exist(adj_fname,'file')  % success will clear the flag.
   readbias
 else
   disp('   ')
   disp('  ** No appropriately named adjust bias file found.')
   yorn = lower(input('  ** Do you wish to search for a bias file? ','s'));
   if strcmp(yorn,'y')
      [adj_fname] = uigetfile('*.*', 'Select a adjust bias file');
   end
   disp('    ')
   if exist(adj_fname,'file')
      readbias(adj_fname)
     else 
      adj_fname = 'adjbias.txt';
   end
end

% maybe we have to enter by hand.  if there is no existing file or if does not
% contain a reference to the loaded data file.
if (~exist(adj_fname,'file')) || (adjbias_err_flag == 1)
   inputbias
end

% tempSampFreq is read from the bias file for asyst, ascii or rawbin formatted files
% tempSampFreq is read directly from file header for labview, ober and rtrv files
%samp_freq_vect(total_files) = tempSampFreq;
samp_freq = tempSampFreq;