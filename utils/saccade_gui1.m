function varargout = saccade_gui(varargin)
% SACCADE_GUI MATLAB code for saccade_gui.fig
%      SACCADE_GUI, by itself, creates a new SACCADE_GUI or raises the existing
%      singleton*.
%
%      H = SACCADE_GUI returns the handle to a new SACCADE_GUI or the handle to
%      the existing singleton*.
%
%      SACCADE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SACCADE_GUI.M with the given input arguments.
%
%      SACCADE_GUI('Property','Value',...) creates a new SACCADE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before saccade_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to saccade_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help saccade_gui

% Last Modified by GUIDE v2.5 21-Feb-2018 16:15:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
   'gui_Singleton',  gui_Singleton, ...
   'gui_OpeningFcn', @saccade_gui_OpeningFcn, ...
   'gui_OutputFcn',  @saccade_gui_OutputFcn, ...
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


% --- Executes just before saccade_gui is made visible.
function saccade_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to saccade_gui (see VARARGIN)

% Choose default command line output for saccade_gui
handles.output = hObject;

% read in data filesdisp('Choose eye data *.bin file')
% eye
[fnSave, pnSave] = uigetfile({'*.bin'}, 'Choose eye data *.bin file ...');
if isequal(fnSave,0) || isequal(pnSave,0)
   disp('no  file chosen ... ')
   return
end

handles.bin_filename = fullfile(pnSave, fnSave); %'/Users/peggy/Desktop/pegtas2/pegtas2_1.bin'; % must be full path for rd_cli to work
handles.eye_data = rd(handles.bin_filename);

handles.txtFileName.String = handles.bin_filename;

samp_freq = handles.eye_data.samp_freq;
numsamps = handles.eye_data.numsamps;
t = (1:numsamps)/samp_freq;

% initialize the data in the axes
axes(handles.axes_eye)
handles.line_rh = line(t, handles.eye_data.rh.pos, 'Tag', 'line_rh', 'Color', 'g');
handles.line_lh = line(t, handles.eye_data.lh.pos, 'Tag', 'line_lh', 'Color', 'r');
handles.line_rv = line(t, handles.eye_data.rv.pos, 'Tag', 'line_rv', 'Color', 'g', 'LineStyle', '--');
handles.line_lv = line(t, handles.eye_data.lv.pos, 'Tag', 'line_lv', 'Color', 'r', 'LineStyle', '--');
ylabel('Gaze Pos (\circ)')
xlabel('Time (s)')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes saccade_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = saccade_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -------------------------------
function showSaccades(h, r_or_l, h_or_v, sacc_source)
eye_str = [r_or_l(1) h_or_v(1)];
tag_search_str = ['^saccade_' eye_str '_' sacc_source '.*'];
line_list = findobj(h.figure1,'-regexp', 'Tag', tag_search_str);
if isempty(line_list)
   createSaccLines(h, r_or_l, h_or_v, sacc_source);
else
   set(line_list, 'Visible', 'on');
   
end

return

function hideSaccades(h, r_or_l, h_or_v, sacc_source)
eye_str = [r_or_l(1) h_or_v(1)];
tag_search_str = ['saccade_' eye_str '_' sacc_source '.*'];
line_list = findobj(h.figure1,'-regexp', 'Tag', tag_search_str);
if ~isempty(line_list)
   set(line_list, 'Visible', 'off');
end
return

function createSaccLines(h, r_or_l, h_or_v, sacc_source)
axes(h.axes_eye)
eye_str = [r_or_l(1) h_or_v(1)];

beg_line_color = getLineColor(h, ['saccade_' eye_str '_' sacc_source '_begin']);
end_line_color = getLineColor(h, ['saccade_' eye_str '_' sacc_source '_end']);
samp_freq = h.eye_data.samp_freq;

switch sacc_source
   case 'eyelink'
      start_ms = h.eye_data.start_times;
      sacclist = h.eye_data.(eye_str).saccades.sacclist; % eyelink data
      sacc_marker = 'o';
   case 'findsacc'
      % get parameter values
      acc_on = str2double(h.edAccelThresh.String);
      acc_off = str2double(h.edAccelStop.String);
      vel_on = str2double(h.edVelThresh.String);
      vel_off = str2double(h.edVelStop.String);
      gap_fp = str2double(h.edGapFP.String);
      gap_sp = str2double(h.edGapSP.String);
      vel_or_acc = h.popmenuAccelVel.Value; % 1=Accel, 2=Vel, 3=Both
      extend = str2double(h.edExtend.String);
      %dataName = 'unknown';
      %strict_strip = 1;
      foundsaccs = findsaccs(h.eye_data.(eye_str).pos, acc_on, vel_on, acc_off, ...
         vel_off, gap_fp, gap_sp, vel_or_acc, extend); % dataName, strict_strip);
      if foundsaccs.num == 0
         keyboard
      else
         sacclist.start = foundsaccs.start;
         sacclist.end  = foundsaccs.stop;
      end
      %saccstart = evalin('base','saccstart');
      %saccstop = evalin('base','saccstop');      
      
      start_ms = 1/samp_freq;
      % convert index values to time in ms
      sacclist.start = ( (sacclist.start/samp_freq)*1000 );
      sacclist.end  = ( (sacclist.end/samp_freq)*1000 );
      
      % h.findsacc_data.(eye_str).start_time = start_ms;
      h.findsacc_data.(eye_str).start = sacclist.start + h.eye_data.start_times;
      h.findsacc_data.(eye_str).end  = sacclist.end + h.eye_data.start_times;
      % save new figure handles
      guidata(h.figure1, h)
      
      sacc_marker = 's';
      
   case 'engbert'
      % get parameters
      vel_factor = str2double(h.edVelFactor.String);
      min_num_samples = str2double(h.edMinSamples.String);
      
      h_str = strrep(eye_str, 'v', 'h');
      v_str = strrep(eye_str, 'h', 'v');
      % eye data converted to angular minutes of arc (from degrees)
      x = [h.eye_data.(h_str).pos h.eye_data.(v_str).pos] * 60;
      
      % velocity using function from Asef
      v = vecvel(x, samp_freq, 2);
      
      % compute saccades using function from Engbert
      sac = microsacc(x, v, vel_factor, min_num_samples);
      %   sac(1:num,1)   onset of saccade
      %   sac(1:num,2)   end of saccade
      %   sac(1:num,3)   peak velocity of saccade
      %   sac(1:num,4)   saccade amplitude
      %   sac(1:num,5)   angular orientation
      %   sac(1:num,6)   horizontal component (delta x)
      %   sac(1:num,7)   vertical component (delta y)
      
      % save saccades in handles
      start_ms = 1/samp_freq;
      sacclist.start = sac(:,1)' / samp_freq * 1000; % time in ms
      sacclist.end = sac(:,2)' / samp_freq * 1000;
      
      % impose minimum intersaccade interval
      isi = str2double(h.edInterSaccInterval.String);
      if length(sacclist.start) > 1 && isi > 0
         % if intersacc interval < isi, delete the 2nd saccade
         sacc_intervals = sacclist.start(2:end)-sacclist.end(1:end-1);
         inds = find(sacc_intervals<isi);
         sacclist.start(inds+1) = [];
         sacclist.end(inds+1) = [];
      end
      
      % 		h.engbertsacc_data.(eye_str).start_time = start_ms;
      h.engbertsacc_data.(eye_str).start = sacclist.start + h.eye_data.start_times;
      h.engbertsacc_data.(eye_str).end = sacclist.end + h.eye_data.start_times;
      % save new figure handles
      guidata(h.figure1, h)
      
      sacc_marker = 'd';
end

for sacc_num = 1:length(sacclist.start)
   % saccade begin
   time1 = (sacclist.start(sacc_num)-start_ms)/1000; %in seconds
   if isnan(time1)
      continue
   end
   y = h.eye_data.(eye_str).pos(round(time1*samp_freq));
   h_beg_line = line( time1, y, 'Tag', ['saccade_' eye_str '_' sacc_source '_#' num2str(sacc_num) '_begin'], ...
      'Color', beg_line_color, 'Marker', sacc_marker, 'MarkerSize', 10);
   eye_m = uicontextmenu;
   h_beg_line.UIContextMenu = eye_m;
   uimenu(eye_m, 'Label', 'Disable Saccade', 'Callback', @disableSaccade, ...
      'Tag', ['menu_saccade_' eye_str '_' sacc_source '_#' num2str(sacc_num) '_begin']);
   
   % saccade end
   time2 = (sacclist.end(sacc_num) - start_ms)/1000;
   if isnan(time2)
      continue
   end
   y = h.eye_data.(eye_str).pos(round(time2*samp_freq));
   line( time2, y, 'Tag', ['saccade_' eye_str '_' sacc_source '_#' num2str(sacc_num) '_end'], ...
      'Color', end_line_color, 'Marker', sacc_marker, 'MarkerSize', 10);
   % saccade segment
   sac_start_ind = round(time1*samp_freq);
   sac_stop_ind  = round(time2*samp_freq);
   if sac_stop_ind-sac_start_ind > 2	% if start and stop are consecutive time points, then there is no segment
      tempdata = h.eye_data.(eye_str).pos;
      segment = tempdata(sac_start_ind:sac_stop_ind);
      time3 = maket(segment)+time1 - 1/samp_freq;
      line(time3, segment,'Tag', ['saccade_' eye_str '_' sacc_source '_#' num2str(sacc_num) ], 'Color','b' , ...
         'Linewidth', 1.5)
   end
end
%end %function

%--------------------------------------
function line_color = getLineColor(handles, type)
line_color = 'y';
h_txt = findobj(handles.figure1, 'Tag', ['txt_' type]);
if ~isempty(h_txt)
   line_color = h_txt.ForegroundColor;
else
   beg_or_end = regexp(type, '(begin)|(end)|(bp)$', 'match');
   if ~isempty(beg_or_end)
      switch beg_or_end{:},
         case 'begin',
            line_color = 'g';
         case 'end'
            line_color = 'r';
         case 'bp'
            line_color = 'c';
      end
   end
end
return

% --- Executes on button press in tbSaccadesRightHoriz.
function tbSaccadesRightHoriz_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesRightHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') % returns toggle state of tbSaccades
   showSaccades(handles, 'right','horizontal', 'eyelink');
   hObject.UserData = 'eyelink';
else
   hideSaccades(handles, 'right','horizontal', 'eyelink');
end
return

% --- Executes on button press in tbSaccadesRightVert.
function tbSaccadesRightVert_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesRightHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') % returns toggle state of tbFixations
   showSaccades(handles, 'right','vertical', 'eyelink');
   hObject.UserData = 'eyelink';
else
   hideSaccades(handles, 'right','vertical', 'eyelink');
end
return


% --- Executes on button press in tbSaccadesLeftHoriz.
function tbSaccadesLeftHoriz_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesLeftHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') % returns toggle state of tbFixations
   showSaccades(handles, 'left', 'horizontal', 'eyelink');
   hObject.UserData = 'eyelink';
else
   hideSaccades(handles, 'left', 'horizontal', 'eyelink');
end
return

% --- Executes on button press in tbSaccadesLeftHoriz.
function tbSaccadesLeftVert_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesLeftHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') % returns toggle state of tbFixations
   showSaccades(handles, 'left', 'vertical', 'eyelink');
   hObject.UserData = 'eyelink';
else
   hideSaccades(handles, 'left', 'vertical', 'eyelink');
end
return


% --- Executes on button press in tbSaccadesRightHorizFindSacc.
function tbSaccadesRightHorizFindSacc_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesRightHorizFindSacc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
   showSaccades(handles, 'right','horizontal', 'findsacc');
   hObject.UserData = 'findsacc';
else
   hideSaccades(handles, 'right','horizontal', 'findsacc');
end
return



% --- Executes on button press in tbSaccadesLeftHorizFindSacc.
function tbSaccadesLeftHorizFindSacc_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesLeftHorizFindSacc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value') % returns toggle state of tbFixations
   showSaccades(handles, 'left','horizontal', 'findsacc');
   hObject.UserData = 'findsacc';
else
   hideSaccades(handles, 'left','horizontal', 'findsacc');
end
return


% --- Executes on button press in tbSaccadesRightVertFindSacc.
function tbSaccadesRightVertFindSacc_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesRightVertFindSacc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value') % returns toggle state of tbFixations
   showSaccades(handles, 'right','vertical', 'findsacc');
   hObject.UserData = 'findsacc';
else
   hideSaccades(handles, 'right','vertical', 'findsacc');
end
return


% --- Executes on button press in tbSaccadesLeftVertFindSacc.
function tbSaccadesLeftVertFindSacc_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesLeftVertFindSacc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value') % returns toggle state of tbFixations
   showSaccades(handles, 'left','vertical', 'findsacc');
   hObject.UserData = 'findsacc';
else
   hideSaccades(handles, 'left','vertical', 'findsacc');
end
return



function edAccelThresh_Callback(hObject, eventdata, handles)
% hObject    handle to edAccelThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edAccelThresh as text
%        str2double(get(hObject,'String')) returns contents of edAccelThresh as a double


% --- Executes during object creation, after setting all properties.
function edAccelThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edAccelThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function edVelThresh_Callback(hObject, eventdata, handles)
% hObject    handle to edVelThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edVelThresh as text
%        str2double(get(hObject,'String')) returns contents of edVelThresh as a double


% --- Executes during object creation, after setting all properties.
function edVelThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edVelThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function edAccelStop_Callback(hObject, eventdata, handles)
% hObject    handle to edAccelStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edAccelStop as text
%        str2double(get(hObject,'String')) returns contents of edAccelStop as a double


% --- Executes during object creation, after setting all properties.
function edAccelStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edAccelStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function edVelStop_Callback(hObject, eventdata, handles)
% hObject    handle to edVelStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edVelStop as text
%        str2double(get(hObject,'String')) returns contents of edVelStop as a double


% --- Executes during object creation, after setting all properties.
function edVelStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edVelStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function edGapFP_Callback(hObject, eventdata, handles)
% hObject    handle to edGapFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGapFP as text
%        str2double(get(hObject,'String')) returns contents of edGapFP as a double


% --- Executes during object creation, after setting all properties.
function edGapFP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGapFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function edGapSP_Callback(hObject, eventdata, handles)
% hObject    handle to edGapSP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edGapSP as text
%        str2double(get(hObject,'String')) returns contents of edGapSP as a double


% --- Executes during object creation, after setting all properties.
function edGapSP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edGapSP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmenuAccelVel.
function popmenuAccelVel_Callback(hObject, eventdata, handles)
% hObject    handle to popmenuAccelVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmenuAccelVel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmenuAccelVel


% --- Executes during object creation, after setting all properties.
function popmenuAccelVel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmenuAccelVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function edExtend_Callback(hObject, eventdata, handles)
% hObject    handle to edExtend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edExtend as text
%        str2double(get(hObject,'String')) returns contents of edExtend as a double


% --- Executes during object creation, after setting all properties.
function edExtend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edExtend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbClearOldSaccs.
function pbClearOldSaccs_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearOldSaccs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear the saccades generated by findsaccs
eye_str_list = {'rh', 'lh', 'rv', 'lv'};
for e_cnt = 1:length(eye_str_list)
   eye_str = eye_str_list{e_cnt};
   tag_search_str = ['^saccade_' eye_str '_findsacc.*'];
   line_list = findobj(handles.figure1,'-regexp', 'Tag', tag_search_str);
   if ~isempty(line_list)
      delete(line_list)
   end
end

% reset togglebuttons
handles.tbSaccadesRightHorizFindSacc.Value = 0;
handles.tbSaccadesRightVertFindSacc.Value = 0;
handles.tbSaccadesLeftHorizFindSacc.Value = 0;
handles.tbSaccadesLeftVertFindSacc.Value = 0;
% reset userdata
handles.tbSaccadesRightHorizFindSacc.UserData = [];
handles.tbSaccadesRightVertFindSacc.UserData = [];
handles.tbSaccadesLeftHorizFindSacc.UserData = [];
handles.tbSaccadesLeftVertFindSacc.UserData = [];

% remove data saved in handles
if isfield(handles, 'findsacc_data')
   handles = rmfield(handles, 'findsacc_data');
   guidata(handles.figure1, handles)
end

return


% --- Executes on button press in pbSaveFindSaccs.
function pbSaveFindSaccs_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveFindSaccs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fname = strrep(handles.bin_filename, '.bin', '_findsaccs.mat');
[filename, pathname] = uiputfile(fname, 'Save saccade data file');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
else
   disp(['Saving ', fullfile(pathname, filename)])
   data = handles.findsacc_data;
   % remove disabled saccades
   data = remove_disabled_saccades(handles, data, 'findsacc');
   params.accelThresh = handles.edAccelThresh.String;
   params.velThresh = handles.edVelThresh.String;
   params.accelStop = handles.edAccelStop.String;
   params.velStop = handles.edVelStop.String;
   params.gapFP = handles.edGapFP.String;
   params.gapSP = handles.edGapSP.String;
   params.accelVel = handles.popmenuAccelVel.Value;
   params.extend = handles.edExtend.String;
   save(fullfile(pathname, filename), 'data', 'params')
end
return

function data = remove_disabled_saccades(handles, data, sacc_type)
eye_str_list = {'rh', 'lh', 'rv', 'lv'};
for e_cnt = 1:length(eye_str_list)
   eye_str = eye_str_list{e_cnt};
   tag_search_str = ['^saccade_' eye_str '_' sacc_type '.*_begin$'];
   sacc_beg_lines = findobj(handles.figure1,'-regexp', 'Tag', tag_search_str);
   disabled_lines = findobj(sacc_beg_lines, 'Marker', 'x');
   if ~isempty(disabled_lines)
      for sac_num = 1:length(disabled_lines)
         sacc_time_ms = round(disabled_lines(sac_num).XData*1000 + handles.eye_data.start_times);
         sac_ind = find(data.(eye_str).start == sacc_time_ms, 1);
         assert(~isempty(sac_ind), 'error finding saccade at %d\n', sacc_time_ms)
         data.(eye_str).start(sac_ind) = [];
         data.(eye_str).end(sac_ind) = [];
      end
   end
   
end

return


% --- Executes on button press in pbDefaultParams.
function pbDefaultParams_Callback(hObject, eventdata, handles)
% hObject    handle to pbDefaultParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.edAccelThresh.String = '800';
handles.edVelThresh.String = '20';
handles.edAccelStop.String = '100';
handles.edVelStop.String = '10';
handles.edGapFP.String = '10';
handles.edGapSP.String = '10';
handles.popmenuAccelVel.Value = 1;
handles.edExtend.String = '5';

% Update handles structure
guidata(handles.figure1, handles);
return


% --- Executes on button press in tbSaccadesRightHorizEngbert.
function tbSaccadesRightHorizEngbert_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesRightHorizEngbert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
   showSaccades(handles, 'right','horizontal', 'engbert');
   hObject.UserData = 'engbert';
else
   hideSaccades(handles, 'right','horizontal', 'engbert');
end
return

% --- Executes on button press in tbSaccadesLeftHorizEngbert.
function tbSaccadesLeftHorizEngbert_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesLeftHorizEngbert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
   showSaccades(handles, 'left','horizontal', 'engbert');
   hObject.UserData = 'engbert';
else
   hideSaccades(handles, 'left','horizontal', 'engbert');
end
return

% --- Executes on button press in tbSaccadesRightVertEngbert.
function tbSaccadesRightVertEngbert_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesRightVertEngbert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
   showSaccades(handles, 'right','vertical', 'engbert');
   hObject.UserData = 'engbert';
else
   hideSaccades(handles, 'right','vertical', 'engbert');
end
return

% --- Executes on button press in tbSaccadesLeftVertEngbert.
function tbSaccadesLeftVertEngbert_Callback(hObject, eventdata, handles)
% hObject    handle to tbSaccadesLeftVertEngbert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
   showSaccades(handles, 'left','vertical', 'engbert');
   hObject.UserData = 'engbert';
else
   hideSaccades(handles, 'left','vertical', 'engbert');
end
return

% --- Executes on button press in pbClearSaccsEngbert.
function pbClearSaccsEngbert_Callback(hObject, eventdata, handles)
% hObject    handle to pbClearSaccsEngbert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clear the saccades generated by findsaccs
eye_str_list = {'rh', 'lh', 'rv', 'lv'};
for e_cnt = 1:length(eye_str_list)
   eye_str = eye_str_list{e_cnt};
   tag_search_str = ['^saccade_' eye_str '_engbert.*'];
   line_list = findobj(handles.figure1,'-regexp', 'Tag', tag_search_str);
   if ~isempty(line_list)
      delete(line_list)
   end
end

% reset togglebuttons
handles.tbSaccadesRightHorizEngbert.Value = 0;
handles.tbSaccadesRightVertEngbert.Value = 0;
handles.tbSaccadesLeftHorizEngbert.Value = 0;
handles.tbSaccadesLeftVertEngbert.Value = 0;
% and user data
handles.tbSaccadesRightHorizEngbert.UserData = [];
handles.tbSaccadesRightVertEngbert.UserData = [];
handles.tbSaccadesLeftHorizEngbert.UserData = [];
handles.tbSaccadesLeftVertEngbert.UserData = [];

% remove data saved in handles
if isfield(handles, 'engbertsacc_data')
   handles = rmfield(handles, 'engbertsacc_data');
   guidata(handles.figure1, handles)
end

return



% --- Executes on button press in pbDefaultParamsEngbert.
function pbDefaultParamsEngbert_Callback(hObject, eventdata, handles)
% hObject    handle to pbDefaultParamsEngbert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.edVelFactor.String = '6';
handles.edMinSamples.String = '3';
handles.edInterSaccInterval.String = '20';
handles.chbxBinocular.Value = 0;

% Update handles structure
guidata(handles.figure1, handles);
return

function edVelFactor_Callback(hObject, eventdata, handles)
% hObject    handle to edVelFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edVelFactor as text
%        str2double(get(hObject,'String')) returns contents of edVelFactor as a double


% --- Executes during object creation, after setting all properties.
function edVelFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edVelFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function edMinSamples_Callback(hObject, eventdata, handles)
% hObject    handle to edMinSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edMinSamples as text
%        str2double(get(hObject,'String')) returns contents of edMinSamples as a double


% --- Executes during object creation, after setting all properties.
function edMinSamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edMinSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSaveEngbert.
function pbSaveEngbert_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveEngbert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname = strrep(handles.bin_filename, '.bin', '_engbert.mat');
[filename, pathname] = uiputfile(fname, 'Save Engbert saccade data file');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
else
   disp(['Saving ', fullfile(pathname, filename)])
   data = handles.engbertsacc_data;
   data = remove_disabled_saccades(handles, data, 'engbert');
   % remove disabled saccades -- FIXME
   params.velFactor = handles.edVelFactor.String;
   params.minSamples = handles.edMinSamples.String;
   
   save(fullfile(pathname, filename), 'data', 'params')
end
return


% --- Executes on button press in tbDataRightHoriz.
function tbDataRightHoriz_Callback(hObject, eventdata, handles)
% hObject    handle to tbDataRightHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% data & saccade lines
line_list = findobj(handles.figure1,'-regexp', 'Tag', '^.*rh.*');
tb_list = findobj(handles.figure1, '-regexp', 'Tag', 'tb.*RightHoriz.*');

visible = get(hObject,'Value');
if visible
   for tb_cnt = 1:length(tb_list)
      data_line = findobj(line_list, '-regexp', 'Tag', 'line_.*');
      set(data_line, 'Visible', 'on')
      % if the togglebutton indicates that there is saccade lines to
      % display - userData contains the saccade type (eyelink, findsacc,
      % engbert)
      if ~isempty(tb_list(tb_cnt).UserData)
         set(tb_list(tb_cnt), 'Value', 1)
         tb_sacc_type_line_list = findobj(line_list,'-regexp', 'Tag', ['^.*' tb_list(tb_cnt).UserData '.*']);
         set(tb_sacc_type_line_list, 'Visible', 'on')
      end
   end
else
   set(line_list, 'Visible', 'off')
   set(tb_list, 'Value', 0)
end

return


% --- Executes on button press in tbDataLeftHoriz.
function tbDataLeftHoriz_Callback(hObject, eventdata, handles)
% hObject    handle to tbDataLeftHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% data & saccade lines
line_list = findobj(handles.figure1,'-regexp', 'Tag', '^.*lh.*');
tb_list = findobj(handles.figure1, '-regexp', 'Tag', 'tb.*LeftHoriz.*');

visible = get(hObject,'Value');
if visible
   for tb_cnt = 1:length(tb_list)
      data_line = findobj(line_list, '-regexp', 'Tag', 'line_.*');
      set(data_line, 'Visible', 'on')
      % if the togglebutton indicates that there is saccade lines to
      % display - userData contains the saccade type (eyelink, findsacc,
      % engbert)
      if ~isempty(tb_list(tb_cnt).UserData)
         set(tb_list(tb_cnt), 'Value', 1)
         tb_sacc_type_line_list = findobj(line_list,'-regexp', 'Tag', ['^.*' tb_list(tb_cnt).UserData '.*']);
         set(tb_sacc_type_line_list, 'Visible', 'on')
      end
   end
else
   set(line_list, 'Visible', 'off')
   set(tb_list, 'Value', 0)
end

return
% --- Executes on button press in tbDataRightVert.
function tbDataRightVert_Callback(hObject, eventdata, handles)
% hObject    handle to tbDataRightVert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% data & saccade lines
line_list = findobj(handles.figure1,'-regexp', 'Tag', '^.*rv.*');
tb_list = findobj(handles.figure1, '-regexp', 'Tag', 'tb.*RightVert.*');

visible = get(hObject,'Value');
if visible
   for tb_cnt = 1:length(tb_list)
      data_line = findobj(line_list, '-regexp', 'Tag', 'line_.*');
      set(data_line, 'Visible', 'on')
      % if the togglebutton indicates that there is saccade lines to
      % display - userData contains the saccade type (eyelink, findsacc,
      % engbert)
      if ~isempty(tb_list(tb_cnt).UserData)
         set(tb_list(tb_cnt), 'Value', 1)
         tb_sacc_type_line_list = findobj(line_list,'-regexp', 'Tag', ['^.*' tb_list(tb_cnt).UserData '.*']);
         set(tb_sacc_type_line_list, 'Visible', 'on')
      end
   end
else
   set(line_list, 'Visible', 'off')
   set(tb_list, 'Value', 0)
end

return
% --- Executes on button press in tbDataLeftVert.
function tbDataLeftVert_Callback(hObject, eventdata, handles)
% hObject    handle to tbDataLeftVert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% data & saccade lines
line_list = findobj(handles.figure1,'-regexp', 'Tag', '^.*lv.*');
tb_list = findobj(handles.figure1, '-regexp', 'Tag', 'tb.*LeftVert.*');

visible = get(hObject,'Value');
if visible
   for tb_cnt = 1:length(tb_list)
      data_line = findobj(line_list, '-regexp', 'Tag', 'line_.*');
      set(data_line, 'Visible', 'on')
      % if the togglebutton indicates that there is saccade lines to
      % display - userData contains the saccade type (eyelink, findsacc,
      % engbert)
      if ~isempty(tb_list(tb_cnt).UserData)
         set(tb_list(tb_cnt), 'Value', 1)
         tb_sacc_type_line_list = findobj(line_list,'-regexp', 'Tag', ['^.*' tb_list(tb_cnt).UserData '.*']);
         set(tb_sacc_type_line_list, 'Visible', 'on')
      end
   end
else
   set(line_list, 'Visible', 'off')
   set(tb_list, 'Value', 0)
end

return


% --- Executes on button press in pbLoadSaccTarget.
function pbLoadSaccTarget_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadSaccTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = parse_msg_file_for_targets(handles, 'sacc');
guidata(handles.figure1, handles)
return


% --- Executes on button press in pbLoadSmoothTarget.
function pbLoadSmoothTarget_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadSmoothTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = parse_msg_file_for_targets(handles, 'smoothp');
guidata(handles.figure1, handles)
return


% --- Executes on button press in tbTargetV.
function tbTargetV_Callback(hObject, eventdata, handles)
% hObject    handle to tbTargetV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value') % returns toggle state
   set(handles.line_target_y, 'Visible', 'on')
else
   set(handles.line_target_y, 'Visible', 'off')
end
return

% --- Executes on button press in tbTargetH.
function tbTargetH_Callback(hObject, eventdata, handles)
% hObject    handle to tbTargetH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value') % returns toggle state
   set(handles.line_target_x, 'Visible', 'on')
else
   set(handles.line_target_x, 'Visible', 'off')
end
return


function edInterSaccInterval_Callback(hObject, eventdata, handles)
% hObject    handle to edInterSaccInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edInterSaccInterval as text
%        str2double(get(hObject,'String')) returns contents of edInterSaccInterval as a double


% --- Executes during object creation, after setting all properties.
function edInterSaccInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edInterSaccInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chbxBinocular.
function chbxBinocular_Callback(hObject, eventdata, handles)
% hObject    handle to chbxBinocular (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxBinocular
