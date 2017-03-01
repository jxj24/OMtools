function out = lcmvect(in)

[r,c]=size(in); if r>c, in=in'; end

% find prime factors for each input value
%factsmat = NaN( length(in), 20 );
for i = 1:length(in)
   facts = factor(in(i));
   factsmat(i, 1:length(facts)) = facts;
end

% generate prime number list:
% find LARGEST prime factor over all input values
% make placeholders for all primes up to & including largest.
primeslist = primes(max(max(factsmat)));
pr_facts   = zeros(1,length(primeslist));

% how many occurrences of each prime occur in each input number
for i = 1:length(primeslist)
   in_facts = factsmat(i,:);
   % examine each input value's primes count vs prime factors list
   % store the maximum number of each prime per input value
   for j = 1:length(in_facts)
      num_prfacts = length(find(in_facts) == primeslist(j));
      if num_prfacts > pr_facts(i), pr_facts(i) = num_prfacts; end
   end
end

out = prod(primeslist.^pr_facts);
