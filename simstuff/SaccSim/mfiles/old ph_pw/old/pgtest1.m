function [ret,x0,str,ts,xts]=pgtest1(t,x,u,flag);
%PGTEST1	is the M-file description of the SIMULINK system named PGTEST1.
%	The block-diagram can be displayed by typing: PGTEST1.
%
%	SYS=PGTEST1(T,X,U,FLAG) returns depending on FLAG certain
%	system values given time point, T, current state vector, X,
%	and input vector, U.
%	FLAG is used to indicate the type of output to be returned in SYS.
%
%	Setting FLAG=1 causes PGTEST1 to return state derivatives, FLAG=2
%	discrete states, FLAG=3 system outputs and FLAG=4 next sample
%	time. For more information and other options see SFUNC.
%
%	Calling PGTEST1 with a FLAG of zero:
%	[SIZES]=PGTEST1([],[],[],0),  returns a vector, SIZES, which
%	contains the sizes of the state vector and other parameters.
%		SIZES(1) number of states
%		SIZES(2) number of discrete states
%		SIZES(3) number of outputs
%		SIZES(4) number of inputs
%		SIZES(5) number of roots (currently unsupported)
%		SIZES(6) direct feedthrough flag
%		SIZES(7) number of sample times
%
%	For the definition of other parameters in SIZES, see SFUNC.
%	See also, TRIM, LINMOD, LINSIM, EULER, RK23, RK45, ADAMS, GEAR.

% Note: This M-file is only used for saving graphical information;
%       after the model is loaded into memory an internal model
%       representation is used.

% the system will take on the name of this mfile:
sys = mfilename;
new_system(sys)
simver(1.3)
if (0 == (nargin + nargout))
     set_param(sys,'Location',[228,112,728,412])
     open_system(sys)
end;
set_param(sys,'algorithm',     'RK-45')
set_param(sys,'Start time',    '0.0')
set_param(sys,'Stop time',     '0.5')
set_param(sys,'Min step size', '0.0001')
set_param(sys,'Max step size', '.005')
set_param(sys,'Relative error','1e-3')
set_param(sys,'Return vars',   '')

add_block('built-in/From Workspace',[sys,'/','pulse step'])
set_param([sys,'/','pulse step'],...
		'matl_expr','[0, t_on, t_on, t_on+dur,t_on+dur 5; 0, 0,peakval,peakval,0,0]''',...
		'Mask Display','Pulse Step',...
		'Mask Dialogue','Pulse|Peak value|Time of step|Step duration')
set_param([sys,'/','pulse step'],...
		'Mask Translate','peakval = @1; t_on = @2; dur = @3; ',...
		'Mask Entries','peakval\/stepat\/stepdur\/',...
		'position',[60,78,130,112])


%     Subsystem  'pulse (lin)'.

new_system([sys,'/','pulse (lin)'])
set_param([sys,'/','pulse (lin)'],'Location',[8,44,699,499])


%     Subsystem  'pulse (lin)/Rst Int (2)'.

new_system([sys,'/','pulse (lin)/Rst Int (2)'])
set_param([sys,'/','pulse (lin)/Rst Int (2)'],'Location',[25,291,640,717])

add_block('built-in/Note',[sys,'/',['pulse (lin)/Rst Int (2)/When the input goes to zero, the upper input to product2 goes to one,',13,'closing the loop around the integrator.  When this happens, the output',13,'of the integrator decreases rapidly (large negative gain) to zero.']])
set_param([sys,'/',['pulse (lin)/Rst Int (2)/When the input goes to zero, the upper input to product2 goes to one,',13,'closing the loop around the integrator.  When this happens, the output',13,'of the integrator decreases rapidly (large negative gain) to zero.']],...
		'position',[300,344,310,349])

add_block('built-in/Note',[sys,'/',['pulse (lin)/Rst Int (2)/This block is a resettable integrator.  When the input signal is non-zero, the upper',13,'input to product2 is zero.  This effectively opens the loop around the integrator and',13,'the output is the integration of the input.',13,'']])
set_param([sys,'/',['pulse (lin)/Rst Int (2)/This block is a resettable integrator.  When the input signal is non-zero, the upper',13,'input to product2 is zero.  This effectively opens the loop around the integrator and',13,'the output is the integration of the input.',13,'']],...
		'position',[295,280,300,285])

add_block('built-in/Gain',[sys,'/','pulse (lin)/Rst Int (2)/Gain2'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Gain2'],...
		'hide name',0,...
		'Gain','1000',...
		'position',[260,54,310,86])

add_block('built-in/Constant',[sys,'/','pulse (lin)/Rst Int (2)/Constant'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Constant'],...
		'hide name',0,...
		'Value','-1',...
		'position',[355,15,375,35])

add_block('built-in/Sum',[sys,'/','pulse (lin)/Rst Int (2)/Sum3'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Sum3'],...
		'position',[290,225,310,245])

add_block('built-in/Outport',[sys,'/','pulse (lin)/Rst Int (2)/out_1'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/out_1'],...
		'position',[520,190,540,210])

add_block('built-in/Inport',[sys,'/','pulse (lin)/Rst Int (2)/in_1'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/in_1'],...
		'position',[55,230,75,250])

add_block('built-in/Integrator',[sys,'/','pulse (lin)/Rst Int (2)/Integrator'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Integrator'],...
		'position',[400,225,420,245])

add_block('built-in/Gain',[sys,'/','pulse (lin)/Rst Int (2)/Gain'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Gain'],...
		'orientation',2,...
		'hide name',0,...
		'Gain','1000',...
		'position',[350,158,400,192])

add_block('built-in/Product',[sys,'/','pulse (lin)/Rst Int (2)/product2'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/product2'],...
		'orientation',2,...
		'position',[255,133,285,157])

add_block('built-in/Dead Zone',[sys,'/',['pulse (lin)/Rst Int (2)/(dead zone)',13,'-0.05-->0.05']])
set_param([sys,'/',['pulse (lin)/Rst Int (2)/(dead zone)',13,'-0.05-->0.05']],...
		'Lower_value','0.05',...
		'Upper_value','-0.05',...
		'position',[115,62,145,88])

add_block('built-in/Sum',[sys,'/','pulse (lin)/Rst Int (2)/Sum'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Sum'],...
		'position',[200,60,220,80])

add_block('built-in/Saturation',[sys,'/','pulse (lin)/Rst Int (2)/0-->1'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/0-->1'],...
		'Lower Limit','0.0',...
		'Upper Limit','1.0',...
		'position',[335,58,365,82])

add_block('built-in/Sum',[sys,'/','pulse (lin)/Rst Int (2)/Sum2'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Sum2'],...
		'position',[420,55,440,75])

add_block('built-in/Constant',[sys,'/','pulse (lin)/Rst Int (2)/Constant1'])
set_param([sys,'/','pulse (lin)/Rst Int (2)/Constant1'],...
		'hide name',0,...
		'Value','-0.05',...
		'position',[115,17,155,43])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[425,235;465,235;465,175;405,175])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[465,200;515,200])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[370,70;415,70])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[315,70;330,70])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[380,25;395,25;395,60;415,60])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[345,175;325,175;325,150;290,150])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[445,65;475,65;475,140;290,140])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[315,235;395,235])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[225,70;255,70])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[150,75;195,75])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[160,30;180,30;180,65;195,65])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[250,145;225,145;225,230;285,230])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[80,240;285,240])
add_line([sys,'/','pulse (lin)/Rst Int (2)'],[195,240;195,160;85,160;85,75;110,75])
set_param([sys,'/','pulse (lin)/Rst Int (2)'],...
		'Mask Display','reset\ninteg')


%     Finished composite block 'pulse (lin)/Rst Int (2)'.

set_param([sys,'/','pulse (lin)/Rst Int (2)'],...
		'position',[385,68,425,102])

add_block('built-in/Note',[sys,'/',['pulse (lin)/This block generates a saccadic pulse with a linear pulse width function (of saccade size)',13,'and a non-linear pulse height function.']])
set_param([sys,'/',['pulse (lin)/This block generates a saccadic pulse with a linear pulse width function (of saccade size)',13,'and a non-linear pulse height function.']],...
		'position',[330,330,335,335])

add_block('built-in/Gain',[sys,'/','pulse (lin)/k=100'])
set_param([sys,'/','pulse (lin)/k=100'],...
		'hide name',0,...
		'Gain','100',...
		'position',[230,188,280,222])

add_block('built-in/Fcn',[sys,'/',['pulse (lin)/pulse width fcn',13,'(-0.0089 - u[1]*0.00132)']])
set_param([sys,'/',['pulse (lin)/pulse width fcn',13,'(-0.0089 - u[1]*0.00132)']],...
		'Font Name','Courier New',...
		'Font Size',9,...
		'Expr','-0.0089 - u[1]*0.00132',...
		'position',[285,125,325,145])

add_block('built-in/Fcn',[sys,'/',['pulse (lin)/Pulse Height',13,'590*u[1]//(7.5+u[1])',13,'']])
set_param([sys,'/',['pulse (lin)/Pulse Height',13,'590*u[1]//(7.5+u[1])',13,'']],...
		'Font Name','Courier New',...
		'Font Size',9,...
		'Expr','590*u[1]/(7.5+u[1])',...
		'position',[160,235,200,255])

add_block('built-in/Note',[sys,'/',['pulse (lin)/Notes: The transport delay is used to break up an algebraic loop.',13,'The upper loop will generate the negative trigger pulse when an input change',13,'exceeds a threshold value.  The input change can be positive or negative.    ']])
set_param([sys,'/',['pulse (lin)/Notes: The transport delay is used to break up an algebraic loop.',13,'The upper loop will generate the negative trigger pulse when an input change',13,'exceeds a threshold value.  The input change can be positive or negative.    ']],...
		'position',[355,560,360,565])

add_block('built-in/Note',[sys,'/',['pulse (lin)/The output from the resettable integrator, however, is linearly increasing and is summed',13,'with the output of product2.  When this sum reaches zero (the upper input to the sum',13,'will be zero by this time), then input 1 of the switch (zero) is outputted.']])
set_param([sys,'/',['pulse (lin)/The output from the resettable integrator, however, is linearly increasing and is summed',13,'with the output of product2.  When this sum reaches zero (the upper input to the sum',13,'will be zero by this time), then input 1 of the switch (zero) is outputted.']],...
		'position',[345,465,350,470])

add_block('built-in/Note',[sys,'/',['pulse (lin)/This then causes a zero to be sent to product1 which causes the',13,'resettable integrator to reset to zero and the output of product2 to be zero.',13,'']])
set_param([sys,'/',['pulse (lin)/This then causes a zero to be sent to product1 which causes the',13,'resettable integrator to reset to zero and the output of product2 to be zero.',13,'']],...
		'position',[355,515,360,520])

add_block('built-in/Note',[sys,'/',['pulse (lin)/This also causes a one to be sent to the lower input of product1.',13,'This then causes the output of product2 to be the pulse_width_fcn (that is negative)',13,'times a one.  This keeps input 2 to the switch negative.  ',13,'']])
set_param([sys,'/',['pulse (lin)/This also causes a one to be sent to the lower input of product1.',13,'This then causes the output of product2 to be the pulse_width_fcn (that is negative)',13,'times a one.  This keeps input 2 to the switch negative.  ',13,'']],...
		'position',[350,415,355,420])

add_block('built-in/Note',[sys,'/',['pulse (lin)/A step change from the input cause a small negative pulse to be generated',13,'(by the upper path) and sent to the sum.  This causes input 2 of the switch',13,'to be negative and input 3 of the switch to be outputted by the switch. ']])
set_param([sys,'/',['pulse (lin)/A step change from the input cause a small negative pulse to be generated',13,'(by the upper path) and sent to the sum.  This causes input 2 of the switch',13,'to be negative and input 3 of the switch to be outputted by the switch. ']],...
		'position',[335,365,340,370])

add_block('built-in/Saturation',[sys,'/','pulse (lin)/0-->1.0'])
set_param([sys,'/','pulse (lin)/0-->1.0'],...
		'Lower Limit','0.0',...
		'Upper Limit','1.0',...
		'position',[310,193,340,217])

add_block('built-in/Product',[sys,'/','pulse (lin)/product2'])
set_param([sys,'/','pulse (lin)/product2'],...
		'position',[430,128,460,152])

add_block('built-in/Sum',[sys,'/','pulse (lin)/Sum'])
set_param([sys,'/','pulse (lin)/Sum'],...
		'hide name',0,...
		'inputs','+++',...
		'position',[505,62,525,108])

add_block('built-in/Transport Delay',[sys,'/','pulse (lin)/0.001s'])
set_param([sys,'/','pulse (lin)/0.001s'],...
		'Delay Time','0.001',...
		'position',[85,25,125,55])

add_block('built-in/Product',[sys,'/','pulse (lin)/product1'])
set_param([sys,'/','pulse (lin)/product1'],...
		'position',[140,73,170,97])

add_block('built-in/Constant',[sys,'/','pulse (lin)/Constant1'])
set_param([sys,'/','pulse (lin)/Constant1'],...
		'hide name',0,...
		'Value','0.0',...
		'position',[255,40,280,60])

add_block('built-in/Fcn',[sys,'/','pulse (lin)/k =100'])
set_param([sys,'/','pulse (lin)/k =100'],...
		'Expr','u[1]*100',...
		'position',[240,75,280,95])

add_block('built-in/Saturation',[sys,'/','pulse (lin)/0-->1'])
set_param([sys,'/','pulse (lin)/0-->1'],...
		'Lower Limit','-0.0',...
		'Upper Limit','1.0',...
		'position',[315,73,345,97])

add_block('built-in/Abs',[sys,'/','pulse (lin)/Abs'])
set_param([sys,'/','pulse (lin)/Abs'],...
		'hide name',0,...
		'position',[210,13,240,37])

add_block('built-in/Outport',[sys,'/','pulse (lin)/out_1'])
set_param([sys,'/','pulse (lin)/out_1'],...
		'position',[635,105,655,125])

add_block('built-in/Switch',[sys,'/','pulse (lin)/Switch'])
set_param([sys,'/','pulse (lin)/Switch'],...
		'hide name',0,...
		'Threshold','0.0',...
		'position',[565,99,595,131])

add_block('built-in/Gain',[sys,'/','pulse (lin)/K=1000'])
set_param([sys,'/','pulse (lin)/K=1000'],...
		'orientation',2,...
		'hide name',0,...
		'Gain','1000',...
		'position',[440,289,490,321])

add_block('built-in/Transport Delay',[sys,'/','pulse (lin)/0.001 sec'])
set_param([sys,'/','pulse (lin)/0.001 sec'],...
		'orientation',2,...
		'Delay Time','0.001',...
		'position',[345,290,385,320])

add_block('built-in/Saturation',[sys,'/','pulse (lin)/0.0-->1.0'])
set_param([sys,'/','pulse (lin)/0.0-->1.0'],...
		'orientation',2,...
		'Lower Limit','0.0',...
		'Upper Limit','1.0',...
		'position',[230,293,260,317])

add_block('built-in/Sum',[sys,'/','pulse (lin)/Sum1'])
set_param([sys,'/','pulse (lin)/Sum1'],...
		'hide name',0,...
		'inputs','+-',...
		'position',[165,15,185,35])

add_block('built-in/Constant',[sys,'/','pulse (lin)/Constant'])
set_param([sys,'/','pulse (lin)/Constant'],...
		'hide name',0,...
		'Value','0.0',...
		'position',[510,17,535,43])

add_block('built-in/Saturation',[sys,'/','pulse (lin)/-0.002-->0'])
set_param([sys,'/','pulse (lin)/-0.002-->0'],...
		'Lower Limit','-0.002',...
		'Upper Limit','0.00',...
		'position',[435,13,465,37])

add_block('built-in/Gain',[sys,'/','pulse (lin)/Gain4'])
set_param([sys,'/','pulse (lin)/Gain4'],...
		'hide name',0,...
		'Gain','-1',...
		'position',[375,11,410,39])

add_block('built-in/Switch',[sys,'/','pulse (lin)/Switch1'])
set_param([sys,'/','pulse (lin)/Switch1'],...
		'hide name',0,...
		'Threshold','0.040',...
		'position',[315,9,345,41])

add_block('built-in/Inport',[sys,'/','pulse (lin)/in_1'])
set_param([sys,'/','pulse (lin)/in_1'],...
		'position',[15,145,35,165])
add_line([sys,'/','pulse (lin)'],[175,85;210,85;210,135;280,135])
add_line([sys,'/','pulse (lin)'],[210,85;235,85])
add_line([sys,'/','pulse (lin)'],[40,155;60,155;60,245;155,245])
add_line([sys,'/','pulse (lin)'],[60,155;60,40;80,40])
add_line([sys,'/','pulse (lin)'],[60,115;60,20;160,20])
add_line([sys,'/','pulse (lin)'],[60,80;135,80])
add_line([sys,'/','pulse (lin)'],[245,25;310,25])
add_line([sys,'/','pulse (lin)'],[255,25;255,15;310,15])
add_line([sys,'/','pulse (lin)'],[190,25;205,25])
add_line([sys,'/','pulse (lin)'],[465,140;465,100;500,100])
add_line([sys,'/','pulse (lin)'],[205,245;550,245;560,125])
add_line([sys,'/','pulse (lin)'],[530,85;535,85;535,115;560,115])
add_line([sys,'/','pulse (lin)'],[415,25;430,25])
add_line([sys,'/','pulse (lin)'],[470,25;490,25;500,70])
add_line([sys,'/','pulse (lin)'],[225,305;100,305;100,90;135,90])
add_line([sys,'/','pulse (lin)'],[600,115;600,305;495,305])
add_line([sys,'/','pulse (lin)'],[285,85;310,85])
add_line([sys,'/','pulse (lin)'],[130,40;150,40;160,30])
add_line([sys,'/','pulse (lin)'],[330,135;425,135])
add_line([sys,'/','pulse (lin)'],[210,110;210,205;225,205])
add_line([sys,'/','pulse (lin)'],[345,205;400,205;400,145;425,145])
add_line([sys,'/','pulse (lin)'],[285,205;305,205])
add_line([sys,'/','pulse (lin)'],[435,305;390,305])
add_line([sys,'/','pulse (lin)'],[350,85;380,85])
add_line([sys,'/','pulse (lin)'],[430,85;500,85])
add_line([sys,'/','pulse (lin)'],[340,305;265,305])
add_line([sys,'/','pulse (lin)'],[350,25;370,25])
add_line([sys,'/','pulse (lin)'],[285,50;295,50;295,35;310,35])
add_line([sys,'/','pulse (lin)'],[540,30;550,30;560,105])
add_line([sys,'/','pulse (lin)'],[600,115;630,115])
set_param([sys,'/','pulse (lin)'],...
		'Mask Display','P.G. 1')


%     Finished composite block 'pulse (lin)'.

set_param([sys,'/','pulse (lin)'],...
		'position',[235,77,280,113])

add_block('built-in/To Workspace',[sys,'/','PG out'])
set_param([sys,'/','PG out'],...
		'mat-name','PGout',...
		'position',[405,17,455,33])

add_block('built-in/To Workspace',[sys,'/','clock out'])
set_param([sys,'/','clock out'],...
		'mat-name','t',...
		'position',[405,227,455,243])

add_block('built-in/Clock',[sys,'/','Clock'])
set_param([sys,'/','Clock'],...
		'position',[350,225,370,245])

add_block('built-in/To Workspace',[sys,'/','stm'])
set_param([sys,'/','stm'],...
		'mat-name','stm',...
		'position',[390,167,440,183])
add_line(sys,[135,95;230,95])
add_line(sys,[285,95;300,95;300,25;400,25])
add_line(sys,[375,235;400,235])
add_line(sys,[185,95;185,150;315,150;315,175;385,175])

drawnow

% Return any arguments.
if (nargin | nargout)
	% Must use feval here to access system in memory
	if (nargin > 3)
		if (flag == 0)
			eval(['[ret,x0,str,ts,xts]=',sys,'(t,x,u,flag);'])
		else
			eval(['ret =', sys,'(t,x,u,flag);'])
		end
	else
		[ret,x0,str,ts,xts] = feval(sys);
	end
else
	drawnow % Flash up the model and execute load callback
end
