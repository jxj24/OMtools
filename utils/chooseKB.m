function [kbIndex, kbName] = chooseKB(forcecheck)

% chooseKB: identify and select the active keyboard.
% Usage: [kbIndex, kbName] = chooseKB(forcecheck)
%    forcecheck = 1: force choosKB to examine and verify all possible
%    devices, rather than automatically guess one based on available names.

% Written by; Jonathan Jacobs
% November 2015 - August 2017  (last mod: 4 August 2017)

if nargin==0,forcecheck=0;end

[kbIndices, product, allInfos] = GetKeyboardIndices;
% There may be multiple "keyboards" so we can try to find one we really like
% or we can use "-1" as the "look at all" option.
% go through list, use KbCheck + on-screen prompt: "press 'j' key" while monitoring
% each "keyboard" entry for keypress activity.
if isempty(kbIndices)
    sca
    disp('Oops! No keyboard detected! (How did you run this?)')
    return
end
if length(kbIndices) == 1
   if ~isempty(strfind((product{1}),'keyboard')) || ~isempty(strfind(lower(product{1}),'kb'))
      kbIndex = kbIndices(1); %only one keyboard. Hope it's valid
      kbName  = product(1);
   else
      disp('Oops! No keyboard detected! (How did you run this?)')
   end
   return
end

% look at names of each device. Compare against list of known devices
% or potential matches, e.g. KB, K/B, etc. If not able to make a choice
% then prompt the user for intervention.    
foundlist = zeros(2, length(kbIndices) );
goodKBlist = [ {'key'}, {'kb'}, {'kbd'}, {'board'}];
chickendinner = {'apple keyboard'}; % could add other known winners here
for kbl = 1:length(kbIndices)
    temp = lower( product{kbl} );
    alpha_ind = isstrprop(temp, 'alpha'); % all alphabetic characters OR
    ws_ind = isstrprop(temp, 'wspace');   % all whitespace characters
    aws_ind = alpha_ind | ws_ind ;        % YIELDS no numbers, punctuation
    tempKBname = temp(aws_ind);
         
    % do you feel lucky, punk? Well, do you?
    if ~forcecheck
       if strfind(tempKBname, chickendinner)
          kbIndex = kbIndices(kbl);
          kbName  = product(kbl);
          return
       end
    end
    
    % compare device string against possible matches.
    for i=1:length(goodKBlist)
       if strfind(tempKBname, goodKBlist{i})
          foundlist(1,kbIndices(kbl)) = 1;
          foundlist(2,kbIndices(kbl)) = kbl;
       end
    end
end    

% only one keyboard candidate found. Select it and exit.
kbcandidates = find(foundlist(1,:)==1);
if ~forcecheck
   if length( kbcandidates ) == 1
      kbIndex = kbcandidates;
      kbName  = product(foundlist(2,kbIndex));
      devnum  = foundlist(2,kbIndex);
      if nargout==0
         disp(['   Selected: ' allInfos{devnum}.product])
      end
      return
   end
end

% more KB TF: examine returned keyCode list
% open a small GUI here to catch attention and keypresses?
disp(' ')
disp('I have found multiple devices that may be keyboards');
disp('Hit the "j" key (probably multiple times) to identify the keyboard')
commandwindow
timeout = 0.125;
loopstart=GetSecs; looptimeout=15;
while GetSecs<loopstart+looptimeout
   for kbl = 1:length(kbcandidates)
      start_time=GetSecs(0);
      %disp(['testing device ' num2str(kbcandidates(kbl))])
      clear KbWait
      [~, keyCode, ~] = KbWait(kbcandidates(kbl),0,start_time+timeout);
      if keyCode(13)~=0
         kbIndex = kbcandidates(kbl);
         kbName  = product(kbl);
         disp(['Got it! -- ' char(kbName) ', index #' num2str(kbIndex)])
         return
      end
   end
end
disp('loop timeout')

% last ditch effort if autoguess and kbd polling didn't work.
disp('I cannot figure it out. It is up to you, human.');
disp('   0: I don''t know, either!!!')
for kbl = 1:length(kbcandidates)
    disp(['   ' num2str(kbl) ': ' allInfos{kbl}.product])
end    
       
whichKB = -1;
while whichKB < 0 || whichKB > length(kbcandidates)
    whichKB = input('Which device do you want to use? ');
end

disp(' ')
if whichKB > 0
   kbIndex = kbIndices(whichKB);
   kbName  = product{whichKB};
   return
end    
       
% we didn't know
disp(' ')
disp('Something is terribly wrong. I have failed you.')
kbIndex = 0;

% more KB TF: examine returned keyCode list
%disp('      ***')
%disp('Hit any key to identify the keyboard')
%disp('      ***')
%[secs, keyCode, deltaSecs] = KbWait(kbIndex);
%stuckDown = find(keyCode==1);
%olddisabledkeys = DisableKeysForKbCheck(stuckDown);

%[keyIsDown, secs, keyCode, deltaSecs] = KbCheck([deviceNumber])