% ao_deblink: Remove blinks from data recorded by sampling from
% (e.g.) Eyelink's optional analog out card.
% Usage: out = ao_deblink( in, spread, width )
% where 'in' is pos data (e.g., lh). This is the only REQUIRED ARGUMENT
% where 'spread' is the STD of the data's range considered good (def = 3)
%       'width' is how many msec to remove before/after a blink (def = 250)
%
% What could go wrong? I am assuming a close-enough-to-normal distribution
% of eye-movement position data (for generous values of "close enough"). 
% So far, moderate amounts of blinking (one every 5-10 seconds) does not 
% seem to shift the mean noticeably, even though Eyelink AO drives voltage
% to the minus rail when it detects a dropout.

% written by: Jonathan Jacobs  November 2016 - January 2019
% last mod: 01/08/19

% 01/08/19: added new "NaN spreading" to clean area to either side of NaNs
%           (default +/-50 samples)

function pos_d=ao_deblink(pos, spread, inpSF)

global samp_freq

if all(isempty(pos))
   disp('deblink_ao: input array is empty!')
   pos_d = [];
   return
end

if nargin<3 || isempty(inpSF)
   if isempty(samp_freq) || samp_freq==0
      samp_freq = input('Enter the sampling frequency: ');
   end
else
   samp_freq=inpSF;
end

if nargin<2
   spread = 1.125;
   %pre_width  = 250;  % width in msec
   %post_width = 250;
end  

%pre_width  = fix(samp_freq*pre_width/1000);  % convert from milliseconds to samples.
%post_width = fix(samp_freq*post_width/1000);
%poslen = length(pos);
vel = d2pt(pos,3,samp_freq); 
acc = d2pt(vel,3,samp_freq);

% assume normal distribution
% (can we REALLY make this assumption for EM data???)
% Don't think so -- use histfit after doing histogram to decide.
% -- Stats TBX function -- find basic replacement -- 
%[mu_pos,sig_pos]=normfit(stripnan(pos));
%[mu_vel,sig_vel]=normfit(stripnan(vel));
%[mu_acc,sig_acc]=normfit(stripnan(acc));

% FAKE FAKE FAKE!!!
mu_pos =   50;   sig_pos =    -50;
mu_vel =  1000;  sig_vel =  -1000;
mu_acc = 75000;  sig_acc = -75000;

% upper/lower limits for actual eye-movement data
min_pos_hi_lim =   50;   min_pos_lo_lim =    -50;
min_vel_hi_lim =  1000;  min_vel_lo_lim =  -1000;
min_acc_hi_lim = 75000;  min_acc_lo_lim = -75000;

pos_hi_lim = mu_pos + spread*sig_pos; 
pos_hi_lim = max(pos_hi_lim, min_pos_hi_lim);
pos_lo_lim = mu_pos - spread*sig_pos; 
pos_lo_lim = min(pos_lo_lim, min_pos_lo_lim);
vel_hi_lim = mu_vel + spread*sig_vel; 
vel_hi_lim = max(vel_hi_lim, min_vel_hi_lim);
vel_lo_lim = mu_vel - spread*sig_vel; 
vel_lo_lim = min(vel_lo_lim, min_vel_lo_lim);
acc_hi_lim = mu_acc + spread*sig_acc; 
acc_hi_lim = max(acc_hi_lim, min_acc_hi_lim);
acc_lo_lim = mu_acc - spread*sig_acc; 
acc_lo_lim = min(acc_lo_lim, min_acc_lo_lim);

pos_d = pos; %posfig=figure;plot(pos_d);hold on
%vel_d = vel; %velfig=figure;plot(vel_d);hold on
%acc_d = acc; %accfig=figure;plot(acc_d);hold on

bad_pos = union( find(pos<pos_lo_lim), find(pos>pos_hi_lim) ); 
pos_d(bad_pos)=NaN; %#ok<*FNDSB>
%vel_d(bad_pos)=NaN;
%acc_d(bad_pos)=NaN;
%figure(posfig);plot(pos_d,'g')
%figure(velfig);plot(vel_d,'g')
%figure(accfig);plot(acc_d,'g')

bad_vel = union( find(vel<vel_lo_lim), find(vel>vel_hi_lim) ); 
pos_d(bad_vel)=NaN;
%vel_d(bad_vel)=NaN;
%acc_d(bad_vel)=NaN;
%figure(posfig);plot(pos_d,'r')
%figure(velfig);plot(vel_d,'r')
%figure(accfig);plot(acc_d,'r')

bad_acc = union( find(acc<acc_lo_lim), find(acc>acc_hi_lim) ); 
pos_d(bad_acc)=NaN;

% NEW NaN spread method
%expand the NaNs x places to either side. 
% default 50 samples = +/- 100 msec for 500Hz
for ii = 1:50
   temp1 = [pos_d(1); pos_d(1:end-1)];
   temp2 = [pos_d(2:end); pos_d(end)];   
   temp3 = (pos_d+temp1)/2;
   temp4 = (pos_d+temp2)/2;
   pos_d = (temp3+temp4)/2;
end

%vel_d(bad_acc)=NaN;
%acc_d(bad_vel)=NaN;
%figure(posfig);plot(pos_d,'m')
%figure(velfig);plot(vel_d,'m')
%figure(accfig);plot(acc_d,'m')

%{
% OLD NaN spread method
% for now(?), disable the spread feature
% all points that meet exclusion criteria
bad_pts = union(bad_pos, bad_vel);
bad_pts = union(bad_pts, bad_acc);

% and then spread to catch points on either side
bp2 = [bad_pts(1); bad_pts];
bp1 = [bad_pts; bad_pts(end)];
temp = abs(bp2-bp1);
bp_seps = bad_pts(find(temp>1)); %#ok<FNDSB>
for i = 1:length(bp_seps)
   plug = (bp_seps(i)-pre_width):(bp_seps(i)+post_width); 
   x = plug(plug>0 & plug<poslen);
   pos_d(x)=NaN;
end
%}

end %function