% initialize wf_ax, wf_over
wf_ax = cell(3,2); wf_over = cell(3,2);

chanstr{1,1} = 'rhs';         chanstr{1,2} = 'lhs';
titlestr{1}  = 'Horizontal';  ylabelstr{1} = 'RH (deg)';
minval(1,1)  = minRHS;        maxval(1,1)  = maxRHS;
minval(1,2)  = minLHS;        maxval(1,2)  = maxLHS;
scale(1,1)   = rh_scale;      offset(1,1)  = rh_offset;
scale(1,2)   = lh_scale;      offset(1,2)  = lh_offset;

chanstr{2,1} = 'rvs';         chanstr{2,2} = 'lvs';
titlestr{2}  = 'Vertical';    ylabelstr{2} = 'RV (deg)';
minval(2,1)  = minRVS;        maxval(2,1)  = maxRVS;
minval(2,2)  = minLVS;        maxval(2,2)  = maxLVS;
scale(2,1)   = rv_scale;      offset(2,1)  = rv_offset;
scale(2,2)   = lv_scale;      offset(2,2)  = lv_offset;

chanstr{3,1} = 'rts';         chanstr{3,2} = 'lts';
titlestr{3}  = 'Torsional';   ylabelstr{3} = 'RT (deg)';
minval(3,1)  = minRTS;        maxcal(3,1)  = maxRTS;
minval(3,2)  = minLTS;        maxcal(3,2)  = maxLTS;
scale(3,1)   = rt_scale;      offset(3,1)  = rt_offset;
scale(3,2)   = lt_scale;      offset(3,2)  = lt_offset;

plotAX(1) = plotHOR; plotAX(2) = plotVRT; plotAX(3) = plotTOR;
for x=1:3
   if plotAX(x)
		wf_ax{x,1} = axes('Position',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);
		if plotSTM, plot(t,sv,'r'); hold on; end
		eval([ 'plot(t,' chanstr{x,1} ',''c''); hold on; axis tight; grid' ]);
		title(titlestr{x},  'FontSize',14)
		ylabel(chanstr{x,1},'FontSize',12)
		wf_over{x,1} = plot(NaN, NaN,'wo');
		set(wf_over{x,1},'MarkerSize',6,'EraseMode','xor','MarkerFaceColor','r')
		if minval(x,1)~=maxval(x,1), set(wf_ax{x,1},'yLim',[minval(x,1) maxval(x,1)]); end
		set(wf_ax{x,1},'UserData',{scale(x,1), offset(x,1) });
		set(wf_ax{x,1},'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_ax{x,1},'xticklabel','')
		set(wf_ax{x,1},'Units',ax_units,'Color','k')
		sub_p=sub_p+1;

		wf_ax{x,2} = axes('Position',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);
		if plotSTM, plot(t,sv,'r'); hold on; end
		eval([ 'plot(t,' chanstr{x,2} ',''y''); hold on; axis tight; grid' ]);
		ylabel(chanstr{x,2},'FontSize',12)
		wf_over{x,2} = plot(NaN, NaN,'wo');
		set(wf_over{x,2},'MarkerSize',6,'EraseMode','xor','MarkerFaceColor','r')
		if minval(x,2)~=maxval(x,2), set(wf_ax{x,2},'yLim',[minval(x,2) maxval(x,2)]); end
		set(wf_ax{x,2},'UserData',{scale(x,2), offset(x,2) });
		set(wf_ax{x,2},'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_ax{x,2},'Units',ax_units,'Color','k')
		sub_p=sub_p+1;
   end
end

wf_axRH = wf_ax{1,1}; wf_overRH = wf_over{1,1}; wf_axLH = wf_ax{1,2}; wf_overLH = wf_over{1,2};
wf_axRV = wf_ax{2,1}; wf_overRV = wf_over{2,1}; wf_axLV = wf_ax{2,2}; wf_overLV = wf_over{2,2};
wf_axRT = wf_ax{3,1}; wf_overRT = wf_over{3,1}; wf_axLT = wf_ax{3,2}; wf_overLT = wf_over{3,2};

