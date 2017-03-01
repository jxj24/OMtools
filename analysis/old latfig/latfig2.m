% save unmod data
t=maket(rh); rh_old=rh;lh_old=lh;st_old=st;

% filter
rh=lpf(rh,4,20,500); lh=lpf(lh,4,20,500); st=lpf(st,4,20,500);

% calc vel  & blank out pts > 750 deg/sec
rhv=d2pt(rh,3); lhv=d2pt(lh,3); stv=d2pt(st,3);
ind = find(abs(rhv)>750); rhv(ind) = NaN;
ind = find(abs(lhv)>750); lhv(ind) = NaN;

ind = find(abs(rh)>45); rh(ind) = NaN;
ind = find(abs(lh)>45); lh(ind) = NaN;

% plot UNFILTERED pos, scaled vel data, stim
figure;plot(t,rh_old,'b',t,lh_old,'g',t,st_old,'r',t,rhv/25-5,'c',t,lhv/25-5,'k',t,stv/25-5,'m')

% calc pos errors -- blank pts >5 deg
rh_err = rh-st; lh_err = lh-st;
ind = find(abs(rh_err)>5); rh_err(ind) = NaN;
ind = find(abs(lh_err)>5); lh_err(ind) = NaN;

hold on; plh=plot(t,rh_err*4-40,'b'); set(plh,'color', [0 0 .8]);
plh=plot(t,lh_err*4-40,'g'); set(plh,'color',[0 .8 0]);
plh=plot([0 60],[-40 -40],'k--');set(plh,'color',[.666 .666 .666])
plh=plot([0 60],[-42 -42],'k--');set(plh,'color',[.666 .666 .666])
plh=plot([0 60],[-38 -38],'k--');set(plh,'color',[.666 .666 .666])

% calc vel errors (NO SCALING)
rhv_err = (rhv-stv); lhv_err = (lhv-stv);
ind = find(abs(rhv_err)>15); rhv_err(ind) = NaN;
ind = find(abs(lhv_err)>15); lhv_err(ind) = NaN;

hold on; plh=plot(t,rhv_err*1+40,'b'); set(plh,'color',[0 0 .666]);
plh=plot(t,lhv_err*1+40,'g'); set(plh,'color',[0 .666 0]);
plh=plot([0 60],[40 40],'k--');set(plh,'color',[.666 .666 .666])
plh=plot([0 60],[44 44],'k--');set(plh,'color',[.666 .666 .666])
plh=plot([0 60],[36 36],'k--');set(plh,'color',[.666 .666 .666])

zoomtool