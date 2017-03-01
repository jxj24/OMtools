% latchp.m: display latch timing

subplot(4,1,1);plot(t,pulse,'b')
ylabel('In')
set(gca,'Box','off')

subplot(4,1,2);plot(t,enable,'g')
ylabel('Enable?')
set(gca,'Box','off')

subplot(4,1,3);plot(t,swin,'r')
ylabel('SWin')
set(gca,'Box','off')

subplot(4,1,4);plot(t,swout,'c')
ylabel('SWout')
set(gca,'Box','off')

xlabel('Time (ms)')