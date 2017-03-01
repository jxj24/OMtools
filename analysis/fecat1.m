function [fx,new_t,new_st,t_int]=fecat1(varargin)
%function for constructing alternating fixating eye NAFX readable data
%
%Use this function to merge date between two signal channels to account
%for a change in the fixating eye. This function allows for a maimum of 50
%merged intervals
%
%Inputs 
% NONE , assumes user is merging horizontal data, inputs set at rh and lh
%
% [choice], where choice is either 'h' for horizontal or 'v' for vertical
% data merging
%
% [signal_1,signal_2], where signal 1 is assigned to the right eye in the
% GUI and signal 2 is assigned to the left.  Any signals may be merged, but
% the gui assignments were chosen due to the intended use of the function
%
% [signal_1,signal_2,refrence_signal] , where the reference signal is
% usually a stimulus
%
%Outputs 
% NONE  *NOTE when using NAFX, the channel name must be ans when no outputs are
% assigned
% fe    =  output of merged signal
% [fe,new_time]  = output of merged signal and associated time vector
% [fe,new,time,new_stimuls] = see above as well as associated stimulus
% vector
% [fe,new_time,new_stimulus,interval_data] = see above and also the interval
% data listed in a 50x3 matrix  [fixating_eye,interval_start,interval_end]
%
%Closing any open zoomtool windows is reccomended before running
%
%Further information is listed in fecat.m


%   GUI Instruction
%
%   In addition to the GUI, a zoomtool window will also open.
%
%   The GUI will display the inital data, as well as a panel for beginning
%   the data merge.  Select what point to start at by entering a value into
%   the box, or by using zoomtool's c1 Get button on a point chosen with
%   curser one in the zoomtool window.  
%
%   Then simply continue to choose interval endpoints either by entering
%   them manually or using c2 get with zoomtool.
%
%   Interval Data may also be entered in the editable text box in the
%   format  "(#fixating eye)  start_time  end_time" where (#fixating eye)
%   is 1 for right eye and -1 for left eye
%
%   **NOTE  It is very important to notice that intervals caonnot overlap.
%   When entering data into the text box make sure that the next interval
%   starts 0.002 seconds after the end of the previous interval or the
%   plotter will not function 

% Joel Simon  July 2009


    %initilize pass variable and read data from the workspace
    global fx
    fe=[];
    new_t=[];
    new_st=[];
    %determine the function input parameters
    switch nargin
        case 0
            rh=evalin('base','rh');
            lh=evalin('base','lh');
            st=evalin('base','st');
        case 1
            hv = varargin{1};
            switch hv
                case 'v'
                    rh=evalin('base','rv');
                    lh=evalin('base','lv');
                    st=evalin('base','sv');
                case 'h'
                    rh=evalin('base','rh');
                    lh=evalin('base','lh');
                    st=evalin('base','st');
                otherwise
                    error('input not recognized...see help for argument details')
            end
        case 2
            rh=varargin{1};
            lh=varargin{2};
        case 3
            rh=varargin{1};
            lh=varargin{2};
            st=varargin{3};
        otherwise
            error('input not recognized...see help for argument details')
    end
            
    %set up the fecat gui with a plot area and some whitespace for the
    %controls
    %fecat_ui=figure(777);
    fecat_ui=figure('Name','FECAT Plot Window','NumberTitle','off');
    set(fecat_ui,'position',[50 100 600 600],'deletefcn',@quit);
    plotter=axes('parent',fecat_ui,'units','pixels','position',[20 300 560 285]);
    set(plotter,'yticklabel',{},'xticklabel',{});
    %do an initial plot of the uncatted(?) data, and make a new figure for
    %the zoomtool window so the gui doesn't get overwritten
    t=maket(rh);
    plot(t,rh,'c',t,lh,'y',t,st,'r')
    %figure(888)
    figure('Name','ZoomTool Window','NumberTitle','off');
    plot(t,rh,'c',t,lh,'y',t,st,'r')
    zoomtool
    %create the panel for choosing the initial starting criteria
    %starting=uipanel('parent',777,'units','pixels','fontsize',9,'position',[100 50 200 200],'title','Select Starting Position and Eye');
    starting=uipanel('parent',fecat_ui,'units','pixels','fontsize',9,'position',[100 50 200 200],'title','Select Starting Position and Eye');
    uicontrol('parent',starting,'style','text','fontsize',9,'string','Select Starting Eye','units','pixels','position',[10 160 120 20])
    st_eye=uicontrol('parent',starting,'style','popupmenu','units','pixels','position',[10 145 150 20],'string',{'Right Eye','Left Eye'});
    uicontrol('parent',starting','style','text','fontsize',9,'string','Select Starting Time','units','pixels','position',[10 115 120 20])
    st_t=uicontrol('parent',starting,'style','edit','string','0.002','units','pixels','position',[10 95 60 25]);
    uicontrol('parent',starting,'style','pushbutton','string','Use C1 get','callback',@use_c1,'units','pixels','position',[80 95 100 25])
    uicontrol('parent',starting,'style','pushbutton','fontsize',15,'string','Begin','units','pixels','position',[20 20 160 65],'callback',@fe_loop);
    %need to uiwait because the output fx is redefined by the uicontrols.
    %If we allow the function to finish it will not write any changesto fx
    %to memeory
    uiwait
    fx;
    
    function quit(hObject,eventdata)
        %just in case the user closes the window instead of finishing
        fx=fe;
        %close(888);
        close('ZoomTool Window');
        uiresume
    end
    
    function use_c1(hObject,eventdata)
        %use C1xy for the start position and then clear it
        xyCur1Mat=evalin('base','xyCur1Mat');
        set(st_t,'string',num2str(xyCur1Mat(1,3)));
        cursmatr('cur1_clr');
    end
    
    function fe_loop(hObject,eventdata)
        %all the functions below are nested to avoid over-zelous
        %globalization
        %This function contains all the actual concatination as well as
        %plotting of the result.  The user is held in this function by
        %uiwait, and exits by use of 'Finish' which enacts a uiresume
        set(starting,'visible','off')
        %turn of initials
        %try used for error handling
        try
        st_eye_val=get(st_eye,'value');
        switch st_eye_val
            case 1
                f_eye=1;
            case 2
                f_eye=-1;
        end
        t_int=zeros(50,3);
        t_int(1)=f_eye;
        t_int(1,2)=str2double(get(st_t,'string'));
        %check to make sure starting number is actually a number
        if ~isfinite(t_int(1,2))
            error('The Value enetered for start point was not a number.  Try again.');
        end
        %since time for data goes in 0.002 steps we need to correct in case
        %the user entered in an incompatible number i.e. x.xx1
        if mod(t_int(1,2),0.002)>0
            t_int(1,2)=t_int(1,2)+0.001;
        end
        on_int=1;
        catch
            set(starting,'visible','on')
            return
        end
        %find the new start point and update the plotter
        ind=find(t==t_int(1,2));
        axes(plotter)
        lim=numel(t);
        plot(t(ind:lim),rh(ind:lim),'c',t(ind:lim),lh(ind:lim),'y',t(ind:lim),st(ind:lim),'r')
        %create all the user controls
        %*Note controls with named handles are modified by callback
        %functions at some point
        intervals=uicontrol('parent',fecat_ui,'style','edit','max',50,'units','pixels','position',[300 10 290 255],'callback',@t_edit);
        uicontrol('parent',fecat_ui,'style','text','fontsize',9,'string','Current Fixating Eye: ','position',[10 250 120 25]);
        switch f_eye
            case 1
                fe_name='Right Eye';
            case -1
                fe_name='Left Eye';
        end
        cur_eye=uicontrol('parent',fecat_ui,'style','text','fontsize',9,'string',fe_name,'position',[140 250 120 25]);
        uicontrol('parent',fecat_ui,'style','text','fontsize',9,'string','Set End Point For Current Eye','units','pixels','position',[10 210 175 25]);
        next_t=uicontrol('parent',fecat_ui,'style','edit','string',num2str(t(lim)),'units','pixels','position',[10 180 60 25]);
        uicontrol('parent',fecat_ui,'style','pushbutton','string','Use C2 get','callback',@use_c2,'units','pixels','position',[80 180 100 25])
        uicontrol('parent',fecat_ui,'style','pushbutton','string','SET','callback',@set_next,'units','pixels','position',[10 130 100 40]);
        uicontrol('parent',fecat_ui','style','pushbutton','string','Finish','callback',@finish,'units','pixels','position',[50 50 100 40]);
        
        function set_next(hObject,eventdata)
            %executed by the set button
            %adds the next interval to the t_int matrix as well as the
            %editable text box
            cur_ints=get(intervals,'string');
            on_int=size(cur_ints,1)+1;
            t_int(on_int,3)=str2double(get(next_t,'string'));
            check_dd=find(t==t_int(on_int,3), 1);
            %make sure the timestamp works for the 0.002 step
            if isempty(check_dd)
                t_int(on_int,3)=t_int(on_int,3)+0.001;
                set(next_t,'string',num2str(t_int(on_int,3)));
            end
            cur_ints=strvcat(cur_ints,num2str([f_eye t_int(on_int,2) t_int(on_int,3)])); %#ok<VCAT>
            set(intervals,'string',cur_ints);
            on_int=on_int+1;
            f_eye=f_eye*-1;
            switch f_eye
                case 1
                    fe_name='Right Eye';
                case -1
                    fe_name='Left Eye';
            end
            set(cur_eye,'string',fe_name);            
            t_int(on_int,2)=t_int(on_int-1,3)+0.002;
            t_int(on_int,1)=f_eye;
            cat_it
        end
        
        function use_c2(hObject,eventdata)
            xyCur2Mat=evalin('base','xyCur2Mat');
            set(next_t,'string',num2str(xyCur2Mat(1,3)));
            cursmatr('cur2_clr');
        end
                
        function t_edit(hObject,eventdata)
            %response to the user manually editing the intervals in the
            %editable text box
            text=get(intervals,'string');
            %error handling :(
            for i = 1:size(text,1)
                seperate=regexp(text(i,:),' ','split');
                nums=str2double(seperate);
                nums=nums(find(abs(nums)>0)); %#ok<FNDSB>
                t_int(i,:)=nums;
            end
            ind=find(t==t_int(1,2));
            f_eye=t_int(i,1);
            f_eye=f_eye*-1;
            switch f_eye
                case 1
                    fe_name='Right Eye';
                case -1
                    fe_name='Left Eye';
            end
            set(cur_eye,'string',fe_name);  
            on_int=size(text,1)+1;
            cat_it
        end
        
        function cat_it()
            %function to concatinate the intervals into a new single data
            %stream, as well as update the plotter
            %determine the new end point as well as the new time index and
            %stimulus index
            new_lim=find(t==t_int(on_int-1,3));
            new_t=t(ind:new_lim);
            new_st=st(ind:new_lim);
            fe=[];
            %find the coresponding time t for each interval point in t_int
            %and check which eye is fixating and add it to the new data set
            for j =1:on_int-1
                t_s=t_int(j,2);
                t_s=str2double(num2str(t_s)); %MATLAB floating point error fix
                ind_start=find(t==t_s);
                ind_end=find(t==t_int(j,3));
                switch (t_int(j,1))
                    case 1
                        fe=[fe;rh(ind_start:ind_end)];
                    case -1
                        fe=[fe;lh(ind_start:ind_end)];
                end
            end
            axis(plotter);
            try
            plot(new_t,fe,'color',[1 0.64 0])
            hold on
            plot(new_t,new_st,'r')
            hold off
            catch
                error('time index size and signal size do not match.  Ckeck to make sure intervals do not overlap')
            end
            
            fx=fe;
        end
        
        function finish(hObject,eventdata)
            %figure(222)
            figure('Name','Concatenated Data','NumberTitle','off')
            fx=fe;
            plot(new_t,fe,'color',[1 0.64 0])
            hold on
            plot(new_t,new_st,'r')
            hold off
            %close(888)
            close('ZoomTool Window');
            close(fecat_ui)
            intervals=t_int(1:on_int-1,:) %#ok<NOPRT>
            uiresume
        end
    end
    
end