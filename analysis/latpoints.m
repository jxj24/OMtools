function latptdata=latpoints(null)

global namearray samp_freq lh rh st

rhf=lpf(rh,4,20,500); lhf=lpf(lh,4,20,500); stf=lpf(st,4,20,500); t=maket(rh);
rhv=d2pt(rhf,3); lhv=d2pt(lhf,3); stv=d2pt(stf,3);

% disable the useless Excel warning
warning off MATLAB:xlsread:Mode

olddir = pwd;
[filename, pathname] = uigetfile('*.xls','Select an Excel spreadsheet');

% figure out which sheet we want from this spreadsheet.  The loaded eye movement data file
% is in 'namearray'. The sheets are named 'record'+'n' where 'n' is the data record number.
[typ, desc, fmt] = xlsfinfo([pathname filename]);
index = regexp(namearray,'\d');
recnum = namearray(index);
sheetname = ['record' recnum];
shortname=lower(strtok(namearray,'.'));
disp([' *** Looking for excel sheet "' sheetname '" for ' namearray])

for sheet=1:length(desc)
	if findstr( num2str(recnum), desc{sheet} ) ~= 0
	   disp([' *** Found "' sheetname '" in sheet position ' num2str(sheet)])
	end
end

[rawdata, strdata] = xlsread([pathname filename], sheetname);

% break out the columns
T0 	= rawdata(2:end,1);			%% time of target jump
ts 	= rawdata(2:end,2);			%% time of init sacc to tgt jump
r0 	= rawdata(2:end,3);		 	%% time of ramp start
tr 	= rawdata(2:end,4);			%% time of pursuit onset
t_cus = rawdata(2:end,5);			%% time of 1st corrective saccade
t_on_tgt = rawdata(2:end,6);		%% time of 1st sustained accurate pursuit
E_vel1 = rawdata(2:end,7);			%% initial pursuit velocity
E_vel2 = rawdata(2:end,8);			%% corrected pursuit velocity
which_eye = strdata(2:end,10);	%% which eye used for analysis
comments = strdata(2:end,11);		%% comments
interval = strdata(2:end,1);		%% which interval

% build the marker lists
T0_stimpos = [];		ts_pos = [];   	r0_stimpos = [];
tr_pos = []; 			cus_vel = []; 		on_tgt_pos = [];
trials=length(T0);	shortname_list = [];

for i = 1:trials
	if strcmp(lower(which_eye(i)),'lh')
		pos = lhf; vel = lhv;
	 elseif strcmp(lower(which_eye(i)),'rh')
	 	pos = rhf; vel = rhv;
	 else
		error('Unknown eye channel.  Check the spreadsheet.')
	end
	pos_err = pos-stf;

	T0_stimpos	= [T0_stimpos 	st( fix(T0(i)*samp_freq) )];
	r0_stimpos	= [r0_stimpos 	st( fix(r0(i)*samp_freq) )];

 	if ~isnan(ts(i)), newpt = pos(fix(ts(i)*samp_freq)); 	else newpt = NaN; end
		ts_pos = [ts_pos 	newpt];
	if ~isnan(tr(i)), newpt = pos(fix(tr(i)*samp_freq));	else newpt = NaN; end
		tr_pos = [tr_pos 	newpt];
	if ~isnan(t_cus(i)),	newpt = vel(fix(t_cus(i)*samp_freq)); else newpt = NaN; end
		cus_vel = [cus_vel newpt];
	if ~isnan(t_on_tgt(i)), newpt	= pos_err(fix(t_on_tgt(i)*samp_freq)); else newpt = NaN; end
		 on_tgt_pos	= [on_tgt_pos newpt];
	shortname_list = [shortname_list; {shortname}];
end
latptdata = {T0', ts', r0', tr', t_cus', t_on_tgt', E_vel1', E_vel2', which_eye', comments', interval', ...
		 T0_stimpos, ts_pos, r0_stimpos, tr_pos, cus_vel, on_tgt_pos, shortname_list'  ; ...
		'T0','ts','r0','tr','t_cus','t_on_tgt','E_vel1','E_vel2','which_eye','comments','interval',...
		'T0_stimpos','ts_pos','r0_stimpos','tr_pos','cus_vel','on_tgt_pos','filename'};

%% save points to a .mat file
eval(['cd ' '''' pathname ''''])
eval([ 'save latpts_' shortname '.mat latptdata' ])
disp([' *** latpts_' shortname '.mat written to ' pathname '.'])

% check to see if there is already an existing figure with the latency data
latfignum = -1;
figlist = get(0,'Children');
for i=1:length(figlist)
	figname = lower(get(figlist(i),'Name'));
	if strfind( figname, 'latency') & ~strfind( figname, 'points')
		latfignum = i;
		break
	end
end

% if there is no existing figure -- or there is a figure that already has points added --
% then create a new figure and overplot the latency analysis points
if latfignum<0, latfig; latfignum=gcf; end
figure(latfignum); zoomclr; hold on
figname = [get(latfignum,'Name') ' w/points'];
set(latfignum,'Name', figname)
temp=plot(T0, T0_stimpos, 'g^'); set(temp,'Color',[1 .5 0],'Markersize',8);
temp=plot(r0, r0_stimpos, 'gv'); set(temp,'Color',[1 .5 0],'Markersize',8);

temp=plot(ts, ts_pos, 'g*'); set(temp,'Color',[1 .5 0],'Markersize',8);
temp=plot(tr, tr_pos, 'gd'); set(temp,'Color',[1 .5 0],'Markersize',8);

temp=plot(t_cus,    cus_vel/25-5,    'gs'); set(temp,'Color',[1 .5 0],'Markersize',8);
temp=plot(t_on_tgt, on_tgt_pos*4-30, 'go'); set(temp,'Color',[1 .5 0],'Markersize',8);

%% bizarre but fun: for sadk10.lab, if these two 'text' lines come before previous
%% two 'plot' lines, zoomtool will not properly draw the cursors.
%% also, text can get drawn beyond the axis.
tr(isnan(tr))=r0(isnan(tr));
temp=text( tr+0.125, pos(fix(tr*samp_freq))+1, num2str(E_vel1) );
temp=text( tr+0.5,   pos(fix(tr*samp_freq))+1, num2str(E_vel2) );

eval(['cd ' '''' olddir ''''])
zoomtool