function hand_eye()



% eye data:
% edf2bin
% biasgen



% hdf_filename = '20161229-141243-peggyposition.h5';
% avi_filename = 'pegpos1.avi';

bin_filename = '/Users/peggy/Dropbox/Fatema/peggydata 122916/pegtas2/pegtas2_1.bin'; % must be full path for rd_cli to work
hdf_filename = '20161229-141855-pegtask2.h5';
avi_filename = 'pegtas21.avi';

[rh,rv,lh,lv,samp_freq] = rd_cli(bin_filename);
t = (1:length(rh))/samp_freq;

% t, rh, lh, rv, lv (& rhv, lhv, ...)
% t = evalin('base', 't');
% rh = evalin('base', 'rh');
% lh = evalin('base', 'lh');
% rv = evalin('base', 'rv');
% lv = evalin('base', 'lv');
figure('Position', [1000 391 767 947]);

h_ax_eye = subplot(3,1,1);

plot(t,rh,t,lh,t,rv,t,lv)
title( 'Eye Position')
set(h_ax_eye, 'YLim', [-30 30]); 
legend('rh', 'lh', 'rv', 'lv')

% accelerometer data

[time, sensors, accel, annot] = get_hdf_data(hdf_filename);

hand_accel = accel{1};

h_ax_hand = subplot(3,1,2);
plot(time, hand_accel(1,:), time, hand_accel(2,:), time, hand_accel(3,:))
title('Hand Acceleration')
set(h_ax_hand, 'YLim', [-15 15]); 


ud.h_link = linkprop([h_ax_eye, h_ax_hand ], 'XLim');


% vertical line in the 2 data plots
x_scrub_line = 0;
axes(h_ax_eye)
h_scrub_line = line( [x_scrub_line, x_scrub_line], [-2000, 2000], ...
    'Color', 'k', 'linewidth', 2, ...
    'Tag', 'eye_scrub_line');
draggable(h_scrub_line,'h', @scrubLineMotionFcn)
axes(h_ax_hand)
h_line2 = line( [x_scrub_line, x_scrub_line], [-15 15], ...
    'Color', 'k', 'linewidth', 2, ...
    'Tag', 'hand_scrub_line');
draggable(h_line2,'h', @scrubLineMotionFcn)



% video

%implay(avi_filename)

v = VideoReader(avi_filename);

v.CurrentTime = 0;

currAxes = subplot(3,1,3);
ud.video_axes = currAxes;
ud.video_reader = v;
set(gcf, 'UserData', ud);

if hasFrame(v)
    vidFrame = readFrame(v);
    %image(currAxes, vidFrame);
     image(vidFrame, 'Parent', currAxes);
    currAxes.Visible = 'off';
end


end

% --------------------------------------------------------
function scrubLineMotionFcn(h_line)
xdata = get(h_line, 'XData');
t = xdata(1);

h_hand_line = findobj(gcf, 'Tag', 'hand_scrub_line');
h_eye_line = findobj(gcf, 'Tag', 'eye_scrub_line');

if h_line ~= h_hand_line,
    set(h_hand_line, 'XData', [t t]);
else
    set(h_eye_line, 'XData', [t t]);
end

ud = get(gcf, 'UserData');
vidRdr = ud.video_reader;
vidRdr.CurrentTime = t;
if hasFrame(vidRdr)
    vidFrame = readFrame(vidRdr);
    %image(ud.video_axes, vidFrame);
    image(vidFrame, 'Parent', ud.video_axes);
    ud.video_axes.Visible = 'off';
end
end
