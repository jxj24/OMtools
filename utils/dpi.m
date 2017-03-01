% dpi.m: set MATLAB's pixel/inch resolution.
% 
% USAGE: out = dpi('command', value)
% where 'command' is either 'get' or 'set' and 'value' is between 60 and 150
% If no value is specified, you will be prompted for one.
% It can either be a desired value to force the display to match
% or it can be calculated based on the actual screen width of your monitor in inches.
% dpi will attempt to write the new value to 'DPI_pref.txt' in the OMprefs directory.

% written by:  Jonathan Jacobs
%              April 2012  (last mod 04/02/12)

function out=dpi(dpi_cmd,val)

v=version;
if strcmp( v(1),'9'), return; end

if ~exist('dpi_cmd'), dpi_cmd='get'; end
if ~exist('val'), val=0; end

ppi = get(0,'ScreenPixelsPerInch');
temp = get(0, 'ScreenSize');
hPix = temp(3);

if strcmp(lower(dpi_cmd), 'get')
   out=ppi;
   return
end


init_ppi=ppi;
init_hPix = hPix;

% if there is a DPI parameter entered:  If in acceptable range, apply it.
% Otherwise prompt user for proper value.
if (val<60 | val>150) 
	which = -1;
	disp('Do you wish to: ')
	disp('   (0) Do nothing at this time.')
	disp('   (1) Set DPI to proper value for this monitor?')
	disp('   (2) Force display to a specific DPI value?')
	disp(' ')
	while( which<0 | which>2)
		which = input('  -->  ');
	end
 else
   set(0,'ScreenPixelsPerInch',val)
   return
end 


switch which
   case 0
      disp('To run this program again, type "dpi"')
      return
   case 1
      monitor_width = input('What is the monitor width (in inches)? ');
      new_ppi=hPix/monitor_width;
      disp(['True DPI for this monitor is ' num2str(new_ppi) ' pixels/inch.'])
      set(0,'ScreenPixelsPerInch',new_ppi)
   case 2
      new_ppi = input('What is the desired DPI setting? ');
      set(0,'ScreenPixelsPerInch',new_ppi)
end      

% write new PPI out to preference file.
cur_dir = pwd;
cd(findomprefs)
save 'DPIprefs.txt' new_ppi -ASCII
cd(cur_dir)