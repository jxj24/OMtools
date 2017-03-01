% ao_deblink: Remove blinks from data recorded by sampling from
% (e.g.) Eyelink's optional analog out card.
% Usage: out = ao_deblink( in, spread, width )
% where 'in' is pos data (e.g., lh). This is the only REQUIRED ARGUMENT
% where 'spread' is the STD of the data's range considered good (def = 3)
%       'width' is how many msec to remove before/after a blink (def = 75)
%
% What could go wrong? I am assuming a close-enough-to-normal distribution
% of eye-movement position data (for generous values of "close enough"). 
% So far, moderate amounts of blinking (one every 5-10 seconds) does not 
% seem to shift the mean noticeably, even though Eyelink AO drives voltage
% to the minus rail when it detects a dropout.

% written by: Jonathan Jacobs  Nov 2016
% last mod: 11/11/16

function pos=ao_deblink(pos, spread, width)

global samp_freq

if nargin<2, spread = 3; width = 75; end

width = fix(width/1000 * samp_freq);  % convert from milliseconds to samples.
npts = length(pos);
vel = d2pt(pos,2); acc = d2pt(vel,2);

% assume normal distribution
[mu_pos, sig_pos]=normfit(pos);
[mu_vel, sig_vel]=normfit(vel);
[mu_acc, sig_acc]=normfit(acc);

% upper/lower limits for actual eye-movement data
min_pos_hi_lim = 40; min_pos_lo_lim = -40;
min_vel_hi_lim = 400; min_vel_lo_lim = -400;
min_acc_hi_lim = 4000; min_acc_lo_lim = -4000;

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

bad_pos = find( pos < pos_lo_lim | pos > pos_hi_lim );
bad_vel = find( vel < vel_lo_lim | vel > vel_hi_lim );
bad_acc = find( acc < acc_lo_lim | acc > acc_hi_lim );

% all points that meet exclusion criteria
bad_pts = union(bad_pos, bad_vel);
bad_pts = union(bad_pts, bad_acc);

% and then spread
for i = width
    bad_pts = union(bad_pts, bad_pts+i);
    bad_pts = union(bad_pts, bad_pts-i);
end

bad_pts = bad_pts( find(bad_pts>0 | bad_pts<npts) );
pos(bad_pts)=NaN;