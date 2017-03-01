%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% POST-PROCESSING %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the saccade control points file ( 'xxxxxxx.s' )
% if (doLoadSacs)
%    sacpt_file = upper([shortname '.s']);
%    [sacv_on, sacp_on, sacp_off, sacv_off, prev_fov_pt,slow_peak, max_v_pt,...
%       cycle_beg, cycle_end, eye, w_form, s_type, sac_loaded] = rdscp(sacpt_file);
%    [temp,count]=size(sacv_on);
% else
%    sac_loaded = 0;
% end
% 
% hasSacPts(total_files,:) = [0 0 0 0 0 0];
% whichWFST(total_files,:) = '?????   ?????????????'; %5,3,13
% if sac_loaded
%    pick_wfst
%    fill_scp
% end
% 
% % plot the data & saccades
% color = ['y','c','m','r','b','g','w'];
% if (showGraphs)
%    figure
%    for xx = 1:dat_cols
%       if sac_loaded
%          if strcmpi( chName(xx,:), 'lh')
%             [max_len_l, lh_col] = size( lh );
%             sacOnTemp = sacp_on_lh(:,lh_col);     % could be NaNs
%             sacOffTemp = sacp_off_lh(:,lh_col);   % could be NaNs
%             
%          elseif strcmpi( chName(xx,:), 'rh')
%             [max_len_r, rh_col] = size( rh );
%             sacOnTemp = sacp_on_rh(:,rh_col);
%             sacOffTemp = sacp_off_rh(:,rh_col);
%             
%          elseif strcmpi( chName(xx,:), 'lv')
%             [max_len_l, lv_col] = size( lv );
%             sacOnTemp = sacp_on_lv(:,lv_col);
%             sacOffTemp = sacp_off_lv(:,lv_col);
%             
%          elseif strcmpi(chName(xx,:), 'rv')
%             [max_len_r, rv_col] = size( rv );
%             sacOnTemp = sacp_on_rv(:,rv_col);
%             sacOffTemp = sacp_off_rv(:,rv_col);
%             
%          elseif strcmpi(chName(xx,:), 'lt')
%             [max_len_l, lt_col] = size( lt );
%             sacOnTemp = sacp_on_lt(:,lt_col);
%             sacOffTemp = sacp_off_lt(:,lt_col);
%             
%          elseif strcmpi(chName(xx,:), 'rt')
%             [max_len_r, rt_col] = size( rt );
%             sacOnTemp = sacp_on_rt(:,rt_col);
%             sacOffTemp = sacp_off_rt(:,rt_col);
%          end
%       end %if sac_loaded
%       
%       dat_len = length(find(newdata(:,xx)<100000));
%       if (useTimeAxis)
%          t = (1:dat_len)/samp_freq(1);
%          x_label = 'time (seconds)';
%          x_factor = samp_freq;
%       else
%          t = 1:dat_len;
%          x_label = 'sample number';
%          x_factor = 1.0;
%       end
%       hold on
%       plot( t, newdata(1:dat_len, xx ),color(xx) )
%       hold on
%       if (sac_loaded)
%          numSPts = length(find(sacOnTemp<100000));
%          if numSPts
%             on  = [1; sacOnTemp(1:numSPts); dat_len];
%             off = [1; sacOffTemp(1:numSPts); dat_len];
%             plot( on/x_factor,  newdata(on, xx), 'go', 'Marker', 4)
%             plot( off/x_factor, newdata(off, xx), 'co', 'Marker', 4)
%          end
%       end
%       drawrad(0, 0.5, 0, 0,'w',1);
%       xlabel( x_label )
%       ylabel( 'position (deg)' )
%       hold off
%    end %if xx
%    title( [ filename ] )
% end %for (showGraphs)
% %title( [ filename '   (' chName(xx,:) ')' ] )
