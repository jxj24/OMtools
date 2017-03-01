% stdproc.m: Perform standard LPF, differentiation operations on
% rh, lh, rv, lv data.  Create a time vector, t.
% 

global samp_freq

order = 4;
cutoff = samp_freq/20;

if exist('lh')
   if ~isempty(lh)
      lh=lpf(lh,order, cutoff, samp_freq); lhv=d2pt(lh,3);
      disp('lh low-pass filtered, velocity created as "lhv".')
      t=maket(lh);
   end
end
   
if exist('rh')
   if ~isempty(rh)
      rh=lpf(rh,order, cutoff, samp_freq); rhv=d2pt(rh,3);
      t=maket(rh);
      disp('rh low-pass filtered, velocity created as "rhv".')
   end
end

if exist('lv')
   if ~isempty(lv)
      lv=lpf(lv,order, cutoff, samp_freq); lvv=d2pt(lh,3);
       disp('lv low-pass filtered, velocity created as "lvv".')
  end
end

if exist('rv')
   if ~isempty(rv)
      rv=lpf(rv,order, cutoff, samp_freq); lrvv=d2pt(rv,3);
      disp('rv low-pass filtered, velocity created as "rvv".')
   end
end

disp('Time vector created as "t".')
disp(' ')