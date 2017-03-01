% getsep.m: find the path separator characters for your OS and ML version

function [sep, sep2] = getsep;

[comp, maxsize] = computer;
vers=version;
P = path;
if comp(1) == 'M' & vers(1)<='5' % 'classic' Mac OS
   sep  = ':';                   % between dirs in a single path
   sep2 = ';';                   % between path entries
 elseif comp(1) == 'P'           % PC
   sep  = '\'; 
   sep2 = ';';
 else                            % Unix (including Mac OS X)
   sep  = '/';
   sep2 = ':';    
end
