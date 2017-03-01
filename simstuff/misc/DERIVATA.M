function deriv=derivata(vett,passo)
%function deriv=derivata(vett,passo)
%Calculates least squares derivative
%vett is the input vector
%passo is smpf (=sampling time)
passo = 1/passo ;
dim=max(size(vett));
temp=zeros(dim,1);
temp(1)=(vett(2)-vett(1))/passo;
temp(2)=(vett(3)-vett(2))/passo;
temp(dim)=(vett(dim)-vett(dim-1))/passo;
temp(dim-1)=(vett(dim-1)-vett(dim-2))/passo;
dim1 = dim-2;
centrale(3:dim1)=(vett(4:dim1+1)-vett(2:dim1-1))/12;
esterno(3:dim1)=(vett(5:dim1+2)-vett(1:dim1-2))/12;
temp(3:dim1)=(1/passo)*(8*centrale(3:dim1)-esterno(3:dim1));


deriv=temp;
