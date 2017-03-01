function out = refix_seg(in, startPt, stopPt, shift)

global samp_freq

% because sometimes 4.095e+03 ~= 4095.  Go figure.
startPt = fix(startPt);
stopPt  = fix(stopPt);

%patchMode = 'spline';
patchMode = 'cubic';
maxWid = fix(samp_freq/10);   % 1/10th second wide
maxFakeDur = 6;               % max seg (sec) that will show up as a local shift

% 'dummy' is an indicator array that will overlay on the data
% it will hilite the segments that were shifted
datalen = length(in);
dummy = NaN*ones(datalen,1);

% re-zero the data segment
segment  = (startPt:stopPt)';          % make it a column
in(segment) = in(segment) - shift;

% keep track of the shifted segments so we can plot them on top of the data
% (NOTE that we do NOT keep track of times when we shift more than
% 'maxFakeDur' (about 5?) seconds of data)
if length(segment) < maxFakeDur*samp_freq
	dummy(segment) = in(segment);
end

% now smooth out the discontinuity between segments

% first do the leading edge...
% make sure that _maxWid_ seconds before this segment is not
% beyond the bounds of the data array.
if(startPt-maxWid)>0
	matchseg=in(startPt-maxWid:startPt-1);
 else
	matchseg=in(1:startPt-1);
end
diffpoints = abs(matchseg-in(startPt));
slopes = abs( (diffpoints)' ./ (length(matchseg):-1:1) );
goodpoints = find(diffpoints==min(diffpoints));
bestslopept = find(slopes==min(slopes));
if isempty(bestslopept)
	if isempty(goodpoints), goodpoints = 1; end
	bestpoint = goodpoints(1);
 else
	bestpoint = bestslopept(1);
end  
transWid = (maxWid-bestpoint)+1;

outerPatPt = startPt - transWid;
if outerPatPt < 1
	outerPatPt = 1;
	transWid   = startPt;
end
if startPt ~= 1
	outerPatPt = startPt - transWid;
	patchseg   = makeptch( in, outerPatPt, startPt, patchMode );
	in(outerPatPt:startPt) = patchseg;
end

% ...and then the trailing edge
% make sure that _maxWid_ second after this segment is not
% beyond the bounds of the data array.
if(stopPt+maxWid)<datalen
	matchseg=in(stopPt+1:stopPt+maxWid);
 else
	matchseg=in(stopPt+1:datalen);
end
diffpoints = abs(matchseg-in(stopPt));
slopes = abs( (diffpoints)' ./ (1:length(matchseg)) );
goodpoints = find(diffpoints==min(diffpoints));
bestslopept = find(slopes==min(slopes));
if isempty(bestslopept)
  if isempty(goodpoints), goodpoints = maxWid-1; end
  bestpoint = goodpoints(1);
 else
	temp = length(bestslopept);
	bestpoint = bestslopept(temp);
end
transWid = bestpoint+1;

outerPatPt = stopPt + transWid;
if outerPatPt > datalen
	outerPatPt = datalen;
	transWid  = datalen - stopPt;
end
if stopPt ~= datalen
	outerPatPt = stopPt + transWid;
	patchseg   = makeptch( in, stopPt, outerPatPt, patchMode );
	in( stopPt:outerPatPt ) = patchseg;
end

out = in;