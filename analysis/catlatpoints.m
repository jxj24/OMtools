function catlatpts

curdir=pwd;

catlat=[];
%% is there an already existing file to modify?
yorn = input('Do you want to use an already existing concatenated points file (y/n)? ','s');
if strcmp(lower(yorn),'n')
 	%disp('  We will create a new concatenated file to store the points.')
 	catptsfile = 0;
 else
	disp('Select a concatenated file (".mat" format)')
	[catptsfile, pathname] = uigetfile('','Load an existing concatenated file (".mat")');

	if catptsfile == 0
		disp('Cancelled.  Quitting.');
		return;
	 else
	 	[temp,exten]=strtok(catptsfile,'.');
	 	if ~strcmp( lower(exten), '.mat')
	 		disp('You need to select a ".mat" file.  Quitting.')
	 		return
	 	end
	 	load([pathname catptsfile])
	 	disp(['  ' catptsfile ' loaded.'])
	end 	%% if catptsfile

end		%% 'yorn' strcmp

%% if concatenated file has been loaded, check its contents and display summary
presentfiles = cell(1,10);
if catptsfile ~= 0
	[r,c]=size(catlat);
	for i=1:c
		if ~isempty(catlat{i})
			presentfiles{i} = catlat{i}{1,18};
			disp(['  Found record: ' char(presentfiles{i})])
		end
	end
end

%% start loading single-file latpoints.  If the file entry already exists, ask
%% user if we want to replace the previous entry.
done=0;
while ~done
	loadlist=[];
	disp('Currently loaded files:')
	for i=1:length(presentfiles)
		loadlist = [loadlist presentfiles{i} '   '];
	end
	disp(loadlist)

	disp('Load a latpoints file...')
	[filename,pathname]=uigetfile('','Load a "latpts" file:');
	if filename == 0, pathname=pwd; break; end
	disp(['   ' filename ' selected'])
	temp=strtok(filename,'.');
	temp=temp(end-2:end);
	filenumber = str2num(temp(find(isdigit(temp))));

	%% check if this entry already exists
	loadfile=1;
	if ~isempty(presentfiles{filenumber})
		disp(['You have already loaded this file.'])
		yorn=lower(input('Do you want to replace it (y/n)? ','s'));
		loadfile = 0; if strcmp(yorn,'y'), loadfile=1; end
	end

	if loadfile
		eval(['load ' '''' pathname filename '''' ])
		disp([ '   ' filename ' loaded'])
		if exist('latptdata')~=1
			disp('  *** No "latptdata" variable found in the loaded file')
			break
		end
		catlat{filenumber}=latptdata;
		presentfiles{filenumber} = latptdata{1,18}{1};
	end
	
	yorn = lower(input('Add another file (y/n)? ','s'));
	if strcmp(yorn,'n'), done = 1; end

end	

%% now concatenate the individual latpoints arrays into their respective big arrays
[r,c]=size(catlat);
points = cell(18,1);
for i = 1:c
	if ~isempty(catlat{i})
		for j = 1:18
			temp = catlat{i}{1,j};
			points{j} = cat(2, points{j}, temp);
		end
	end	
end

latptdata = points';
var_names={'T0','ts','r0','tr','t_cus','t_on_tgt','E_vel1','E_vel2','which_eye','comments','interval',...
		'T0_stimpos','ts_pos','r0_stimpos','tr_pos','cus_vel','on_tgt_pos','filename'};


[filename, pathname]=uiputfile('','Save the concatenated file as:');
if filename==0, disp('File not saved'); return; end
eval(['cd ' '''' pathname ''''])
eval(['save ' filename ' catlat var_names latptdata'])
eval(['cd ' '''' curdir ''''])
disp(['Saved the concatenated points file as: ' filename])
