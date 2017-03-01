function latstats(latptdata)

global namearray samp_freq lh rh st

%rhf=lpf(rh,4,20,500); lhf=lpf(lh,4,20,500); stf=lpf(st,4,20,500); t=maket(rh);
%rhv=d2pt(rhf,3); lhv=d2pt(lhf,3); stv=d2pt(stf,3);

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

%% from LFD-defined columns in spreadsheets
SAClat  = ts - T0;
SPlat   = tr - r0;
CUSlat  = t_cus - r0;
t_at    = t_on_tgt - T0;
overlap = ts - r0;

%% LFD-added spreadsheet values:
%% e0 is the pos err just before corrective sacc.  Use t_cus and backtrack a few samples
%%   from the PV mark to find the local max absolute error.
%% e_ss is the pos err at time of "steady-state" pursuit. It is SOMETIMES the eye pos 
%%   at Tt (t_on_tgt), but usually(?) is NOT, as the eye may drift toward the target before
%%   settling on a final stable value.  Possible approach: look forward from Tt for a period
%%   of sufficient duration (TBD), where slope is less than TBD, and use the mean pos value.
%% Tat = t_on_tgt - T0

%% results: SAClat, SPlat, CUSlat, Tat -- plotted vs overlap
%% 	fit polynom to: CUSlat, Tat
%%		fit linear to: SAClat, SPlat

%% results: e0, e_ss -- plotted vs overlap
%% 	fit polynom to: e0, e_ss

%% find and remove any NaN from 'overlap', and use only its non-Nan indices for the other data
%% (will we want to do this symmectically? i.e. find NaNs in the others and remove them from
%% 'overlap'?  If so, will do a new 'overlap' for each case.)
ind=isnan(overlap);
SPlat(isnan(overlap))=NaN;			SAClat(isnan(overlap))=NaN;
CUSlat(isnan(overlap))=NaN;		t_tat(isnan(overlap))=NaN;

fig1=figure; box; hold on
fitorder=input('What order fit for SAClat? ');
[coeff1,Rsq1,p,recon,xrange]=pfit(stripnan(overlap),stripnan(SAClat),fitorder);
linH(1)=plot(overlap,SAClat,'b^'); plot(xrange, recon, 'b')
temp=text(xrange(end),recon(end), ['r^2 =' num2str(Rsq1,3) ', p = ' num2str(p,3)]);
set(temp,'color','b')

fitorder=input('What order fit for SPlat? ');
[coeff2,Rsq2,p,recon,xrange]=pfit(stripnan(overlap),stripnan(SPlat),fitorder);
linH(2)=plot(overlap,SPlat,'g<'); plot(xrange, recon, 'g')
temp=text(xrange(end),recon(end), ['r^2 =' num2str(Rsq2,3) ', p = ' num2str(p,3)]);
set(temp,'color','g')

fitorder=input('What order fit for CUSlat? ');
[coeff3,Rsq3,p,recon,xrange]=pfit(stripnan(overlap),stripnan(CUSlat),fitorder);
linH(3)=plot(overlap,CUSlat,'r>'); plot(xrange, recon, 'r')
temp=text(xrange(end),recon(end), ['r^2 =' num2str(Rsq3,3) ', p = ' num2str(p,3)]);
set(temp,'color','r')

fitorder=input('What order fit for t_at? ');
[coeff4,Rsq4,p,recon,xrange]=pfit(stripnan(overlap),stripnan(t_at),fitorder);
linH(4)=plot(overlap,t_at,'cv'); plot(xrange, recon, 'c')
temp=text(xrange(end),recon(end), ['r^2 =' num2str(Rsq4,3) ', p = ' num2str(p,3)]);
set(temp,'color','c')

xlabel('overlap')
legend(linH,'SAC_l_a_t','SP_l_a_t','CUS_l_a_t','t_T')