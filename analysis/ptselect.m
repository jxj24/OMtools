function selectedpoints = ptselect(latptdata)

curdir=pwd;
if nargin == 0
	[filename,pathname]=uigetfile('','Select a latpoints file:');
	if filename == 0, disp('Cancelled.'); return; end
	load([pathname filename])
	if ~exist('latptdata'), disp('File has no latptdata. Aborting.'); return; end
end	

%% read from latpoints file
T0 	= latptdata{1,1};				%% time of target jump
ts 	= latptdata{1,2};				%% time of init sacc to tgt jump
r0 	= latptdata{1,3};		 		%% time of ramp start
tr 	= latptdata{1,4};				%% time of pursuit onset
t_cus = latptdata{1,5};				%% time of 1st corrective saccade (at its PV)
t_on_tgt = latptdata{1,6};			%% time of 1st sustained accurate pursuit
E_vel1 = latptdata{1,7};			%% initial pursuit velocity
E_vel2 = latptdata{1,8};			%% corrected pursuit velocity

%% positions or velocities calculated in latpoints from time-index data
T0_stimpos 	= latptdata{1,12};	%% stim value at T0
ts_pos	 	= latptdata{1,13};	%% eye pos at time of ts
r0_stimpos 	= latptdata{1,14};	%% stim value at r0
tr_pos 		= latptdata{1,15};	%% eye pos at time of tr
cus_vel 		= latptdata{1,16};	%% eye peak vel at time of t_cus
on_tgt_pos	= latptdata{1,17};	%% eye pos at time of 1st stability

%% from LFD-defined columns in spreadsheets
SAClat  = ts - T0;
SPlat   = tr - r0;
CUSlat  = t_cus - r0;
t_at    = t_on_tgt - T0;
overlap = ts - r0;
t_atsp  = t_on_tgt - r0; 

%% append the other useful variables to the data array
allpoints = [latptdata, SAClat, SPlat, CUSlat, t_at, overlap];
new_var_names = [var_names, 'SAClat', 'SPlat', 'CUSlat', 't_at', 'overlap', 't_atsp'];

%% show variable names and prompt for which one to sort against.
for i=1:4:length(new_var_names)
	disp([prepad(num2str(i),2)   ') ' pad(new_var_names{i},15) ...
			prepad(num2str(i+1),2) ') ' pad(new_var_names{i+1},15) ...
			prepad(num2str(i+2),2) ') ' pad(new_var_names{i+2},15) ...
			prepad(num2str(i+3),2) ') ' pad(new_var_names{i+3},15) ])
end

disp(' ')
which_var=0;
while ( which_var<1 ) | ( which_var>23 )
	which_var=input('Sort using which variable?  ');	
	if which_var == 0, disp('Aborting.'); return; end
end

%% do the actual sorting for the selected variable.  Use the index of the sorting to
%% re-order the other variables' points in the same order as the now-sorted selected variable.
temp = allpoints{which_var};
[tempsorted, sortindex] = sort(temp);

allpoints_sorted=allpoints;	%% initialize target to unsorted source
for i=1:length(allpoints)
	allpoints_sorted{i}=allpoints{i}(sortindex);		%% replace each var with its sorted result
end

%% now determine value or range to extract
disp(['Results of sorting variable ' new_var_names{which_var}])
dlen=10;
for i = 1:fix(length(tempsorted)/dlen)
	disp(tempsorted( (i-1)*dlen+(1:dlen) ))
end
lastfew= [fix(length(tempsorted)/dlen)*dlen+1 : length(tempsorted) ];
disp( tempsorted(lastfew) )
disp(' ')

tempmin = min(tempsorted); minval=-inf;
while minval<tempmin
	tempstr=input('Select a minimum value to use ("q" to quit. "Enter" uses lowest value): ','s');
	if strcmp(tempstr,'')
	 	minval=tempmin;
	 else
		minval=str2num(tempstr);
	end
	if strcmp(tempstr,'q'); disp('Aborting.'); return; end
end
temp = find(tempsorted < minval);
if isempty(temp)
    min_index = 1;
 else 
    min_index = temp(end) + 1;
end

tempmax = max(tempsorted); maxval=inf;
while maxval>tempmax	
	tempstr=input('Select a maximum value to use ("q" to quit. "Enter" uses highest value): ','s');
	if isempty(tempstr)
	 	maxval=tempmax;
	 else
		maxval=str2num(tempstr);
	end
	if strcmp(maxval,'q'); disp('Aborting.'); return; end
end
temp = find(tempsorted > maxval);
if isempty(temp)
    min_index = length(tempsorted);
 else 
    max_index = temp(1) - 1;
end


%% package and offer to save output.  We don't save the five calculated columns (SAClat,
%%   SPlat, CUSlat, t_at and overlap) because they're trivial to calculate in 'latstats'
for i=1:length(latptdata)
	selectedpoints{i}=allpoints_sorted{i}(min_index:max_index);
end

latptdata = [];
latptdata = selectedpoints;

[filename, pathname]=uiputfile('','Save the selected points as:');
if filename==0, disp('File not saved'); return; end
eval(['cd ' '''' pathname ''''])
eval(['save ' filename ' var_names latptdata'])
eval(['cd ' '''' curdir ''''])
disp(['Saved the selected points file as: ' filename])
