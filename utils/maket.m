% maket.m: make a time vector for the given array.
% usage: t = maket(inArray, sample frequency);

% Written by: Jonathan Jacobs
%             February 1997 - April 1998 (last mod: 04/02/98)

function  t_vect = maket(inArray, samp_vect)
global samp_freq

if nargin == 0
   help maket
   return
end

if nargin == 1
   samp_vect = samp_freq;
   if (isempty(samp_vect)) || (samp_vect == 0)
      while (isempty(samp_vect)) || (samp_vect == 0)
         samp_vect = input( 'Enter the sampling frequency: ');
      end
   end
end

numDPts = max(size(inArray));
t_vect = (1:numDPts)'/samp_vect(1);
