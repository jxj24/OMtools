function  amplvect = loadcomponent(firstcomponent,samptemp)

if ~exist('samptemp'), samptemp=100; end

%% get the other component -- embedded in while loop -- keep trying until happy with selection
%% main loop is terminated by a successful selection (one that meets all the criteria that
%% are being tested by the inner loops).  inner loops are terminated by a break when successful
isSelected = 0;
while ~isSelected 

	isAscii = 0; 

	while (~isAscii)
	  [filename pathname] = uigetfile('*.*','Select a ''.stm'' file');
	  if filename == 0
		  secondcomponent = [];
		  break;
		else
		  try
			 secondcomponent = load(['' pathname filename '']);
			 isAscii = 1;
			catch
			 display('You did not select an ASCII stimulus file. Try again.')
		  end

		end  
	end  %%while isAscii
			
	
	%% check dimensions of the loaded second component.  Must be only one dimensional.
	%% it is easier to work with row-oriented data for now (1 sample/column) 
	[r1,c1]=size(firstcomponent);
	if c1<r1, firstcomponent=firstcomponent'; end
	[r2,c2]=size(secondcomponent);
	if c2<r2, secondcomponent=secondcomponent'; end

	isOneDim = 0;
	numchans = min(r2,c2);
	if numchans <= 1, isOneDim = 1; end	
	while (isAscii & ~isOneDim)
		t=maket(secondcomponent,samptemp);
		colorlist = ['b', 'r', 'g', 'm', 'c'];
		colorstrings = [{'(b)lue'}, {' (r)ed'}, {' (g)reen'}, {' (m)agenta'}, {' (c)yan'}];
		colordef white
		colorselectstr = '';
		componentfigure = figure; hold on
		for i = 1:numchans
			plot(t,secondcomponent(i,:),colorlist(i) )
			colorselectstr = [colorselectstr colorstrings{i}];
		end
		if min(r2,c2) > 1
			%% if it is a multi-channel stim let user select one of the channels.
			display(['This file has ' num2str(numchans) ' channels.'])
			whichchan = lower(input(['Which channel do you want [' colorselectstr ']? '],'s'));
			switch whichchan
				case {'b','blue'}
					chanindex=1;
				case {'r','red'}
					chanindex=2;
				case {'g','green'}
					chanindex=3;
				case {'m','magenta'}
					chanindex=4;
				case {'c','cyan'}
					chanindex=5;
				otherwise
					isOneDim=0;
					break
			end
			isOneDim=1;
			secondcomponent = secondcomponent(chanindex,:);
		end
		
	end %% while (isAscii & ~isOneDim)
		
	%% is the loaded component the same length as the generated component?  if not, 
	%% offer to trim/padone or the other, then display the two components together.
	if length(firstcomponent) > length(secondcomponent)
		display(['The loaded stimulus is shorter than the just-created one.'])
		display(['I will pad it to the same length.'])
		padlen = length(firstcomponent)-length(secondcomponent);
		secondcomponent = [secondcomponent zeros(1,padlen)];
	  elseif  length(firstcomponent) < length(secondcomponent)
		display(['The loaded stimulus is longer than the just-created one.'])
		display(['I will truncate it to the same length.'])
		secondcomponent = secondcomponent(1:length(firstcomponent));
	end

	h_or_v = lower(input('Will the loaded stimulus be the (h)orizontal or the (v)ertical component?' ,'s'));
	if strcmp(h_or_v,'v')
		amplvect = [firstcomponent' secondcomponent']';
	  else
		amplvect = [secondcomponent' firstcomponent']';
	end   
	%% amplvect is still samples along columns, one channel per row
	
	%% is this what you wanted?
	t=maket(secondcomponent,samptemp);
	figure(componentfigure)
	subplot(2,1,1)
	plot(t,amplvect(1,:))
	ylabel('Hor. Stim.')
	subplot(2,1,2)
	plot(t,amplvect(2,:))
	ylabel('Vrt. Stim.')
	xlabel('Time')
	
	happy = lower(input('Are you happy with this result (y/n)? ','s'));
	if strcmp(happy, 'y')
		;
	 else
		isAscii = 0;
	end 
	close(componentfigure)      

	
	%% reasons to exit the loop:  1) we've canceled file selection 
	%% 								or 2) we've satisfied all requirements
	if isempty(secondcomponent), break; end
	isSelected = isAscii & isOneDim;
end
