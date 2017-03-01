function [monitorLabels monitorCaseIDs figureNames subplotHandles] = PlotHdfFile(filename, varargin)
%PlotHdfFile: Plots all data within an APDM HDF file. Data from each individual monitor
%             is plotted as a separate figure. Only data from enabled sensors
%             (e.g., accelerometers) is plotted. Figures can optionally be saved in any
%             supported format.
%
%   [figureNames monitorLabels monitorCaseIDs] = PlotHdfFile(filename, varargin)
%
% Required input parameter:
%
%   filename           The path to the HDF file to be plotted.
%
% Optional input parameter:
%
%   useMonitorLabels   A cell array specifying the monitor labels to plot.
%                      For example {'Lumbar', 'Right Arm'} would plot only
%                      data that originated from monitors with either of
%                      these labels.
%                      Default: {}, all data will be plotted
%
%   baseSaveName       The base file name to use when data is plotted.
%                      For example, 'Foo' would generate files of the
%                      format 'Foo_CaseID_MonitorLabel.jpg'.
%                      Default: 'Plot'
%
%   saveDir            Specifies the directory to save the figures in
%                      (if saving is enabled)
%                      Default: '.'
%
%   showFigures        Boolean parameter specifying whether to make the
%                      figures visible after plotting. Setting this to
%                      false is useful if this function is being used
%                      for saving figures only, and viewing them is
%                      unimportant
%                      Default: true
%
%   showLegend         Boolean parameter specifying whether to include
%                      the x,y,z legend to the right of the figures.
%                      Default: false
%
%   saveFigures        Boolean parameter specifying whether to save the
%                      figures to disk.
%                      Default: false
%
%   format             String value specifying what format to save the
%                      figures in. Examples include: 'jpeg', 'eps','epsc',
%                      'pdf','eps2','epsc2','tiff', and 'png'
%                      Default: 'jpeg'
%
%   width              The width of saved figures, in inches.
%                      Default: 6 inches
%
%   height             The height of saved figures, in inches.
%                      Default: 5 inches
%
%   resolution         The resolution of saved figures, in dots/inch
%                      Default: 300 dpi
%
%   setAxes            Specifies whether to apply the custom axes to minimize
%                      whitespace. The settings are optimized for the default
%                      figure size (7x9 in) and is suitable for plotting a
%                      single figure on a complete page. Note that using
%                      these custome axes with different figure sizes may
%                      result in bad axes placement.
%                      Default: false
%
%   removeMean         Specifies whether to remove the mean of each signal
%                      before plotting. This is particularly useful when
%                      plotting accelerometer, where gravity typically results
%                      in significantly different ranges for the different axes.
%                      Default: false
%
% Output parameters:
%
%   monitorLabels      A cell array listing the monitor names corresponding
%                      to plotted data.
%
%   monitorCaseIDs     A cell array listing the case IDs corresponding
%                      to plotted data.
%
%   figureNames        A cell array listing the names of the saved files
%
%   subplotHandles     An (nMonitors x nSensors) array of subplot handles
%
%   Version 1.00 LH

% Suppress certain warnings
%#ok<*CTCH>
%#ok<*AGROW>

%==============================================================================
% User-Specified Parameters
%==============================================================================
nMandatoryArguments = 1;
useMonitorLabels = {};
saveDir = './';
baseSaveName = 'Plot';
showFigures = true;
saveFigures = false;
showLegend = false;
format = 'jpeg';
width = 7;
height = 9;
resolution = 300;
setAxes = false;
removeMean = false;

if nargin>nMandatoryArguments
    if ~isstruct(varargin{1})
        if rem(length(varargin),2)~=0, error('Optional input arguments must be in name-value pairs.'); end;
        Parameters = struct;
        for c1=1:2:length(varargin)-1
            if ~ischar(varargin{c1}), error(['Error parsing arguments: Expected property name string at argument ' num2str(c1+1)]); end
            Parameters.(varargin{c1}) = varargin{c1+1};
        end
    else
        Parameters = varargin{1};
    end
    
    parameterNames = fieldnames(Parameters);
    for c1 = 1:length(parameterNames)
        parameterName  = parameterNames{c1};
        if(~ischar(parameterName))
            error(['Error parsing arguments: Expected property name string at argument ' num2str(c1+1)]);
        end
        parameterValue = Parameters.(parameterName);
        switch lower(parameterName)
            case lower('showFigures'), showFigures = parameterValue;
            case lower('useMonitorLabels'), useMonitorLabels = parameterValue;
            case lower('saveDir'), saveDir = parameterValue;
            case lower('baseSaveName'), baseSaveName = parameterValue;
            case lower('saveFigures'), saveFigures = parameterValue;
            case lower('format'), format = parameterValue;
            case lower('width'), width = parameterValue;
            case lower('height'), height = parameterValue;
            case lower('resolution'), resolution = parameterValue;
            case lower('showLegend'), showLegend = parameterValue;
            case lower('setAxes'), setAxes = parameterValue;
            case lower('removeMean'), removeMean = parameterValue;
            otherwise, error(['Unrecognized property: ''' varargin{c1} '''']);
        end
    end
end

if showFigures
    visibility = 'on';
else
    visibility = 'off';
end

% try
%     vers = hdf5read(filename, '/FileFormatVersion');
% catch
%     try
%         vers = hdf5read(filename, '/File_Format_Version');
%     catch
%         error('Couldn''t determine file format');
%     end
% end

vers = h5readatt(filename, '/', 'FileFormatVersion');
if vers < 3 || vers > 4
     error('This example only works with version 3 & 4 of the data file')
end



figureNames = {};
monitorLabels = {};
monitorCaseIDs = {};
subplotHandles = [];
figureIdx = 0;


% annotations
annotation_struct = h5read(filename, '/Annotations');
% .Time (Microseconds since 0:00 Jan 1, 1970, UTC), .DeviceID, .Annotation 

% monitorCaseIDList = hdf5read(filename, '/CaseIdList');
% monitorLabelList = hdf5read(filename, '/MonitorLabelList');
monitorCaseIDList = h5readatt(filename, '/', 'CaseIdList');
monitorLabelList = h5readatt(filename, '/', 'MonitorLabelList');
for iMonitor = 1:length(monitorCaseIDList)
%   caseID = monitorCaseIDList(iMonitor).data;
%    monitorLabel = monitorLabelList(iMonitor).data;
    caseID = remove_non_chars(monitorCaseIDList{iMonitor});
    monitorLabel = remove_non_chars(monitorLabelList{iMonitor});
%     if ~isempty(useMonitorLabels) && isempty(strmatch(monitorLabel, useMonitorLabels, 'exact'))
%         continue;
%     end
    
    accPath = ['/' caseID '/Calibrated/Accelerometers'];
    gyroPath = ['/' caseID '/Calibrated/Gyroscopes'];
    magPath = ['/' caseID '/Calibrated/Magnetometers'];
    timePath = ['/' caseID '/Time'];
    
    includeAcc = h5readatt(filename, ['/' caseID], 'AccelerometersEnabled');
    includeGyro = h5readatt(filename, ['/' caseID], 'GyroscopesEnabled');
    includeMag = h5readatt(filename, ['/' caseID], 'MagnetometersEnabled');
    
    fs = h5readatt(filename, ['/' caseID], 'SampleRate');
    fs = double(fs);
    
    data = {};
    labels = {};
    units = {};
    
    t = h5read(filename, timePath);
    
    nPlots = 0;
    if includeAcc
        nPlots = nPlots + 1;
        data{nPlots} = h5read(filename, accPath);
        labels{nPlots} = 'Accelerometers';
        units{nPlots} = 'm/s^2';
    end
    if includeGyro
        nPlots = nPlots + 1;
        data{nPlots} = h5read(filename, gyroPath);
        labels{nPlots} = 'Gyroscopes';
        units{nPlots} = 'rad/s';
    end
    if includeMag
        nPlots = nPlots + 1;
        data{nPlots} = h5read(filename, magPath);
        labels{nPlots} = 'Magnetometers';
        units{nPlots} = 'a.u.';
    end
    
    if nPlots == 0
        continue;
    end
    
    figureIdx = figureIdx + 1;
    monitorCaseIDs{figureIdx} = caseID;
    monitorLabels{figureIdx} = monitorLabel;
    subplotHandles{iMonitor} = [];
    figure('visible', visibility);
    for iPlot = 1:nPlots
        hS = subplot(nPlots,1,iPlot);
        subplotHandles{iMonitor} = [subplotHandles{iMonitor} hS];
        [p1 p2 p3 p4] = MakePlot(fs, data{iPlot}, labels{iPlot}, units{iPlot}, removeMean);
        if iPlot == 1 && showLegend
            hL = legend([p2 p3 p4],{'x','y','z'},'Location','EastOutside');
            legend(hL, 'boxoff');
        end
        if iPlot ~= nPlots
            set(gca, 'XTick', []);
        end
        if iPlot == nPlots
            xlabel('Time (s)');
        end
        if setAxes
            p = get(hS, 'pos');
            p(1) = 0.1;
            if showLegend
                p(3) = 0.75;
            else
                p(3) = 0.87;
            end
            switch nPlots
                case 1
                    p(4) = 0.9;
                    p(2) = p(2) - 0.05;
                case 2
                    p(4) = 0.42;
                    p(2) = p(2) - 0.05;
                case 3
                    p(4) = 0.26;
                    p(2) = p(2) - 0.04;
            end
            set(hS,'pos',p);
        end
    end
    
    linkaxes(subplotHandles{iMonitor},'x');
    
    t_beg = t(1);
    for an_num = 1:length(annotation_struct.Time),
       annot_time = annotation_struct.Time(an_num);
       annot_rel_time = (annot_time - t_beg) / 1e6;
       
       annot = annotation_struct.Annotation(:,an_num)';
       annot = remove_non_chars(annot);
       sprintf('t=%f, %s', annot_rel_time, annot)
    end
    
    
    figureName = [baseSaveName '_' caseID];
    figurePath = fullfile(saveDir, figureName);
    if saveFigures
        PrintFigure(gcf, figurePath, format, width, height, resolution);
        figureNames{figureIdx} = figureName;
    end
end
end

function [minY maxY] = GetYRange(data)
minY = min(min(data));
maxY =  max(max(data));
range = maxY - minY;
minY = minY - 0.05*range;
maxY =  maxY + 0.05*range;
end

function [p1 p2 p3 p4] = MakePlot(fs, data, label, units, removeMean)
t = (1:size(data,2))/fs;
if removeMean
    data = data - repmat(mean(data,2),1,size(data,2));
end
colors = [1 0 0 ; 0 0.8 0 ; 0 0 1];
hold on;
p1 = plot(t,zeros(1,length(t)),'color',[0.8 0.8 0.8]);
p4 = plot(t,data(3,:),'color',colors(3,:));
p3 = plot(t,data(2,:),'color',colors(2,:));
p2 = plot(t,data(1,:),'color',colors(1,:));
xlim([min(t) max(t)])
[minY maxY] = GetYRange(data);
ylim([minY maxY])
title(label);
ylabel(units);
end


function out = remove_non_chars(in)
tmp = double(in);
tmp = tmp(tmp > 32);
out = char(tmp);
end
