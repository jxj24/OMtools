for i=0:.1:1,
hold on;p=plot([i i],[0 1]);set(p,'color',[i 1 .5]);
hold on;p=plot([i+.01 i+.01],[0 1]);set(p,'color','w');
end