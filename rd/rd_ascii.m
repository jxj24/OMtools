% rd_ascii.m:  called by RD to handle whitespace delimited% ASCII data files (such as the MD data)% This m-file can read in multiple data files (of different% durations no less!) and assign them to columns, eg lh, rh, lv, etc.% written by:  Jonathan Jacobs%              September 1995 - February 2004  (last mod: 02/25/02)% this has outlived its usefulness. deprecate.% We've added another file to the list of open files.% a_files = a_files + 1;% total_files = r_files + a_files + b_files...%                    + o_files + x_files + l_files;% load the file and put the data into 'newdata' eval( [ 'load ' lower(filename) ] )newdata = eval(lower(shortname));[dat_len, dat_cols] = size( newdata );disp( ['  Channels found: ' num2str(dat_cols)] );disp( ['  Samples found: ' num2str(dat_len)] );getbiasapplybias% return to RD