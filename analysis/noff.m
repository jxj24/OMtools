function [noff, timesUsedForCalculation] = nystagmus_calc_noff(position,velocity, ...
          eyeTrackerSamplingRate,useManualOffset,foveationPositionConstraint, ...
          foveationVelocityConstraint,foveationMinDuration,foveationMaxGapToBridge, ...
          windowSize,windowStepSize,manualOffsetWindowSize)

% Usage: [noff, calcpoints] = noff(pos);


% Calculates the Nystagmus Optimal Fixation Function (NOFF) from eye trace data
% Version 1.0 coded by Matt J Dunn and Joost Felius 2013
%
% *** Required inputs ***
% position: vector, containing eye position data (°)
% velocity: vector, should be same length as 'position', containing eye velocity (°/s)
% eyeTrackerSamplingRate: int, the eye tracker sampling rate (Hz)
%
% *** Optional inputs ***
% useManualOffset: boolean, set to true if you'd like to use a manual offset in foveation
%    position calculation
% foveationPositionConstraint: float, maximum position error in foveation (°)
% foveationVelocityConstraint: float, maximum velocity error in foveation (°/s)
% foveationMinDuration: int, minimum duration of a foveation (ms)
% foveationMaxGapToBridge: int, maximum gap between foveations that should be considered
%    as the same foveation (ms)
% windowSize: int, the size of the time window used to calculate NOFF (ms)
% windowStepSize: int, the amount of time that the time window used to calculate NOFF
%    should be moved along by for each recalculation (ms)
% manualOffsetWindowSize: int, if using a manual offset, the amount of data about the
%    selected point that are used to calculate manualOffset (ms)
%
% *** Outputs ***
% noff: float
% timesUsedForCalculation: vector containing the timestamps of the data used for NOFF 
% calculation. This may be useful if you want to visualise the data from your eye trace 
% that were used.
%
% For further information, see: Felius J, Fu VL, Birch EE, Hertle RW, Jost RM and 
% Subramanian V (2011) Quantifying nystagmus in infants and young children: relation 
% between foveation and visual acuity deficit. Invest Ophthalmol Vis Sci 52: 8724–8731.


global sampfreq
eyeTrackerSamplingRate = sampfreq;
velocity = d2pt(position, 2);


% Set defaults (if input not supplied)
% The following parameters are defined in {Felius et al. 2011}:
if ~exist('foveationPositionConstraint', 'var')
    foveationPositionConstraint = 1; % in °
end
if ~exist('foveationVelocityConstraint', 'var')
    foveationVelocityConstraint = 6; % in °/s
end
if ~exist('foveationMinDuration', 'var')
    foveationMinDuration = 7; % in ms
end
if ~exist('foveationMaxGapToBridge', 'var')
    foveationMaxGapToBridge = 35; % in ms
end
if ~exist('windowSize', 'var')
    windowSize = 4000; % in ms
end
if ~exist('windowStepSize', 'var')
    windowStepSize = 500; % in ms
end
if ~exist('manualOffsetWindowSize', 'var')
    manualOffsetWindowSize = 2000; % in ms
end

% Check whether we have the required functions available:
if ~exist('nanmedian','file')
    error('requiredRoutines:nanMedianNotFound', ...
          ['Cannot find nanmedian: This function relies on the ''nanmedian'' function ', ...
           'available as part of the Statistics Toolbox or for free in ''NaN Suite'', '...
           'from http://www.mathworks.com/matlabcentral/fileexchange/6837-nan-suite'])
end

% Convert everything from ms into samples:
foveationMinDuration = round(foveationMinDuration / 1000 * eyeTrackerSamplingRate); % in samples
foveationMaxGapToBridge = round(foveationMaxGapToBridge / 1000 * eyeTrackerSamplingRate); % in samples
windowSize = round(windowSize / 1000 * eyeTrackerSamplingRate); % in samples
windowStepSize = round(windowStepSize / 1000 * eyeTrackerSamplingRate); % in samples
manualOffsetWindowSize = round(manualOffsetWindowSize / 1000 * eyeTrackerSamplingRate); % in samples

recordingDuration = length(position); % in samples

% Manual offset:
manualOffsetWindowHalfSize = round(manualOffsetWindowSize/2);
if exist('useManualOffset','var') && useManualOffset && recordingDuration > 2 * manualOffsetWindowHalfSize
    plot(1:recordingDuration,position)
    xlabel('Sample number')
    ylabel('Position')
    disp('Please click approximate foveation position in eye trace')
    try
        x = 0;
        while x < manualOffsetWindowHalfSize || x > recordingDuration - manualOffsetWindowHalfSize
            [x, y] = ginput(1); % get input from cursor
            x = round(x);
            if x < manualOffsetWindowHalfSize || x > recordingDuration - manualOffsetWindowHalfSize
                warning('offset:invalidPointSelected','Please select a point not within the first or last 1000ms of the recording')
            end
        end
        manualOffset = y - nanmedian(position(x - manualOffsetWindowHalfSize : x + manualOffsetWindowHalfSize)); % in °
    catch
        warning('offset:noOffsetSelected','No manual offset selected')
        manualOffset = 0;
    end
    close(gcf);
else
    manualOffset = 0;
end

nSegments = floor((recordingDuration - windowSize) / windowStepSize + 1); % number of steps to be taken to analyse all segments

foveationDataForSegment = cell(1,nSegments); % initialise
nFoveationDataInEachSegment = zeros(1,nSegments); % initialise
for i = 1:nSegments
    segmentStart = (i - 1) * windowStepSize + 1; % segment start time
    segmentEnd = (i - 1) * windowStepSize + windowSize; % segment end time
    medianPositionForSegment = nanmedian(position(segmentStart:segmentEnd));
    zeroedPositionForSegment = position(segmentStart:segmentEnd) - medianPositionForSegment + manualOffset; % position zero'ed on the median position for segment
    foveationDataForSegment{i} = find(abs(zeroedPositionForSegment) <= foveationPositionConstraint & abs(velocity(segmentStart:segmentEnd)) <= foveationVelocityConstraint) + segmentStart - 1; % find foveation data for segment based on position and velocity criteria
    foveationDataForSegment{i} = cleandata(foveationDataForSegment{i}, foveationMinDuration, foveationMaxGapToBridge); % clean up foveations
    nFoveationDataInEachSegment(i) = length(foveationDataForSegment{i}); % count number of foveation data samples in this segment; append to record
end

foveationFraction = max(nFoveationDataInEachSegment) / windowSize; % 'p opt' from {Felius et al. 2011}
noff = log(foveationFraction/(1 - foveationFraction));

bestSegmentIndex = find((nFoveationDataInEachSegment == max(nFoveationDataInEachSegment)),1); % get the segment index number of the segment used for NOFF calculation
if ~isempty(bestSegmentIndex)
    timesUsedForCalculation = foveationDataForSegment{bestSegmentIndex}; % get the times of all samples used for NOFF calculation
else
    timesUsedForCalculation = []; % if no foveations were found, return empty array
end


%%****************************************************

function foveationTimes = cleandata(foveationTimes,foveationMinDuration,foveationMaxGapToBridge)
% Clean up foveation data: remove short foveations and bridge short gaps

% 1) Impose minimum foveation duration
if ~isempty(foveationTimes) % if we have detected any foveation data at all
    x = diff(foveationTimes) ~=1; % mark the borders between non-contiguous foveation data
    xRotated = [1, rot90(x)]; % diff() created an offset; fix this by adding an extra element (rotate vector first to allow for this)
    y = cumsum(xRotated); % assign each contiguous group's elements a reference number
    for i = max(y): -1 : 1 % for each group of foveation data (working backwards to avoid deleting elements at the beginning of the array first)
        if sum(y == i) < foveationMinDuration % find those groups with less than the minimum required number of data to satisfy foveation...
            foveationTimes(y == i) = []; % ...and delete them
        end
    end
end

% 2) Bridge adjacent foveations
x = diff(foveationTimes) ~= 1; % mark the borders between non-contiguous elements in the foveation data timecodes
for i = 1 : length(x)
    if x(i) % if we are at a boundary between non-contiguous elements
        timeGapBetweenFoveations = foveationTimes(i+1) - foveationTimes(i); % calculate the time passed between foveations
        if timeGapBetweenFoveations <= foveationMaxGapToBridge
            y = foveationTimes(i); % 'y' is the first row of inputData of our gap between foveations
            for k = y + 1 : y + timeGapBetweenFoveations - 1 % for each line from the inputData that exists between the local foveations...
                foveationTimes(end+1) = k; %... add it to the foveationTimes vector [IGNORE MATLAB WARNING; THIS IS THE MOST EFFICIENT COMPUTATIONAL METHOD]
            end
        end
    end
end
