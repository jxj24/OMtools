	if plotTOR
		wf_axRT = axes('Position',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);
		plot(t,rts,'c'); hold on; axis tight; grid
		title('Torsional','FontSize',14)
		ylabel('RT (deg)','FontSize',12)
		wf_overRT = plot(NaN, NaN,'wo');
		set(wf_overRT,'MarkerSize',6,'EraseMode','xor','MarkerFaceColor','r')
		if minRTS~=maxRTS, set(wf_axRT,'yLim',[minRTS maxRTS]); end
		set(wf_axRT,'UserData',{rt_scale, rt_offset});
		set(wf_axRT,'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_axRT,'xticklabel','')
		set(wf_axRT,'Units',ax_units,'Color','k')
		sub_p=sub_p+1;

		wf_axLT = axes('Position',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);
		plot(t,lts,'y'); hold on; axis tight; grid
		ylabel('LT (deg)','FontSize',12)
		wf_overLT = plot(NaN, NaN,'wo');
		set(wf_overLT,'MarkerSize',6,'EraseMode','xor','MarkerFaceColor','r')
		if minLTS~=maxLTS, set(wf_axLT,'yLim',[minLTS maxLTS]); end
		set(wf_axLT,'UserData',{lt_scale, lt_offset});
		set(wf_axLT,'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_axLT,'Units',ax_units,'Color','k')
		sub_p=sub_p+1;
	end
