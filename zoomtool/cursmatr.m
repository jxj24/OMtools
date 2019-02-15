% cursmatr.m: modifies (x,y) cursor matrices when C1, C2 buttons are pressed.

% Written by: Jonathan Jacobs
% April 2009  (last mod: 04/01/09)

function cursmatr(command)%,obj_handle)

global xyCur1Ctr xyCur2Ctr xyCur1Mat xyCur2Mat

%if ~exist('obj_handle'), obj_handle = gco; end

% find clr1 and clr2 handles.
zoomwindow = findme('zoomed window');
if zoomwindow<=0
    disp('Error: No zoomed window found.')
    return
end
figure(zoomwindow)

zoomed_axes = get(zoomwindow,'CurrentAxes');
usr_dat = get(zoomed_axes,'UserData');
zt_hand = usr_dat{1}; my_hand = usr_dat{2};
c1GetH = zt_hand(18); c2GetH = zt_hand(19); 
c1clrH = my_hand{15}; c2clrH = my_hand{16};

switch lower(command)
  case {'cur1_clr'}	
	xyCur1Mat = []; xyCur1Ctr = 0;
	set(c1GetH,'String', ['C1 get','  (0)'] );
	
  case {'cur2_clr'}		
	xyCur2Mat = []; xyCur2Ctr = 0;
	set(c2GetH,'String', ['C2 get','  (0)'] );
	
  case {'cur1_add'}	
	xyCur1Ctr = xyCur1Ctr + 1;
	[xyCur1Mat(xyCur1Ctr,1),xyCur1Mat(xyCur1Ctr,2), ...
			xyCur1Mat(xyCur1Ctr,3),xyCur1Mat(xyCur1Ctr,4)] = getcurxy(gca,1);
	set( c1GetH, 'String', ['C1 get  (' num2str(xyCur1Ctr) ')'] );
	
  case {'cur2_add'}	
	xyCur2Ctr = xyCur2Ctr + 1;
	[xyCur2Mat(xyCur2Ctr,1),xyCur2Mat(xyCur2Ctr,2), ...
			xyCur2Mat(xyCur2Ctr,3),xyCur2Mat(xyCur2Ctr,4)] = getcurxy(gca,2);
	set( c2GetH, 'String', ['C2 get  (' num2str(xyCur2Ctr) ')'] );
end