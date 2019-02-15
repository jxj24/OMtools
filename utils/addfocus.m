function addfocus(whatfig,fn_name)

if nargin==0
   % demo mode. create test focus window
   if (0), hFig = figure;   %#ok<*UNRCH>
   else,   hFig = uifigure; pause(0.1); % SLOOOOOOOW... wait for it to be registered 
   end
   hFig.Name = 'focustest';
   figname = hFig.Name;
   fn_name='ftest_act'; %eg 'nafx_gui' name of the caller function
else
   % use specified window, can specify by either handle or Tag string
   if ishandle(whatfig)
      hFig=whatfig;
      figname = hFig.Name;
   elseif ischar(whatfig)
      figname=whatfig;
      hFig=findme(whatfig);
   end
end

% Get the underlying Java reference
warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
jFig = get(hFig, 'JavaFrame');

if ~isempty(jFig)
   % for old-style figures   
   jAxis = jFig.getAxisComponent;
   
   % Set the event callbacks (fname is 3rd arg in receiving funct)
   set(jAxis.getComponent(0), ...
      'FocusGainedCallback',{@myMatlabFunc,fn_name,'gained'});
   set(jAxis.getComponent(0), ...
      'FocusLostCallback',  {@myMatlabFunc,fn_name,'lost'});
   
else
   % for UIFIGURE.
   webWindows = matlab.internal.webwindowmanager.instance.windowList;
   found=0;
   for i=1:length(webWindows)
      if strcmp(webWindows(i).Title,figname)
         win = webWindows(i);
         found=1;
         break
      end
   end
   if found
      win.FocusGained = {@myMatlabFunc,fn_name,'gained'};
      win.FocusLost   = {@myMatlabFunc,fn_name,'lost'};
   else
      disp('Could not find UIFIGURE window')
      return
   end
   
end
end % function


function myMatlabFunc(jAxis, jEventData, fn_name,gorl) %#ok<INUSL>
% do whatever you wish with the event/hFig information
if contains(gorl,'gained')
   %if contains(char(jEventData),'FOCUS_GAINED')
   focusgained = 'focusgained';
   cmdname = [fn_name '(' focusgained ');'];
elseif contains(gorl,'lost')
   %elseif contains(char(jEventData),'FOCUS_LOST')
   focuslost = 'focuslost';
   cmdname = [fn_name '(' focuslost ');'];
end
eval(cmdname)
end

