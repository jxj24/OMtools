% stdproc.m: Deblink & perform standard LPF, differentiation operations on
% rh, lh, rv, lv data.  Create a time vector, t.
% 

%global samp_freq rh lh rv lv rt lt t do_deblink

do_deblink = 0;

if ~exist('do_deblink','var')
   do_deblink = [];
end

yorn='n';
if isempty( do_deblink )
   yorn = input('Apply deblinking to this trial (y/n)? ','s');
end

if strcmpi(yorn,'y')
   do_deblink = 1;
   dblstr = 'deblinked and ';
else
   do_deblink = 0;
   dblstr = '';
end

order = 4;
cutoff = samp_freq/20;

if exist('lh','var')
   if ~isempty(lh) && ~all(isnan(lh))
      if do_deblink
         lh=deblink(lh);
      end      
      lh=lpf(lh,order, cutoff, samp_freq); lhv=d2pt(lh,5);
      disp(['lh ' dblstr 'low-pass filtered, velocity created as "lhv".'])
      t=maket(lh);
   end
end
   
if exist('rh','var')
   if ~isempty(rh) && ~all(isnan(rh))
      if do_deblink
         rh=deblink(rh);
      end
      rh=lpf(rh,order, cutoff, samp_freq); rhv=d2pt(rh,5);
      t=maket(rh);
      disp(['rh ' dblstr 'low-pass filtered, velocity created as "rhv".'])
   end
end

if exist('lv','var')
   if ~isempty(lv) && ~all(isnan(lv))
      if do_deblink
         lv=deblink(lv);
      end
      lv=lpf(lv,order, cutoff, samp_freq); lvv=d2pt(lv,5);
      disp(['lv ' dblstr 'low-pass filtered, velocity created as "lvv".'])
  end
end

if exist('rv','var')
   if ~isempty(rv) && ~all(isnan(rv))
      if do_deblink
         rv=deblink(rv);
      end
      rv=lpf(rv,order, cutoff, samp_freq); rvv=d2pt(rv,5);
      disp(['rv ' dblstr 'low-pass filtered, velocity created as "rvv".'])
   end
end

if exist('lt','var')
   if ~isempty(lt)  && ~all(isnan(lt))
      if do_deblink
         lt=deblink(lt);
      end
      lt=lpf(lt,order, cutoff, samp_freq); ltv=d2pt(lt,5);
      disp(['lt ' dblstr 'low-pass filtered, velocity created as "ltv".'])
  end
end

if exist('rt','var')
   if ~isempty(rt) && ~all(isnan(rt))
      if do_deblink
         rt=deblink(rt);
      end
      rt=lpf(rt,order, cutoff, samp_freq); rtv=d2pt(rt,5);
      disp(['rt ' dblstr 'low-pass filtered, velocity created as "rtv".'])
   end
end

disp('Time vector created as "t".')
disp(' ')