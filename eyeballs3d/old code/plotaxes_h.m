	if plotHOR
		wf_axRH = axes('position',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);
		if plotSTM, plot(t,st,'r'); hold on; end
		plot(t,rhs,'c'); hold on; axis tight; grid
		title('Horizontal','FontSize',14)
		ylabel('RH (deg)','FontSize',12)
		wf_overRH = plot(NaN, NaN,'wo');
		set(wf_overRH,'MarkerSize',6,'EraseMode','xor','MarkerFaceColor','r');
		if minRHS~=maxRHS, set(wf_axRH,'yLim',[minRHS maxRHS]); end
		set(wf_axRH,'UserData',{rh_scale, rh_offset});
		set(wf_axRH,'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_axRH,'xticklabel','')
		set(wf_axRH,'Units',ax_units,'Color','k')
		sub_p=sub_p+1;

		wf_axLH = axes('position',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);
		if plotSTM, plot(t,st,'r'); hold on; end
		plot(t,lhs,'y'); hold on; axis tight; grid
		ylabel('LH (deg)','FontSize',12)
		wf_overLH = plot(NaN, NaN,'wo');
		set(wf_overLH,'MarkerSize',6,'EraseMode','xor','MarkerFaceColor','r')
		if minLHS~=maxLHS, set(wf_axLH,'yLim',[minLHS maxLHS]); end
		set(wf_axLH,'UserData',{lh_scale, lh_offset});
		set(wf_axLH,'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_axLH,'Units',ax_units,'Color','k')
		sub_p=sub_p+1;
	end
