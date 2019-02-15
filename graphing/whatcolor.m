
function color = whatcolor(colorval)

abbrev = ['k';'b';'g';'c';'r';'m';'y';'w'];

colorlist = {'black';'blue';'green';'cyan';'red';'magenta';'yellow';'white';...
   'orange';'dk. orange';'lt. gray';'med. gray';'dk. gray';'off-white';...
   'other...';'auto';'none'};

bgclrlist = {'w';'w';'green';'k';'w';'w';'k';'k';...
   'w';'w';'k';'w';'w';'k';...
   'r';'w';'w'};

ORANGE = 9;  DKORANGE = 10;
LTGRAY = 11; MEDGRAY  = 12;
DKGRAY = 13; OFFWHITE = 14;
OTHER = 15;  AUTO = 16; NONE = 17;

color.colorval=colorval;

if ischar(colorval)
   switch colorval(1)
      case 'a'
         color.index = AUTO;
      case 'n'
         color.index = NONE;
      otherwise
         color.index = find(abbrev==colorval(1));
   end
   color.str   = colorlist{color.index};
   color.bgstr = bgclrlist{color.index};
   
else
   if any(colorval>0 & colorval<1)
      if all(colorval==[1 0.5 0])
         color.index = ORANGE;
      elseif all(colorval==[1.0 0.25 0.0])
         color.index = DKORANGE;
      elseif all(colorval==[0.75 0.75 0.75])
         color.index = LTGRAY;
      elseif all(colorval==[0.5 0.5 0.5])
         color.index = MEDGRAY;
      elseif all(colorval==[0.15 0.15 0.15])
         color.index = DKGRAY;
      elseif all(colorval==[0.94 0.94 0.94])
         color.index = OFFWHITE;
      else
         color.index = OTHER;
         % truncate the RGB components to fit w/in 13 chars.
         valstr=cell(1,3);
         for k=1:3
            temp= num2str(colorval(k));
            if ~contains(temp,'.')
               valstr{k} = temp(1);
            else
               [~,b] = strtok(temp,'.');
               valstr{k} = b;
            end
         end
         color.str=[valstr{1} ' ' valstr{2} ' ' valstr{3}];
      end
   else
      % the built-in ML colors 1-8
      if length(colorval)==1
         temp = reverse(dec2bin(colorval));
         colorval = [0 0 0 0];
         for ii=1:length(temp)
            colorval(ii)=str2num(temp(ii));
         end
      end
      color.index = colorval(1)*4 + colorval(2)*2 + colorval(3) + 1;
      
   end
   
   color.lum = perceivedlum(colorval);
   
   if color.index~=OTHER
      color.str=colorlist{color.index};
   end
   
   if color.lum.a<0.5
      color.bgstr='w';
   else
      color.bgstr='k';
   end
   
end

end % function

%%%%%%%%%%%%%
function lum = perceivedlum( rgb )

R = rgb(1);
G = rgb(2);
B = rgb(3);

lum.a = sqrt( 0.299*R^2 + 0.587*G^2 + 0.114*B^2 );
lum.b = 0.299*R + 0.587*G + 0.114*B;
lum.c = 0.2126*R + 0.7152*G + 0.0722*B;


end