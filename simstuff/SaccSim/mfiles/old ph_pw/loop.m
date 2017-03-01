% loop.m:

j=1;
index = 0:0.1:50;
for i = index
  ph(j)  = PHnew(i);
  phs(j) = PHsimp(i);
  pw(j)  = PWnew(i);
  pw2(j) = PWnew2(i);
  pw3(j) = PWnew3(i);
  j=j+1;
end

%figure
%plot(index,ph)
%title('Duration function:''PHnew''')

%figure
%plot(index,pw)
%title('Duration function:''PWnew''')

%hold on
%figure
%plot(index,pw2,'g')
%title('Duration function:''PWnew2''')

figure
plot(index,pw3,'c')
%title('Duration function:''PWnew3''')