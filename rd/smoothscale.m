% smoothscale.m: smooth-curve function for asymmetric rescaling.  Improvement on
% the piecewise-linear function originally implemented in 'adj'.
% 

function scaled_pos = smoothscale(scaled_vect,scaled_data,z_adj,maxcalpt,mincalpt,stim);

global sampfreq

%% 'rd' passes to (e.g.) 'rd_labv' which passes to 'getbias' which calls 'readbias'
%% after the bias values are read in, 'applybias' passes offset value, the 
%% scale points & values to 'adj' which calls 'smoothscale'.

%% NOTE: the code in 'cal_test' was written as a test of a future version that doesn't 
%% perform the rescaling after each new cal point is picked.
%% Also, the min_cal and max_cal arrays in 'cal' are NOT the same order or indices as the ones
%% that are passed from 'applybias', which are in the final, cleaned-up format.

[dataRows, dataCols] = size( scaled_data );
if min(dataCols,dataRows) > 1
   dColStr = num2str(dataCols);
   disp( ['There are ' dColStr ' columns in the data array.'] )
   disp( ['I will adjust only the last column added.'] ) 
   scaled_data=scaled_data(:,end)
end

up_lim = 60;
%%% hard limit data to [-upper limit ... upper limit]
scaled_data( find(scaled_data>up_lim) )  =  up_lim;
scaled_data( find(scaled_data<-up_lim) ) = -up_lim;

%%% set x range wider than measured cal range.  we will use this so that we can force scaling
%%% out of measured range to be 1.0
x_temp = [mincalpt(end:-1:1)  0   maxcalpt(1:end)];
%extra_min = [-up_lim: 2: x_temp(1)];
%extra_max = [up_lim: -2: x_temp(end)];
%extra_max = extra_max(end:-1:1);
extra_min = [-up_lim:  2: -50];
extra_max = [ up_lim: -2:  50];
extra_max = extra_max(end:-1:1);

% remove duplication between added points and calibrated points
if extra_min(end) >= x_temp(1), extra_min=extra_min(1:end-1); end
if extra_max(1) <= x_temp(end), extra_max=extra_max(2:end); end

x_data = [extra_min x_temp extra_max];

%% Old-style calibration was applied (in 'applybias') to a vector of [-lim ... lim]
%% Now simply pick out the points that have scaled to match the calibration
%% points.
delta = 0.01;
test_vect = [mincalpt(end) : 0.01 : maxcalpt(end)]';
for i = 1:length(x_temp)	
	closepts = [];
   while isempty(closepts)
		calval = x_temp(i);
		closepts=find( (scaled_vect>calval-delta) & (scaled_vect<calval+delta) );		
		
		% make sure delta range around val gives results
		if length(closepts)<1, delta = delta*2; end

	end %% while
	
	%% now we have some points close to the cal point. Find the closest one.
	bestpt = find( abs(scaled_data(closepts)-calval) == min(abs(scaled_data(closepts)-calval)) );
	cal_index(i) = closepts(bestpt(1));

end

% now we have points that are equivalent to those originally picked for the p.w-lin calibration
% we can use them for the mapping.
%new_max_pts = unscaled_data(max_cal_index)'-z_adj;
%new_min_pts = unscaled_data(min_cal_index)'-z_adj;

%y_temp = [new_min_pts(end:-1:1) 0 new_max_pts];
y_temp = cal_index;
y_data = [extra_min y_temp extra_max];

keyboard

% what order fit to perform?  For safety sake, just over half the length of the x vector.
% pfit using (y,x) data because we want an INVERSE, so, e.g., -20.3 would map to -20 deg
% NOTE: to prevent ill-conditioned fit, 'pfit' has been modified to perform centering and 
% scaling using mu (mean, std scaling).  Therefore the mu vector MUST be used in the
% reconstructed polynomial evaluation, or the results will be garbage.
order = fix(length(x_data)/2)+2;

[coeff,Rsq,p,recon,xrange,errmat,mu]=pfit(y_data, x_data, order);

%%% temporary diagnostic
figure; plot([-up_lim up_lim],[-up_lim up_lim],'r--'); hold on
plot(xrange,recon)
plot(y_data,x_data,'mo')

% use polyval to apply curvefit function to unscaled data
scaled_pos = polyval(coeff, unscaled_data-z_adj, errmat, mu);

%%% more diagnostic
t=maket(scaled_data);
figure; plot(t, unscaled_data-z_adj, 'g', t, scaled_pos, 'b')