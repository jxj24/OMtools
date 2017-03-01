	wf_axLV = 0; wf_axRV = 0; wf_overLV = 0; wf_overRV = 0;
	if plotVRT
		eval([ wf_ax{x,1} ' = axes(''Position'',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);' ]);
		if plotSTM, plot(t,sv,'r'); hold on; end
		eval([ 'plot(t,' chanstr{x,1} ',''c''); hold on; axis tight; grid' ]);
		title(titlestr{x},  'FontSize',14)
		ylabel(chanstr{x,1},'FontSize',12)
		eval([ wf_over{x,1} ' = plot(NaN, NaN,''wo'');' ]);
		eval([ 'set(' wf_over{x,1} ',''MarkerSize'',6,''EraseMode'',''xor'',''MarkerFaceColor'',''r'')' ]);
		if minRVS~=maxRVS, set(wf_axRV,'yLim',[minRVS maxRVS]); end
		set(wf_axRV,'UserData',{rv_scale, rv_offset});
		set(wf_axRV,'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_axRV,'xticklabel','')
		set(wf_axRV,'Units',ax_units,'Color','k')
		sub_p=sub_p+1;

		wf_axLV = axes('Position',[xorig yorig{num_ax}(sub_p) wid ht{num_ax}]);
		if plotSTM, plot(t,sv,'r'); hold on; end
		plot(t,lvs,'y'); hold on; axis tight; grid
		ylabel('LV (deg)','FontSize',12)
		wf_overLV = plot(NaN, NaN,'wo');
		set(wf_overLV,'MarkerSize',6,'EraseMode','xor','MarkerFaceColor','r')
		if minLVS~=maxLVS, set(wf_axLV,'yLim',[minLVS maxLVS]); end
		set(wf_axLV,'UserData',{lv_scale, lv_offset});
		set(wf_axLV,'xlim',[startpt/samp_freq stoppt/samp_freq])
		set(wf_axLV,'Units',ax_units,'Color','k')
		sub_p=sub_p+1;
	end
