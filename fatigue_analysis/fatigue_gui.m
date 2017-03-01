function varargout = fatigue_gui(varargin)
% FATIGUE_GUI - interactive analysis of saccades from 10 minute fatigue test
%
% USAGE:
% hFig = fatigue_gui
%
% OUTPUTS:
% hFig - handle of figure

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @fatigue_gui_OpeningFcn, ...
    'gui_OutputFcn',  @fatigue_gui_OutputFcn, ...
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

% --- Executes just before figure is made visible.
function fatigue_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments  (see VARARGIN)

% Choose default command line output for mtbi_saccade_tests
handles.output = hObject; % figure handle (default tagged as "figure1")

% Set text with rev info
set(handles.txtRev,'string','Version: 2013-08-20');

% get the data
[handles.data.rh, handles.data.rv, handles.data.lh, handles.data.lv, ...
   handles.data.samp_freq, handles.data.pathName, handles.data.fileName, ...
   handles.data.st, handles.data.sv,ds, tl, sampFreq] = rd_wrapper;

set(handles.fnameH,'String', handles.data.fileName);
%rhd = deblink(handles.data.rh);
%lhd = deblink(handles.data.lh);
%rvd = deblink(handles.data.rv);
%lvd = deblink(handles.data.lv);

% if filename is empty, user canceled, close the window
if isempty(handles.data.fileName)
	guidata(hObject, handles);
	return;
end
% create time vector
handles.data.t = maket(handles.data.rh, handles.data.samp_freq);

% filter the position data
%lpf_params.filter_order = 4;
%lpf_params.cutoff_freq = 25;

% RD automatically applies filtering now, rather than prompt for the answer which is always 'yes'.
%handles.data.rh = lpf(handles.data.rh, lpf_params.filter_order, lpf_params.cutoff_freq, handles.data.samp_freq);
%handles.data.lh = lpf(handles.data.lh, lpf_params.filter_order, lpf_params.cutoff_freq, handles.data.samp_freq);
%handles.data.rv = lpf(handles.data.rv, lpf_params.filter_order, lpf_params.cutoff_freq, handles.data.samp_freq);
%handles.data.lv = lpf(handles.data.lv, lpf_params.filter_order, lpf_params.cutoff_freq, handles.data.samp_freq);

% RD automatically does de-blinking now, using "stdproc.m" (3/18/16)
% deblinking added 3/16/16 (JBJ)
if ~isempty(handles.data.rh)
   handles.data.rhd = deblink(handles.data.rh);
else
   handles.data.rhd = [];
end

if ~isempty(handles.data.lh)
   handles.data.lhd = deblink(handles.data.lh);
else
   handles.data.lhd = [];
end

if ~isempty(handles.data.rv)
   handles.data.rvd = deblink(handles.data.rv);
else
   handles.data.rvd = [];
end

if ~isempty(handles.data.lv)
   handles.data.lvd = deblink(handles.data.lv);
else
   handles.data.lvd = [];
end

num_pts = 4;
% compute horizontal velocities
handles.data.rhv = d2pt(handles.data.rh, num_pts, handles.data.samp_freq);
handles.data.lhv = d2pt(handles.data.lh, num_pts, handles.data.samp_freq);
handles.data.rvv = d2pt(handles.data.rv, num_pts, handles.data.samp_freq);
handles.data.lvv = d2pt(handles.data.lv, num_pts, handles.data.samp_freq);

handles.data.rhvd = d2pt(handles.data.rhd, num_pts, handles.data.samp_freq);
handles.data.lhvd = d2pt(handles.data.lhd, num_pts, handles.data.samp_freq);
handles.data.rvvd = d2pt(handles.data.rvd, num_pts, handles.data.samp_freq);
handles.data.lvvd = d2pt(handles.data.lvd, num_pts, handles.data.samp_freq);

% and accelerations
handles.data.rha = d2pt(handles.data.rhv, num_pts, handles.data.samp_freq);
handles.data.lha = d2pt(handles.data.lhv, num_pts, handles.data.samp_freq);
handles.data.rha = d2pt(handles.data.rhv, num_pts, handles.data.samp_freq);
handles.data.lha = d2pt(handles.data.lhv, num_pts, handles.data.samp_freq);

handles.data.rhad = d2pt(handles.data.rhvd, num_pts, handles.data.samp_freq);
handles.data.lhad = d2pt(handles.data.lhvd, num_pts, handles.data.samp_freq);
handles.data.rvad = d2pt(handles.data.rvvd, num_pts, handles.data.samp_freq);
handles.data.lvad = d2pt(handles.data.lvvd, num_pts, handles.data.samp_freq);

% display data in the axes
handles = initPlot(handles);

% Set figure properties (dynamic size, etc)
%locFigureInit(handles.output);

handles.blnCalc = false;	% results calculated yet?
handles.blnSaved = false;	% has the output been saved yet?


% Initialize plot
%set(handles.txtTrialNum,'string','0'); % zero for trial # when we are zoomed out
%handles = locPlotInit(handles);

% Set figure props
%set(hObject,'NumberTitle','off','Name',[handles.strTestname ' trial browser']);

% Hold handles of rubberband boxes (rbboxes) & saccadic intrusion boxes (siboxes)
handles.rbboxes = [];		% not being updated with deleted rbboxes DO NOT USE
%handles.siboxes = [];

% Initialize per-test (switch used for future/enhancements/customization based on which test we are are dealing with)
%set([handles.txtSaccIntruBox handles.txtLabelDesiredDelta handles.txtDesiredDelta],'vis','off');
%set([handles.txtLabelReactionTime handles.edReactionTime handles.txtReactionNumPts],'vis','off'); % reaction time criteria should be applied to intermediate results instead...
%switch handles.strTestname
%    case 'fixation'
%        set(handles.txtSaccIntruBox,'vis','on');
%    otherwise
        % nothing yet (customize a bit here?)
%end % switch

% Set figure visibility on
set(hObject,'visible','on');

% Update handles structure (handle graphics ftw)
guidata(hObject, handles);




% --- Initialize some figure properties ------------------------------------------------------
function locFigureInit(hFig)
%set(hFig,'Toolbar','figure'); % standard toolbar
% [screenwidth,screenheight] = javagetscreensize;
xywh = get(hFig,'position');
set(hFig,'pos',[0.05 0.05 0.8 0.7]);


% --- Outputs from this function are returned to the command line. ----------------------------
function varargout = fatigue_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output; % the figure handle


% --- Plot "demedian-scaled" derivative trace (vel,acc,jrk) -----------------------------------
function [ys,hys,indExt,hyse] = locPlotTrace(t,y,sf,sizeMark,c)
ys = demedianscaled(y,sf);
indExt = locGetLocalExtrema(ys);
hyse = plot(t(indExt),ys(indExt),'o'); % plot first for "send2front" access
hys = plot(t,ys,'marker','.','markersize',sizeMark,'color',c);
set([hys hyse],'buttondownfcn',@locButtonDownVelLocMin,'markersize',sizeMark);
set(hyse,'color',0.8*c,'markersize',1.2*sizeMark);


% --- Initialize lines for sacc start/stop ------------------------------------------------
function hdots = locPlotSacc(h,inds)
numSacc = length(inds);
hdots = nan*ones(numSacc,1);
% one line per saccade start or stop point
for i = 1:numSacc
    ind = inds(i);
    hdots(i) = plot(h.t(ind),h.posEye(ind),'.');
end

% --- Initialize plot ---------------------------------------------------------------------
function handles = initPlot(handles)
axes(handles.axes1)

% right horizontal
handles.rh_line = plot(handles.data.t, handles.data.rh, 'b-');
set(handles.rh_line, 'Tag', 'rhPosLine')

% left horizontal
handles.lh_line = plot(handles.data.t, handles.data.lh, 'g-');
set(handles.lh_line, 'Tag', 'lhPosLine')

% velocities
velScale = str2double(get(handles.edVScale, 'String'));
accScale = str2double(get(handles.edAScale, 'String'));

handles.rhv_line = plot(handles.data.t, handles.data.rhv*velScale, 'b:');
set(handles.rhv_line, 'Tag', 'rhVelLine')

handles.lhv_line = plot(handles.data.t, handles.data.lhv*velScale, 'g:');
set(handles.lhv_line, 'Tag', 'lhVelLine')

handles.rha_line = plot(handles.data.t, handles.data.rha*accScale, 'b-.');
set(handles.rha_line, 'Tag', 'rhAccLine')

handles.lha_line = plot(handles.data.t, handles.data.lha*accScale, 'b-.');
set(handles.lha_line, 'Tag', 'lhAccLine')

% --- Initialize plot ---------------------------------------------------------------------
function h = locPlotInit(h)
% Hard-code constants (for now)
alphaPatch = 0.25; % transparency value for the "target patches"

% Need these yLims before we start adding plot objects
yLim = [-40 40]; % TODO make this smarter

% Let's be sure to hold on the axis of interest
axes(h.axTrial); %#ok<MAXES>
hold on;

% Plot position of eye position, desired (target) & saccade start/stops dots
h.linePosEye = plot(h.t,h.posEye,'b');
set(h.linePosEye,'tag','eyePos');
h.linePosDesired = plot(h.t,h.posDesired,'m');
h.dotsSaccStart = locPlotSacc(h,h.saccStarts);
set(h.dotsSaccStart,'color','g');
h.dotsSaccStop = locPlotSacc(h,h.saccStops);
set(h.dotsSaccStop,'color','r');
set([h.dotsSaccStart(:); h.dotsSaccStop(:)],'markersize',16);
set(h.dotsSaccStart,'buttondownfcn',@locButtonDownSaccStart);
set(h.dotsSaccStop,'buttondownfcn',@locButtonDownSaccStop);

% Plot target diamonds
numTargets = length(h.indStepStarts);
casTargetTypes = sacctargettypes(h.strTestname);
%h.diamondsTarget = nan*ones(numTargets,1);
h.diamondsTarget = [];
h.hgTargetTypes = nan*ones(numTargets,1);
for targNum = 1:length(h.indStepStarts)
    indStepStart = h.indStepStarts(targNum);
    indStepStop = h.indStepStops(targNum);
    
    % targets at 0 and -15
    hdt = plot(h.t(indStepStart),h.posDesired(indStepStart),'bd');
	 hdt = locCreateDiamMenu(hdt);
    ud.trialNum = sacctrialnum(targNum,h.strTestname);
    ud.targetNum = targNum;
    ud.targetType = casTargetTypes{targNum};
    ud.targetAngle = h.posDesired(indStepStart);
    ud.indStepStart = indStepStart;
    ud.indStepStop = indStepStop;
    ud.deltaDesired = h.deltasDesired(targNum);
    ud.hBox = [];
    set(hdt,'userdata',ud);
%    h.diamondsTarget(targNum) = hdt;
	 h.diamondsTarget = [h.diamondsTarget hdt];
    % add an additional target at +15 for each -15 one
    if abs(h.posDesired(indStepStart)+15) < 0.01,
		hdt = plot(h.t(indStepStart),-1*h.posDesired(indStepStart),'gd');
		hdt = locCreateDiamMenu(hdt);
		ud.trialNum = sacctrialnum(targNum,h.strTestname);
		ud.targetNum = targNum;
		ud.targetType = casTargetTypes{targNum};
		ud.targetAngle = -1 * h.posDesired(indStepStart);
		ud.indStepStart = indStepStart;
		ud.indStepStop = indStepStop;
		ud.deltaDesired = h.deltasDesired(targNum);
		ud.hBox = [];
		set(hdt,'userdata',ud);
		h.diamondsTarget = [h.diamondsTarget hdt];    
    end
    
    % patches for background coloring of 'visible' vs 'fixation' targetTypes
    x1patch = h.t(indStepStart);
    x2patch = h.t(indStepStop);
    hTargetPatch = mypatch(x1patch,x2patch,yLim(1),yLim(2),alphaPatch,ud.targetType);
    set(hTargetPatch,'tag',sprintf('targetpatch%02d',targNum));
    uistack(hTargetPatch,'bottom');		% send it to the bottom layer
    h.hgTargetTypes(targNum) = hTargetPatch;
end
set(h.diamondsTarget,'markersize',9);	%,'markeredgecolor','k');
set(h.diamondsTarget,'buttondownfcn',@locButtonDownDiamondTarget);	%% left click to add rbbox

% Plot derivatives of eye position
sf = str2double(get(h.edSquelch,'string'));
[h.vel,h.acc,h.jrk] = derivs(h.posEye,1/h.sampFreq);
[h.velScaled,h.lineVelocityScaled,h.indVelExtrema,h.dotsVelLocalMin] = locPlotTrace(h.t,h.vel,sf,8,0.55*[1 0 1]);
[h.accScaled,h.lineAccelScaled,h.indAccExtrema,h.dotsAccLocalMin] = locPlotTrace(h.t,h.acc,sf,8,0.55*[0 1 1]);
[h.jrkScaled,h.lineJerkScaled,h.indJrkExtrema,h.dotsJerkLocalMin] = locPlotTrace(h.t,h.jrk,sf,8,0.55*[1 1 0]);

% Initially invisible for the derivatives of position
set([h.dotsVelLocalMin h.lineVelocityScaled h.dotsAccLocalMin h.lineAccelScaled h.dotsJerkLocalMin h.lineJerkScaled],'vis','off'); % initially hidden

% Decorate the plot
title(sprintf('%s %s Eye Position',h.strTitle,upper(h.strEyeDir)));
xlabel('Time (s)');
ylabel('Position (deg)');
set(h.axTrial,'ylim',yLim);

% Plot magenta vertical lines at trial starts & trial # as text objects
h.linesTrialStart = nan*ones(h.numTrials,1);
h.txtTrialMarkers = nan*ones(h.numTrials,1);
yTxt = 0.82*yLim(2); % y-value for trial # text objects to be nearly at top of plot
%h.reactionPts = locGetReactionPoints(h);
for trialNum = 1:h.numTrials
    h.linesTrialStart(trialNum) = linetrialstart(gca,h.t,trialNum,h.indTrialStarts,'lineTrialStart');
    xTxt = h.t(h.indTrialStarts(trialNum)-round(0.3*h.ptsBeforeTrialStart)); % fit it between zero & trial start line
    h.txtTrialMarkers(trialNum) = locTrialMarker(xTxt,yTxt,trialNum);
    % Build structure for storing trial-by-trial info FTW [this got revamped after talk with Jon -- there is likely a better way]
    sTrial = struct(); % for this trial
    sTrial.trialNum = trialNum;
    sTrial.indTrialStart = h.indTrialStarts(trialNum);
%    sTrial.indReactionTime = h.indStepStarts(trialNum) + h.reactionPts;
    sTrial.indTrialStop = h.indTrialStops(trialNum);
    sTrial.note = '';
    set(h.linesTrialStart(trialNum),'userdata',sTrial); % stash into trial start vertical line's userdata
end

% Create end of record marker & text to be user friendly
h.lineEndOfRecord = line(h.t(end)*[1 1],yLim);
xEor = h.t(end-round(0.3*h.ptsBeforeTrialStart)); % not like other trials
h.txtEndOfRecord = locTrialMarker(xEor,yTxt,'end');
set(h.lineEndOfRecord,'tag','endOfRecord','vis','on');

% Group trial start lines and end of record vertical magenta lines
h.grpTrialStarts = locGroupTrialStartsEndOfRec([h.linesTrialStart; h.lineEndOfRecord]);
hLink = linkprop([h.linesTrialStart; h.lineEndOfRecord; h.txtTrialMarkers],'Color'); % TODO no use of color yet, but maybe useful [later?]
set(h.linesTrialStart,'color','m'); % all get magenta color via link

% Initialize handles and cells to hold some useful graphic objects
h.linesReaction = []; % vertical time that is "reaction time" after trial start

% Update plot
h = locUpdatePlot(h);

% Better font size? and hold off (for now)
set([h.txtTrialMarkers; h.txtEndOfRecord],'fontsize',10);
set([h.txtPerTrial],'fontsize',9);

% Get xlim for restoring it later (like reset is when trial # edit box gets set to zero)
h.xlim = get(gca,'xlim');

% Initialize reaction points text
%rtInit = locGetReactionPoints(h);
%set(h.txtReactionNumPts,'string',sprintf('(%0dpts)',rtInit));

% Initialize zoom object
h.hZoom = zoom(h.output);
% change the zoom cursor menu
hCMZ = uicontextmenu;
item1 = uimenu('Parent',hCMZ,'Label','zoom off','Callback','zoom(gcbf,''off'')');
item2 = uimenu('Parent',hCMZ,'Label','switch to pan','Callback','pan(gcbf,''on'')');
set(h.hZoom,'UIContextMenu',hCMZ);
set(h.hZoom,'ActionPostCallback',@zoomPostCallback);

% Update guidata
guidata(h.output,h);

% Initial sweep to "left click" found saccs for marking as default (user just has to "unselect")
locPreSelectFoundSaccs(h);
locDoReset(h);


% --- Executes on key press when focus is on figure1 and none of its controls! -------------
function figure1_KeyPressFcn(hObject, eventdata, h)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles, h that is, is structure with handles and user data (see GUIDATA)

switch eventdata.Key
    case 'backslash'
        strVis = get(h.hgTargetTypes(1),'vis');
        switch strVis
            case 'on'
                strNewVis = 'off';
                set(h.txtTargetTypes,'foregroundcolor',0.5*[1 1 1]);
            case 'off'
                strNewVis = 'on';
                set(h.txtTargetTypes,'foregroundcolor','w');
            otherwise
                % ignore unaccounted for "visible" property value
                return
        end % switch
        set(h.hgTargetTypes,'vis',strNewVis);
    case 'b'
        locDoRubberbandBox;
       
    case 'c'
        set([h.dotsVelLocalMin h.lineVelocityScaled h.dotsAccLocalMin h.lineAccelScaled h.dotsJerkLocalMin h.lineJerkScaled],'vis','off');
        set(h.txtDerivs,'string','(v) none');
    case 'd' % toggle desired position trace and dim its label
        mtbitogglevis(h.linePosDesired,h.txtPosDesired);
    case 'e'  % toggle eye position trace and dim its label
        mtbitogglevis(h.linePosEye,h.txtPosEye);
    case 'equal'
        h.blnSaved = locSaveFigure(h);
        guidata(hObject,h);
    case 'f1' % move "right" in time
        xlim = get(h.axTrial,'xlim');
        xDist = (xlim(2)-xlim(1)) * 0.95;	% move 95% of the visible axes distance
        set(h.axTrial,'xlim',xlim - xDist);
    case 'f2' % move "left" in time
        xlim = get(h.axTrial,'xlim');
		xDist = (xlim(2)-xlim(1)) * 0.95;	% move 95% of the visible axes distance
        set(h.axTrial,'xlim',xlim + xDist);
    case 'f3' % can turn on, but can't turn off by keypress
         set(h.hZoom, 'enable', 'on');
    case 'hyphen' % the "minus" sign to left of "equal" sign print "just this view"
        locDoPrintFig();
    case 'leftarrow' % move data in the window to the right
%        locPrevTrial(h);
		xlims = get(h.axTrial,'Xlim');
		width = diff(xlims);
		set(h.axTrial, 'Xlim', [xlims(1)-width xlims(1)]+width*0.05);
    case 'm'  % toggle saccStart/Stop markers
        mtbitogglevis([h.dotsSaccStart; h.dotsSaccStop],h.txtSaccStarts);
    case 'p' % screencapture PNG for each "trial"
        locDoReset(h);
        for i = 1:h.numTrials
            locNextTrial(h);
            locDoPrintFig();
            pause(0.2);
        end
    case 'rightarrow' % move data in figure to the left
%        locNextTrial(h);
		xlims = get(h.axTrial,'Xlim');
		width = diff(xlims);
		set(h.axTrial, 'Xlim', [xlims(2) xlims(2)+width]-width*0.05);

    case 's' % FIXME this works if FIG already saved and you do not resave because...
        disp('need "dualcursor" bug fix from this 3rd party tool, but disable it for now')
        %         DeltaX_x = 0.80;
        %         DeltaX_y = 1.02;
        %         DeltaY_x = 0.89;
        %         DeltaY_y = 1.02;
        %         posDeltalabelpos = [DeltaX_x, DeltaX_y; DeltaY_x, DeltaY_y]; % above/right of axis
        %         dualcursor([],posDeltalabelpos);
    case 't'  % toggle trial start vertical lines and dim its label
        mtbitogglevis(h.linesTrialStart,h.txtTrialStarts);
    case {'v','downarrow'} % show scaled/offset velocity
        switch get(h.txtDerivs,'string')
            case '(v) none'
                set([h.dotsVelLocalMin h.lineVelocityScaled],'vis','on');
                set([h.dotsAccLocalMin h.lineAccelScaled h.dotsJerkLocalMin h.lineJerkScaled],'vis','off');
                set(h.txtDerivs,'string','(v) velocity');
                set(h.edSquelch,'string','5e-2');
            case '(v) velocity'
                set([h.dotsAccLocalMin h.lineAccelScaled],'vis','on');
                set([h.dotsVelLocalMin h.lineVelocityScaled h.dotsJerkLocalMin h.lineJerkScaled],'vis','off');
                set(h.txtDerivs,'string','(v) acceleration');
                set(h.edSquelch,'string','5e-4');
            case '(v) acceleration'
                set([h.dotsJerkLocalMin h.lineJerkScaled],'vis','on');
                set([h.dotsVelLocalMin h.lineVelocityScaled h.dotsAccLocalMin h.lineAccelScaled],'vis','off');
                set(h.txtDerivs,'string','(v) jerk');
                set(h.edSquelch,'string','5e-6');
            case '(v) jerk'
                set([h.dotsVelLocalMin h.lineVelocityScaled h.dotsAccLocalMin h.lineAccelScaled h.dotsJerkLocalMin h.lineJerkScaled],'vis','off');
                set(h.txtDerivs,'string','(v) none');
                set(h.edSquelch,'string','5e-2');
            otherwise
                % FIXME unhandled case
        end % switch
        locApplyScale(h);
    case 'w'
        if length(eventdata.Modifier) == 1,
	           switch eventdata.Modifier{1}
             case 'command'
				if locVerifyClose(h),
					delete(hObject);
				end
           end
        elseif length(eventdata.Modifier) == 0,
			% export data structure to workspace (a request from Jon)
%			casFields = {'strFullFilename','strEyeDir','runNum','lpf_params','findsaccs_params','trials'};
%			for i = 1:length(casFields)
%				strField = casFields{i};
%				s.(strField) = h.(strField);
%			end
%			if evalin('base','exist(''s'')')
%				uiwait(msgbox('Cannot save "s" in workspace because a variable with that name exists there already.','Cannot put "s" in base workspace.','modal'));
%			else
%				assignin('base','s',s);
%			end  
        end

  
    case 'z' % launch zoomtool & resume when that window is killed
        % copy objects instead of zoomtooling on gui to preserve functionality
        a = axis;
        hChildren = get(h.axTrial,'children');
        hFigZoom = figure;
        set(hFigZoom,'Name','Kill Window Returns to Trial Browser');
        hAxZoom = axes;
        title(sprintf('%s %s Eye Position Trial %s',h.strTitle,upper(h.strEyeDir),get(h.txtTrialNum,'string')));
        copyobj(hChildren,hAxZoom);
        axis(a);
        set(hObject,'vis','off');
        zoomtool;
        waitfor(hFigZoom);
        set(hObject,'vis','on');
%    otherwise
        % gracefully do nothing here
        %str = sprintf('the "%s" key is not assigned a callback in "%s"',eventdata.Key,mfilename);
        %disp(str)
end % switch


% --- Get local extrema
function inds = locGetLocalExtrema(v)
[~,imax,~,imin] = extrema(v);
inds = [imin(:); imax(:)];


% --- Update plot as we step through trial-by-trial
function locUpdateTrial(h,tmin,tmax,trial)
set(h.edNote,'enable','on');
indNxtStep = mgsnexttrialfirststep(h,trial);
tmax = h.t(indNxtStep);
set(h.axTrial,'xlim',[tmin tmax]);
desiredDelta = h.deltasDesired(trial);
%set(h.txtDesiredDelta,'string',sprintf('%.2f',desiredDelta));
% scalePct = str2double(get(h.edVScale,'String')); % FIXME for when we allow this to change (not now)
s = get(h.linesTrialStart(trial),'userdata'); % get sTrial from userdata for this line object
str = sprintf('trial %02d',trial);
if isfield(s,'events')
    for i = 1:length(s.events)
        evt = s.events(i);
        str = [str sprintf('\n%6d: %s',evt.sampnum,evt.tag)];
    end
end
set(h.edNote,'string',s.note);		% note field at top of fig
set(h.txtPerTrial,'string',str);	% text box lower right - list events
hNoteLabel=findobj(h.output,'tag','txtLabelNote');
set(hNoteLabel,'string',sprintf('Trial %d note:',trial));


% --- Step to previous trial; event handler for leftarrow key press
function locPrevTrial(h)
if numel(h.indStepStarts)==1
    return
end
currTrial = str2double(get(h.txtTrialNum,'String')); % returns contents of txtTrialNum as a double
newTrial = max([1,currTrial-1]);
set(h.txtTrialNum,'string',newTrial);
i1 = h.indTrialStarts(newTrial)-h.ptsBeforeTrialStart;
i2 = h.indStepStarts(newTrial+1)+h.ptsBeforeTrialStart;
locUpdateTrial(h,h.t(i1),h.t(i2),newTrial);


% --- Step to next trial; event handler for rightarrow key press
function locNextTrial(h)
currTrial = str2double(get(h.txtTrialNum,'String')); % returns contents of txtTrialNum as a double
newTrial = min([h.numTrials,currTrial+1]);
set(h.txtTrialNum,'string',newTrial);
i1 = max([h.indTrialStarts(newTrial)-h.ptsBeforeTrialStart 1]);
if newTrial==h.numTrials
    i2 = length(h.t);
else
    i2 = h.indStepStarts(newTrial+1)+h.ptsBeforeTrialStart;
end
tmax = min([h.t(i2) max(h.t)]);
locUpdateTrial(h,h.t(i1),tmax,newTrial);


% --- Executes on edit box change in edReactionTime.
function edReactionTime_Callback(hObject, eventdata, handles)
% hObject    handle to edReactionTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hints: get(hObject,'String') returns contents of edReactionTime as text
%        str2double(get(hObject,'String')) returns contents of edReactionTime as a double
% % % rtNew = locGetReactionPoints(handles);
% % % set(handles.txtReactionNumPts,'string',sprintf('(%0dpts)',rtNew));
% % % handles.linesReaction = locUpdatePlot();
% % % guidata(handles.output,handles);
strMsg = sprintf('this no longer works, we will deal with reaction time criteria in intermediate results (text) files');
uiwait(msgbox(strMsg,'Obsolete','modal'));


% --- Delete graphic objects that depend on reaction time criteria
function locClearPlot(h)
delete(h.linesReaction);
cellfun(@delete,h.chPreStarts);
cellfun(@delete,h.chPreStops);
cellfun(@delete,h.chPostStartSquelchs);
cellfun(@delete,h.chPostStopSquelchs);


% --- Update plot after having changed (or initialized) reaction time value
function h = locUpdatePlot(h)
if ~isempty(h.linesReaction) % FIXME for robustness
    bln = yesnodlg('Want to forget current results and start over?','Are You Sure?');
    if ~bln, return, end
    locClearPlot(h); % out with the old...
end
% ...and in with the new
numTrials = h.numTrials;
h.linesReaction = nan*ones(numTrials,1);
for trialNum = 1:numTrials
    s = get(h.linesTrialStart(trialNum),'userdata');
%    h.linesReaction(trialNum) = linetrialstart(h.axes1,h.t,trialNum,h.indStepStarts+h.reactionPts,'lineReactionTime');
    % Stash info for this trial into userdata of vertical line of trial start object
    set(h.linesTrialStart(trialNum),'userdata',s);
end
%set(h.linesReaction,'color',0.4*[1 1 1],'linestyle','-');
%set(h.linesReaction,'vis','off'); % FIXME...we are carrying around legacy baggage (which is okay for now, but should be revamped)


% --- Calculate number of points for reaction time (rounded)
function reactionPts = locGetReactionPoints(h)
reactionPts = round(h.sampFreq*str2double(get(h.edReactionTime,'String')));


% --- Executes during object creation, after setting all properties.
function edReactionTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edReactionTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Reset plot to "trial zero" (initial state)
function locDoReset(h)
set(h.axTrial,'xlim',h.xlim);
set(h.txtTrialNum,'string','0');
set(h.edNote,'string','');
set(h.edNote,'enable','off');



% --- Executes on button press in pbReset.
function pbReset_Callback(hObject, eventdata, handles)
% hObject    handle to pbReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ask are you sure? all saccades will be added back as circled events
blnSure = yesnodlg('Are you sure? All saccades will be added back as events.','Are You Sure?');
if ~blnSure, return, end
locPreSelectFoundSaccs(handles);	% reselect all "findsaccs" saccades as circles
% remove any objects added with 'tmp' tags (usually added for debugging purposes)
h = findobj(handles.output,'tag','tmp');	
delete(h);
locDoReset(handles);		% reset back to "trial zero"
locNextTrial(handles);		% first trial


% --- Executes during object creation, after setting all properties.
function txtTrialNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTrialNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Gather end of record objects into group
function hg = locGroupTrialStartsEndOfRec(hLines)
hg = hggroup('ButtonDownFcn',@locShowTrialInfo); % not fully implemented
set(hLines,'Parent',hg,'HitTest','off');


% --- Show this trial's info
function locShowTrialInfo(hg,eventdata) %#ok<INUSD>
hLines = get(hg,'Children'); % hg is handle of hggroup object
for i = 1:length(hLines) % TODO not fully implemented yet
    str = get(hLines,'tag');
    fprintf('\nGroup item %d has tag %s',i,str)
end


% --- Create text object for this trial rotated 90deg & tagged
function hTxt = locTrialMarker(x,y,trialNum)
if isnumeric(trialNum)
    str = sprintf('Trial %02d',trialNum);
else
    str = trialNum; % re-use for 'end' of record marker string
end
hTxt = text(x,y,str);
set(hTxt,'color','m','rot',90,'tag','textTrialNum');


% --- Get marked events info into embedded structure
function locGetMarkedEvents(h)
s.filename = h.strFullFilename;
s.channel = h.strEyeDir; % like 'rh'
locDoReset(h);
for trial = 1:h.numTrials
    locNextTrial(h);
    mgseventsort(trial,h);
end
guidata(h.output,h);


% --- Update event structure for this trial
function locUpdateEventStructure(trialNum,s,h)
s = rasdatastructuretemplate(trialNum,s,h);


% --- Executes on button press in pbCalcSaccades -----------------------------------------------
function pbCalcSaccades_Callback(hObject, eventdata, handles)
% hObject    handle to pbCalcSaccades (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with handles and user data (see GUIDATA)
   % default values  for findsaccs
    thresh_a = str2double(get(handles.edAccStart, 'String'));
    acc_stop = str2double(get(handles.edAccStop, 'String'));
    thresh_v = str2double(get(handles.edVelStart, 'String'));
    vel_stop = str2double(get(handles.edVelStop, 'String'));
    gap_fp = 10;
    gap_sp = 10;
	
    %vel_or_acc = 1; 1= accel, 2=vel, 3 = use either/both criteria
	vel_or_acc = get(handles.popupVelAccel,'Value'); 
	
    extend = 5;
    dataName = 'unknown';
    strict_strip = 1;
    
    % Find saccades - right eye
    [ptlist, pvlist] = findsaccs(handles.data.rh, thresh_a, thresh_v, acc_stop, vel_stop, gap_fp, gap_sp, vel_or_acc, extend, dataName, strict_strip);
%ptlist = []; pvlist = [];   
    % Get variables from base workspace
    % NOTE: pvel (for example & among others) gets "assignin" to workspace from findsaccs!
    [ptlist,pv_pt,saccstart,saccstop,pvel,extend,dataName,thresh_v,thresh_a,vel_stop,acc_stop] = fetchfindsaccsvars;

% saccstart sometimes has repeats
handles.saccStarts.rh = unique(saccstart);	% indices of saccade starts
handles.saccStops.rh = unique(saccstop);		% indices of saccade stops

% same thing for left eye
[ptlist, pvlist] = findsaccs(handles.data.lh, thresh_a, thresh_v, acc_stop, vel_stop, gap_fp, gap_sp, vel_or_acc, extend, dataName, strict_strip);
[ptlist,pv_pt,saccstart,saccstop,pvel,extend,dataName,thresh_v,thresh_a,vel_stop,acc_stop] = fetchfindsaccsvars;
handles.saccStarts.lh = unique(saccstart);	% indices of saccade starts
handles.saccStops.lh = unique(saccstop);		% indices of saccade stops


% display the saccades
showSaccades(handles)

guidata(handles.figure1, handles);

% --- Display the saccade starts and stops -----------------------------------
function showSaccades(handles)

axes(handles.axes1)

% right saccade starts
drawSaccLine( handles.axes1, handles.data.t, handles.data.rh, 'rhSaccStartLine', handles.saccStarts.rh, ...
	'b', '.', 18);
% left saccade starts
drawSaccLine( handles.axes1, handles.data.t, handles.data.lh, 'lhSaccStartLine', handles.saccStarts.lh, ...
	'g', '.', 18);

% and stops
drawSaccLine( handles.axes1, handles.data.t, handles.data.rh, 'rhSaccStopLine', handles.saccStops.rh, ...
	'b', '*', 10);
drawSaccLine( handles.axes1, handles.data.t, handles.data.lh, 'lhSaccStopLine', handles.saccStops.lh, ...
	'g', '*', 10);

% --- draw a saccade start or stop marker line
function drawSaccLine( hAx, xdata, ydata, lineTag, saccInds, color, marker, markSize)

saccLine = findobj(hAx, 'Tag', lineTag);
if isempty(saccLine),
	saccLine = line(xdata(saccInds), ydata(saccInds), ...
		'Tag', lineTag, ...
		'Linestyle', 'none', 'Marker', marker, 'Color', color, 'MarkerSize', markSize);
	hcmenu = uicontextmenu;
	item1 = uimenu(hcmenu, 'label', 'Delete', 'callback', {@locDeleteSaccPoint,saccLine});
	set(saccLine,'uicontextmenu',hcmenu);
else
	set(saccLine, 'XData', xdata(saccInds), 'YData', ydata(saccInds))
end

% --- Callback to delete a point on a saccade Line --------------------------------
function locDeleteSaccPoint(src, evt, hSaccLine)
% figure handle struct
handles = guidata(gcbf);

pt = get(gca,'CurrentPoint');
x = pt(1,1);
y = pt(1,2);
xdata = get(hSaccLine, 'XData');
ydata = get(hSaccLine, 'YData');
% get the xSacc, ySacc points on the sacc data line closest to the cursor
[xSacc,ySacc,ind] = findNearestPoint(x, y, xdata, ydata);

% remove the point on the line from the data
xdata = xdata(xdata~=xSacc);
ydata = ydata(ydata~=ySacc);

% reset the data line
set(hSaccLine, 'XData', xdata);
set(hSaccLine, 'YData', ydata);

% --- findNearestPoint ---------------------------------------
function [xDataPoint yDataPoint idx] = findNearestPoint(xPoint, yPoint, xdata, ydata)
A = [xdata(:) ydata(:)];
goal = [xPoint yPoint];
[~,idx] = min(sum(abs(bsxfun(@minus, A, goal)), 2));

xDataPoint  = A(idx,1);
yDataPoint = A(idx,2);


% --- Executes on button press in pbSaveResults -----------------------------------------------
function pbSaveResults_Callback(hObject, eventdata, handles)
% hObject    handle to pbCalcSaccades (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with handles and user data (see GUIDATA)

% save results
handles.blnSaved = locSaveResults(handles);

guidata(hObject,handles);

% ------------ Save results in a text file ---------------------------
function blnSaved = locSaveResults(handles)
% input: handles = figure's handle graphics struc
blnSaved = false;
% format results into a dataset (for easy input/output into tab delimited text files)

ds = locFormatResults(handles);
if ~isempty(ds),
	
    
    T = array2table(ds);
    prop_names= {'r_start_t'; 'r_start_pos'; 'r_stop_t'; 'r_stop_pos'; ...
                 'r_peak_vel'; 'r_peak_vel_t'; 'r_peak_acc'; 'r_peak_acc_t'; ...
                 'l_start_t'; 'l_start_pos'; 'l_stop_t'; 'l_stop_pos'; ...
                 'l_peak_vel'; 'l_peak_vel_t'; 'l_peak_acc'; 'l_peak_acc_t'};

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
end




% -------------- format the results of the analysis for text file output ----------
function ds = locFormatResults(h)
% input: h = handle to figure guidata struc
% output: ds = dataset of results
         
% TO DO:
% 1. convert time to sample number for compat with old saccade analyses tools
% 2. limit pos,vel,acc output to two decimal places (prob in findpeak fn)


ds=[];
% saccade line handles
rhSaccStartLine = findobj(h.axes1, 'Tag', 'rhSaccStartLine');
rhSaccStopLine = findobj(h.axes1, 'Tag', 'rhSaccStopLine');
lhSaccStartLine = findobj(h.axes1, 'Tag', 'lhSaccStartLine');
lhSaccStopLine = findobj(h.axes1, 'Tag', 'lhSaccStopLine');

% saccade x & y data
% limit to two dec places?
%old_digits = digits(3);
rhSaccStartX = get(rhSaccStartLine, 'XData');
rhSaccStartY = get(rhSaccStartLine, 'YData');
rhSaccStopX = get(rhSaccStopLine, 'XData');
rhSaccStopY = get(rhSaccStopLine, 'YData');
lhSaccStartX = get(lhSaccStartLine, 'XData');
lhSaccStartY = get(lhSaccStartLine, 'YData');
lhSaccStopX = get(lhSaccStopLine, 'XData');
lhSaccStopY = get(lhSaccStopLine, 'YData');

% Info from the rbboxes
for i=1:length(h.rbboxes),
	boxUd = get(h.rbboxes(i),'userdata');	% box user data (has comments)
	boxXlims = get(h.rbboxes(i), 'XData');
	boxXmin = min(boxXlims);
	boxXmax = max(boxXlims);
	boxYlims = get(h.rbboxes(i), 'YData');
	boxYmin = min(boxYlims);
	boxYmax = max(boxYlims);
	
	% find the saccades within the limits of the box
    rStartX = rhSaccStartX(rhSaccStartX >= boxXmin & rhSaccStartX <= boxXmax);
	rStartY = rhSaccStartY(rhSaccStartX >= boxXmin & rhSaccStartX <= boxXmax);
	lStartX = lhSaccStartX(lhSaccStartX >= boxXmin & lhSaccStartX <= boxXmax);
	lStartY = lhSaccStartY(lhSaccStartX >= boxXmin & lhSaccStartX <= boxXmax);

	rStopX = rhSaccStopX(rhSaccStopX >= boxXmin & rhSaccStopX <= boxXmax);
	rStopY = rhSaccStopY(rhSaccStopX >= boxXmin & rhSaccStopX <= boxXmax);
	lStopX = lhSaccStopX(lhSaccStopX >= boxXmin & lhSaccStopX <= boxXmax);
	lStopY = lhSaccStopY(lhSaccStopX >= boxXmin & lhSaccStopX <= boxXmax);

	% at least one startX, stopX, startY & stopY
	if length(rStartX) >= 1 && length(lStartX) >= 1 && length(rStopX) >= 1 && length(lStopY) >= 1,
		[rPeakVel, rPeakVelT] = findpeak(h.data.rhv, h.data.t, rStartX(1), rStopX(1));
		[lPeakVel, lPeakVelT] = findpeak(h.data.lhv, h.data.t, lStartX(1), lStopX(1));
		[rPeakAcc, rPeakAccT] = findpeak(h.data.rha, h.data.t, rStartX(1), rStopX(1));
		[lPeakAcc, lPeakAccT] = findpeak(h.data.lha, h.data.t, lStartX(1), lStopX(1));

		% add info to the dataset
		dsTmp = [ rStartX(1),  rStartY(1), rStopX(1), rStopY(1), ...
                  rPeakVel, rPeakVelT, rPeakAcc, rPeakAccT, ...
                  lStartX(1), lStartY(1), lStopX(1),lStopY(1), ...
                  lPeakVel, lPeakVelT, lPeakAcc, lPeakAccT ];
	
		ds = vertcat(ds, dsTmp);
    end
end
ds = jjround(ds,3);
%digits(old_digits);

% --- jjround ---------------------------------------------
function out = jjround(in, prec)

if isempty(prec), prec=0; end

in = in .* 10^prec;
in = round(in);
out = in ./ 10^prec;


% --- findpeak ---------------------------------------------
function [peak, tPeak] = findpeak( dataVec, timeVec, tMin, tMax )
% find the peak (max absolute value) in the data vector during the time interval
% specified by tMin and tMax

%old_digits=digits(3);

% extract time interval of interest from dataVec and timeVec
dataInterval = dataVec(timeVec>=tMin & timeVec<=tMax);
timeInterval = timeVec(timeVec>=tMin & timeVec<=tMax);

% find the abs max data value & index
[peakAbs, peakInd] = max(abs(dataInterval));

% return values
peak = dataInterval(peakInd);
tPeak = timeInterval(peakInd);
%digits(old_digits);

% --- Find nearest posEye data point
% FIXME use pdist for Euclidean, but for now...
function idx = locFindNearestEyePosPoint(x,h)
xd = h.t;
[~,idx] = min(abs(xd-x));


% --- Find nearest saccStart data point
% FIXME use pdist for Euclidean, but for now...
function [xSacc,ySacc,imin] = locFindNearestPoint(x,y,h,str)
hnd = h.(['dotsSacc' str]);
xd = cell2mat(get(hnd,'xdata')); % FIXME do this "separate dots" scheme for RAS too?
yd = cell2mat(get(hnd,'ydata'));
[~,imin] = min(abs(xd-x));
xSacc = xd(imin);
ySacc = yd(imin);


% --- Callback for delete of trialxxMarkCircle/Square
function locButtonDownUndoTrialMark(src,evnt)
% src - the object that is the source of the event
% evnt - empty for this property
sel_typ = get(gcbf,'SelectionType');
switch sel_typ
    case 'normal' % User clicked left-mouse button
        % ignore
    case 'extend' %User did a shift-click
        % ignore
    case 'alt' % User did a right-click
        delete(src);
    otherwise
        % ignore
end %switch


% --- Callback for saccStop dots
% FIXME consolidate with saccStart callback like velLocMin
function locButtonDownSaccStop(src,evnt)
% src - the object that is the source of the event
% evnt - empty for this property
h = guidata(gcbf);
strTrial = get(h.txtTrialNum,'str');
sel_typ = get(gcbf,'SelectionType');
pt = get(gca,'CurrentPoint');
x = pt(1,1);
y = pt(1,2);
[xSacc,ySacc,ind] = locFindNearestPoint(x,y,h,'Stop');
switch sel_typ
    case 'normal' % User clicked left-mouse button
        hold on
        hCircle = plot(xSacc,ySacc,'ko','markersize',11,'tag',sprintf('trial%02dmark_stop_findsaccs',str2double(strTrial)));
        ud.sampnum = find(h.t==xSacc);
        set(hCircle,'userdata',ud);
        set(hCircle,'buttondownfcn',@locButtonDownUndoTrialMark,'color',0.55*[1 0 0]);
    case 'extend' %User did a shift-click
        % ignore
    case 'alt' % User did a right-click
        % ignore
    otherwise
        % ignore
end %switch


% --- Callback for velLocMin dots
function locButtonDownVelLocMin(src,evnt)
% src - the object that is the source of the event
% evnt - empty for this property
h = guidata(gcbf);
strTrial = get(h.txtTrialNum,'str');
sel_typ = get(gcbf,'SelectionType');
pt = get(gca,'CurrentPoint');
x = pt(1,1);
y = pt(1,2);
idx = locFindNearestEyePosPoint(x,h);
switch sel_typ
    case 'normal' % User clicked left-mouse button
        hold on
        hCircle = plot(h.t(idx),h.posEye(idx),'go','markersize',11,'tag',sprintf('trial%02dmark_start_manual',str2double(strTrial)));
        ud.sampnum = idx;
        set(hCircle,'userdata',ud);
        set(hCircle,'color',0.55*[0 1 0]);
        set(hCircle,'buttondownfcn',@locButtonDownUndoTrialMark);
    case 'extend' % User did a shift-click
        % ignore
    case 'alt' % User did a right-click
        hold on
        hCircle = plot(h.t(idx),h.posEye(idx),'rs','markersize',9,'tag',sprintf('trial%02dmark_stop_manual',str2double(strTrial)));
        ud.sampnum = idx;
        set(hCircle,'userdata',ud);
        set(hCircle,'color',0.55*[1 0 0]);
        set(hCircle,'buttondownfcn',@locButtonDownUndoTrialMark);
    otherwise
        % ignore
end %switch


% --- Callback for saccStart dots
function locButtonDownSaccStart(src,evnt)
% src - the object that is the source of the event
% evnt - empty for this property
h = guidata(gcbf);
strTrial = get(h.txtTrialNum,'str');
sel_typ = get(gcbf,'SelectionType');
pt = get(gca,'CurrentPoint');
x = pt(1,1);
y = pt(1,2);
[xSacc,ySacc] = locFindNearestPoint(x,y,h,'Start');
switch sel_typ
    case 'normal' % User clicked left-mouse button
        hold on
        hCircle = plot(xSacc,ySacc,'ko','markersize',11,'tag',sprintf('trial%02dmark_start_findsaccs',str2double(strTrial)));
        ud.sampnum = find(h.t==xSacc);
        set(hCircle,'userdata',ud);
        set(hCircle,'buttondownfcn',@locButtonDownUndoTrialMark,'color',0.55*[0 1 0]);
    case 'extend' %User did a shift-click
        % ignore
    case 'alt' % User did a right-click
        % ignore
    otherwise
        % ignore
end %switch


% --- Append events to trials structure
function h=locAppendEventStructure(h)
trial = struct([]);
for i = 1:h.numTrials
    ud = get(h.linesTrialStart(i),'userdata');
    trial(i).note = ud.note;
    trial(i).events = ud.events;
end
h.trials = trial;
guidata(h.output,h);


% --- Screencapture as PNG
function strPath = locDoPrintFig()
% FIXME with better path handling (quick fix after dmg disk space issue)
[blnPathOkay,strPath,strFile,h] = mtbipathokay(gcbf);
if blnPathOkay
    tnum = str2double(get(h.txtTrialNum,'str'));
    strName = sprintf('%s_%s_%s_trial%02d.png',strFile,h.strEyeDir,h.strTestname,tnum);
    strPNG = fullfile(strPath,strName);
    screencapture(gcbf,[],strPNG);
    fprintf('\nScreenshot at "%s"',strPNG)
else
    uiwait(msgbox('Could not make directory for PNG to save.','Permissions Problem?','modal'));
end


% --- Save FIG file
function blnDone = locSaveFigure(h)
blnDone = false;
% extract default filename
h.strTitle = get(h.fnameH,'String');
ind = findstr(h.strTitle,'.');
strInit = lower(h.strTitle(1:ind-1));
strName = sprintf('%s_%s_%s.fig',strInit); %%%%%%%%%,h.strEyeDir); %,h.strTestname); <-------

% default location
%strFileFig = fullfile(h.strResultPath,'figures','catalog',strName);
[fn, pn] = uiputfile;
if pn==0
    return
else
    h.strResultPath = pn; 
    savefig([pn fn])
    %strFileFig = fullfile(h.strResultPath,'figures','catalog',strName);
    return
end

% confirm user wants to save
butName = locSavDlg( strFileFig );
switch butName,
	case 'Save',
		[blnDidSeq,strFileSeq] = sequesterfile(strFileFig,'obsolete');
		hgsave(h.output,strFileFig);
		blnDone = true;
	case 'Save as...',
        olddir=pwd;
        cd(pn)
		savefig();		% FIX this fcn doesn't let us know if something was saved or not (user could have 'canceled')
		cd(olddir)
        %blnDone = true;  to be on the safe side asssume it has not been saved
end
%fprintf('\nWrote "%s"\n',strFileFig)

% ------ ask to save or save as... file if it already exits --------------
function butName = locSavDlg(strFile)
% input strfile = name of the file (including path) to check
%	output a string indicating which button was selected. One of 'Save', 'Save as...' or 'Cancel'
% does file already exist?
strExist = 'does not';
if exist(strFile,'file'),
	strExist = 'does';
end
strFile = strrep(strFile, '_', '\_');	% add backslash in preparation of tex interpretation 
% inform user if it exists or not and confirm saving
strMsg = {[strFile '{\color{blue} ' strExist  '} exist.'] ...
	'Save? (old version sent to obsolete folder)'};
butSave = 'Save'; butSaveAs = 'Save as...'; butCancel = 'Cancel'; 
options.Default = butSave;
options.Interpreter = 'tex';
butName  = questdlg(strMsg,'Save Verification',butSave, butSaveAs, butCancel, options);


% --- Unmark any saccades not in a rbbox
function locDeleteStartStopSaccMarksNotInBox(h)
% Get left/right (time index) bounds for all boxes
indBoxBounds = mgsgetboxinds(h);
% Delete individual marks not in box
locDeleteMarkNotInBox('start',indBoxBounds,h);
locDeleteMarkNotInBox('stop',indBoxBounds,h);


% --- Unmark any saccades in a blink box
function hBoxesBlink = locDeleteStartStopSaccMarksInBlinkBox(h)
% Get left/right (time index) bounds for blink boxes
[indBlinkBoxBounds,hBoxesBlink] = mtbigetblinkboxinds(h);
% Delete individual marks in blink boxes
locDeleteMarkInBox('start',indBlinkBoxBounds,h);
locDeleteMarkInBox('stop',indBlinkBoxBounds,h);


% --- Delete individual sacc start/stop marks not in box
function locDeleteMarkNotInBox(str,indBoxBounds,h)
hAllMarks = findobj(h.output,'-regexp','Tag',['trial..mark_' str '_.*']);
if isempty(indBoxBounds)
    delete(hAllMarks); % no boxes, no bounds...so delete all marks
    return
end
X = get(hAllMarks,'xdata');
if iscell(X)
    inds = round(cell2mat(X)*h.sampFreq);
else
    inds = round(X*h.sampFreq);
end
indsNotInBox = mgsnotinbox(indBoxBounds,inds);
delete(hAllMarks(indsNotInBox));


% --- Delete individual sacc start/stop marks in box
function locDeleteMarkInBox(str,indBoxBounds,h)
hAllMarks = findobj(h.output,'-regexp','Tag',['trial..mark_' str '_.*']);
if isempty(indBoxBounds)
    return
end
X = get(hAllMarks,'xdata');
if iscell(X)
    inds = round(cell2mat(X)*h.sampFreq);
else
    inds = round(X*h.sampFreq);
end
indsInBox = mtbiinbox(indBoxBounds,inds);
delete(hAllMarks(indsInBox));


% --- Round to nearest sample pt
function out = locRoundNearestSample(xd,fs)
if iscell(xd)
    xd = cell2mat(xd);
end
out = round(xd*fs);


% --- Populate "target diamond" objects with useful userdata
function locPopulateBoxesWithSaccs(h)
% get start circle handles (marked start saccades)
hTrialMarkStarts = findobj(h.output,'-regexp','Tag','^trial.*_start_.*');
% get stop circle handles (marked stop saccades)
hTrialMarkStops = findobj(h.output,'-regexp','Tag','^trial.*_stop_.*');

% why sort?
%[iStarts,iSortStart] = sort(locRoundNearestSample(get(hTrialMarkStarts,'xdata'),h.sampFreq));
%[iStops,iSortStop] = sort(locRoundNearestSample(get(hTrialMarkStops,'xdata'),h.sampFreq));
%hTrialMarkStarts = hTrialMarkStarts(iSortStart);
%hTrialMarkStops = hTrialMarkStops(iSortStop);

% loop through each target diamond
for diam = 1:length(h.diamondsTarget)
    set(h.diamondsTarget(diam),'markerfacecolor','r');
    udTargDiamond = get(h.diamondsTarget(diam),'userdata');
	% loop through each rbBox
	for idxBox = 1:length(udTargDiamond.hBox),
 		hb = udTargDiamond.hBox(idxBox);	% this box handle
		set(hb,'color','r');
        udBox = get(hb,'userdata');
%        udBox.hSaccStarts = locGetBoxSaccs(hTrialMarkStarts,iStarts,udBox);
%        udBox.hSaccStops = locGetBoxSaccs(hTrialMarkStops,iStops,udBox);
        udBox.hSaccStarts = locGetBoxSaccs(hTrialMarkStarts,hb);
        udBox.hSaccStops = locGetBoxSaccs(hTrialMarkStops,hb);
        set(hb,'userdata',udBox); % stash sacc start/stop handles in userdata of rbbox
%{
        for i = 1:length(udBox.hSaccStarts)
            ud = get(udBox.hSaccStarts(i),'userdata');
            ud.hDiamondTarget = h.diamondsTarget(diam);
            set(udBox.hSaccStarts(i),'userdata',ud);
        end
        for i = 1:length(udBox.hSaccStops)
            ud = get(udBox.hSaccStops(i),'userdata');
            ud.hDiamondTarget = h.diamondsTarget(diam);
            set(udBox.hSaccStops(i),'userdata',ud);
        end
%}
        set(hb,'color','k');
    end
    set(h.diamondsTarget(diam),'markerfacecolor','none'); 
end

% --- Get/tag saccades for this rubberband box (rbbox)
function hSaccs = locGetBoxSaccs(hTrialMarks,hBox)
xbox = get(hBox,'xdata');	% box xdata
xMin = min(xbox);		% box left side
xMax = max(xbox);		% box right side
ybox = get(hBox,'ydata');	% y - top & bottom
yMin = min(ybox);
yMax = max(ybox);

markXdata = get(hTrialMarks,'xdata');
markYdata = get(hTrialMarks,'ydata');
% indices of saccades in the box
iSaccs = find([markXdata{:}]'>=xMin & [markXdata{:}]'<=xMax & ...
				[markYdata{:}]' >= yMin &  [markYdata{:}]' <= yMax);
%disp('Check that adding the y dimensions finds the correct saccades.')
%iSaccs = find([xdata{:}] > get(udBox,'xdata') & 
%udDiamTarg = get(udBox.hDiamondTarget,'userdata');

hSaccs = hTrialMarks(iSaccs);
%{
for i = 1:length(iSaccs)
    ind = iSaccs(i);
    hSaccs = [hSaccs hTrialMarks(ind)];
    % retag the saccade with the trial and target number - why?
    strTag = get(hTrialMarks(ind),'tag');
    casSplit = strsplit('_',strTag);
    casSplit{1} = sprintf('trial%02d@target%02d',udDiamTarg.trialNum,udDiamTarg.targetNum);
    strTagNew = strjoin(casSplit,'_');
    set(hTrialMarks(ind),'tag',strTagNew);
end
%}



% --- Get info embedded in target diamonds
function locProcessTargetDiamondInfo(h)
locDeleteStartStopSaccMarksNotInBox(h);
locPopulateBoxesWithSaccs(h);


% --- Initial sweep to "left click" all saccStart/Stops, so we only have to "right click" turn some off
function locPreSelectFoundSaccs(h)
locPreMark(h,'Start',0.55*[0 1 0]);
locPreMark(h,'Stop',0.55*[1 0 0]);


% --- Help user by premarking all saccade pts from findsaccs routine (puts open circles around dots)
function locPreMark(h,str,c)
axes(h.axTrial);
hold on;
inds = h.(['sacc' str 's']);
h.circlesMarked = nan*ones(length(inds),1); %% clears out old marks (therefore it will only contain the list generated by the last call to this function which is only for the 'stop' saccades. Warning do not use this variable. Its name is not what it suggests and is probably not updated as saccades are marked and unmarked.)
for j = 1:length(inds)
    ind = inds(j);
    h.circlesMarked(j) = plot(h.t(ind),h.posEye(ind),'ko','markersize',11,'tag',sprintf('trialXXmark_%s_findsaccs',lower(str)));
    ud.sampnum = ind;
    set(h.circlesMarked(j),'userdata',ud);
    set(h.circlesMarked(j),'buttondownfcn',@locButtonDownUndoTrialMark,'color',c);
end
% fprintf('\n%s had %d %s inds',h.strEyeDir,length(inds),str)
guidata(h.output,h);


% --- Callback for edit note box
function edNote_Callback(hObject, eventdata, h)
% hObject    handle to edNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edNote as text
%        str2double(get(hObject,'String')) returns contents of edNote as a double
trial = str2double(get(h.txtTrialNum,'string'));
s = get(h.linesTrialStart(trial),'userdata');
str = get(h.edNote,'string');
if isempty(str), str = ''; end % FIXME unbeatable bug
s.note = str;
set(h.linesTrialStart(trial),'userdata',s);


% --- Executes during object creation, after setting all properties.
function edNote_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%{
% --- Callback for buttondown on rubberband box
function locButtonDownRubberbandBox(src,evnt)
% src - the object that is the source of the event
% evnt - empty for this property
h = guidata(gcbf);
strTrial = get(h.txtTrialNum,'str');
sel_typ = get(gcbf,'SelectionType');
switch sel_typ
    case 'normal' % User clicked left-mouse button
        % ignore
    case 'extend' %User did a shift-click
        % ignore
    case 'alt' % User did a right-click
        delete(src);
    otherwise
        % ignore
end %switch

%}

% --------- Create uicontextmenu for a diamondtarget -------------------------
function hdt = locCreateDiamMenu(hdt)
% add the uimenu to a diamondtarget line object
hcmenu = uicontextmenu;
uimenu(hcmenu, 'label', 'Highlight', 'callback', {@menuDiamHilite,hdt});
uimenu(hcmenu, 'label', 'Unhighlight', 'callback', {@menuDiamUnHilite,hdt});
set(hdt, 'uicontextmenu', hcmenu);

% -------- 'Highlight' diamond target menu callback -------------------------------
function menuDiamHilite(src,evt,hdt)
locSetdtandboxColor(hdt,'r');

% -------- 'UnHighlight' diamond target menu callback -------------------------------
function menuDiamUnHilite(src,evt,hdt)
locSetdtandboxColor(hdt,'k');

% ----------- set diamond target and rbboxes to specific color -------------------
function locSetdtandboxColor(hdt,color)
set(hdt,'color',color);
% loop through each rbbox
hdtud = get(hdt,'userdata');
for i=1:length(hdtud.hBox),
	set(hdtud.hBox(i),'color',color);
end


% --- Callback for buttondown on diamond target
function locButtonDownDiamondTarget(hDiamTarg,evnt)
% hDiamTarg - the object that is the source of the event
% evnt - empty for this property
h = guidata(gcbf);
strTrial = get(h.txtTrialNum,'str');
sel_typ = get(gcbf,'SelectionType');
udDiamTarg = get(hDiamTarg,'userdata');
switch sel_typ
    case 'normal' % User clicked left-mouse button
    	hBox = locDoRubberbandBox(hDiamTarg); % creates the box and returns its handle
        udDiamTarg.hBox = [udDiamTarg.hBox hBox]; 	% append it to the list
%    case 'extend' %User did a shift-click
%        udDiamTarg.hBox = locDoRubberbandBox(hDiamTarg); % this updates guidata with additions
%        set(udDiamTarg.hBox,'color',rgb('mgsUnsure'));
%        udBox = get(udDiamTarg.hBox,'userdata');
%        udBox.boxcomment = {'unsure'};
%        set(udDiamTarg.hBox,'userdata',udBox);
%    case 'alt' % User did a right-click
%        if isfield(udDiamTarg,'hBox')
%            indToss = ismember(h.rbboxes,udDiamTarg.hBox);
%            h.rbboxes(indToss) = []; % remove it from main guidata set
%            delete(udDiamTarg.hBox); % delete object
%            udDiamTarg.hBox = []; % empty placeholder
%            guidata(h.output,h);
%        end
    otherwise
        % ignore
end %switch
set(hDiamTarg,'userdata',udDiamTarg);


% --- Draw rubberband box around sacc pairs
function hrb = locDoRubberbandBox(hDiamTarg)
h = guidata(gcbf);
set(gcbf,'Pointer','crosshair');

hold on;
k = waitforbuttonpress;
set(gcbf,'Pointer','arrow');

point1 = get(h.axes1,'CurrentPoint');	% button down detected
xywh = rbbox;                           % return figure units
point2 = get(h.axes1,'CurrentPoint');	% button up detected
point1 = point1(1,1:2);                 % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);                % calculate locations
offset = abs(point1-point2);            % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

% if box has no dimensions (often happens ~ weird mouse click detection), abort
if offset < 0.01,
	hrb=[];
	strMsg = 'Zero width or height box ignored.';
    warndlg(strMsg,'Improper rubberband box click','modal');
	return;
end

%udDiamTarg = get(hDiamTarg,'userdata');
% create the box
hrb = plot(x,y,'k','linewidth',2);          % draw box around selected region
set(hrb, 'Tag', 'rbBox');
%set(hrb,'buttondownfcn',@locButtonDownRubberbandBox);	% serves no purpose
draggable(hrb,'none',[-inf inf -inf inf]); % no drag constraints
udBox.boxcomment = {'none'};

set(hrb,'userdata',udBox);
% create context menu to change the box's comment userdata
hcmenu = uicontextmenu;
item1 = uimenu(hcmenu, 'Label', 'Comment', 'Callback', {@locBoxComment,hrb});
item2 = uimenu(hcmenu, 'label', 'Delete', 'callback', {@locDeleteRBBox,hrb});
set(hrb,'uicontextmenu',hcmenu);

h.rbboxes = [h.rbboxes; hrb];	% save the box handle in figure's guidata (make sure it gets deleted if the box is deleted)
guidata(h.output,h);

% ----------- Callback for delete menu item of RB Boxes --------------------------------
function locDeleteRBBox(src,evt,hbox)
ud = get(hbox,'userdata');		% hbox's userdata
% find and remove this rbbox in the figure's handle structure
handles = guidata(gcbf);
handles.rbboxes = handles.rbboxes(handles.rbboxes ~= hbox);

% delete this hbox
delete(hbox);
% reset handle struct
guidata(handles.figure1, handles)



% --- Callback for comment menu item of rubberband box
function locBoxComment(varargin)
hrb = varargin{3};
ud = get(hrb,'userdata');
cas = ud.boxcomment;
ud.boxcomment = inputdlg({'boxcomment'},'name',1,cas);
if ~isempty(ud.boxcomment)
    set(hrb,'userdata',ud);
end



% --- Executes during object creation, after setting all properties.
function txtDesiredDelta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDesiredDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Event handler for "after zoom" action -------------------
function zoomPostCallback(obj,evt)
%zoom(evt,'off');
newLim = get(evt.Axes,'XLim');	% only event data is handle of axes being zoomed
%disp(sprintf('The new X-Limits are [%.2f %.2f].',newLim))


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'SelectionType'),'alt') % right-click event
	disp('ctrl-click of figure does nothing')
%    hLinesTarg2Box = findobj(handles.output,'-regexp','Tag','lineTargetToBox');
%    if isempty(hLinesTarg2Box)
%        locDrawTargetBoxAssociations(handles);
%    else
%        delete(hLinesTarg2Box);
%    end
end


% --- Draw target/box associations
function locDrawTargetBoxAssociations(h)
% Get all target diamonds for this trial
trialNum = str2double(get(h.txtTrialNum,'str'));
UDs = get(h.diamondsTarget,'userdata');
if ~iscell(UDs)
    casTrialNums = {UDs.trialNum};
else
    casTrialNums = cellfun(@(x)x.trialNum,UDs,'uni',false);
end
trialNums = cell2mat(casTrialNums);
trialMask = (trialNums==trialNum);
hDTargs = h.diamondsTarget(trialMask);
% For each visible target diamond, get its associated rbbox
% ...and draw thick, semi-transparent line from center of diamond to center of box
for i = 1:length(hDTargs)
    hdt = hDTargs(i);
    xdt = get(hdt,'xdata');
    ydt = get(hdt,'ydata');
    ud = get(hdt,'userdata');
    hBox = ud.hBox;		% hBox fix - make it able to handle a vector of hboxes
    if isempty(hBox)
        continue;
    end
    if length(hBox)>1
        disp(sprintf('TRIAL %d: why more than one (%d) boxes associated with target @ [%.3f %.1f]',trialNum,length(hBox),xdt,ydt))
        continue;
    end
    if ~ishandle(hBox)
        disp(sprintf('TRIAL %d: invalid handle for target @ [%.3f %.1f]',trialNum,xdt,ydt))
        continue;
    end
    % get center of box
    xcob = mean(unique(get(hBox,'xd')));
    ycob = mean(unique(get(hBox,'yd')));
    % draw thick association line
    hLineTarg2Box = line([xcob xdt],[ycob ydt]);
    set(hLineTarg2Box,'linewidth',8,'color','m','tag','lineTargetToBox');
    % FIXME maybe assign callback to buttondownfcn on these association lines?
end

% --------------- verify close figure -----------------------------------
function blnClose = locVerifyClose(handles)
% Are you sure you want to close? Info has not been saved yet.
blnClose = false;
butName = 'Yes';
if ~handles.blnSaved,
	% warning about closing
	butName  = questdlg('Data may not have been saved yet. Are you sure you want to close?','Close Figure');
end
if(strcmp(butName,'Yes')),
	% yes
	blnClose = true;
end	


function edAScale_Callback(hObject, eventdata, handles)
% hObject    handle to edAScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edAScale as text
%        str2double(get(hObject,'String')) returns contents of edAScale as a double
accScale = str2double(get(hObject,'String'));
aLine = findobj(handles.axes1, 'Tag', 'rhAccLine');
set(aLine, 'YData', handles.data.rha*accScale);
aLine = findobj(handles.axes1, 'Tag', 'lhAccLine');
set(aLine, 'YData', handles.data.lha*accScale);


% --- Executes during object creation, after setting all properties.
function edAScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edAScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on edit box change in edVScale.
function edVScale_Callback(hObject, eventdata, handles)
% hObject    handle to edVScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edVScale as text
%        str2double(get(hObject,'String')) returns contents of edVScale as a double
velScale = str2double(get(hObject,'String'));
vLine = findobj(handles.axes1, 'Tag', 'rhVelLine');
set(vLine, 'YData', handles.data.rhv*velScale);
vLine = findobj(handles.axes1, 'Tag', 'lhVelLine');
set(vLine, 'YData', handles.data.lhv*velScale);



% --- Executes during object creation, after setting all properties.
function edVScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edVScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on edit box change in edVScale.
function edSquelch_Callback(hObject, eventdata, h)
% hObject    handle to edVScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edVScale as text
%        str2double(get(hObject,'String')) returns contents of edVScale as a double
locApplyScale(h);


% --- Executes during object creation, after setting all properties.
% hObject    handle to edVScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
function edSquelch_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edNumTargPos_Callback(hObject, eventdata, handles)
% hObject    handle to edNumTargPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edNumTargPos as text
%        str2double(get(hObject,'String')) returns contents of edNumTargPos as a double


% --- Executes during object creation, after setting all properties.
function edNumTargPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edNumTargPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edNumTargNeg_Callback(hObject, eventdata, handles)
% hObject    handle to edNumTargNeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edNumTargNeg as text
%        str2double(get(hObject,'String')) returns contents of edNumTargNeg as a double


% --- Executes during object creation, after setting all properties.
function edNumTargNeg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edNumTargNeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edMeanTdur_Callback(hObject, eventdata, handles)
% hObject    handle to edMeanTdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edMeanTdur as text
%        str2double(get(hObject,'String')) returns contents of edMeanTdur as a double


% --- Executes during object creation, after setting all properties.
function edMeanTdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edMeanTdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edStdTdur_Callback(hObject, eventdata, handles)
% hObject    handle to edStdTdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edStdTdur as text
%        str2double(get(hObject,'String')) returns contents of edStdTdur as a double


% --- Executes during object creation, after setting all properties.
function edStdTdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edStdTdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edMeanErr_Callback(hObject, eventdata, handles)
% hObject    handle to edMeanErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edMeanErr as text
%        str2double(get(hObject,'String')) returns contents of edMeanErr as a double


% --- Executes during object creation, after setting all properties.
function edMeanErr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edMeanErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edStdErr_Callback(hObject, eventdata, handles)
% hObject    handle to edStdErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edStdErr as text
%        str2double(get(hObject,'String')) returns contents of edStdErr as a double


% --- Executes during object creation, after setting all properties.
function edStdErr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edStdErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uiSaveFigure_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uiSaveFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.blnSaved = locSaveFigure(handles);
guidata(hObject,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%if locVerifyClose(handles),
	delete(hObject);
%end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbDoubleLeft.
function pbDoubleLeft_Callback(hObject, eventdata, handles)
% hObject    handle to pbDoubleLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axLims = get(handles.axes1, 'XLim');
width = abs(diff(axLims));
set(handles.axes1, 'XLim', [axLims(1)-width axLims(1)]);
updateEdAxLims(handles)


% --- Executes on button press in pbLeft.
function pbLeft_Callback(hObject, eventdata, handles)
% hObject    handle to pbLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axLims = get(handles.axes1, 'XLim');
width = abs(diff(axLims));
set(handles.axes1, 'XLim', axLims-width*0.2);
updateEdAxLims(handles)


function edAxMin_Callback(hObject, eventdata, handles)
% hObject    handle to edAxMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edAxMin as text
newVal = str2double(get(hObject,'String')); % returns contents of edAxMin as a double
axLims = get(handles.axes1, 'XLim');
set(handles.axes1, 'XLim', [newVal axLims(2)]);


% --- Executes during object creation, after setting all properties.
function edAxMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edAxMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edAxMax_Callback(hObject, eventdata, handles)
% hObject    handle to edAxMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edAxMax as text
%        str2double(get(hObject,'String')) returns contents of edAxMax as a double
newVal = str2double(get(hObject,'String')); % returns contents of edAxMin as a double
axLims = get(handles.axes1, 'XLim');
set(handles.axes1, 'XLim', [axLims(1) newVal]);


% --- Executes during object creation, after setting all properties.
function edAxMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edAxMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Update the edAxMin and max values
function updateEdAxLims(handles)
% get the axes x limits
xlims = get(handles.axes1, 'Xlim');

% update the text in the edit boxes
set(handles.edAxMin, 'String', num2str(xlims(1)))
set(handles.edAxMax, 'String', num2str(xlims(2)))

% --- Executes on button press in pbRight.
function pbRight_Callback(hObject, eventdata, handles)
% hObject    handle to pbRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axLims = get(handles.axes1, 'XLim');
width = abs(diff(axLims));
set(handles.axes1, 'XLim', axLims+width*0.2);
updateEdAxLims(handles)


% --- Executes on button press in pbDoubleRight.
function pbDoubleRight_Callback(hObject, eventdata, handles)
% hObject    handle to pbDoubleRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axLims = get(handles.axes1, 'XLim');
width = abs(diff(axLims));
set(handles.axes1, 'XLim', [axLims(2) axLims(2)+width]);
updateEdAxLims(handles)

% --- Executes on button press in pbZoomIn.
function pbZoomIn_Callback(hObject, eventdata, handles)
% hObject    handle to pbZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axLims = get(handles.axes1, 'XLim');
xCenter = mean(axLims);
newWidth = abs(diff(axLims))/2;
set(handles.axes1, 'XLim', [xCenter-newWidth/2 xCenter+newWidth/2]);
updateEdAxLims(handles)


function edCursor_Callback(hObject, eventdata, handles)
% hObject    handle to edCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edCursor as text
%        str2double(get(hObject,'String')) returns contents of edCursor as a double


% --- Executes during object creation, after setting all properties.
function edCursor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edCursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbZoomOut.
function pbZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to pbZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axLims = get(handles.axes1, 'XLim');
xCenter = mean(axLims);
newWidth = abs(diff(axLims))*2;
set(handles.axes1, 'XLim', [xCenter-newWidth/2 xCenter+newWidth/2]);
updateEdAxLims(handles)



function edAccStart_Callback(hObject, eventdata, handles)
% hObject    handle to edAccStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edAccStart as text
%        str2double(get(hObject,'String')) returns contents of edAccStart as a double


% --- Executes during object creation, after setting all properties.
function edAccStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edAccStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edAccStop_Callback(hObject, eventdata, handles)
% hObject    handle to edAccStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edAccStop as text
%        str2double(get(hObject,'String')) returns contents of edAccStop as a double


% --- Executes during object creation, after setting all properties.
function edAccStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edAccStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edVelStart_Callback(hObject, eventdata, handles)
% hObject    handle to edVelStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edVelStart as text
%        str2double(get(hObject,'String')) returns contents of edVelStart as a double


% --- Executes during object creation, after setting all properties.
function edVelStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edVelStart (see GCBO)
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


% --- Executes on selection change in popupVelAccel.
function popupVelAccel_Callback(hObject, eventdata, handles)
% hObject    handle to popupVelAccel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupVelAccel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupVelAccel


% --- Executes during object creation, after setting all properties.
function popupVelAccel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupVelAccel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in toggle_deblink.
function toggle_deblink_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_deblink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_deblink

if get(hObject,'Value')
	set(handles.rh_line, 'YData', handles.data.rhd);
	set(handles.lh_line, 'YData', handles.data.lhd);
	set(handles.rhv_line, 'YData', handles.data.rhvd * str2double(get(handles.edVScale, 'String')));
	set(handles.lhv_line, 'YData', handles.data.lhvd * str2double(get(handles.edVScale, 'String')));
%    handles.rh_line.YData  = handles.data.rhd;
%    handles.lh_line.YData  = handles.data.lhd;
%    handles.rhv_line.YData = handles.data.rhvd * str2double(handles.edVScale.String);
%    handles.lhv_line.YData = handles.data.lhvd * str2double(handles.edVScale.String);
else
	set(handles.rh_line, 'YData', handles.data.rh);
	set(handles.lh_line, 'YData', handles.data.lh);
	set(handles.rhv_line, 'YData', handles.data.rhv * str2double(get(handles.edVScale, 'String')));
	set(handles.lhv_line, 'YData', handles.data.lhv * str2double(get(handles.edVScale, 'String')));
%    handles.rh_line.YData  = handles.data.rh;
%    handles.lh_line.YData  = handles.data.lh;
%    handles.rhv_line.YData = handles.data.rhv * str2double(handles.edVScale.String);
%    handles.lhv_line.YData = handles.data.lhv * str2double(handles.edVScale.String);
end



% --- Executes on button press in showREvel.
function showREvel_Callback(hObject, eventdata, handles)
% hObject    handle to showREvel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showREvel
if get(hObject,'Value')
   set(handles.rhv_line, 'LineStyle', ':');
else
   set(handles.rhv_line, 'LineStyle','none');
end


% --- Executes on button press in showLEvel.
function showLEvel_Callback(hObject, eventdata, handles)
% hObject    handle to showLEvel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showLEvel
if get(hObject,'Value')
   set(handles.lhv_line, 'LineStyle', ':');
else
   set(handles.lhv_line, 'LineStyle','none');
end


% --- Executes on button press in showREpos.
function showREpos_Callback(hObject, eventdata, handles)
% hObject    handle to showREpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showREpos
if get(hObject,'Value')
   set(handles.rh_line, 'LineStyle', '-');
else
   set(handles.rh_line, 'LineStyle','none');
end


% --- Executes on button press in showLEpos.
function showLEpos_Callback(hObject, eventdata, handles)
% hObject    handle to showLEpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showLEpos
if get(hObject,'Value')
   set(handles.lh_line, 'LineStyle', '-');
else
   set(handles.lh_line, 'LineStyle','none');
end


% --- Executes on button press in showREacc.
function showREacc_Callback(hObject, eventdata, handles)
% hObject    handle to showREacc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showREacc
if get(hObject,'Value')
   set(handles.rha_line, 'LineStyle', '-.');
else
   set(handles.rha_line, 'LineStyle','none');
end


% --- Executes on button press in showLEacc.
function showLEacc_Callback(hObject, eventdata, handles)
% hObject    handle to showLEacc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showLEacc
if get(hObject,'Value')
   set(handles.lha_line, 'LineStyle', '-.');
else
   set(handles.lha_line, 'LineStyle','none');
end
