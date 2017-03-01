function latstats(latptdata)

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
which_eye = latptdata{1,9};		%% which eye used for analysis
comments = latptdata{1,10};		%% comments
interval = latptdata{1,11};		%% which interval

%% positions or velocities calculated in latpoints from time-index data
T0_stimpos 	= latptdata{1,12};	%% stim value at T0
ts_pos	 	= latptdata{1,13};	%% eye pos at time of ts
r0_stimpos 	= latptdata{1,14};	%% stim value at r0
tr_pos 		= latptdata{1,15};	%% eye pos at time of tr
cus_vel 		= latptdata{1,16};	%% eye peak vel at time of t_cus
on_tgt_pos	= latptdata{1,17};	%% eye pos at time of 1st stability
shortname	= latptdata{1,18};	%% eye pos at time of 1st stability

%% LFD-added spreadsheet values:
%% e0 is the pos err just before corrective sacc.  Use t_cus and backtrack a few samples
%%   from the PV mark to find the local max absolute error.
%% e_ss is the pos err at time of "steady-state" pursuit. It is SOMETIMES the eye pos 
%%   at Tt (t_on_tgt), but usually(?) is NOT, as the eye may drift toward the target before
%%   settling on a final stable value.  Possible approach: look forward from Tt for a period
%%   of sufficient duration (TBD), where slope is less than TBD, and use the mean pos value.
SAClat  = ts - T0;
SPlat   = tr - r0;
CUSlat  = t_cus - r0;
t_at    = t_on_tgt - T0;
overlap = ts - r0;
t_atsp  = t_on_tgt - r0; 

allpoints = [latptdata, SAClat, SPlat, CUSlat, t_at, overlap];
new_var_names = [var_names, 'SAClat', 'SPlat', 'CUSlat', 't_at', 'overlap', 't_atsp'];

%% show variable names and prompt for which one to sort against.
doneplotting=0;
colorlist  = ['b', 'r', 'g', 'c', 'y', 'm'];
stylelist = ['^', '>', '<', 'v', '*', 'x'];
while ~doneplotting
	for i=1:4:length(new_var_names)
		disp([prepad(num2str(i),2)   ') ' pad(new_var_names{i},15) ...
				prepad(num2str(i+1),2) ') ' pad(new_var_names{i+1},15) ...
				prepad(num2str(i+2),2) ') ' pad(new_var_names{i+2},15) ...
				prepad(num2str(i+3),2) ') ' pad(new_var_names{i+3},15) ])
	end
	
	disp(' ')
	which_var=0;
	while ( which_var<1 ) | ( which_var>23 )
		which_var=input('Use which variable as X data ("0" to abort)?  ');	
		if which_var == 0, disp('Aborting.'); return; end
	end
 	disp(['  "' new_var_names{which_var} '" selected.'])
	xdata = allpoints{which_var};
	xname = new_var_names{which_var};
	
	y_done=0; y_count=0;
	while ~y_done
		which_var=-1;
		while ( which_var<0 ) | ( which_var>23 )
			which_var=input('Use which variable as Y data ("0" to end)?  ');	
			if which_var == 0
				y_done=1;
			 else
			 	disp(['  "' new_var_names{which_var} '" added.'])
			end
		end		
		if ~y_done
			y_count = y_count + 1;		
			ydata{y_count} = allpoints{which_var};
			yname{y_count} = new_var_names{which_var};
		end	
	end %% y_done
	if y_count==0, disp('No Y data added. Quitting.'); return; end
	
	%% find and remove any NaN from 'xdata', and use only its non-Nan indices for the other data
	%% (will we want to do this symmectically? i.e. find NaNs in the others and remove them from
	%% 'overlap'?  If so, will do a new 'overlap' for each case.)
	nan_ind=isnan(xdata);
	for i=1:length(ydata)
		ydata{i}(nan_ind)=NaN;
		ydata{i}=stripnan(ydata{i});
	end
	xdata=stripnan(xdata);

	%% plot the figure
	figure; box; hold on
	
	for i=1:length(ydata)
		fitdone=0; 
		while ~fitdone
			fitorder=input(['What order fit for ' yname{i} '? ']);
			[coeff,Rsq,p,recon,xrange] = pfit(xdata,ydata{i},fitorder);
			linH(i) = plot(xdata,ydata{i},[colorlist(i) stylelist(i)]);
			tempfit = plot(xrange, recon, colorlist(i));
			temptext = text(xrange(end),recon(end), ['r^2 =' num2str(Rsq,3) ', p = ' num2str(p,3)]);
			disp(['  r^2 =' num2str(Rsq,3) ', p = ' num2str(p,3)])
			set(temptext,'color',colorlist(i))
			yorn = input('Are you happy with this order of fit (y/n)? ','s');
			if strcmp(lower(yorn),'y')
				fitdone=1;
			 else
			   delete(temptext); delete(tempfit); delete(linH(i));
			end
		end
	end
	xlabel(xname); legend(linH, yname) 
   
	yorn=input('Plot another graph (y/n)? ','s');
	if strcmp(lower(yorn),'n'), doneplotting=1; end
	disp('  ')

end %% done plotting