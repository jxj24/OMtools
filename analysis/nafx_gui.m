% nafx_gui.m: Graphical front-end for nafx.

% Written by:  Jonathan Jacobs
%              December 2001 - June 2018  (last mod: 06/21/18)

% 09/18/07:  Set "tau" field to "empty" when pos/vel lims are changed
% June 2018: Gutted and rewritten to send callbacks to "nafxAct".
%            Load data via call to "datstat"
%            Plot data via call to "nafxAct"

function nafx_gui()

global samp_freq
if isempty(samp_freq), samp_freq = 500; end

nafxFig = findme('NAFXwindow');
if nafxFig > 0
   figure(nafxFig)
   return
end

scrsize = get(0,'Screensize');
mBarHgt = 35;
maxHgt = scrsize(4)-mBarHgt;
maxWid = scrsize(3);
fontsize = 11;
fig_width = 250;
fig_height = 430;
tau = 'empty';
CR = char([10 13]);  % multi-platform carriage return
deg=char(176);       % pmstr=char(177); slash=char(47);
dps=[deg '/sec'];

% default values
posArray = '';
velArray = '';
posLim = 1;     % which entry in menu is selected
velLim = 1;
fovstat = 0;
dblplot = 3;
age_range = 1;
tau_vers2 = 1;

% Set the window position. Check if the window is already open.
% If not, then we will first try to read its last saved position from
% the pref file. If not, we will place it at its default position.
% Make sure that it will be drawn completely on the screen.
fErrFlag=0;
oldpath = pwd;
cd(findomprefs)
try    load nafxprefs.mat nafxXPos nafxYPos
catch, fErrFlag=1;
end

if fErrFlag  % default position
   nafxXPos = 20;
   nafxYPos = (maxHgt-fig_height)/2;
else
   % make sure that the window will be on the screen
   if nafxXPos<1,nafxXPos=1;end
   if nafxYPos<1,nafxYPos=1;end
   if (nafxYPos+fig_height)>maxHgt
      nafxYPos=maxHgt-fig_height;
   end
   if (nafxXPos+fig_width)>maxWid
      nafxXPos=maxWid-fig_width;
   end
end
cd(oldpath)

nafxFig = findme('NAFXwindow');
if ~ishandle(nafxFig)
   % create a new NAFX window
   linelist={0};
   h.guistate = '';
   nafxFig = figure('pos',[nafxXPos, nafxYPos, fig_width, fig_height],...
      'Resize', 'off','Name','NAFX v3.0 (Jun 2018)',...
      'NextPlot','new', 'NumberTitle', 'off','MenuBar', 'none',... 
      'CloseRequestFcn','nafxAct(''done'')',...
      'Tag','NAFXwindow','UserData', {h, linelist} );
   h.nafxFig = nafxFig;
else
   % bring existing one to front
   figure(nafxFig)
   return
   % or create new one?
   
end

h.EMDMwindow=findwind('EM Data');
if ~ishandle(h.EMDMwindow)
   %try to open it
   datstat('null')
   pause(0.5) % give sloooooooooooow MLWindow time to get its shit together
end
h.EMDMwindow=findwind('EM Data');
if ~ishandle(h.EMDMwindow)
   disp('Can not find the data manager window.')
   return
end
h.emHand = h.EMDMwindow.UserData;

% create the GUI
x_orig=8;
y_pos=fig_height-28;
figure(nafxFig)
uicontrol('Style','Frame','Pos',[3 y_pos-25 245 52],...
   'BackgroundColor',[0.5 0.5 0.5]);
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[x_orig y_pos+4 35 20],...
   'HorizontalAlignment','Right','FontSize',fontsize,...
   'String', 'Data: ');
h.availDataH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+32 y_pos+4 145 20],'FontSize',fontsize,...
   'String',[{'Get new data'};{'Refresh Menu'}], ...
   'HorizontalAlignment', 'center', 'Value', 1, ...
   'Tooltip','Load or select data',...
   'Callback','nafxAct(''selectAvailData'')');
h.datachanH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+169 y_pos+4 70 20],'FontSize',fontsize,...
   'String',[{'rh'};{'lh'};{'rv'};{'lv'}],'Value',1, ...
   'HorizontalAlignment', 'center',...
   'Tooltip','Select which channel to analyze');   

y_pos=y_pos-25;
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[x_orig y_pos+4 35 20],...
   'HorizontalAlignment','Right','FontSize',fontsize,...
   'String', 'Plot: ');
h.plotactionH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+32 y_pos+4 145 20],'FontSize',fontsize,...
   'String',[{'Choose Plot Action'};{'New Plot'};{'Grab Existing'}; ...
   {'Show Current'};{'Update Current'}], ...
   'HorizontalAlignment','center','Value', 1,'UserData',[], ...
   'Tooltip','Create, select or modify a plot',...
   'Callback','nafxAct(''plotaction'')');
h.nafxprepH = uicontrol('Style','Push','Units','Pixels',...
   'Position', [x_orig+172 y_pos+1 60 25],'FontSize',fontsize,...
   'Tooltip',['Select segment start, stop, minfov and maxfov points ' CR,...
   'using "zoomtool''s" cursor1 button and "nafxprep" will ' CR,...
   'create a position-centered array  and a velocity array.'],...
   'String','nafxprep', 'Callback','nafxprep');

y_pos=y_pos-25;
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[x_orig y_pos 95 20],...
   'HorizontalAlignment','Left','FontSize',fontsize,...
   'String','Subject age:');
h.nafx2snelH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+100 y_pos 140 20],'FontSize',fontsize,...
   'String',['SELECT AGE|Under 6 y.o.|6-12 y.o.|12+ to 40 y.o.|' ...
   '40+ to 60 y.o.|over 60 y.o.|Dog (any age)'], ...
   'HorizontalAlignment','center',...
   'Tooltip',['Select the age of the subject (human), or "dog"' CR,...
   'to convert NAFX to the proper Snellen acuity.'],...
   'Value',age_range);

y_pos=y_pos-34;
uicontrol('Style','Frame','Pos',[3 fig_height-300 245 216],...
   'BackgroundColor',[0.5 0.5 0.5]);
uicontrol('Style','text','Units','pixels',...
   'Position',[x_orig y_pos 95 25],...
   'HorizontalAlignment','Left','FontSize',fontsize,...
   'String','Position Array:');
h.posArrayNAFXH = uicontrol('Style','edit','Units','pixels',...
   'BackgroundColor','cyan','ForeGroundColor','black',...
   'Tooltip',['Enter the name of the position segment to analyze.' CR,...
   'Automatically filled in when you use "nafxprep"'],...
   'FontSize',fontsize,...
   'Position',[x_orig+100 y_pos 135 25], 'String',posArray);

y_pos=y_pos-30;
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[x_orig y_pos 95 25],...
   'HorizontalAlignment','Left',...
   'FontSize',fontsize,'String', 'Velocity Array:');
h.velArrayNAFXH = uicontrol('Style','edit','Units','pixels',...
   'BackgroundColor','cyan','ForeGroundColor','black',...
   'Tooltip',['Enter the name of the velocity segment to analyze.' CR,...
   'Automatically filled in when you use "nafxprep"'],...
   'FontSize',fontsize,...
   'Position',[x_orig+100 y_pos 135 25], 'String',velArray);

y_pos=y_pos-30;
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[x_orig y_pos 95 25],...
   'HorizontalAlignment','Left','FontSize',fontsize,...
   'String', 'Position Limit:');
pos_lim_array=[0.5, 0.75, 1, 1.25, 1.5, 2, 2.5 ,3, 3.5, 4, 5, 6];
posstr=[{['0.5' deg]};{['0.75' deg]};{['1.0' deg]};{['1.25' deg]};...
   {['1.5' deg]};{['2.0' deg]};{['2.5' deg]};{['3.0' deg]}; ...
   {['3.5' deg]};{['4.0' deg]};{['5.0' deg]};{['6.0' deg]}];
h.posLimNAFXH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+100 y_pos 135 25],'FontSize',fontsize,...
   'String',posstr,'Value',posLim,'UserData',pos_lim_array,...
   'Tooltip',['Enter the position window limit.' CR,...
   'It can be one of the following values:' CR,...
   '0.5, 0.75, 1.0, 1.25, 1.5. 2.0,' CR,...
   '2.5, 3.0, 3.5, 4.0, 5.0, or 6.0' deg],...
   'Callback','nafxAct(''settau'')');

y_pos=y_pos-30;
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[x_orig y_pos 95 25],...
   'HorizontalAlignment','Left','FontSize',fontsize,...
   'String', 'Velocity Limit:');
vel_lim_array = [4,5,6,7,8,9,10];
velstr = [{['4' dps]};{['5' dps]};{['6' dps]};{['7' dps]};...
   {['8' dps]};{['9' dps]};{['10' dps]}];
h.velLimNAFXH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+100 y_pos 135 25],'FontSize',fontsize,...
   'String',velstr,'Value',velLim,'UserData',vel_lim_array,...
   'HorizontalAlignment','Right',...
   'Tooltip',['Enter the velocity window limit.' CR,...
   'It can be one of the following values:' CR,...
   '4, 5, 6, 7, 8, 9 or 10' deg ' per sec'],...
   'Callback','nafxAct(''settau'')');

y_pos=y_pos-30;
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[x_orig y_pos 95 25],...
   'HorizontalAlignment','Left','FontSize',fontsize,...
   'String', 'Sampling Freq.:');
h.sampFreqH = uicontrol('Style','edit','Units','pixels',...
   'BackgroundColor','cyan','ForeGroundColor','black',...
   'Position',[x_orig+100 y_pos 135 25],...
   'Tooltip',['Sampling frequency of the data. Should' CR,...
   'be automatically detected. It is used to' CR,...
   'determine filtering and differentiation values.'],...
   'FontSize',fontsize,'String', num2str(samp_freq) );

y_pos=y_pos-30;
uicontrol('Style','text','Units','pixels',...
   'Position',[x_orig y_pos 95 25],...
   'HorizontalAlignment','Left','FontSize',fontsize,...
   'String', 'Foveation Criteria:');
h.fovCritNAFXH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+100 y_pos-2 135 25],...
   'HorizontalAlignment','center','FontSize',fontsize,...
   'String','Pos & Vel|Pos Only|Vel Only',...
   'Tooltip',['Determines what criteria will be used to' CR,...
   'determine selection of raw foveation points.' CR,...
   'Default is "Pos & Vel"'],...
   'Value',1, 'UserData',['showpv';'showp ';'showv '] );

y_pos=y_pos-30;
uicontrol('Style','text','Units','pixels',...
   'Position',[x_orig y_pos 95 25],...
   'HorizontalAlignment','Left','FontSize',fontsize,...
   'String','Tau:');
h.tauNAFXH = uicontrol('Style','edit','Units','pixels',...
   'BackgroundColor','cyan','ForeGroundColor','black',...
   'Position',[x_orig+100 y_pos 135 25],...
   'FontSize',fontsize,...
   'Tooltip',['"Tau" is normally determined automatically' CR,...
   'based on the above position and velocity limits.' CR,...
   'If you manually enter a value here, it will' CR,...
   'over-ride the automatic value (DANGEROUS!).'],...
   'String',num2str(tau) );

y_pos=y_pos-40;
uicontrol('Style','Frame','Pos',[3 y_pos-63 245 90],...
   'BackgroundColor',[0.5 0.5 0.5]);

y_pos=y_pos-2;
uicontrol('Style','text','Units','pixels',...
   'Position',[x_orig y_pos 55 25],...
   'HorizontalAlignment','Left', 'FontSize',fontsize-2,...
   'String', 'Raw P,V points plot:');
h.dblPlotNAFXH = uicontrol('Style','popup','Units','pixels',...
   'Position',[x_orig+56 y_pos-2 95 25],'FontSize',fontsize,...
   'String','Together|Separate|None',...
   'Tooltip',['Determines how raw foveation points for the' CR,...
   'position and velocity segments are displayed.' CR,...
   'They can be plotted on the same figure, on' CR,...
   'separate figures, or not at all.'],...
   'Value', dblplot);
h.fovStatNAFXH = uicontrol('Style','checkbox','Units','pixels',...
   'Position',[160 y_pos 83 25],'FontSize',fontsize,...
   'Tooltip',['Determines whether or not to output statistics' CR,...
   'about the foveations to the command window.'],...
   'Value', fovstat, 'String','Show Stats' );

y_pos=y_pos-30;
h.fovCalcH = uicontrol('Style','Push','Units','Pixels',...
   'Position', [x_orig y_pos-3 85 30],...
   'String','Calc Fovs.','FontSize',fontsize,...
   'Tooltip',['Once you have entered all the above required' CR,...
   'values, click this button to see how many' CR,...
   'foveation periods meet the criteria. You can' CR,...
   'modify any settings and recalculate as desired.'],...
   'Callback','nafxAct(''calcfovs'')');
uicontrol('Style', 'text', 'Units', 'pixels',...
   'Position',[100 y_pos 60 25],...
   'HorizontalAlignment','Center', 'FontSize',fontsize,...
   'String', '# found:' );
h.numFovNAFXH = uicontrol('Style','edit','Units','Pixels',...
   'BackgroundColor','cyan','ForeGroundColor','black',...
   'Position', [165 y_pos 65 25],...
   'Tooltip',['Displays the best guess of the number of foveations' CR,...
   'detected by the algorithm. This value can be replaced' CR,...
   'by your more accurate count of the actual number of ' CR,...
   'nystagmus cycles present in the data segment.'],...
   'String','empty','FontSize',fontsize);

y_pos=y_pos-30;
h.nafxCalcH = uicontrol('Style','Push','Units','Pixels',...
   'Position', [x_orig y_pos-1 85 30],...
   'String','Calc NAFX', 'FontSize',fontsize,...
   'Tooltip',['After you have determined the number of foveations' CR,...
   '(and optionally modified the given value), click' CR,...
   'this button to calculate the NAFX for this data segment.'],...
   'Callback','nafxAct(''calcnafx'')');
h.tauVersH = uicontrol('Style','checkbox','Units','Pixels',...
   'Foregroundcolor','k',...
   'Position', [100 y_pos+2 60 23],'String','Tau v2', ...
   'FontSize',fontsize,'Value',tau_vers2, ...
   'Tooltip',['Choose which version of the Tau Surface to' CR,...
   'use for NAFX calculations. The default is' CR,...
   'Tau version 2 (box is checked).'] ,...
   'Callback','nafxAct(''settau'')');
h.NAFXvalH = uicontrol('Style','text','Units','Pixels',...
   'BackgroundColor','cyan','ForeGroundColor','black',...
   'Position', [165 y_pos+2 65 23],...
   'Tooltip','Displays the calculated NAFX.',...
   'String','empty','FontSize',fontsize);

y_pos=y_pos-32;
h.doneH = uicontrol('Style','Push','Units','Pixels',...
   'Position', [90 y_pos 70 25],...
   'String','Done', 'FontSize',fontsize+2,...
   'Tooltip',['When you''re sick and tired of calculating NAFXes' CR,...
   'you can make this go away. Go outside and enjoy' CR,...
   'the real world for a while.'],...
   'Callback','nafxAct(''done'')');


% finish up by calculating the initial Tau value based on the
% stored pos and vel settings (same as a call to 'settau')
tau_surf_temp=tau_surface(h.tauVersH.Value);
tau_temp=tau_surf_temp(h.velLimNAFXH.Value, h.posLimNAFXH.Value);
h.tauNAFXH.String = num2str(tau_temp);

% update handles list & linelist (what the hell was i planning to do?)
h.datawindow  = [];
h.lastselname = [];
h.lastselind  = 1;
nafxFig.UserData={h,linelist};
nafxAct('updateAvailData');
addfocus(nafxFig,'nafxAct')

end % function
