% stdfilt.m: apply standard lpf filtering to rh, lh, rv and lv data.
% standard params: 4th order, cutoff = samp_freq/20.


rh_old = rh; lh_old = lh;
rv_old = rv; lv_old = lv;

cutoff = fix(samp_freq(1)/20);

rh=lpf(rh, 4, cutoff, samp_freq);
rv=lpf(rv, 4, cutoff, samp_freq);
lh=lpf(lh, 4, cutoff, samp_freq);
lv=lpf(lv, 4, cutoff, samp_freq);

disp(' * standard low-pass filtering applied to rh, lh, rv and lv')
disp(' * unfiltered data saved as ''rh_old'',''lh_old'',''rv_old'',''lv_old''.')
disp(' ')