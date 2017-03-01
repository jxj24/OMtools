function [peak, tPeak] = findpeak( dataVec, timeVec, tMin, tMax )
% find the peak (max absolute value) in the data vector during the time interval
% specified by tMin and tMax

% extract time interval of interest from dataVec and timeVec
dataInterval = dataVec(timeVec>=tMin & timeVec<=tMax);
timeInterval = timeVec(timeVec>=tMin & timeVec<=tMax);

% find the abs max data value & index
[peakAbs, peakInd] = max(abs(dataInterval));

% return values
peak = dataInterval(peakInd);
tPeak = timeInterval(peakInd);
