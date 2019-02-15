% AKshift.m: convert between Total mm of R&R and Null-Angle shift.% Usage: out = akshift(mm_or_ang, inputValue, rr);%% where mm_or_ang = 1 converts mm of Surgical Rotation to Null-Angle Shift%                 = 2 converts Null-Angle Shift to mm of Surgical Rotation% inputValue is the number to be converted.% rr = 0 returns 'out' as an Angle or single-muscle mm.%    = 1 returns 'out' as an  Angle or total mm of R&R.%% Alternatively, you can simply type "pd2ang" and follow the prompts% To plot the function, use 'AKplot'function out = akshift(mm_or_ang, inpVal, rr)if nargin == 0   mm_or_ang = -1;   inpVal=-1;   verbose=1; else   verbose=0;endwhile(mm_or_ang<0) | (mm_or_ang>2)   disp(' 0) Quit')   disp(' 1) Convert Surgical Rotation to Null-Angle Shift')   disp(' 2) Convert Null-Angle Shift to Surgical Rotation')   mm_or_ang = input(' --> ');endswitch mm_or_ang case 0    disp('aborting')    return case 1   mm=inpVal;   if verbose      disp(' ')      disp(' 1) Single Muscle Relocation')      disp(' 2) Total R&R Relocations')      rr = input(' --> ');   end    switch rr    case 1      while (mm<0) | (mm>25)         mm = input('Enter the mm of single-muscle movement: ');      end      ang = (mm/0.00128).^(1/2.79);      if verbose         disp(['  Null-Angle Shift calculated to be ' num2str(ang) ' deg'])         return      end      out = ang;           case 2      while (mm<0) | (mm>25)         mm = input('Enter Sum of total muscle movement: ');      end               ang = (mm/0.00256).^(1/2.79);      if verbose         disp(['  Null-Angle Shift calculated to be ' num2str(ang) ' deg'])         return      end      out = ang;   otherwise     disp([num2str(rr) ' is not a valid choice'])       end  %% switch rr   case 2   ang=inpVal;   if verbose      disp(' ')      disp(' 1) Single Muscle Relocation')      disp(' 2) Total R&R Relocation')      rr = input(' --> ');   end   switch rr    case 1      while (ang<0) | (ang>30)         ang = input('Enter the Null Angle (degrees): ');      end         mm = 0.00128*(ang).^2.79;      if verbose         disp(['  Single-muscle rotation calculated to be ' num2str(mm)  ' mm'])         return      end      out = mm;    case 2      while (ang<0) | (ang>30)         ang = input('Enter the Null Angle (degrees): ');      end      mm = 0.00256*(ang).^2.79;          if verbose         disp(['  Total R&R Relocation calculated to be ' num2str(mm)  ' mm'])         return      end      out = mm;             otherwise      disp([num2str(rr) ' is not a valid choice'])   end %% switch rr otherwise   disp([num2str(mm_or_ang) ' is not a valid choice'])   end