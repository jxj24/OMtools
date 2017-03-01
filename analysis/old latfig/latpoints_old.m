% 
%
function latpoints

global namearray samp_freq lh rh st

rhf=lpf(rh,4,20,500); lhf=lpf(lh,4,20,500); stf=lpf(st,4,20,500); t=maket(rh);
rhv=d2pt(rhf,3); lhv=d2pt(lhf,3); stv=d2pt(stf,3);

% disable the useless Excel warning
warning off MATLAB:xlsread:Mode

olddir = pwd;
[filename, pathname] = uigetfile('','Select an Excel spreadsheet');

% figure out which sheet we want from this spreadsheet.  The loaded eye movement data file
% is in 'namearray'. The sheets are named 'record'+'n' where 'n' is the data record number.
[typ, desc, fmt] = xlsfinfo([pathname filename]);
index = regexp(namearray,'\d');
recnum = namearray(index);

for sheet=1:length(desc)
	if findstr( num2str(recnum), desc{sheet} ) ~= 0
	   disp([' ** Found record ' num2str(recnum) ' at sheet ' num2str(sheet)])
	end
end

sheetname = ['record' namearray(index)];

[rawdata, strdata] = xlsread([pathname filename], sheetname);

% break out the columns
T0 	= rawdata(2:end,1);			%% time of target jump
sacc 	= rawdata(2:end,2);			%% time of init sacc to tgt jump
r0 	= rawdata(2:end,3);		 	%% time of ramp start
purs 	= rawdata(2:end,4);			%% time of pursuit onset
c_sacc = rawdata(2:end,5);			%% time of 1st corrective saccade
on_tgt = rawdata(2:end,6);			%% time of 1st sustained accurate pursuit
E_vel1 = rawdata(2:end,7);			%% initial pursuit velocity
E_vel2 = rawdata(2:end,8);			%% corrected pursuit velocity
which_eye = strdata(2:end,10);	%% which eye used for analysis
comments = strdata(2:end,11);		%% comments
interval = strdata(2:end,1);		%% which interval

% build the marker lists
T0_list = [];   sacc_list = [];   r0_list = [];
purs_list = []; c_sacc_list = []; on_tgt_list = [];
trials=length(T0);

for i = 1:trials
	if strcmp(lower(which_eye(i)),'lh')
		pos = lhf; vel = lhv;
	 elseif strcmp(lower(which_eye(i)),'rh')
	 	pos = rhf; vel = rhv;
	 else
		error('Unknown eye channel.  Check the spreadsheet.')
	end
	pos_err = pos-stf;

	T0_list	= [T0_list 	st( T0(i)*samp_freq )];
	r0_list	= [r0_list 	st( r0(i)*samp_freq )];

 	if ~isnan(sacc(i)), 		newpt = pos(fix(sacc(i)*samp_freq)); 	else newpt = NaN; end
			sacc_list	= [sacc_list 	newpt];
	if ~isnan(purs(i)),  	newpt = pos(fix(purs(i)*samp_freq));	else newpt = NaN; end
			purs_list 	= [purs_list 	newpt];
	if ~isnan(c_sacc(i)),	newpt = vel(fix(c_sacc(i)*samp_freq))/25 - 5; else newpt = NaN; end
			c_sacc_list	= [c_sacc_list newpt];

	if ~isnan(on_tgt(i))
		newpt	= pos_err(fix(on_tgt(i)*samp_freq))*4 -30;  %% make sure that these agree with p_shift
	 else															%% and scaling used in 'latfig'
	 	newpt = NaN;
	 end
	on_tgt_list	= [on_tgt_list newpt];
end

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
temp=plot(T0, T0_list, 'g^'); set(temp,'Color',[1 .5 0],'Markersize',8);
temp=plot(r0, r0_list, 'gv'); set(temp,'Color',[1 .5 0],'Markersize',8);

temp=plot(sacc, sacc_list, 'g*'); set(temp,'Color',[1 .5 0],'Markersize',8);
temp=plot(purs, purs_list, 'gd'); set(temp,'Color',[1 .5 0],'Markersize',8);

temp=plot(c_sacc, c_sacc_list, 'gs'); set(temp,'Color',[1 .5 0],'Markersize',8);
temp=plot(on_tgt, on_tgt_list, 'go'); set(temp,'Color',[1 .5 0],'Markersize',8);

%% bizarre but fun: for sadk10.lab, if these two 'text' lines come before previous
%% two 'plot' lines, zoomtool will not properly draw the cursors.
%% also, text can get drawn beyond the axis.
purs(isnan(purs))=r0(isnan(purs));
temp=text( purs+0.125, pos(fix(purs*samp_freq))+1, num2str(E_vel1) );
temp=text( purs+0.5,   pos(fix(purs*samp_freq))+1, num2str(E_vel2) );

eval(['cd ' '''' olddir ''''])

zoomtool