function varargout = hand_eye_gui(varargin)
% HAND_EYE_GUI MATLAB code for hand_eye_gui.fig
%      HAND_EYE_GUI, by itself, creates a new HAND_EYE_GUI or raises the existing
%      singleton*.
%
%      H = HAND_EYE_GUI returns the handle to a new HAND_EYE_GUI or the handle to
%      the existing singleton*.
%
%      HAND_EYE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HAND_EYE_GUI.M with the given input arguments.
%
%      HAND_EYE_GUI('Property','Value',...) creates a new HAND_EYE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hand_eye_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hand_eye_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hand_eye_gui

% Last Modified by GUIDE v2.5 22-Feb-2017 13:02:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
   'gui_Singleton',  gui_Singleton, ...
   'gui_OpeningFcn', @hand_eye_gui_OpeningFcn, ...
   'gui_OutputFcn',  @hand_eye_gui_OutputFcn, ...
   'gui_LayoutFcn',  [] , ...
   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
   [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
   gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before hand_eye_gui is made visible.
function hand_eye_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hand_eye_gui (see VARARGIN)


% read in data filesdisp('Choose eye data *.bin file')
% eye
[fnameSave, pathnameSave] = uigetfile({'*.bin'}, 'Choose eye data *.bin file ...');
if isequal(fnameSave,0) || isequal(pathnameSave,0),
   disp('no  file chosen ... ')
   return
end
handles.bin_filename = fullfile(pathnameSave, fnameSave); %'/Users/peggy/Desktop/pegtas2/pegtas2_1.bin'; % must be full path for rd_cli to work

% [rh,rv,lh,lv,samp_freq] = rd_cli(bin_filename);
handles.eye_data = rd(handles.bin_filename);
samp_freq = handles.eye_data.samp_freq;
t = (1:handles.eye_data.numsamps)/handles.eye_data.samp_freq;

% apdm sensor data - we can handle up to 2 sensors
disp('Choose APDM data *.h5 file')
[fnameSave, pathnameSave] = uigetfile({'*.h5'}, 'Choose APDM data *.h5 file ...');
if isequal(fnameSave,0) || isequal(pathnameSave,0),
   disp('no  file chosen ... ')
   handles.hdf_filename = [];
   handles.apdm_data.sensors=[];
else
   handles.hdf_filename = fullfile(pathnameSave, fnameSave);
   [handles.apdm_data.time, handles.apdm_data.sensors, ...
      handles.apdm_data.accel, handles.apdm_data.annot] = get_hdf_data(handles.hdf_filename);
end

% video
disp('Choose eyelink video overlay *.avi file')
[fnameSave, pathnameSave] = uigetfile({'*.avi'}, 'Choose = *.avi file ...');
if isequal(fnameSave,0) || isequal(pathnameSave,0),
   disp('no  file chosen ... ')
   handles.video_reader = [];
   handles.avi_filename = [];
else
   handles.avi_filename = fullfile(pathnameSave, fnameSave);
   handles.video_reader = VideoReader(handles.avi_filename);
end

% initialize the data in the axes
handles = resizeAxes(handles); % size the axes depending upon how many sensor there are to display

axes(handles.axes_eye)
handles.line_rh = line(t, handles.eye_data.rh.data, 'Tag', 'line_rh', 'Color', 'g');
handles.line_lh = line(t, handles.eye_data.lh.data, 'Tag', 'line_lh', 'Color', 'r');
handles.line_rv = line(t, handles.eye_data.rv.data, 'Tag', 'line_rv', 'Color', 'g', 'LineStyle', '--');
handles.line_lv = line(t, handles.eye_data.lv.data, 'Tag', 'line_lv', 'Color', 'r', 'LineStyle', '--');
ylabel('Gaze Pos (\circ)')


if ~isempty(handles.apdm_data.sensors),
   axes(handles.axes_hand) % 1st axis is called hand no matter what the sensor is
   %drawSensorAccelLines(handles.apdm_data, 1);
   drawSensorCombinedVelocityLine(handles.apdm_data, 1)
   handles.linkprop_list(1) = linkprop([handles.axes_eye, handles.axes_hand ], 'XLim');
end

if length(handles.apdm_data.sensors) > 1,
   axes(handles.axes_head) % 2nd axis is called head no matter what the sensor is
   drawSensorAccelLines(handles.apdm_data, 2);
   
   handles.linkprop_list(end+1) = linkprop([handles.axes_eye, handles.axes_head ], 'XLim');
end

% lines
handles = show_annot_lines(handles);
% disp('adding fixation lines')
% handles = createFixLines(handles);
% disp('done')
% video
show_video_frame(handles, 0)

% video scrub line in the eye & hand data plots
x_scrub_line = 0;
axes(handles.axes_eye)
handles.scrub_line_eye = line( [x_scrub_line, x_scrub_line], handles.axes_eye.YLim, ...
   'Color', 'b', 'linewidth', 2, 'Tag', 'scrub_line_eye');
draggable(handles.scrub_line_eye,'h', @scrubLineMotionFcn)

% for sens_num = 1:length(sens_num)
if ~isempty(handles.apdm_data.sensors),
   axes(handles.axes_hand)
   handles.scrub_line_hand = line( [x_scrub_line, x_scrub_line], handles.axes_hand.YLim, ...
      'Color', 'b', 'linewidth', 2, 'Tag', 'scrub_line_hand');
   draggable(handles.scrub_line_hand,'h', @scrubLineMotionFcn)
   handles.linkprop_list(end+1) = linkprop([handles.scrub_line_hand, handles.scrub_line_eye], 'XData');
end

% uicontextmenu to axes
c = uicontextmenu;
handles.axes_eye.UIContextMenu = c;
m1 = uimenu(c, 'Label', 'Exclude Data', 'Callback', @createExclusionBox);
uimenu(c, 'Label', 'Add Reach Begin', 'Callback', {@addLine, 'annotation_reach_begin'})
uimenu(c, 'Label', 'Add Reach End', 'Callback', {@addLine, 'annotation_reach_end'})
uimenu(c, 'Label', 'Add Grasp', 'Callback', {@addLine, 'annotation_grasp'})
uimenu(c, 'Label', 'Add Transfer', 'Callback', {@addLine, 'annotation_transfer'})
uimenu(c, 'Label', 'Add Mistake', 'Callback', {@addLine, 'annotation_mistake'})

% Choose default command line output for hand_eye_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
return

% --- Outputs from this function are returned to the command line.
function varargout = hand_eye_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
return

% -------------------------------------------------------------
function drawSensorAccelLines(apdm_data, sensor_num)
sensor = apdm_data.sensors{sensor_num};
accel = filterData(apdm_data, sensor_num);

line(apdm_data.time, accel(:,1), 'Tag', ['line_' sensor '_acc_x']);
line(apdm_data.time, accel(:,2), 'Tag', ['line_' sensor '_acc_y'], 'Color', [0.8 0.1 0]);
line(apdm_data.time, accel(:,3), 'Tag', ['line_' sensor '_acc_z'], 'Color', [0.1 0.8 0.2]);
ylabel([sensor ' sensor'])
return

% -------------------------------------------------------------
function drawSensorCombinedVelocityLine(apdm_data, sensor_num)
sensor = apdm_data.sensors{sensor_num};
accel = filterData(apdm_data, sensor_num);

interval = mean(diff(apdm_data.time));
vel = cumtrapz(accel)*interval;

line(apdm_data.time, vel(:,1), 'Tag', ['line_' sensor '_vel_x']);
line(apdm_data.time, vel(:,2), 'Tag', ['line_' sensor '_vel_y'], 'Color', [0.8 0.1 0]);
line(apdm_data.time, vel(:,3), 'Tag', ['line_' sensor '_vel_z'], 'Color', [0.1 0.8 0.2]);

ylabel([sensor ' sensor'])
return

% -------------------------------------------------------------
function filt_data = filterData(apdm_data, sensor_num)
samp_freq = 1/mean(diff(apdm_data.time));
nyqf = samp_freq/2;
ord = 4;
cutoff = 1;
[b,a] = butter(ord, cutoff/nyqf);
filt_data = filtfilt(b, a, apdm_data.accel{sensor_num}');
return
% -------------------------------------------------------------
function handles = resizeAxes(handles)

switch length(handles.apdm_data.sensors),
   case 0,
      handles.axes_eye.Position = [0.067 0.24 0.41 0.628];
      handles.axes_eye.XLabel.String = 'Time (sec)';
      handles.axes_hand.Visible = 'Off';
      handles.axes_head.Visible = 'Off';
   case 1,
      handles.axes_eye.Position = [0.067 0.539 0.41 0.329];
      handles.axes_eye.XTickLabel = {};
      handles.axes_hand.Position = [0.067 0.252 0.41 0.261];
      handles.axes_hand.XLabel.String = 'Time (sec)';
      handles.axes_head.Visible = 'Off';
   case 2,
      handles.axes_eye.Position = [0.067 0.641 0.41 0.227];
      handles.axes_eye.XTickLabel = {};
      handles.axes_hand.Position = [0.067 0.439 0.41 0.187];
      handles.axes_hand.XTickLabel = {};
      handles.axes_head.Position = [0.067 0.239 0.41 0.187];
      handles.axes_head.XLabel.String = 'Time (sec)';
   otherwise,
      error('more than 3 sensors of data')
end
return

% -------------------------------------------------------------
function createExclusionBox(source,callbackdata)
handles = guidata(gcf);
axes(handles.axes_eye)
cursor_loc = get(handles.axes_eye, 'CurrentPoint');
cursor_x = cursor_loc(1);
ylims = get(handles.axes_eye, 'YLim');

if isfield(handles, 'noUseDataPatches'),
   patch_cnt = length(handles.noUseDataPatches) + 1;
else
   patch_cnt = 1;
end

handles.noUseDataPatches(patch_cnt).patch = patch([cursor_x cursor_x cursor_x+5 cursor_x+5], ...
   [ylims(1) ylims(2) ylims(2) ylims(1)], [0.5 0.5 0.5]);
set(handles.noUseDataPatches(patch_cnt).patch, 'FaceAlpha', 0.5, ...
   'LineStyle', 'none')
createPatchMenu(handles.noUseDataPatches(patch_cnt).patch);
uistack(handles.noUseDataPatches(patch_cnt).patch, 'bottom')

% left side of patch
handles.noUseDataPatches(patch_cnt).left_line = line([cursor_x cursor_x], ...
   [ylims(1) ylims(2)], 'Color', 'k');
handles.noUseDataPatches(patch_cnt).left_line.UserData = handles.noUseDataPatches(patch_cnt).patch;

%right side of patch
handles.noUseDataPatches(patch_cnt).right_line = line([cursor_x+5 cursor_x+5], ...
   [ylims(1) ylims(2)], 'Color', 'k');
handles.noUseDataPatches(patch_cnt).right_line.UserData = handles.noUseDataPatches(patch_cnt).patch;

% save lines in patch userdata & make whole patch draggable
handles.noUseDataPatches(patch_cnt).patch.UserData.h_r_line = handles.noUseDataPatches(patch_cnt).right_line;
handles.noUseDataPatches(patch_cnt).patch.UserData.h_l_line = handles.noUseDataPatches(patch_cnt).left_line;

% matching patch in other axis
if ~isempty(handles.apdm_data.sensors),
   axes(handles.axes_hand)
   ylims = get(handles.axes_hand, 'YLim');
   h_patch = patch([cursor_x cursor_x cursor_x+5 cursor_x+5], ...
      [ylims(1) ylims(2) ylims(2) ylims(1)], [0.5 0.5 0.5]);
   set(h_patch, 'FaceAlpha', 0.5)
   uistack(h_patch, 'bottom')
   handles.linkprop_list(end+1) = linkprop([handles.noUseDataPatches(patch_cnt).patch, h_patch], 'XData');
end

% Update handles structure
guidata(gcf, handles);
return

% -------------------------------------------------------------
function addLine(source, callbackdata, line_type)
% function called by menu to add a new line line_type is a string with the
% type (reach, grasp, transfer, mistake)
handles = guidata(gcf);
axes(handles.axes_eye)
cursor_loc = get(handles.axes_eye, 'CurrentPoint');
cursor_x = cursor_loc(1);

handles = addAxesLine(handles, cursor_x, line_type, 'on');

guidata(gcf, handles);

return

% -------------------------------------------------------------
function handles = show_annot_lines(handles)
if isfield(handles,'apdm_data')
   annot = handles.apdm_data.annot;
   
   for annot_num = 1:length(handles.apdm_data.annot),
      line_type = ['annotation_' annot{annot_num}.msg];
      
      handles = addAxesLine(handles, annot{annot_num}.time, line_type, 'on');
      
   end
end
return

% ----------------------------
function handles = addAxesLine(handles, time, line_type, vis_on_off)
line_color = getLineColor(handles, line_type);

axes(handles.axes_eye)
ylims = get(handles.axes_eye, 'YLim');

h_eye = line([time, time], ylims, 'Color', line_color, 'Tag', line_type, 'Visible', vis_on_off);
uistack(h_eye, 'bottom')

[hcmenu, ud] = createLineMenu(h_eye);
ud.line_type = line_type;
ud.h_all_lines = h_eye;

if ~isempty(handles.apdm_data.sensors),
   axes(handles.axes_hand)
   ylims = get(handles.axes_hand, 'YLim');
   h_hand = line([time, time], ylims, 'Color', line_color, 'Tag', line_type, 'Visible', vis_on_off);
   uistack(h_hand, 'bottom')
   ud.h_all_lines(end+1) = h_hand;
end
if length(handles.apdm_data.sensors) > 1,
   axes(handles.axes_head)
   ylims = get(handles.axes_head, 'YLim');
   h_head = line([time, time], ylims, 'Color', line_color, 'Tag',  line_type, 'Visible', vis_on_off);
   uistack(h_head, 'bottom')
   ud.h_all_lines(end+1) = h_head;
end

set(h_eye, 'UIContextMenu', hcmenu, 'UserData', ud);
if ~isempty(handles.apdm_data.sensors),
   set(h_hand, 'UIContextMenu', hcmenu, 'UserData', ud);
end
if length(handles.apdm_data.sensors) > 1,
   set(h_head, 'UIContextMenu', hcmenu, 'UserData', ud);
end

handles.linkprop_list(end+1) = linkprop (ud.h_all_lines, ...
   {'XData', 'UIContextMenu', 'UserData'} );

return

%--------------------------------------
function line_color = getLineColor(handles, type)
line_color = 'y';
h_txt = findobj(handles.figure1, 'Tag', ['txt_' type]);
if ~isempty(h_txt)
   line_color = h_txt.ForegroundColor;
end
return

% ----------------------------
function createLineColorMenu(hLine)
hcmenu = uicontextmenu;
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Blue', 'Tag', 'menuBlue', 'Callback', {@menuLineColor_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Green', 'Tag', 'menuGreen', 'Callback', {@menuLineColor_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Red', 'Tag', 'menuRed', 'Callback', {@menuLineColor_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Cyan', 'Tag', 'menuCyan', 'Callback', {@menuLineColor_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Magenta', 'Tag', 'menuMagenta', 'Callback', {@menuLineColor_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Orange', 'Tag', 'menuOrange', 'Callback', {@menuLineColor_Callback, hLine});
set(hLine, 'UIContextMenu', hcmenu, 'UserData', ud);


function menuLineColor_Callback(source, callbackdata, hLine)
switch source.Tag
   case 'menuBlue'
      hLine.Color = [0 0 0.8];
   case 'menuGreen'
      hLine.Color = [0 0.5 0];
   case 'menuRed'
      hLine.Color = [0.5 0 0];
   case 'menuCyan'
      hLine.Color = [114 214 247]/255;
   case 'menuMagenta'
      hLine.Color = [247 114 238]/255;
   case 'menuOrange'
      hLine.Color = [247 175 114]/255;
end



% -------------------------------------------------------------
function [hcmenu, ud] = createLineMenu(h_line)
hcmenu = uicontextmenu;
ud.hMenuLock = uimenu(hcmenu, 'Label', 'Locked', 'Tag', 'menuLock', 'Callback', {@menuLine_Callback, h_line}, 'Checked', 'on');
ud.hMenuDeleteLine = uimenu(hcmenu, 'Label', 'Delete', 'Tag', 'menuDelete', 'Callback', {@menuLine_Callback, h_line});

% set(h_line, 'UIContextMenu', hcmenu, 'UserData', ud);
return

function menuLine_Callback(source, callbackdata, h_line)
switch source.Tag
   case 'menuLock'
      if strcmp(source.Checked, 'on'),
         source.Checked = 'off';
         for ind = 1:length(h_line.UserData.h_all_lines),
            draggable(h_line.UserData.h_all_lines(ind),'h');
         end
      else
         source.Checked = 'on';
         for ind = 1:length(h_line.UserData.h_all_lines),
            draggable(h_line.UserData.h_all_lines(ind),'off');
         end
      end
   case 'menuDelete'
      h_all_lines = findobj('XData', h_line.XData);
      delete(h_all_lines)
end
return


% -------------------------------------------------------------
function createPatchMenu(h_patch)
hcmenu = uicontextmenu;
ud.hMenuLock = uimenu(hcmenu, 'Label', 'Locked', 'Tag', 'menuLock', ...
   'Callback', {@menuLockPatch_Callback, h_patch}, 'Checked', 'on');
set(h_patch, 'UIContextMenu', hcmenu, 'UserData', ud);

function menuLockPatch_Callback(source, callbackdata, h_patch)
switch source.Tag
   case 'menuLock'
      if strcmp(source.Checked, 'on'),
         source.Checked = 'off';
         draggable( h_patch, 'h', @patchMotionFcn)
         draggable(h_patch.UserData.h_l_line,'h', @leftPatchMotionFcn)
         draggable(h_patch.UserData.h_r_line,'h', @rightPatchMotionFcn)
      else
         source.Checked = 'on';
         
         draggable( h_patch, 'off', @patchMotionFcn)
         draggable(h_patch.UserData.h_l_line,'off', @leftPatchMotionFcn)
         draggable(h_patch.UserData.h_r_line,'off', @rightPatchMotionFcn)
         
      end
end


% -------------------------------------------------------------
function show_video_frame(handles, time)
% axes(handles.axes.video)

v = handles.video_reader;
v.CurrentTime = time;

if hasFrame(v)
   vidFrame = readFrame(v);
   % readFrame increments the time after reading the frame, code here
   % assumes it does not
   v.CurrentTime = time;
   %image(currAxes, vidFrame);
   image(vidFrame, 'Parent', handles.axes_video);
   handles.axes_video.Visible = 'off';
end
return

function moveVideoFrame(handles, frames)
v = handles.video_reader;
new_time = v.CurrentTime + frames/v.FrameRate;

if new_time < 0, new_time = 0; end
if new_time > v.Duration, new_time = v.Duration; end
if new_time >=0 && new_time <= v.Duration,
   show_video_frame(handles, new_time);
   
   updateScrubLine(handles, new_time)
   updateEdTime(handles, new_time)
end
return

function updateScrubLine(handles, time)
handles.scrub_line_eye.XData = [time, time];
if isfield(handles, 'scrub_line_hand'),
   handles.scrub_line_hand.XData = [time, time];
end
if isfield(handles, 'scrub_line_head'),
   handles.scrub_line_head.XData = [time, time];
end
return

% ---------------------------------------------------------------
function scrubLineMotionFcn(h_line)
xdata = get(h_line, 'XData');
t = xdata(1);

h = guidata(gcf);
if t < min(h.line_rh.XData),
   t = min(h.line_rh.XData);
end
if t > max(h.line_rh.XData),
   t = max(h.line_rh.XData);
end


show_video_frame(h, t)
updateEdTime(h, t)
return


% ---------------------------------------------------------------
function leftPatchMotionFcn(h_line)
h_patch = h_line.UserData;
% limit left line to be less than right edge of patch
if h_line.XData(1) >= h_patch.XData(3);
   h_line.XData(1) = h_patch.XData(3);
   h_line.XData(2) = h_patch.XData(3);
end
h_patch.XData(1) = h_line.XData(1);
h_patch.XData(2) = h_line.XData(1);

% ---------------------------------------------------------------
function rightPatchMotionFcn(h_line)
h_patch = h_line.UserData;
% limit right line to be greater than left edge of patch
if h_line.XData(1) <= h_patch.XData(1);
   h_line.XData(1) = h_patch.XData(1);
   h_line.XData(2) = h_patch.XData(1);
end
h_patch.XData(3) = h_line.XData(1);
h_patch.XData(4) = h_line.XData(1);

% ---------------------------------------------------------------
function patchMotionFcn(h_patch)
h_patch.UserData.h_r_line.XData = h_patch.XData(3:4);
h_patch.UserData.h_l_line.XData = h_patch.XData(1:2);


% --- Executes on button press in pb_export.
function pb_export_Callback(hObject, eventdata, handles)
% hObject    handle to pb_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get file name to save
disp('Choose file name to save exported data')
[fnameSave, pathnameSave] = uiputfile({'*.txt'}, 'Choose export data *.txt file ...');
if isequal(fnameSave,0) || isequal(pathnameSave,0),
   disp('no  file chosen ... ')
   return
end
export_filename = fullfile(pathnameSave, fnameSave);
% format data

% eye data
t_eye = handles.line_rh.XData;
rh = handles.line_rh.YData;
lh = handles.line_lh.YData;
rv = handles.line_rv.YData;
lv = handles.line_lv.YData;

out_tbl = table(t_eye', rh', lh', rv', lv');
out_tbl.Properties.VariableNames = {'t_eye', 'rh', 'lh', 'rv', 'lv'};

% sensors
if ~isempty(handles.apdm_data.sensors),
   t_sensor = handles.apdm_data.time;
   
   for sens_num = 1:length(handles.apdm_data.sensors),
      sensor = handles.apdm_data.sensors{sens_num};
      accel_x = handles.apdm_data.accel{sens_num}(1,:);
      accel_y = handles.apdm_data.accel{sens_num}(2,:);
      accel_z = handles.apdm_data.accel{sens_num}(3,:);
      [resamp_accel_x, resamp_t] = resample(accel_x, t_sensor, handles.eye_data.samp_freq);
      [resamp_accel_y, resamp_t] = resample(accel_y, t_sensor, handles.eye_data.samp_freq);
      [resamp_accel_z, resamp_t] = resample(accel_z, t_sensor, handles.eye_data.samp_freq);
      
      ind_end = length(resamp_t);
      t_diff = resamp_t(end) - t_eye(end);
      if t_diff > eps,
         disp(['apdm sensor time vector is longer than eye data time vector'])
         disp([num2str(t_diff) 's of apdm sensor time will be discarded from the end of the record'])
         ind_end = length(t_eye);
      end
      out_tbl.(['t_sensors']) = resamp_t(1:ind_end);
      out_tbl.([sensor '_accel_x']) = resamp_accel_x(1:ind_end)';
      out_tbl.([sensor '_accel_y']) = resamp_accel_y(1:ind_end)';
      out_tbl.([sensor '_accel_z']) = resamp_accel_z(1:ind_end)';
   end
end

h_stop_evt_line = findobj('Tag', 'Receivedexternaltriggerstopevent');

% marks/annotations
out_tbl.annotation = cell(height(out_tbl),1);
line_list = findobj('-regexp', 'Tag', 'annotation_.*');
xdata = cell2mat(get(line_list, 'XData'));
% mark_list = {'reach', 'mistake'};
%for l_num = 1:length(line_list),
% 	h_lines = findobj('Tag', mark_list{mark_num});
%	xdata = cell2mat(get(h_lines, 'XData'));
for row_cnt = 1:size(xdata,1),
   ind = find(out_tbl.t_sensors >= xdata(row_cnt), 1, 'first');
   % 		out_tbl.annotation(ind) = mark_list(mark_num);
   out_tbl.annotation(ind) = {strrep(line_list(row_cnt).Tag, 'annotation_', '')};
end
%end

% remove excluded data
if isfield(handles, 'noUseDataPatches'),
   for seg_num = 1:length(handles.noUseDataPatches),
      % begin exclusion
      excl_beg = handles.noUseDataPatches(seg_num).left_line.XData;
      % end exclusion
      excl_end = handles.noUseDataPatches(seg_num).right_line.XData;
      
      ind_excl_beg = find(out_tbl.t_eye >= excl_beg(1), 1, 'first');
      if isempty(ind_excl_beg),
         ind_excl_beg = 1;
      end
      ind_excl_end = find(out_tbl.t_eye >= excl_end(1), 1, 'first');
      if isempty(ind_excl_end),
         ind_excl_end = height(out_tbl);
      end
      % add an annotation
      out_tbl.annotation(ind_excl_beg) = {'begin excluding data'};
      out_tbl.annotation(ind_excl_end) = {'end excluding data'};
      
      out_tbl = out_tbl([1:ind_excl_beg, ind_excl_end:height(out_tbl)], :);
   end
end
% write data
writetable(out_tbl, export_filename, 'delimiter', '\t');
return

% --------------------------
function updateEdTime(h, time)
time_str = sprintf('%0.3f', time);
set(h.edTime, 'String', time_str);
return

% -------------------------------
function showFixations(h, r_or_l)
tag_search_str = ['^fixation_' r_or_l '.*'];
line_list = findobj(h.figure1,'-regexp', 'Tag', tag_search_str);
if isempty(line_list),
   createFixLines(h, r_or_l);
else
   set(line_list, 'Visible', 'on');
end
txt_beg_str = ['txt_fixation_' r_or_l '_begin'];
h.(txt_beg_str).Visible = 'on';
txt_end_str = ['txt_fixation_' r_or_l '_end'];
h.(txt_end_str).Visible = 'on';
return

function hideFixations(h, r_or_l)
tag_search_str = ['fixation_' r_or_l '.*'];
line_list = findobj(h.figure1,'-regexp', 'Tag', tag_search_str);
if ~isempty(line_list),
   set(line_list, 'Visible', 'off');
end
return

function h = createFixLines(h, r_or_l)
axes(h.axes_eye)
ylims = h.axes_eye.YLim;
start_ms = h.eye_data.start_times;
samp_freq = h.eye_data.samp_freq;
line_color_beg = getLineColor(h, ['fixation_' r_or_l '_begin']);
line_color_end = getLineColor(h, ['fixation_' r_or_l '_end']);

eye_str = 'rh';
if strncmp(r_or_l, 'l', 1),
   eye_str = 'lh';
end
for fix_num = 1:length(h.eye_data.(eye_str).fixation.fixlist.start)
   time1 = (h.eye_data.(eye_str).fixation.fixlist.start(fix_num) - start_ms)/1000;
   %line([time1 time1], ylims, 'Tag', ['fixation_' r_or_l '_begin'], 'Color', line_color_beg);
   time2 = (h.eye_data.(eye_str).fixation.fixlist.end(fix_num) - start_ms)/1000;
   %line([time2 time2], ylims, 'Tag', ['fixation_' r_or_l '_end'], 'Color', line_color_end);
   
   fix_start_ind = round(time1*samp_freq);
   fix_stop_ind  = round(time2*samp_freq);
   tempdata = h.eye_data.(eye_str).data;
   segment = tempdata(fix_start_ind:fix_stop_ind);
   time3 = maket(segment)+time1;
   line(time3, segment,'Tag', ['fixation_' r_or_l '_#' num2str(fix_num)], 'Color','b' , ...
      'Linewidth', 1.5)
   
   
end
return

% -------------------------------
function showSaccades(h, r_or_l)
tag_search_str = ['^saccade_' r_or_l '.*'];
line_list = findobj(h.figure1,'-regexp', 'Tag', tag_search_str);
if isempty(line_list),
   createSaccLines(h, r_or_l);
else
   set(line_list, 'Visible', 'on');
   
end
txt_beg_str = ['txt_saccade_' r_or_l '_begin'];
h.(txt_beg_str).Visible = 'on';
txt_end_str = ['txt_saccade_' r_or_l '_end'];
h.(txt_end_str).Visible = 'on';
return

function hideSaccades(h, r_or_l)
tag_search_str = ['saccade_' r_or_l '.*'];
line_list = findobj(h.figure1,'-regexp', 'Tag', tag_search_str);
if ~isempty(line_list),
   set(line_list, 'Visible', 'off');
end
return

function createSaccLines(h, r_or_l)
axes(h.axes_eye)
ylims = h.axes_eye.YLim;
start_ms = h.eye_data.start_times;
beg_line_color = getLineColor(h, ['saccade_' r_or_l '_begin']);
end_line_color = getLineColor(h, ['saccade_' r_or_l '_end']);
samp_freq = h.eye_data.samp_freq;

eye_str = 'rh';
if strncmp(r_or_l, 'l', 1),
   eye_str = 'lh';
end
for sacc_num = 1:length(h.eye_data.(eye_str).saccades.sacclist.start)
   time1 = (h.eye_data.(eye_str).saccades.sacclist.start(sacc_num) - start_ms)/1000; %in seconds
   %y = h.eye_data.(eye_str).saccades.sacclist.startpos(sacc_num);
   y = h.eye_data.(eye_str).data(round(time1*samp_freq));
   line( time1, y, 'Tag', ['saccade_' r_or_l '_begin'], 'Color', beg_line_color, ...
      'Marker', 'o', 'MarkerSize', 10);
   %line([x x], ylims, 'Tag', ['saccade_' r_or_l '_begin'], 'Color', beg_line_color);
   time2 = (h.eye_data.(eye_str).saccades.sacclist.end(sacc_num) - start_ms)/1000;
   %y = h.eye_data.(eye_str).saccades.sacclist.endpos(sacc_num);
   y = h.eye_data.(eye_str).data(round(time2*samp_freq));
   line( time2, y, 'Tag', ['saccade_' r_or_l '_begin'], 'Color', end_line_color, ...
      'Marker', 'o', 'MarkerSize', 10);
   %line([x x], ylims, 'Tag', ['saccade_' r_or_l '_end'], 'Color', end_line_color);
   
   sac_start_ind = round(time1*samp_freq);
   sac_stop_ind  = round(time2*samp_freq);
   tempdata = h.eye_data.(eye_str).data;
   segment = tempdata(sac_start_ind:sac_stop_ind);
   time3 = maket(segment)+time1;
   line(time3, segment,'Tag', ['saccade_' r_or_l '_#' num2str(sacc_num)], 'Color','b' , ...
      'Linewidth', 1.5)
   
   
end
return

% -------------------------------
function showAnnotations(h)
line_list = findobj(h.figure1,'-regexp', 'Tag', 'annotation_.*');
if ~isempty(line_list),
   set(line_list, 'Visible', 'on');
end
return

function hideAnnotations(h)
line_list = findobj(h.figure1,'-regexp', 'Tag', 'annotation_.*');
if ~isempty(line_list),
   set(line_list, 'Visible', 'off');
end
return

% --- Executes on button press in pbBack.
function pbBack_Callback(hObject, eventdata, handles)
% hObject    handle to pbBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
moveVideoFrame(handles, -1);
return

% --- Executes on button press in pbForward.
function pbForward_Callback(hObject, eventdata, handles)
% hObject    handle to pbForward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
moveVideoFrame(handles, 1);
return



function edTime_Callback(hObject, eventdata, handles)
% hObject    handle to edTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edTime as text
time = str2double(get(hObject,'String')); % returns contents of edTime as a double
updateEdTime(handles, time);
updateScrubLine(handles, time);
show_video_frame(handles, time);

% --- Executes during object creation, after setting all properties.
function edTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbFixationsRight.
function tbFixationsRight_Callback(hObject, eventdata, handles)
% hObject    handle to tbFixationsRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value'), % returns toggle state of tbFixations
   showFixations(handles, 'right');
else
   hideFixations(handles, 'right');
end
return

% --- Executes on button press in tbFixationsLeft.
function tbFixationsLeft_Callback(hObject, eventdata, handles)
% hObject    handle to tbFixationsLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbFixationsLeft
if get(hObject,'Value'), % returns toggle state of tbFixations
   showFixations(handles, 'left');
else
   hideFixations(handles, 'left');
end
return

% --- Executes on button press in tbSaccadesRight.
function tbSaccadesRight_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value'), % returns toggle state of tbFixations
   showSaccades(handles, 'right');
else
   hideSaccades(handles, 'right');
end
return

% --- Executes on button press in tbSaccadesLeft.
function tbSaccadesLeft_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value'), % returns toggle state of tbFixations
   showSaccades(handles, 'left');
else
   hideSaccades(handles, 'left');
end
return

% --- Executes on button press in tbAnnotations.
function tbAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to tbAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value'), % returns toggle state of tbFixations
   showAnnotations(handles);
   hObject.String = 'Hide Annotations';
else
   hideAnnotations(handles);
   hObject.String = 'Show Annotations';
end
return
