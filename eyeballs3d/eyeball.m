eyeballH = figure('Position',[ 2  45 397 291],...
                  'Color', [0.75 0.75 0.75]);

[z,y,x]=sphere(40);
%a=[x(26,28) x(26,19) x(26,10) x(26,1)];
%b=[y(26,28) y(26,19) y(26,10) y(26,1)];
%c=[z(26,28) z(26,19) z(26,10) z(26,1)];

eyeColor = [0 0 1];

depth = 512;
iris_sclera = 470;
iris_pupil  = 505;

map = ones(depth,3);
map(iris_pupil+1:512,:) =  0;

for i=iris_sclera:iris_pupil
   map(i,:) = eyeColor;
end

socket = axes;
od=surf(x,y,z,x);
set(od,'LineStyle','none')
set(socket,'view',[90 0]);

axis equal; axis off
axis vis3d
hold on
colormap(map)

lt1 = camlight(0,00);
lt2 = camlight(0,20);
material('dull')
lighting('gouraud')
