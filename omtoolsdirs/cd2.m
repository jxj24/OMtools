% cd2.m: GUI to change the current directory.

function out = cd2

%[pathname]=uigetdir(pwd, 'Select the new directory ');
[pathname]=uigetdir('Select the new directory ');

if pathname
   eval(['cd ' '''' pathname ''''])
end