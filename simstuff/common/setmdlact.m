function setmdlact(action, value)

global mdlparamlist lastsave lastload mdlname paramsetname saved mdlparamWinH varH numVars

switch(action)

  case('new_set')
    %disp('setmdlact:new')
    if value == 0
       value = get(gco,'Value');
    end
    switch(value)
      case(0)
         % should never happen
      case(1)
         % nothing to do

      case(2)
	    % Normal 
        paramsetname = 'Normal Default'; 
	    mdlparamlist = [ 1.1   35     30   0.0000     1.0 ...    % 1 - 5
						 5.0  1.0   50.0     0.95   -0.03 ...    % 6 - 10
						   0    1      0        1      60 ...    % 11 - 15
						   0    1      7       40       0 ...    % 16 - 20
						   0    0      0        1       1 ...    % 21 - 25
						   0    0	   0		0		0];      % 26 - 30

      case(3)
	   % INS Pendular
	   paramsetname = 'INS Pendular Default'; 
	   mdlparamlist = [3.025   35     40   0.0001     1.0 ...    % 1 - 5
						 5.0  1.0    50.0    0.95   -0.03 ...    % 6 - 10
						   0    1      1        1      60 ...    % 11 - 15
						   1    1      7       40       0 ...    % 16 - 20
						   0    0      0        1       1 ...    % 21 - 25
						   0    0	   0		0		0];      % 26 - 30

      case(4)
	    % INS Jerk Right
        paramsetname = 'INS JR Default'; 
	    mdlparamlist = [ 1.1    35     40    0.00     1.0 ...    % 1 - 5
						 5.0  1.0   50.0     0.95   -0.03 ...    % 6 - 10
						   0    1      0        1      60 ...    % 11 - 15
						   0    1      7       40       0 ...    % 16 - 20
						   1    1      3        1       1 ...    % 21 - 25
						   0    0	   0		0		0];      % 26 - 30
				   
      case(5)
	    paramsetname = 'INS JL Default'; 
	    % JLefdefaultlist 
	    mdlparamlist = [ 1.1    35     40   0.00      1.0 ...    % 1 - 5
						 5.0  1.0   50.0     0.95   -0.03 ...    % 6 - 10
						   0    1      0        1      60 ...    % 11 - 15
						   0    1      7       40       0 ...    % 16 - 20
						   1    2     -3        1       1 ...    % 21 - 25
						   0    0	   0		0		0];      % 26 - 30

      case(6)
	    % FMNS
	    paramsetname = 'FMNS Default'; 
	    mdlparamlist = [ 1.1   35     30   0.0001     1.0 ...    % 1 - 5
						 5.0  1.0   50.0     0.95   -0.03 ...    % 6 - 10
						   0    1      0        1      60 ...    % 11 - 15
						   0    1      7       40       0 ...    % 16 - 20
						   0    0      0        1       1 ...    % 21 - 25
						   0    0	   0		0		0];      % 26 - 30

   end %value

   set(gcf,'name',['Model Params: ' paramsetname])
   %set control values
   for j = 1:numVars
      set( varH(j),'String', num2str(mdlparamlist(j)) )
   end
   set(gco,'Value',1)

   %cd(findomprefs)
   %save mdlparams.mat mdlparamlist lastsave lastload mdlname paramsetname saved
       

  case('setvar')
    %disp('setmdlact:setvar')
	which=get(gco,'UserData');
	newVal = str2double(get(varH(which), 'String'));
	titlestr = get(mdlparamWinH,'Name');
	if ~strcmp(titlestr(1), '*')
	   saved = 0;
	   set(mdlparamWinH,'Name', ['*', titlestr]);
	end
	mdlparamlist(which) = newVal;


  case('load')
    %disp('setmdlact:load')
	setmdlp_tmp=pwd;
	set(gco,'Userdata',setmdlp_tmp);
	eval(['cd(' '''' lastload '''' ')']);
	[fn,pn]=uigetfile('*.mat');
	if fn == 0, cd(setmdlp_tmp); return; end;
	newlastload = pn;
	eval('load([pn fn])');
	cd(matlabroot); cd(findomprefs);
	paramsetname = fn;
	lastload = newlastload;
	save mdlparams.mat mdlparamlist lastsave lastload mdlname paramsetname saved;
	close(mdlparamWinH);
	setmdlp;
	cd(setmdlp_tmp);
	clear setmdlp_tmp;

 
  case('save')
    %disp('setmdlact:save')
	setmdlp_tmp=pwd;
	set(gco,'Userdata',setmdlp_tmp);
	eval(['cd(' '''' lastsave '''' ')' ]);
	[fn,pn]=uiputfile('*.mat','Save these params as a ".mat" file');
	if fn == 0, cd(setmdlp_tmp); return; end;
	lastsave = pn;
	paramsetname = fn;
	set(mdlparamWinH,'Name',['Model Params: ' paramsetname]);
	cd(matlabroot); cd(findomprefs);
	saved=1;
	save mdlparams.mat mdlparamlist lastsave lastload mdlname paramsetname saved;
	eval('cd(pn)');
	eval(['save ' '''' fn '''' ' mdlparamlist lastsave lastload mdlname paramsetname saved']);
	titlestr = get(mdlparamWinH,'Name');
	if strcmp(titlestr(1) ,'*')
	   set(mdlparamWinH,'Name', titlestr(2:end));
	end
	saved=0; 
	cd(setmdlp_tmp);
	clear setmdlp_tmp;
 
 
  case('apply')
    %disp('setmdlact:apply')
	cd(matlabroot); cd(findomprefs);
	save mdlparams.mat mdlparamlist lastsave lastload mdlname paramsetname saved;
	

  case('cancel')
    %disp('setmdlact:cancel')
	close(mdlparamWinH);
	clear global mdlparamlist lastsave lastload mdlname paramsetname saved mdlparamWinH


  case('done')
    %disp('setmdlact:done')
	setmdlp_tmp=pwd;
	set(gco,'Userdata',setmdlp_tmp);
	cd(matlabroot); cd(findomprefs);
	save mdlparams.mat mdlparamlist lastsave lastload mdlname paramsetname saved;
	close(mdlparamWinH);
	clear global mdlparamlist lastsave lastload mdlname paramsetname saved mdlparamWinH
	cd(setmdlp_tmp);
	clear setmdlp_tmp;


end %action
