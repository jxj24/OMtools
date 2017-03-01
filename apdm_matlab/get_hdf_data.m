function [time, monitorLabelList, accel, annot] = get_hdf_data(filename)
%
%
%



% annotations
annotation_struct = h5read(filename, '/Annotations');
% .Time (Microseconds since 0:00 Jan 1, 1970, UTC), .DeviceID, .Annotation 



monitorCaseIDList = h5readatt(filename, '/', 'CaseIdList');
monitorLabelList = h5readatt(filename, '/', 'MonitorLabelList');
for iMonitor = 1:length(monitorCaseIDList)
    caseID = remove_non_chars(monitorCaseIDList{iMonitor});
    monitorLabelList{iMonitor} = remove_non_chars(monitorLabelList{iMonitor});
%     if ~isempty(useMonitorLabels) && isempty(strmatch(monitorLabel, useMonitorLabels, 'exact'))
%         continue;
%     end
    
    timePath = ['/' caseID '/Time'];
    time = h5read(filename, timePath);
    
    
    accPath = ['/' caseID '/Calibrated/Accelerometers'];
    accel{iMonitor} = h5read(filename, accPath);
end

% annotations 
t_beg = double(time(1));
for an_num = 1:length(annotation_struct.Time),
   annot_time = double(annotation_struct.Time(an_num));
   annot_rel_time = (annot_time - t_beg) / 1e6;
   annot{an_num}.time = annot_rel_time;
   
   tmp = annotation_struct.Annotation(:,an_num)';
   annot{an_num}.msg = remove_non_chars(tmp);
   msg = sprintf('t=%f, %s', annot_rel_time, annot{an_num}.msg);
   disp(msg)
end

time = (double(time) - t_beg) ./ 1e6;

end % get_hdf_data

% ------------------------------------------------------------
function out = remove_non_chars(in)
tmp = double(in);
tmp = tmp(tmp > 32);
out = char(tmp);
end
