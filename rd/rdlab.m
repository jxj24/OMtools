% rdlab:  Used to read in data taken by acquire*.vi
% Version 5.0
% Author:  Vallabh Das
% Edited by: Jeff Somers

global2

[filename , path] = uigetfile('*.lab') ;
if filename == 0   
   return;
end
eval( 'cd (path)' );
fid = fopen(filename,'r','b') ;
f1 = fread(fid,40,'char') ;
fname = char(f1');
clear f1
fseek(fid,1,'cof') ;
f2 = fread(fid,80,'char') ;
comments = char(f2') ;
clear f2
fseek(fid,1,'cof') ;
f3 = fread(fid,60,'char') ;
chnls = char(f3') ;
clear f3
fseek(fid,1,'cof') ;
f4 = fread(fid,5,'char') ;
points = str2double(char(f4')) ;
clear f4
fseek(fid,1,'cof') ;
f5 = fread(fid,4,'char') ;
smpf = str2double(char(f5')) ;
clear f5
fseek(fid,1,'cof') ;
f6 = fread(fid,100,'char') ;
calib = str2double(char(f6')) ;
clear f6
fseek(fid,1,'cof') ;
f7 = fread(fid,9,'char') ;
indic = char(f7') ;
clear f7
new_flag = strcmp(indic,'AO_PARAMS') ;
only_ai_flag = strcmp(indic,'ONLY_ANIN') ;
clear indic
if (new_flag)
   fseek(fid,1,'cof') ;
   f8 = fread(fid,6,'char') ;
   ao_smpf = str2double(char(f8')) ;
   clear f8
   fseek(fid,1,'cof') ;
   f9 = fread(fid,6,'char') ;
   n_ao_pts = str2double(char(f9')) ;
   clear f9
   fseek(fid,1,'cof') ;
   f10 = fread(fid,2,'char') ;
   n_int_arrays = str2double(char(f10')) ;
   clear f10
   fseek(fid,1,'cof') ;
   f11 = fread(fid,40,'char') ;
   ch_labels = char(f11') ;
   clear f11
   ch_lab_temp = lower(ch_labels) ;
elseif (only_ai_flag)
   n_int_arrays = 0 ;
   ao_smpf = 0 ;
   n_ao_pts = 0 ;
   fseek(fid,1,'cof') ;
   f11 = fread(fid,40,'char') ;
   ch_labels = char(f11') ;
   clear f11
   ch_lab_temp = lower(ch_labels) ;
else
   fseek(fid,-10,'cof') ;
   ao_smpf = 100 ;
   n_int_arrays = 6 ;
   n_ao_pts = input('No of points in Analog Out: ') ;
end   
clear new_flag only_ai_flag 
%internal arrays
% data in volts
% since analog output is of different frequency frm analog in  - 
% we need to interpolate to get correct array lengths
% arrays must be concatenated depending on length 
% of input
internal = fread(fid,[n_int_arrays,n_ao_pts],'float32') ;
internal = internal' ;

if (~isempty(internal))
   interp_factor = smpf/ao_smpf ;
   cat_factor = ceil(points/(n_ao_pts*interp_factor)) ;
   clear n_ao_pts ao_smpf 
   %chair scaled to degs/sec
   chair = internal(:,1).*30 ;
   chair = interp(chair,interp_factor) ;
   chair1 = chair ;
   for i=1:cat_factor
      chair = cat(1,chair,chair1) ;
   end
   clear chair1
   chair = chair(1:points) ;
   %x_laser scaled to degs
   th = internal(:,2).*4.667 ;
   th = interp(th,interp_factor) ;
   th1 = th ;
   for i=1:cat_factor
      th = cat(1,th,th1) ;
   end
   clear th1 
   th = th(1:points) ;
   %y_laser scaled to degs
   tv = internal(:,3).*4.508 ;
   tv = interp(tv,interp_factor) ;
   tv1 = tv ;
   for i=1:cat_factor
      tv = cat(1,tv,tv1) ;
   end
   clear tv1
   tv = tv(1:points) ;
   
   %projector scaled to degs
   proj = internal(:,4).*5 ;
   proj = interp(proj,interp_factor) ;
   proj1 = proj ;
   for i=1:cat_factor
      proj = cat(1,proj,proj1) ;
   end
   clear proj1
   proj = proj(1:points) ;
   
   switch n_int_arrays
      
   case 5,
      dig_p0 = internal(:,5) ;
      dig_p0 = interp(dig_p0,interp_factor) ;
      dig_temp = zeros(length(dig_p0),1) ;
      dig_temp1 = dig_temp ;
      for i=1:cat_factor
         dig_p0 = cat(1,dig_p0,dig_temp1) ;
      end
      clear dig_temp1
      dig_p0 = dig_p0(1:points) ;
      
      
   case 6,
      %shutters and laser diode are pre-sclaed
      xy = internal(:,5) ;
      xy = interp(xy,interp_factor) ;
      xy1 = xy ;
      for i=1:cat_factor
         xy = cat(1,xy,xy1) ;
      end
      xy = xy(1:points) ;
      %to take care that laser diode on is logic high
      xy = 1-xy ;
      
      proj_sh = internal(:,6) ;
      proj_sh = interp(proj_sh,interp_factor) ;
      proj_sh1 = proj_sh ;
      for i=1:cat_factor
         proj_sh = cat(1,proj_sh,proj_sh1) ;
      end
      proj_sh = proj_sh(1:points) ;
      
   case 8,
      %port 0
      dig_p0 = internal(:,5) ;
      dig_p0 = interp(dig_p0,interp_factor) ;
      dig_temp = zeros(length(dig_p0),1) ;
      for i=1:cat_factor
         dig_p0 = cat(1,dig_p0,dig_temp) ;
      end
      dig_p0 = dig_p0(1:points) ;
      
      %port 1
      dig_p1 = internal(:,6) ;
      dig_p1 = interp(dig_p1,interp_factor) ;
      dig_temp = zeros(length(dig_p1),1) ;
      for i=1:cat_factor
         dig_p1 = cat(1,dig_p1,dig_temp) ;
      end
      dig_p1 = dig_p1(1:points) ;
      
      %port 2
      dig_p2 = internal(:,7) ;
      dig_p2 = interp(dig_p2,interp_factor) ;
      dig_temp = zeros(length(dig_p2),1) ;
      for i=1:cat_factor
         dig_p2 = cat(1,dig_p2,dig_temp) ;
      end
      dig_p2 = dig_p2(1:points) ;
      
      %port 3
      dig_p3 = internal(:,8) ;
      dig_p3 = interp(dig_p3,interp_factor) ;
      dig_temp = zeros(length(dig_p3),1) ;
      for i=1:cat_factor
         dig_p3 = cat(1,dig_p3,dig_temp) ;
      end
      clear dig_temp
      dig_p3 = dig_p3(1:points) ;
      
   otherwise,
   end
   
else
end

clear interp_factor cat_factor
% data arrays
if length(calib) >= 9
   range = calib(9) ;
else
   range = input('Input the range (+/- 50 = 100): ') ;
end
in_arr = fread(fid,inf,'int16') ;
sc_arr = in_arr.*(range/65536) ; %convert to degs
fclose(fid) ;
clear fid range
% creating a time array
t = 0:1/smpf:(points-1)/smpf ;
t = t' ;

% finding array names
ch_nam_temp = sscanf(chnls,'%6s',[7,inf]) ;
[~ , n_chnls]  = size(ch_nam_temp) ;
ch_nam_temp = lower(ch_nam_temp(1:6,:)') ;
arr_len = length(sc_arr) ;
for i=1:n_chnls
   eval([strcat(ch_nam_temp(i,:)) '= sc_arr(i:n_chnls:arr_len);']) ;
end
clear sc_arr arr_len chnls dummy i in_arr n_chnls

% multiplying by calib factors
% and assigning labels
if exist('eye1_h','var') 
   eye1_h = eye1_h.*calib(1) ;
   if exist('ch_labels','var')
      [arr1,ch_lab_temp] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye1_h: ','s') ;
   end
   eval([arr1 '=eye1_h;']) ;
   clear arr1
end

if exist('eye2_h','var')
   eye2_h = eye2_h.*calib(2) ;
   if exist('ch_labels','var')
      [arr1,ch_lab_temp] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye2_h: ','s') ;
   end
   eval([arr1 '=eye2_h;']) ;
   clear arr1
end

if exist('eye3_h','var')
   eye3_h = eye3_h.*calib(3) ;
   if exist('ch_labels','var')
      [arr1,ch_lab_temp] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye3_h: ','s') ;
   end
   eval([arr1 '=eye3_h;']) ;
   clear arr1
end

if exist('eye1_v','var')
   eye1_v = eye1_v.*calib(4) ;
   if exist('ch_labels','var')
      [arr1,ch_lab_temp] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye1_v: ','s') ;
   end
   eval([arr1 '=eye1_v;']) ;
   clear arr1 
end

if exist('eye2_v','var')
   eye2_v = eye2_v.*calib(5) ;
   if exist('ch_labels','var')
      [arr1,ch_lab_temp] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye2_v: ','s') ;
   end
   eval([arr1 '=eye2_v;']) ;
   clear arr1
end

if exist('eye3_v','var')
   eye3_v = eye3_v.*calib(6) ;
   if exist('ch_labels','var')
      [arr1,ch_lab_temp] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye3_v: ','s') ;
   end
   eval([arr1 '=eye3_v;']) ;
   clear arr1
end

if exist('eye1_t','var')
   eye1_t = eye1_t.*calib(7) ;
   if exist('ch_labels','var')
      [arr1,ch_lab_temp] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye1_t: ','s') ;
   end
   eval([arr1 '=eye1_t;']) ;
   clear arr1
end

if exist('eye2_t','var')
   eye2_t = eye2_t.*calib(8) ;
   if exist('ch_labels','var')
      [arr1,~] = strtok(ch_lab_temp,',') ;
   else
      arr1 = input('Assign label to eye2_t: ','s') ;
   end
   eval([arr1 '=eye2_t;']) ;
   clear arr1
end
clear calib ch_lab_temp 

% displaying available information
fprintf('\n\n')
disp('The analog input channels are ')
disp(ch_nam_temp)
if exist('ch_labels','var')
   disp('The labels assigned are ')
   disp(ch_labels)
else
end
if (~isempty(internal))
   disp('The internal analog arrays are chair, th, tv, proj')
   
   switch n_int_arrays
   case 5,
      disp('The internal digital arrays are dig_p0')
   case 6,
      disp('The internal digital arrays are xy (for xy laser diode), and proj_sh (for projector shutter)')
   case 8,
      disp('The internal digital arrays are dig_p0,dig_p1,dig_p2,dig_p3')
   otherwise,
   end
   
else
end

disp(['The sampling rate for A/D is ' num2str(smpf) ' Hz'])
disp(['The length of each channel for A/D is ' num2str(points) ' points'])
disp(comments)
disp(fname)

clear ch_labels comments fname ch_nam_temp internal n_int_arrays 