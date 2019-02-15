function ftest_act(gorl)

% do whatever you wish with the event/hFig information
if contains(gorl,'gained')
   disp('ftest_gui: focus gained')

elseif contains(gorl,'lost')
   disp('ftest_gui: focus lost')

end

end %function