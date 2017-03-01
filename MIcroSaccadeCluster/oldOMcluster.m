% pathname is created by rd. make sure rdclear isn't deleting it at the end of rd.

folder = pathname;
session = deblank(namelist(1,:));
session = strtok(session, '.');    % name of the file (minus exten)

% Set up variables --------------------------------------------------------
samples = [t*samp_freq lh lv rh rv];

lhd = deblink(lh); lvd = deblink(lv);
rhd = deblink(rh); rvd = deblink(rv);

use_deblink = 1;
if use_deblink
   lh_orig = lh;  rh_orig = rh;
   lv_orig = lv;  rv_orig = rv;
   lh = lhd; rh = rhd;
   lv = lvd; rv = rvd;
end

% i think "blinks" is based only on Eyelink-type data, where dropouts are NaNs.
% hopefully using our deblinking ahead of time will force data to look like what
% their deblink routine expects. May have to tune our deblink params?
blinks = filtfilt(ones(100,1)',1,double(isnan(mean(samples')'))); %% this may not work.
% samples(isnan(samples(:))) = 0;

% Loads the recording and prepares it por processing
recording = ClusterDetection.EyeMovRecording.Create(folder, session, ...
      samples, blinks, samp_freq);

% Runs the saccade detection
[saccades, stats] = recording.FindSaccades();
[r,c] = size(saccades);

% Plots a PV vs ampl
enum = ClusterDetection.SaccadeDetector.GetEnum;
figure; hold on
plot(saccades(:,enum.amplitude),saccades(:,enum.peakVelocity),'o')
set(gca,'xlim',[0 1],'ylim',[0 100]);
xlabel('Saccade amplitude (deg)');
ylabel('Saccade peak velocity (deg/s)');

% Plots the traces with the labeled microsaccades
figure; hold on
plot(samples(:,1)/samp_freq, samples(:,2:end));
yl = get(gca,'ylim');
u1 = zeros(size(samples(:,1)))+yl(1);
u2 = zeros(size(samples(:,1)))+yl(1);
u1(saccades(:,enum.startIndex)) = yl(2);
u2(saccades(:,enum.endIndex)) = yl(2);
u = cumsum(u1)-cumsum(u2);
plot(samples(:,1)/samp_freq, u,'k')

% create data array, ds, that holds these variables:
prop_names = {'r_start_t'; 'r_start_pos'; 'r_stop_t'; 'r_stop_pos'; ...
              'r_peak_vel'; 'r_peak_vel_t'; 'r_peak_acc'; 'r_peak_acc_t'; ...
              'l_start_t'; 'l_start_pos'; 'l_stop_t'; 'l_stop_pos'; ...
              'l_peak_vel'; 'l_peak_vel_t'; 'l_peak_acc'; 'l_peak_acc_t'};

dataout = zeros(r,16);
dataout(:,1) = saccades(:,1)/samp_freq; %time based
dataout(:,2) = rh(saccades(:,1));    
dataout(:,3) = saccades(:,2)/samp_freq;        
dataout(:,4) = rh(saccades(:,2));    

dataout(:,5) = saccades(:,12);
% event markers are offsets from beginning of the saccade
dataout(:,6) = (saccades(:,15) + saccades(:,1))/samp_freq; 
dataout(:,7) = saccades(:,21);
dataout(:,8) = (saccades(:,24) + saccades(:,1))/samp_freq;

dataout(:,9)  = saccades(:,1)/samp_freq;
dataout(:,10) = lh(saccades(:,1));
dataout(:,11) = saccades(:,2)/samp_freq;
dataout(:,12) = lh(saccades(:,2));
           
dataout(:,13) = saccades(:,11);
% event markers are offsets from beginning of the saccade
dataout(:,14) = (saccades(:,14) + saccades(:,1))/samp_freq;
dataout(:,15) = saccades(:,20);
dataout(:,16) = (saccades(:,23) + saccades(:,1))/samp_freq;

dataout = jjround(dataout,3);

% columns 6,8,14,16 are in SAMPLES.
% may have to convert to time (div by samp_freq)
% to use with fatigue analysis spreadsheet.

T = array2table(dataout);
T.Properties.VariableNames = prop_names;

% ask where to save the file
[fName, pathName] = uiputfile('*.txt', 'Save Saccade Info as');
if isequal(fName,0) || isequal(pathName,0)
    disp('User pressed cancel')
 else
   % save the file
    disp(['Saving as ', fullfile(pathName, fName)])
    writetable(T, fullfile(pathName, fName),'Delimiter','tab')
end
