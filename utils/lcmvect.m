% out = lcmvect( in )
% Find the least common multiple (lcm) of a list of numbers. Unlike
% MATLAB's  buit-in lcm function, this one can not only handle more than two
% numbers at a time, they list can also be non-integer, thanks to MATLAB's
% 'rat' function. I don't know if I would have been clever enough to write
% 'rat' from scratch, but I was clever enough to figure out how to use it.

% Written by: Jonathan Jacobs
% February 2017

function out = lcmvect(in)

% no negatives allowed
% but non-integers are!
in = abs(in);
[r,c]=size(in); if r>c, in=in'; end

if any( fix(in) ~= in )
   [n,d] = rat(in);
   lcd = lcmfunct(d);
   out = lcmfunct( n.* (lcd./d) ) / lcd;
else
   out = lcmfunct(in);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is the actual computation of Least Common Multiple
function out = lcmfunct(in)

% find prime factors for each input value
%factsmat = cell(length(in),1);
max_len = 0;
for i = 1:length(in)
   facts = factor(in(i));
   if length(facts)>max_len, max_len=length(facts); end
   factsmat{i} = facts;
end

% generate prime number list:
% find LARGEST prime factor over all input values
% make placeholders for all primes up to & including largest.
primeslist = primes( max(cell2mat(factsmat)) );
pr_facts   = zeros(1,length(primeslist));

% how many occurrences of each prime occur in each input number
%in
%primeslist
for i = 1:length(primeslist)
   % examine each input value's primes count vs prime factors list
   % store the maximum number of each prime per input value
   for j = 1:length(in)
      num_prfacts = length( find( factsmat{j} == primeslist(i) ) );      
%     disp(['In: ' num2str(in(j)) ' factor: ' num2str(primeslist(i)) ...
%         ' #: ' num2str(num_prfacts) ])      
      if num_prfacts > pr_facts(i), pr_facts(i) = num_prfacts; end
   end
end

out = prod(primeslist.^pr_facts);
