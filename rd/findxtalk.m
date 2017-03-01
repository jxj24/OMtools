% crosstalk.m: Interactive GUI utility to guide the user in removing% hor-to-vrt and vrt-to-hor crosstalk created by Eyelink and Ober recording equipment.% This program must be run on CALIBRATED data.% To use: type 'findxtalk' at the command line and follow the instructions.% written by:  Jonathan Jacobs%              March 2004 (last mod: 03/05/04)function findxtalk(~)global lh rh lv rv lt rt xyCur1Mat xyCur2Mat xyCur1Ctr xyCur2Ctr filename samp_freqdisp(' 0) --abort--')if ~isempty(rh), disp(' 1) rh'); endif ~isempty(lh), disp(' 2) lh'); endif ~isempty(rv), disp(' 3) rv'); endif ~isempty(lv), disp(' 4) lv'); endif ~isempty(rt), disp(' Torsional data present: not EyeLink or Ober data.'), return; endif ~isempty(lt), disp(' Torsional data present: not EyeLink or Ober data.'), return; endwhich = input('Eliminate crosstalk to which channel? ');switch which  case 0, disp('Aborted.')  case 1, data_src = rh;  d_src_str = 'rh'; d_clrstr = 'CYAN';   d_clr = 'c';          xtalk_src = rv; x_src_str = 'rv'; x_clrstr = 'RED';    x_clr = 'r';   case 2, data_src = lh;  d_src_str = 'lh'; d_clrstr = 'YELLOW'; d_clr = 'y';          xtalk_src = lv; x_src_str = 'lv'; x_clrstr = 'RED';    x_clr = 'r';  case 3, data_src = rv;  d_src_str = 'rv'; d_clrstr = 'CYAN';   d_clr = 'c';          xtalk_src = rh; x_src_str = 'rh'; x_clrstr = 'RED';    x_clr = 'r';  case 4, data_src = lv;  d_src_str = 'lv'; d_clrstr = 'YELLOW'; d_clr = 'y';          xtalk_src = lh; x_src_str = 'lh'; x_clrstr = 'RED';    x_clr = 'r';  otherwise, disp('Invalid selection.  Run "findxtalk" again.'), returnendif isempty(data_src)   disp('You have selected an empty data channel.  Please run "findxtalk" again. ')   returnendif isempty(xtalk_src)   disp('You have selected an empty channel as the source of crosstalk.')	disp('If this is EyeLink or Ober data, please run "findxtalk" again. ')   returnend% plot the data and xtalk sources.  We will use zoomtool to select the points.disp(' ')disp(['Plotting "' d_src_str '" in ' d_clrstr ' and "' x_src_str '" in ' x_clrstr '.'])disp( 'The crosstalk-cleaned result will be shown in GREEN' )t=maket(data_src);plot(t, data_src, d_clr, t, xtalk_src, x_clr)hold onresultH = plot(t,NaN*ones(size(t)),'g');epttitle(['Data source: ' d_clrstr ', XTalk source: ' x_clrstr])% create lines to show selection pointspos_d_pts = plot([t(1) t(end)],[NaN NaN],'w');neg_d_pts = plot([t(1) t(end)],[NaN NaN],'w');pos_x_pts = plot([t(1) t(end)],[NaN NaN],'w');neg_x_pts = plot([t(1) t(end)],[NaN NaN],'w');set(pos_d_pts,'Marker','o','Markersize',5,'LineStyle','none');set(pos_x_pts,'Marker','o','Markersize',5,'LineStyle','none');set(neg_d_pts,'Marker','o','Markersize',5,'LineStyle','none');set(neg_x_pts,'Marker','o','Markersize',5,'LineStyle','none');zoomtool% calculate the effect due to the positive-going xtalk sourcey_or_n = 'n';while( lower(y_or_n) == 'n' )   set(resultH,'YData', NaN*ones(size(t)));   set(pos_d_pts,'XData',[t(1) t(end)],'YData',[NaN NaN])   xyCur1Mat = []; xyCur1Ctr = 0;   xyCur2Mat = []; xyCur2Ctr = 0;   while (xyCur1Ctr<1) || (xyCur2Ctr<1)      disp(' ')      disp(' ')      disp(['Put cursor ONE on the average ' d_clrstr ' fixation while the' ])      disp([x_clrstr ' is most nearly ZERO and click the "C1(x,y)" button.'])      disp(' ')      disp(['Put cursor TWO on the average ' d_clrstr ' fixation while the' ])      disp([x_clrstr 'is at a POSITIVE maximum and click the "C2(x,y)" button.'])      disp(' ')      temp=input( '  << Press ENTER to continue or "q" to quit >>', 's');      if strcmp(temp,'q'), return; end   end   pos_ind_d1 = xyCur1Mat(end,1);     % use the last selected point for each cursor   pos_ind_d2 = xyCur2Mat(end,1);   pos_pt_d1 = data_src(pos_ind_d1);   pos_pt_d2 = data_src(pos_ind_d2);    set(pos_d_pts,'XData',[pos_ind_d1 pos_ind_d2]./samp_freq,...                 'YData',[pos_pt_d1 pos_pt_d2])   set(pos_x_pts,'XData',[t(1) t(end)],'YData',[NaN NaN])   xyCur1Mat = []; xyCur1Ctr = 0;   xyCur2Mat = []; xyCur2Ctr = 0;   while (xyCur1Ctr<1) || (xyCur2Ctr<1)      disp(' ')      disp(' ')      disp(['Put cursor ONE where the average ' x_clrstr ' fixation ' ])      disp( 'is most nearly ZERO and click the "C1(x,y)" button.' )      disp(' ')      disp(['Put cursor TWO where the average ' x_clrstr ' fixation' ])      disp( 'is at a POSITIVE maximum and click the "C2(x,y)" button.' )      disp(' ')      temp=input( '  << Press ENTER to continue or "q" to quit >>', 's');      if strcmp(temp,'q'), return; end   end   pos_ind_x1 = xyCur1Mat(end,1);   pos_ind_x2 = xyCur2Mat(end,1);   pos_pt_x1 = xtalk_src(pos_ind_x1);   pos_pt_x2 = xtalk_src(pos_ind_x2);   set(pos_x_pts,'XData',[pos_ind_x1 pos_ind_x2]/samp_freq,...                 'YData',[pos_pt_x1 pos_pt_x2])	% Make the scaling matrix: multiply all val's>0 in 'xtalk_src' by the pos XT factor;	% multiply all pts<0 in 'xtalk_src' by the negative scale factor;	% combine those vals into 'scaled_xtalk' data.  subtract it from 'data_src'.   pos_xt = (pos_pt_d2-pos_pt_d1)/(pos_pt_x2-pos_pt_x1);   temp = zeros(size(xtalk_src));	temp_pos = find(xtalk_src>0);  	               % find indices of pos points	temp(temp_pos) = pos_xt * xtalk_src(temp_pos);	% creates pos part of xt correction	scaled_xtalk = temp;   % update the result data and display	temp_data_src = data_src - scaled_xtalk;   set(resultH,'YData', temp_data_src);   y_or_n = lower(input( 'Are you happy with this result (y/n)? ', 's'));   switch(y_or_n)    case {'y', ''},   data_src = temp_data_src;    case {'n'},       set(resultH,'YData', NaN*ones(size(t)));    otherwise   end   end% calculate the effect due to the negative-going xtalk sourcey_or_n = 'n';while( lower(y_or_n) == 'n' )   set(resultH,'YData', NaN*ones(size(t)));   set(neg_d_pts,'XData',[t(1) t(end)],'YData',[NaN NaN])   xyCur1Mat = []; xyCur1Ctr = 0;   xyCur2Mat = []; xyCur2Ctr = 0;   while (xyCur1Ctr<1) || (xyCur2Ctr<1)      disp(' ')      disp(' ')      disp(['Put cursor ONE on the average ' d_clrstr ' fixation while the' ])      disp([x_clrstr ' is most nearly ZERO and click the "C1(x,y)" button.'])      disp(' ')      disp(['Put cursor TWO on the average ' d_clrstr ' fixation while the' ])      disp([x_clrstr 'is at a NEGATIVE maximum and click the "C2(x,y)" button.'])      disp(' ')      temp=input( '  << Press ENTER to continue or "q" to quit >>', 's');      if strcmp(temp,'q'), return; end   end   neg_ind_d1 = xyCur1Mat(end,1);   neg_ind_d2 = xyCur2Mat(end,1);   neg_pt_d1 = data_src(neg_ind_d1);   neg_pt_d2 = data_src(neg_ind_d2);   set(neg_d_pts,'XData',[neg_ind_d1 neg_ind_d2]/samp_freq,...                 'YData',[neg_pt_d1 neg_pt_d2])   set(neg_x_pts,'XData',[t(1) t(end)],'YData',[NaN NaN])   xyCur1Mat = []; xyCur1Ctr = 0;   xyCur2Mat = []; xyCur2Ctr = 0;   while (xyCur1Ctr<1) || (xyCur2Ctr<1)      disp(' ')      disp(' ')      disp(['Put cursor ONE where the average ' x_clrstr ' fixation ' ])      disp( 'is most nearly ZERO and click the "C1(x,y)" button.' )      disp(' ')      disp(['Put cursor TWO where the average ' x_clrstr ' fixation' ])      disp( 'is at a NEGATIVE maximum and click the "C2(x,y)" button.' )      disp(' ')      temp=input( '  << Press ENTER to continue or "q" to quit >>', 's');      if strcmp(temp,'q'), return; end   end   neg_ind_x1 = xyCur1Mat(end,1);   neg_ind_x2 = xyCur2Mat(end,1);   neg_pt_x1 = xtalk_src(neg_ind_x1);   neg_pt_x2 = xtalk_src(neg_ind_x2);   set(neg_x_pts,'XData',[neg_ind_x1 neg_ind_x2]/samp_freq,...                 'YData',[neg_pt_x1 neg_pt_x2])   % see comments above   neg_xt    = (neg_pt_d2-neg_pt_d1)/(neg_pt_x2-neg_pt_x1);   temp = zeros(size(xtalk_src));	temp_neg = find(xtalk_src<0);	                  % find indices of neg points	temp(temp_neg) = neg_xt * xtalk_src(temp_neg);	% creates neg part of xt correction	scaled_xtalk = temp;   % update the result data and display	temp_data_src = data_src - scaled_xtalk;   set(resultH,'YData', temp_data_src);   y_or_n = lower(input( 'Are you happy with this result (y/n)? ', 's'));   switch(y_or_n)    case {'y', ''},    case {'n'},       set(resultH,'YData', NaN*ones(size(t)));    otherwise   end   endshortname = strtok(filename,'.');disp(['Formatted for pasting into ' shortname '.xt'])disp([d_src_str '   +' x_src_str ': ' num2str(pos_xt) ...                '   -' x_src_str ': ' num2str(neg_xt) ])% not too sure putting massaged data back is a good idea.  Why?  Because if% we remove crosstalk from, say, 'rh' and then replace 'rh' with its cleaned% version, when we go to remove crosstalk from 'rv,' we won't have the original% signal from 'rh' that interfered with 'rv.'%if which == 1, rh = data_src; end%if which == 2, lh = data_src; end%if which == 3, rv = data_src; end%if which == 4; lv = data_src; end