function vidwaveform

sampfreq = 30;


[ptsfile, path] = uigetfile('*.txt','Load a ".txt" file');
if ptsfile == 0, disp('Canceled'); return; end

if exist([path ptsfile],'file')
	temp = load([path ptsfile]);
	temp = temp(:,2:end);
	[r,c]=size(temp);
 else
    return
end

centerxpt = NaN*ones(r,1); centerypt = NaN*ones(r,1);
minxpt    = NaN*ones(r,1); maxxpt    = NaN*ones(r,1);
eyewidth  = NaN*ones(r,1);

lastpt=r;
for i = 1:r
   xpts = temp(i, 1:c/2);
   ypts = temp(i, c/2+1:c);

   %if all(isnan(xpts)) | all(isnan(ypts)), lastpt=i-1; break; end
   
	% sort the points based on x points
	xtemp = xpts;
	% min and max are the canthi
	minxpt(i) = min(xtemp); mindex = find(xtemp==minxpt(i)); xtemp(mindex)=NaN;
	maxxpt(i) = max(xtemp); maxdex = find(xtemp==maxxpt(i)); xtemp(maxdex)=NaN;
	eyewidth(i) = abs(maxxpt(i)-minxpt(i));
	% now find the limbus pts 
	limb_x1 = min(xtemp); l1index = find(xtemp==limb_x1); limb_y1 = ypts(l1index);
	if isempty(limb_y1), limb_y1 = NaN; end
	limb_x2 = max(xtemp); l2index = find(xtemp==limb_x2); limb_y2 = ypts(l2index);
	if isempty(limb_y2), limb_y2 = NaN; end
	centerxpt(i) = (limb_x1+limb_x2)/2;
   if isempty(centerxpt), centerxpt = NaN; end
	centerypt(i) = (limb_y1+limb_y2)/2;
   if isempty(centerypt), centerypt = NaN; end

end

t=(1:lastpt)'/sampfreq;
figure
plot(t, (centerxpt(1:lastpt)-minxpt(1:lastpt))./eyewidth(1:lastpt), 'ro-', 'markersize',3)