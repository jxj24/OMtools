% look at distribution of vel,acc waveforms. 
% sum up total pts from center (~0) outwards.
% assumes roughly symmetric, unimodal waveform.

function [lower, upper]=bfi_distrib(in,pct)

if nargin<2, pct=0.85; end

[n,edges]=histcounts(in,500);

total_n = sum(n);
max_ind = find(n==max(n));

running_n = n(max_ind);
ii=0;

while running_n < pct*total_n
   ii=ii+1;
   new_lo_val = n(max_ind-ii);
   new_hi_val = n(max_ind+ii);
   running_n = running_n + new_lo_val + new_hi_val;
   
   run_pct=running_n/total_n;
   if (run_pct>0.45) && (run_pct<=0.50)
      low50 = edges(max_ind+1-ii);
      upp50 = edges(max_ind+1+ii);
   elseif (run_pct>0.55) && (run_pct<=0.60)
      low60 = edges(max_ind+1-ii);
      upp60 = edges(max_ind+1+ii);
   elseif (run_pct>0.65) && (run_pct<=0.70)
      low70 = edges(max_ind+1-ii);
      upp70 = edges(max_ind+1+ii);
   elseif (run_pct>0.75) && (run_pct<=0.80)
      low80 = edges(max_ind+1-ii);
      upp80 = edges(max_ind+1+ii);
   elseif (run_pct>0.85) && (run_pct<=0.90)
      low90 = edges(max_ind+1-ii);
      upp90 = edges(max_ind+1+ii);
   end
end

lower = edges(max_ind+1-ii);
upper = edges(max_ind+1+ii);

figure;plot(edges(2:end),n)
ax=gca;
hold on
plot([lower lower],[0 max(n)],'Color',[1 0 0])
plot([upper upper],[0 max(n)],'Color',[1 0 0])
text(upper,0.4*max(n),[num2str(pct) '%'])

if pct>=0.5
   plot([low50 low50],[0 max(n)],'Color',[0.75 0.75 0.75])
   plot([upp50 upp50],[0 max(n)],'Color',[0.75 0.75 0.75])
   text(upp50,0.9*max(n),'50%')
end
if pct>=0.6
   plot([low60 low60],[0 max(n)],'Color',[0.66 0.66 0.66])
   plot([upp60 upp60],[0 max(n)],'Color',[0.66 0.66 0.66])
   text(upp60,0.8*max(n),'60%')
end
if pct>=0.7
   plot([low70 low70],[0 max(n)],'Color',[0.5 0.5 0.5])
   plot([upp70 upp70],[0 max(n)],'Color',[0.5 0.5 0.5])
   text(upp70,0.7*max(n),'70%')
end
if pct>=0.8
   plot([low80 low80],[0 max(n)],'Color',[0.25 0.25 0.25])
   plot([upp80 upp80],[0 max(n)],'Color',[0.25 0.25 0.25])
   text(upp80,0.6*max(n),'80%')
end
if pct>=0.9
   plot([low90 low90],[0 max(n)],'Color',[0.1 0.1 0.1])
   plot([upp90 upp90],[0 max(n)],'Color',[0.1 0.1 0.1])
   text(upp90,0.5*max(n),'90%')
end

ax.XLim = [2*lower 2*upper];
%plot([edges(1) edges(end)], [pct pct])