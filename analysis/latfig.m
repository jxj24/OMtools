function latfig

global rh lh st samp_freq namearray

% save unmod data
t=maket(rh); rh_old=rh;lh_old=lh;st_old=st;

% filter
rhf1=lpf(rh,1,25,500); lhf1=lpf(lh,1,25,500); stf1=lpf(st,1,25,500);
rhf=lpf(rh,4,25,500); lhf=lpf(lh,4,25,500); stf=lpf(st,4,25,500);

% calc vel  & blank out pts > 750 deg/sec
rhv=d2pt(rhf,3); lhv=d2pt(lhf,3); stv=d2pt(stf,3);
ind = find(abs(rhv)>750); rhv(ind) = NaN;
ind = find(abs(lhv)>750); lhv(ind) = NaN;

ind = find(abs(rh)>45); rh(ind) = NaN;
ind = find(abs(lh)>45); lh(ind) = NaN;

% plot UNFILTERED pos, scaled vel data, stim
bg=get(0,'defaultfigurecolor');
if bg(1)==0.8  %% white
	rh_clr='b'; lh_clr='g'; st_clr='r'; rhv_clr='c'; lhv_clr='k'; stv_clr='m';
	rh_err_clr='b'; lh_err_clr='g'; z_style='k--'; rad_style='k--';
	z_clr=[.666 .666 .666]; rad_clr=[.666 .666 .666];		
else %% 'none' or black
	rh_clr='c'; lh_clr='y'; st_clr='r--'; rhv_clr='c'; lhv_clr='y'; stv_clr='m--';
	rh_err_clr='c'; lh_err_clr='y'; z_style='k--'; rad_style='w-.';
	z_clr=[.666 .666 .666]; rad_clr=[.5 .5 .5];		
end

latfignum=figure; set(latfignum,'Name',[deblank(namearray) ' Latency']);
plot(t,rh,rh_clr,t,lh,lh_clr,t,st,st_clr,t,rhv/25-5,rhv_clr,t,lhv/25-5,lhv_clr,t,stv/25-5,stv_clr)

% calc pos errors -- blank pts >5 deg
rh_err = rhf-stf; lh_err = lhf-stf;
ind = find(abs(rh_err)>3.5); rh_err(ind) = NaN;
ind = find(abs(lh_err)>3.5); lh_err(ind) = NaN;

p_shift = 30;

hold on; 
plh=plot(t,(rh_err*4)-p_shift,'b'); set(plh,'color', rh_err_clr);
plh=plot(t,(lh_err*4)-p_shift,'g'); set(plh,'color', lh_err_clr);
plh=plot([0 t(end)],[-p_shift     -p_shift],z_style);       set(plh,'color',z_clr)
plh=plot([0 t(end)],[-(p_shift+2) -(p_shift+2)],rad_style); set(plh,'color',rad_clr)
plh=plot([0 t(end)],[-(p_shift-2) -(p_shift-2)],rad_style); set(plh,'color',rad_clr)

% calc vel errors (NO SCALING)
rhv_err = (rhv-stv); lhv_err = (lhv-stv);
ind = find(abs(rhv_err)>15); rhv_err(ind) = NaN;
ind = find(abs(lhv_err)>15); lhv_err(ind) = NaN;

hold on; 
%plh=plot(t,rhv_err*1+40,'b'); set(plh,'color',[0 0 .666]);
%plh=plot(t,lhv_err*1+40,'g'); set(plh,'color',[0 .666 0]);
%plh=plot([0 60],[40 40],'k--');set(plh,'color',[.666 .666 .666])
%plh=plot([0 60],[44 44],'k--');set(plh,'color',[.666 .666 .666])
%plh=plot([0 60],[36 36],'k--');set(plh,'color',[.666 .666 .666])

ept
title(deblank(namearray))