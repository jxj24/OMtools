function [out] = crsrloc(ax,name)%CRSRLOC Return axes cursor position.%       y=crsrloc(axes,'name') returns the x- or y-axes cursor%       location dependent upon if the cursor is a vertical or%       horizontal cursor.%%       See also CRSRCR, CRSRDEL, CRSRON, CRSROFF%       Dennis W. Brown 1-10-94%       Copyright (c) 1994 by Dennis W. Brown%       May be freely distributed.%       Not for use in commercial products.v = version;v=str2double(v(1:3));% get handle to cursorh = findline(ax,name);% get current axis dataout = get(ax,'YLim');if v >= 8.4    % get current cursor location    [xminmax, yminmax] = getpoints(h);        % move the cursor    if xminmax(1) == xminmax(2)          % vertical cursor        out = xminmax(1);    elseif yminmax(1) == yminmax(2)      % horizontal cursor        out = yminmax(1);    elseif isnan(yminmax(1)) && isnan(yminmax(2))      % horizontal cursor        out = (out(1)+out(2))/2;    else        %keyboard        %disp('crsrloc: Invalid cursor found...');        error('crsrloc: Invalid cursor found...');    end    else    % get current cursor location    y = get(ax,'YLim');    xx = get(h,'XData');    yy = get(h,'YData');        % move the cursor    if xx(1) == xx(2)          % vertical cursor        y = get(h,'XData');        y = y(1);    elseif yy(1) == yy(2)      % horizontal cursor        y = get(h,'YData');        y = y(1);    elseif isnan(yy(1)) && isnan(yy(2))      % horizontal cursor        y = (y(1)+y(2))/2;    else        %keyboard        %disp('crsrloc: Invalid cursor found...');        error('crsrloc: Invalid cursor found...');    end    out = y;    end