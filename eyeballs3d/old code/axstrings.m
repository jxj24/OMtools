wf_ax{1,1}   = 'wf_axRH';	  wf_over{1,1} = 'wf_overRH';
wf_ax{1,2}   = 'wf_axLH';	  wf_over{1,2} = 'wf_overLH';
chanstr{1,1} = 'rhs';         chanstr{1,2} = 'lhs';
titlestr{1}  = 'Horizontal';  ylabelstr{1} = 'RH (deg)';
minStr{1,1}  = 'minRHS';      maxStr{1,1}  = 'maxRHS';
minStr{1,2}  = 'minLHS';      maxStr{1,2}  = 'maxLHS';
scale{1,1}   = 'rh_scale';    offset{1,1}  = 'rh_offset';
scale{1,2}   = 'lh_scale';    offset{1,2}  = 'lh_offset';

wf_ax{2,1}   = 'wf_axRV';	  wf_over{2,1} = 'wf_overRV';
wf_ax{2,2}   = 'wf_axLV';	  wf_over{2,2} = 'wf_overLV';
chanstr{2,1} = 'rvs';         chanstr{2,2} = 'lvs';
titlestr{2}  = 'Vertical';    ylabelstr{2} = 'RV (deg)';
minStr{2,1}  = 'minRVS';      maxStr{2,1}  = 'maxRVS';
minStr{2,2}  = 'minLVS';      maxStr{2,2}  = 'maxLVS';
scale{2,1}   = 'rv_scale';    offset{2,1}  = 'rv_offset';
scale{2,2}   = 'lv_scale';    offset{2,2}  = 'lv_offset';

wf_ax{3,1}   = 'wf_axRT';	  wf_over{3,1} = 'wf_overRT';
wf_ax{3,2}   = 'wf_axLT';	  wf_over{3,2} = 'wf_overLT';
chanstr{3,1} = 'rts';         chanstr{3,2} = 'lts';
titlestr{3}  = 'Torsional';   ylabelstr{3} = 'RT (deg)';
minStr{3,1}  = 'minRTS';      maxStr{3,1}  = 'maxRTS';
minStr{3,2}  = 'minLTS';      maxStr{3,2}  = 'maxLTS';
scale{3,1}   = 'rt_scale';    offset{3,1}  = 'rt_offset';
scale{3,2}   = 'lt_scale';    offset{3,2}  = 'lt_offset';

wf_axLH = 0; wf_axRH = 0; wf_overLH = 0; wf_overRH = 0;
wf_axLV = 0; wf_axRV = 0; wf_overLV = 0; wf_overRV = 0;
wf_axLT = 0; wf_axRT = 0; wf_overLT = 0; wf_overRT = 0;
