function xlstest(index)

olddir = pwd;
[filename, pathname] = uigetfile('','Select an Excel spreadsheet');

% figure out which sheet we want from this spreadsheet.  The loaded eye movement data file
% is in 'namearray'. The sheets are named 'record'+'n' where 'n' is the data record number.
warning off MATLAB:xlsread:Mode
[typ, desc, fmt] = xlsfinfo([pathname filename]);

sheetname = desc{index}
%sheetname = ['record' index];

[rawdata, strdata] = xlsread([pathname filename], sheetname,'basic');
filename
rawdata