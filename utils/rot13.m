function x = rot13(x,shift)

if nargin<2, shift=13; end

ind = ( x>='a' & x<='z' );
x(ind) = char( mod(x(ind) - 'a' + shift, 26) + 'a' );

ind = ( x>='A' & x<='Z' );
x(ind) = char( mod(x(ind) - 'A' + shift, 26) + 'A' );