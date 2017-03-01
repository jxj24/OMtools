% frameAct.m: executes the button actions defined in ''frameup.m''
%
% written by:  Jonathan Jacobs
%              September 2004 - February 2005  (last mod: 02/09/05)

function frameAct(action)

global avimov savedPts avifile cH
global init_xlims init_ylims      %% should be 'persistent' but is broken

persistent oldxlims oldylims oldaxpos 
persistent cur_xlims cur_ylims 
persistent cur_max_wid cur_max_hgt zoomed

cH = get(gcf,'UserData');

playFig = cH{1}; 		playAx = cH{2};
loadH = cH{3};			backH  = cH{4};			fwdH = cH{5};

makemovieH = cH{6};	totalFramesH = cH{7};	pickPtsH = cH{8};
rejectPtsH = cH{9};	savePtsH = cH{10};		playH = cH{11};

pt1x = cH{12};  pt1y = cH{13};  pt2x = cH{14};  pt2y = cH{15};
pt3x = cH{16};  pt3y = cH{17};  pt4x = cH{18};  pt4y = cH{19};

ax_size_sliH = cH{20}; 	ax_size_txtH = cH{21};
start_sliH = cH{22}; 	start_txtH = cH{23};
stop_sliH  = cH{24};	 	stop_txtH  = cH{25};
cur_sliH   = cH{26}; 	cur_txtH   = cH{27};
cropBH     = cH{28};		cropresetBH = cH{29};	movienameH = cH{30};

skip = 1;  %% needed if AVI has soundtrack (skip=2). ML7 bug

% full & uncropped sizes for playback axes
init_wid = 0.775;  init_hgt = 0.700; init_xpos = 0.13; init_ypos = 0.25;
x_center = init_xpos+init_wid/2;
y_center = init_ypos+init_hgt/2;

% set the sizes for the largest allowable video axes
if isempty(cur_max_wid), cur_max_wid = 0.775; end
if isempty(cur_max_hgt), cur_max_hgt = 0.700; end
if ~zoomed, cur_max_wid=init_wid;   cur_max_hgt=init_hgt;   end
if ~zoomed, cur_xlims  =init_xlims; cur_ylims  =init_ylims; end

% check to see if there is already a loaded movie
totalFrames = str2num(get(totalFramesH,'string'));
mlFlag=0; if totalFrames>0, mlFlag = 1; end
curFrame = str2num(get(cur_txtH,'string'));

start = round(get(start_sliH,'Val'));
stop  = round(get(stop_sliH, 'Val'));
cur   = round(get(cur_sliH,  'Val'));

ax_size = get(ax_size_sliH,'val');


% on to the interesting stuff!
switch action
case('load')
   [avifile, path] = uigetfile('*.avi','Load a ".avi" file');
	
   if avifile
	  disp('This might take a few minutes...')
	  avimov=aviread([path avifile]);
	  mlFlag = 1;
	  disp(['Movie ' path avifile ' loaded..']) 	   
	  % look for an associated points file
	  ptsFileName = [strtok(avifile,'.') '.txt'];

	else
	  disp('No file selected.')
	  return
   end
	
   temp = size(avimov); numframes = max(temp);	
   disp(['The movie ' avifile ' has ' num2str(numframes) ' frames.'])
   set(totalFramesH,'string',num2str(numframes))
   set(start_sliH, 'Max', numframes)
   set(start_sliH, 'Val', 1);    set(start_txtH, 'String', '1')
   set(stop_sliH,  'Max', numframes)
   set(stop_sliH,  'Val', numframes);
   set(stop_txtH,  'String', num2str(numframes))
   set(cur_sliH,   'Max', numframes)
   set(cur_sliH,   'Val', 1);    set(cur_txtH, 'String', '1')
   set(movienameH, 'String', ['Current movie: ' avifile])
	
	savedPts = cell(numframes, 2);	
	if exist([path ptsFileName],'file')
	   disp(['Loading ' [path ptsFileName] ])
		temp = load([path ptsFileName]);
		temp = temp(:,2:end);
		[r,c]=size(temp);
		disp([ num2str(r) ' entries found'])
		for i = 1:min(r,numframes)
		  xpts = temp(i, 1:c/2);
		  ypts = temp(i, c/2+1:c);
		  savedPts{i,1} = xpts;	      
		  savedPts{i,2} = ypts;	      
		end
	end
	   
	[frame, map] = frame2im(avimov(:,1));
	hold off
	imagesc(frame); colormap(map)
	%set(playAx,'DataAspectRatio',[1 1 1])
	axis image off
	init_xlims = get(playAx,'XLim');  cur_xlims = init_xlims;
	init_ylims = get(playAx,'YLim');  cur_ylims = init_ylims;
	drawnow;
   drawpts(savedPts,1,gcf);


case {'resize_ax_txt','resize_ax_sli'}
   if strcmp(action(11:13), 'txt')
      ax_size = str2num(get(ax_size_txtH,'String'));
		if isempty(ax_size) | (ax_size>1) | (ax_size<0.5)
			ax_size=get(ax_size_sliH,'Value');
			set(ax_size_txtH,'String',num2str(ax_size,3));
		end
		set(ax_size_sliH,'Value',ax_size)
	end	
	ax_size = get(ax_size_sliH,'Value');
	set(ax_size_txtH,'String', num2str(ax_size,3));
	ax_pos = get(playAx,'Position');
   x0 = ax_pos(1); y0 = ax_pos(2); width = ax_pos(3); height = ax_pos(4);
   center = [x0+width/2, y0+height/2];
   new_wid = cur_max_wid*ax_size;
   new_hgt = cur_max_hgt*ax_size;
   new_x0  = center(1)-new_wid/2;
   new_y0  = center(2)-new_hgt/2;
   set(playAx,'Position',[new_x0, new_y0, new_wid, new_hgt]) 
    


case {'start_txt','start_sli'}
   if strcmp(action(7:9), 'txt')
		start = str2num(get(start_txtH,'String'));
		if isempty(start), start=round(get(start_sliH,'Value')); end
		set(start_sliH,'Value',start);
   end
   if start>=stop, start=stop-1; end
   start = max(start,1);
   start=fix(start);
   set(start_sliH,'Value',start);
   set(start_txtH,'String', num2str(start));
   cur = max(start,cur);
   frameAct('cur_sli')



case {'stop_txt','stop_sli'}
   if strcmp(action(6:8), 'txt')
	 	stop = str2num(get(stop_txtH,'String'));
		if isempty(stop), stop=round(get(stop_sliH,'Value')); end
		set(stop_sliH,'Value',stop);
   end
   if stop<=start, stop=start+1; end
   stop=min(stop,totalFrames);
   if stop == 0, return; end
   stop=fix(stop);
   set(stop_sliH,'Value',stop);
   set(stop_txtH,'String', num2str(stop));
   cur = min(stop,cur);
   frameAct('cur_sli')



case {'cur_sli','cur_txt'}     %% 'cur_txt', 'cur_sli'
   if strcmp( action(5:7), 'txt')
      cur = fix(str2num(get(cur_txtH,'String')));
   end
   if isempty(cur), cur=round(get(cur_sliH,'Value')); end
   if cur<start,  cur=start; end
   if cur>stop,   cur=stop;  end
   set(cur_sliH,'Value', cur );
   set(cur_txtH,'String', num2str(cur));
   frameAct('jump')



case('crop')
   crop = get(cropBH,'Value');
   if crop
      % get current axis width, height.  will be saved in persistent vars
      % so they can be accessed when crop button is unclicked and new axis
      % size and position are calculated
      zoom on
      set(cropBH,'String','Cropping')   
      oldxlims = get(playAx,'XLim');
      oldylims = get(playAx,'YLim');
      oldaxpos = get(playAx,'Pos');
      zoomed = 1;
    else
      zoom off
      cur_xlims = get(playAx,'XLim');
      cur_ylims = get(playAx,'YLim');
      if (cur_xlims~=init_xlims) | (cur_ylims~=init_ylims)
         cropstr = 'Cropped';
       else
         cropstr = 'Crop';
      end
      set(cropBH,'String', cropstr)
      % get new x,y lims and set axis size to match new aspect ratio 
      % will use x axis pos as set from ZOOM.  Will calculate new y axis
      % position -- including new center.
      % oldaxpos, oldx(y)lims were saved previously as persistent variables
      y_center = oldaxpos(2)+oldaxpos(4)/2;
      xratio = (cur_xlims(2)-cur_xlims(1))/(oldxlims(2)-oldxlims(1));
      new_y_hgt = oldaxpos(4)*xratio;
      new_y_orig = y_center-new_y_hgt/2;
      newaxpos = [oldaxpos(1) new_y_orig oldaxpos(3) new_y_hgt];
      %set(playAx,'pos',newaxpos)
      %set(playAx,'DataAspectRatio',[1 1 1])
      axis image off 
      set(playAx,'XLim',cur_xlims)
      set(playAx,'YLim',cur_ylims)
      % calculate the 100% size for this current crop and save as persistent
      cur_max_wid = oldaxpos(3);  %%% is this needed anymore???
      %cur_max_hgt = new_y_hgt/ax_size;     
      cur_max_hgt = oldaxpos(4);  %%% is this needed anymore???   
   end



case('uncrop')
   set(cropBH,'Value',0)
   set(cropBH,'String','Crop')
   zoom out
   zoom off
   % reset to uncropped values
   zoomed = 0;
   cur_max_wid = init_wid;		cur_max_hgt = init_hgt;
   cur_xlims = init_xlims;		cur_ylims = init_ylims;
   % set axis position to uncropped (but scaled) size & pos
   new_wid = init_wid*ax_size;
   new_hgt = init_hgt*ax_size;
   new_x0  = x_center - new_wid/2;
   new_y0  = y_center - new_hgt/2;
   set(playAx,'pos', [new_x0 new_y0 new_wid new_hgt])
   %set(playAx,'DataAspectRatio',[1 1 1])
   axis image off



case('back')
	if ~mlFlag, return; end
	if curFrame-skip>=start
		curFrame=curFrame-skip;
		set(cur_txtH,'string',num2str(curFrame))
		set(cur_sliH,'value',curFrame)
	end
	frameAct('jump')
	


case('fwd')
	if ~mlFlag, return; end
	if curFrame+skip<=stop
		curFrame=curFrame+skip;
		set(cur_txtH,'string',num2str(curFrame))
		set(cur_sliH,'value',curFrame)
	end
	frameAct('jump')



case('jump')
	if ~mlFlag, return; end
	curFrame = str2num(get(cur_txtH,'string'));
	if (curFrame<start) | (curFrame>stop)
		%set(cur_txtH,'string', num2str(totalFrames))
		return
	end
	[frame, map] = frame2im(avimov(:,curFrame));
	hold off
	imagesc(frame); colormap(map)
	%set(playAx,'DataAspectRatio',[1 1 1])
	axis image off
	set(playAx,'XLim',cur_xlims)
	set(playAx,'YLim',cur_ylims)
	drawnow;
   drawpts(savedPts,curFrame,gcf);



case('mod_pt')
	if ~mlFlag, return; end
	curFrame = str2num(get(cur_txtH,'string'));
	if (curFrame<1) | (curFrame>totalFrames)
		set(cur_txtH,'string', num2str(totalFrames))
		return
	end
	xpts(1) = str2num(get(pt1x,'String'));	ypts(1) = str2num(get(pt1y,'String'));
	xpts(2) = str2num(get(pt4x,'String'));	ypts(2) = str2num(get(pt4y,'String'));
	xpts(3) = str2num(get(pt2x,'String'));	ypts(3) = str2num(get(pt2y,'String'));
	xpts(4) = str2num(get(pt3x,'String'));	ypts(4) = str2num(get(pt3y,'String'));
	savedPts{curFrame,1} = xpts;
	savedPts{curFrame,2} = ypts;
	hold off
	[frame, map] = frame2im(avimov(:,curFrame));
	imagesc(frame); colormap(map)
	%set(playAx,'DataAspectRatio',[1 1 1])
	axis image off
	set(playAx,'XLim',cur_xlims)
	set(playAx,'YLim',cur_ylims)
	drawnow;
   drawpts(savedPts,curFrame,gcf);



case('play')
	if ~mlFlag, return; end
	[frame, map] = frame2im(avimov(:,1));

	makemovie = get(makemovieH,'Value');
   
   % set aside some memory for the movie (not needed in ML 7)
   if makemovie
	   numframes = length(start:skip:stop);
	   newmovie=moviein(numframes,playFig);
   end
   
   i = start; j=1;

   movierect = get(playAx,'Pos');
   while i <= stop
   	stop = get(stop_sliH,'Value');
		set(cur_txtH,'string', num2str(i))
		set(cur_sliH,'Value', i)
		[frame, map] = frame2im(avimov(:,i));
		hold off
		imagesc(frame); %colormap(map)
		%set(playAx,'DataAspectRatio',[1 1 1])
		axis image off
		set(playAx,'XLim',cur_xlims)
		set(playAx,'YLim',cur_ylims)
		drawpts(savedPts,i, gcf);
      if makemovie
         %newmovie(:,j)=getframe(playFig,movierect); j=j+1;
         newmovie(:,j)=getframe(playAx); j=j+1;
      end
		drawnow
		i=i+skip;
   end
   
   if makemovie
		% save the movie as a series of still frames
		[fn,pn]=uiputfile('','Save the movie as:');
		if fn==0, return, end
		[fn, exten] = strtok(fn,'.');
		if pn
			tempmap = colormap;
			cd(pn)
			moviemode = 'a';
			switch lower(moviemode(1))
			 case 'q'
			   %qtcompressor = 
				%spatialqual = 
				%fps = 
				%moviespeed = 
				%moviename = [fn '.mov'];
				%eval([ 'qtwrite(' movie ', tempmap, moviename, ' ...
				%			 '[fps/movie_speed, qtcompressor, spatialqual])' ]);
			 otherwise
				% save the movie frames as individual images and use QuickTime
				% to turn them into a real movie, not this AVI shit.
				% First, make sure that we are writing frames to new folder
				if (1) % make_stills
					framefold = [fn '_frames'];
					temp = dir; maxnum = 0;
					foldname = framefold;  %% our inital & default condition
					for i=1:length(temp)
						% name already exists?  maybe more than one?  append a number to
						% the name e.g. 'test_frames1', ... 'test_frames_10',...
						% the created folder name will be one higher than the previous
						% highest.  will NOT fill in gaps below highest number
						tempname = temp(i).name;
						if findstr(tempname, framefold)  % name DOES already exist
							% look for appended number
							num = str2num(tempname(find(isdigit(tempname))));
							if isempty(num), num = 0; end
							if num >= maxnum, maxnum = num+1; end
							foldname = [framefold num2str(maxnum)];
						 
						 else  % name DOES NOT exist
							 ;  % do nothing
						end
					end
					mkdir(foldname); cd(foldname)
	
					% write the individual frames.  We can use QuickTime Pro's nifty
					% "Open Image Sequence..." to make a movie from these frames.
					imageformatstr = 'jpg';
					for i=1:numframes
						temp_frame = frame2im(newmovie(:,i));
						temp_name = ['frame_' num2str(i) '.' imageformatstr];
						imwrite(temp_frame,temp_name, imageformatstr);
					end
				end
	
				if (0)  %% make_avi
					eval([ 'movie2avi(' which_movie{m} ',fn,''colormap'', tempmap,' ...
							 ' ''fps'', fps/movie_speed);' ]);
				end
	
			end           %% switch lower(moviemode(1))
		end				  %% if pn
	end					  %% if makemovie



case('pick')
	pickState = get(pickPtsH,'value');  % '1' pressed, '0' released
	curXPts = savedPts{curFrame,1};
	curYPts = savedPts{curFrame,2};
	if all(isnan(curXPts)) | all(isnan(curYPts))
	   ;
	 else  
	   disp(['frame ' num2str(curFrame) ...
	   ': You must first click "reject" to clear the current selected points'])
	   set(pickPtsH,'value',0)
	   return
	end 
	
	if pickState == 1
	   [xpts, ypts] = ginput;
	   set(pickPtsH,'value',0)	   
	   savedPts{curFrame,1} = xpts;
	   savedPts{curFrame,2} = ypts;
	   %hold on
      drawpts(savedPts,curFrame, gcf);
	   %hold off
	end

	
	
case('reject')
  	savedPts{curFrame,1} = [];
	savedPts{curFrame,2} = [];
	savedPts{curFrame,3} = [];
	chList = get(playAx,'Children');  %should only be 3 children: image and 2 pt plot
	for i = 1:length(chList)
	   if strcmp(get(chList(i),'Type'), 'line')
	      delete(chList(i))
	      drawnow
	   end
	end
	set(pt1x,'String',''); set(pt1y,'String','');
	set(pt2x,'String',''); set(pt2y,'String','');
	set(pt3x,'String',''); set(pt3y,'String','');
	set(pt4x,'String',''); set(pt4y,'String','');

	  

case('savepts')
	savename = strtok(avifile,'.');
	[savePtsFile, path] = uiputfile([savename '.txt'],'Save the points file as:');
	if savePtsFile
	   linenum = (1:totalFrames)';
		% convert cell structure to flat arrays
		xpts = NaN*ones(totalFrames,6);
		ypts = NaN*ones(totalFrames,6);
		for i = 1:totalFrames
		   tempx=savedPts{i,1}';
			tempy=savedPts{i,2}';
			xpts(i,1:length(tempx)) = tempx; 
			ypts(i,1:length(tempy)) = tempy; 
		end
		temp = [linenum xpts ypts];
		save(savePtsFile, 'temp', '-ASCII')
	end
	return

  
end % switch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawpts(savedPts, curFrame, fig)

global cH

pt1x = cH{12};  pt1y = cH{13};  pt2x = cH{14};  pt2y = cH{15};
pt3x = cH{16};  pt3y = cH{17};  pt4x = cH{18};  pt4y = cH{19};

xpts = savedPts{curFrame,1}; if isempty(xpts), xpts = NaN*ones(4,1); end
ypts = savedPts{curFrame,2}; if isempty(ypts), ypts = NaN*ones(4,1); end
% sort the points based on x points
xtemp = xpts;
% min and max are the canthi
minxpt = min(xtemp); mindex = find(xtemp==minxpt); xtemp(mindex)=NaN;
maxxpt = max(xtemp); maxdex = find(xtemp==maxxpt); xtemp(maxdex)=NaN;
% now find the limbus pts 
limb_x1 = min(xtemp); l1index = find(xtemp==limb_x1); limb_y1 = ypts(l1index);
limb_x2 = max(xtemp); l2index = find(xtemp==limb_x2); limb_y2 = ypts(l2index);
centerxpt = (limb_x1+limb_x2)/2;
if isempty(centerxpt), centerxpt = NaN; end
centerypt = (limb_y1+limb_y2)/2;
if isempty(centerypt), centerypt = NaN; end

set(pt1x,'String',num2str(xpts(mindex),'%6.2f'));
set(pt1y,'String',num2str(ypts(mindex),'%6.2f'));
set(pt2x,'String',num2str(xpts(l1index),'%6.2f'));
set(pt2y,'String',num2str(ypts(l1index),'%6.2f'));
set(pt3x,'String',num2str(xpts(l2index),'%6.2f'));
set(pt3y,'String',num2str(ypts(l2index),'%6.2f'));
set(pt4x,'String',num2str(xpts(maxdex),'%6.2f'));
set(pt4y,'String',num2str(ypts(maxdex),'%6.2f'));

if isempty(xpts) | isempty(ypts) | all(isnan(xpts)) | all(isnan(ypts)) 
   %disp('No points currently selected for this frame');
 else
   figure(fig)
   hold on
   plot(xpts([mindex maxdex]),   ypts([mindex maxdex]),   'co','markersize', 4)
   plot(xpts([l1index l2index]), ypts([l1index l2index]), 'go','markersize', 4)
   plot(centerxpt,centerypt,'r+','markersize', 4)
   hold off	
end
