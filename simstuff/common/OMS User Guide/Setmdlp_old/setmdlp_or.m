function setmdlp
%OMSv1_xx GUI Toolkit
%Graphic User Interface for use with the OMlab Ocular Motor System Simulink Model
%written by:  Joel Simon
%             June 2009 - August 2009
%Instruction Manual Available  @ %http://www.omlab.org/OMLAB_page/software/software.html

%check if the GUI is already open, and restore focus to it if so
if ishandle(999)
    figure(999)
    return
end
%set seperator for file locations //  written by John Jacobs  PHD
[comp, maxsize] = computer;
vers=version;
P = path;
if comp(1) == 'M' & vers(1)<='5' % 'classic' Mac OS
   sep  = ':';                   % between dirs in a single path
   sep2 = ';';                   % between path entries
 elseif comp(1) == 'P'           % PC
   sep  = '\'; 
   sep2 = ';';
 else                            % Unix (including Mac OS X)
   sep  = '/';
   sep2 = ':'; 
end   
% //
%***NOTE initiallized variables in a nested function tree act like global
%variables to all nested functions without being global to anything outside
%of the OMS_gui
%
%initilize window handles that are passed between functions
main_window = figure(999);
set(main_window,'toolbar','none','resize','off','menubar','none','color',[0 0 0],...
    'numbertitle','off','name','DD_Omlab OMS Model V1.6.0','visible','off','deletefcn',@err_delete);
edit_gui=figure(909);
set(edit_gui,'toolbar','none','resize','off','menubar','none','color',[0 0 0],...
    'numbertitle','off','name','EDIT SETTINGS','visible','off');
run_gui=figure(111);
set(run_gui,'toolbar','none','resize','off','menubar','none','color',[0 0 0],...
    'numbertitle','off','name','DD_Omlab OMS Model V1.6.0    Run A Simulation','visible','off')
%allow settings to persist if GUI is closed and/or reopened
%may not need evalin since the loadmdlp.m has  global current i.e. even if
%current is cleared from the base w/ clear all its still stored in the
%model workspace, but safe > sorry
evalin('base','global current'); 
global current; def_set=struct; set1=[]; set2=[];
%initialize all of the passed variables
active_preset=4; panel_list={}; hoa=[]; hoe=[]; ret_active=[];
dirs=[]; call_edit_data=[]; set_work_dir=[]; sav_cop=[];
buttons_in_edit_settings=[]; add_def=[]; currently_editing=[];
advanced=[]; t_h={}; p_h={}; n_ha={}; lab={}; sldd=[];
window_positions=struct; def_buttons=[]; data=[]; pan_color=[]; panel={};
loadin=struct; level_1_buttons=[]; def_n_p=[]; def_n=[];
edit_size=[]; main_height=[]; main_width=[]; main_buttons=[]; admin_flag=0;
%set the working directory to be the location of the setmdlp.m m-file
[ST,I]=dbstack; work_direct=strrep(which(ST.name),[sep ST.name '.m'],'');  %#ok<NASGU>
cur_dir=pwd; data_direct=[]; temp_direct=[]; mdl=[];
%ui elements use RGB values ranging from 0 to 1 instead of standard RGB 0
%to 255, so I included a quick conversion for conveniance.  
panel_color=(1/255).*   [255 255 100; 
                         000 250 154; 
                         240 128 128; 
                         176 196 222; 
                         233 150 122; 
                         255 228 181; 
                         240 255 255];
%%
%ROOT OF PROGRAM TREE
%now we can call the root functions of the nested tree
% init load does inital data loading and or creation
init_load()
% everything else is a branching function called in some way by the main
% window created in draw_main
draw_main()

%%
%function to load or create guisettings and load in all of the data
    function init_load()
        cd(work_direct);
        fln=[work_direct sep 'guisettings.mat'];
        try
        loadin=load(fln); %check if the current directory has a settings file
        catch
            % if no setting file exists, find/create one
            set_path  %function to allow the user to load a guisettings in a different location
            uiwait
            cd(temp_direct)
            %try to load a settings file in the new directory
            try
                loadin=load(fln);
            catch
               create_settings %saves a guisettings in the directory that has the GUI and Model
               cd(work_direct); %load the guisettings that was just made
               loadin=load(fln);
            end   
        end
        data=loadin.data;
        def_set=loadin.def_set;
        %load persistant settings
        try
            active_preset=def_set.settings.active_preset;
        catch
            sets_to_def
        end
        if isempty(current); active_preset=4; end %if the user executes a clear all, then set the GUI to NORMAL
        try
            panel_list=def_set.settings.panel_list;
        catch
            panel_list={'General_Tools'};
        end
        window_positions=loadin.window_positions;
        cd(work_direct);
        data_direct=work_direct;
        cd(cur_dir); %finish in whatever directory the user was in
    end

%%
%function to close the GUI called by the close buttion on the main window
    function quit(hObject,eventdata)
        close(main_window);  %see err_delete for what happens when main window is closed
    end

%%
%called when main window is closed in ANY way
%function to keep memory if closed with the window control
%instead of the close button
    function err_delete(hObject,eventdata)
        newpos=get(main_window,'position');
        window_positions.main=[newpos(1),newpos(2)];
        %close initialized windows with a try incase the user already
        %closed them
        try  %#ok<TRYNC>
            extra_pos=get(1010,'pos');
            window_positions.extra=(extra_pos(1:2));
            close(1010)
        end
        try close(111); end %#ok<TRYNC>
        try close(909); end %#ok<TRYNC>
        %save persistant settings
        def_set.settings.active_preset=active_preset;
        def_set.settings.panel_list=panel_list;
        try  cd(data_direct); end %#ok<TRYNC>
        save guisettings.mat def_set data window_positions
        cd(cur_dir);
    end

%%
%Function to ask the user for the directory of a saved guisettings, or
%to make a new one
%called by init_load
    function set_path()
        direct = pwd;    %set the start directory
        dir_gui=figure(10);
        set(dir_gui,'toolbar','none','position',[699 448 450 156],'menubar','none','resize','off',...
            'numbertitle','off','name','Select Working Directory','deletefcn',@err_set_p)
        uicontrol('style','text','position',[25 100 400 50],...
            'String',{'No settings found in current directory.',pwd,...
            'Please Select a Working Directory.','If no settings file is found, one will be created.'})
        uicontrol('style','pushbutton','string','Browse','position',[30 55 75 30],...
            'callback',@set_dirs);
        dirs = uicontrol('style','text','position',[120 55 325 25],...
            'string',direct);
        uicontrol('style','pushbutton','position',[260 15 175 30],...
         'string','Set / Create',...
           'callback',@select);

        function select(hObject,eventdata)
            temp_direct=get(dirs,'string'); %set the directory to the user's choice and return
            close(dir_gui)
            uiresume
        end
    
        function set_dirs(hObject,eventdata)
            direct=uigetdir; %show the currently selected directory
            set(dirs,'string',direct);
        end
        
        function err_set_p(hObject,eventdata)
            errordlg('Exiting without creating guisettings.mat','Error - Quit')
        end
            
    end

%%
%function to draw the main window
    function draw_main()
        %set main window size
        main_height=600;  main_width=270;
        %need to draw this early to make the buttons draw correctly...yay
        %matlab
        set(main_window,'position',[window_positions.main main_width main_height],'visible','on')
        %create Preset selection buttons
        d_button_y=485;
        %get the Preset names from data
        def_n_p=data(1,4:size(data,2));
        for d = 4:(size(data,2))
            %need to get just the name of the Preset, so we seperate out
            %all of the panels-to-draw-data and tooltips
            seper=regexp(def_n_p{d-3},'&&','split');
            sep3=regexp(seper{1},'#','split');
            def_n{d-3}=sep3{1};
            try
                dtooltip=seper{2};
            catch
                dtooltip=def_n{d-3};
            end            
            def_buttons(d-3)=uicontrol('parent',main_window,'style','pushbutton','userdata',d,'string',def_n{d-3},...
                'fontsize',15,'position',[125 d_button_y 130 60],'callback',@sel_default,'tooltip',dtooltip);
            set(def_buttons(d-3),'backgroundcolor',panel_color(d-3,:))
            d_button_y=d_button_y-70;
        end
        %create main window buttons
        main_buttons(1)=uicontrol('parent',main_window,'style','pushbutton','string','Save Current',...
            'position',[10 40 100 30],'callback',@save_current,'tooltip','Save the Current O.M. System as an (.oms) file');
        main_buttons(2)=uicontrol('parent',main_window,'style','pushbutton','string','Load Custom',...
            'position',[10 75 100 30],'callback',@load_current,'tooltip','Load a previously saved O.M. System file');
        main_buttons(3)=uicontrol('parent',main_window,'style','pushbutton','string','Edit GUI',...
            'position',[10 110 100 30],'callback',@edit_settings,'tooltip','Change various aspects of the GUI (some options for administrator only)');
        main_buttons(4)=uicontrol('parent',main_window,'style','pushbutton','string','Close GUI',...
            'position',[10 5 100 30],'callback',@quit);
        main_buttons(5)=uicontrol('parent',main_window,'style','togglebutton','string','Advanced Mode',...
            'position',[7 427.5 110 50],'callback',@advancedbtn,'tooltip','Show/Hide the Advanced Pane');
        main_buttons(6)=uicontrol('parent',main_window,'style','pushbutton','string','Simulation Settings',...
            'position',[5 267.5 110 50],'callback',@run_window,'tooltip','Change run time and stimuli inputs for the simulation');
        main_buttons(7)=uicontrol('parent',main_window,'style','pushbutton','string','RUN Simulation',...
            'position',[5 207.5 110 50],'callback',@main_run);
        %uicontrol('parent',main_window,'style','pushbutton','string','STOP Simulation',...
        %    'position',[5 147.5 110 50],'callback',@force_stop);

        
        if active_preset==0
            %if user returns from another window after making changes 
            %we do not want to redefine current if active default is 0 "custon"
            editname='Custom';
        else
            editname=def_n{active_preset-3};
            %retrieve current settings from data file
            for k=2:size(data,1)
                str=data{k,1};
                current.(str)=data{k,active_preset};
            end
        end
        %create the currently editing dialog
        uicontrol('parent',main_window,'style','text','fontunits','pixels','fontsize',18,'position',[35 main_height-20-1 200 21],...
            'string','Current O.M. System','backgroundcolor',[0 0 0],'foregroundcolor',[1 1 1]);
        currently_editing=uicontrol('parent',main_window,'style','text','fontunits','pixels','fontsize',25,'position',[47 main_height-40-6 173 26],...
            'string',editname,'backgroundcolor',[0 0 0],'foregroundcolor',[1 1 1],'tooltip','The type of simulation currently loaded into the model');
        uicontrol('style','text','parent',999,'fontunits','pixels','fontsize',18,'string','Select the OMS Type to Simulate',...
            'position',[5 332.5 115 65])
        level_1_buttons=[main_buttons def_buttons];
        
        function main_run(hObject,eventdata)
            %add a convenient run button to the main window
            set(level_1_buttons,'enable','off');
            fullmdlp=gcs;
            mdlsep=regexp(fullmdlp,sep,'split');
            mdl=mdlsep{1};
            set_param([mdl sep 'Eye' sep sep 'Tgt Scope'],'TimeRange',current.Run_time)
            evalin('base',['sim(''' mdl ''',' (current.Run_time) ')'])
            set(level_1_buttons,'enable','on');            
        end
        
        %not working
        function force_stop(hObject,eventdata)
            set_param(mdl, 'SimulationCommand','stop')
            set(level_1_buttons,'enable','on');
        end
        
    end

%%
%Function to set response of Advanced Mode Toggle button
    function advancedbtn(hObject,eventdata)
        %whenever a button on the main window is pushed that may change the
        %window size, we need to poll the window location so we can keep it
        %constant when we redraw it
        newpos=get(main_window,'position');
        window_positions.main=[newpos(1),newpos(2)];
        on=get(hObject,'value');
        if on
            draw_tools
        else
            %this way we get rid of the unused ui-objects now so as not to
            %interfere with new panels and to reduce load time when going
            %into advanced mode
            del=findobj('tag','advanced');  
            delete(del);
            %we do this instead of clear_Advanced so clicking the button
            %also closes the extra panel if its open
            set(main_window,'position',[window_positions.main main_width main_height],'visible','on')
         end
    end

%%
%Function to clean out the advanced pane in the fastest possible way
%This eliminated some but not all screen flicker
%basically just searches for all children of the uipanels and deletes them
%- called in many various places
    function clear_advanced(caller)
        %check if we need to draw the advanced pane
        sw_advanced=get(main_buttons(5),'value');
        if sw_advanced
            %prevent the function from deleting the extra window content
            del1=findobj('type','uipanel');
            ex_frm=findobj('parent',1010);
            ex_ad=get(ex_frm,'children');
            ex_pan=get(ex_ad,'children');
            ex=[ex_frm;ex_ad;ex_pan];
            del1=setdiff(del1,ex);
            %delete all of the content
            for aa = 1 : numel(del1)
                del2 = findobj('parent',del1(aa));
                delete(del2)
            end
            delete(del1(1))
            draw_tools
        end
    end

%%
%Function to allow the user to add tool panels to custom systems
    function add_panel(hObject1,eventdata)
        %find the names of all different possible tool panels
        all_panels=unique(data(2:size(data,1),2));
        %find which ones are currently open already
        panels_open=get(findobj('type','uipanel'),'title');
        %and then sort out the ones that are not open yet
        panels_to_add=setdiff(all_panels,panels_open);
        %create the ui with check boxes for each panel
        panel_ui=figure(888);
        set(panel_ui,'toolbar','none','resize','off','menubar','none',...
            'numbertitle','off','name','Add Tool Panels to Current System',...
            'position',[300 300 300 300]);
        ch_box=cell(numel(panels_to_add,1));
        chk_y=240;
        for pp = 1 : numel (panels_to_add)
            ch_box{pp}=uicontrol('parent',panel_ui,'style','checkbox','units','pixels',...
                'position',[10 chk_y 270 30],'string',panels_to_add{pp});
            chk_y=chk_y-25;
        end
        hoa=uicontrol('parent',panel_ui,'style','pushbutton','units','pixels','position',[50 270 75 25],...
            'string','Add to Main','callback',@add);
        uicontrol('parent',panel_ui,'style','pushbutton','units','pixels','position',[200 270 75 25],...
            'string','Cancel','callback',@cancl);
        hoe=uicontrol('parent',panel_ui,'style','pushbutton','units','pixels','position',[125 270 75 25],...
            'string','Add to Extra','callback',@add_in_window);
        
        
        function add_in_window(hObjecta,eventdata)
            %this adds panels to the extra panel window
            %we're doing this by masking the new figure 1010 as the main
            %window so we need to reserve some variables...with the re_*
            %form that are recovered at the end of the function
            re_panel_list=panel_list;
            panel_list={};
            %check if the extra panel is already open
            if ishandle(1010)
                %if it is open we need to poll its data to find its
                %location as well as what panels are already open in it
                %then we clear it to make room to redraw with the new
                %additions
                main_window=figure(1010);
                pos=get(main_window,'position');
                window_positions.extra=pos(1:2);
                frame=findobj('parent',main_window,'type','uipanel');
                adv=get(frame,'children');
                panel_list=get(findobj('type','uipanel','parent',adv),'title');
                delete(main_window)
            end
            main_window=figure(1010);
            set(main_window,'tag','advanced','toolbar','none','resize','off','menubar','none','color',[0 0 0],...
                'numbertitle','off','name','Extra Panel','deletefcn',@close_extra);
            re_main_width=main_width;
            re_pan_color=pan_color;
            %draw_tools uses all of these variables, so we want to keep
            %them for use in the main window's advanced pane
            main_width=10;
            for qq=1:numel (panels_to_add)
                %poll the checkboxes and add all checked values to the list
                %of panels to draw
                if get(ch_box{qq},'value')
                    panel_list=[[panel_list(:)]',panels_to_add(qq)];
                    fnd1=strfind(data(1,:),panels_to_add{qq});
                    findex=cellfun('isempty',fnd1);
                    fnd2=find(~findex)-3;
                    if fnd2>0
                        pan_color(numel(panel_list),:)=panel_color(fnd2(1),:);
                    else
                        pan_color(numel(panel_list),:)=[1 1 1];
                    end
                end
            end
            %draw the new panels on the masked extra window
            active_preset=0; %so as nottoverwrite the panel list
            draw_tools
            pos=get(main_window,'position');
            set(main_window,'position',[window_positions.extra pos(3:4)]);
            set(currently_editing,'string','CUSTOM');
            %recover variables
            pan_color=re_pan_color;
            panel_list=re_panel_list;
            main_width=re_main_width;
            main_window=figure(999);
            close(panel_ui)
            figure(1010); %bring the extra panel to the front
        end
        
        function add(hObjectb,eventdata)
            %function to add panels to the main window's advanced pane
            for qq = 1 : numel (panels_to_add)
                if get(ch_box{qq},'value')
                    %the reason this is different is because the resulting
                    %panel_list of a findobj as used above is a cell array,
                    %and needs to be handled diffeently
                    panel_list=[panel_list,panels_to_add(qq)]; %#ok<AGROW> no way to avoid
                    fnd1=strfind(data(1,:),panels_to_add{qq});
                    findex=cellfun('isempty',fnd1);
                    fnd2=find(~findex)-3;
                    if fnd2>0
                        pan_color(numel(panel_list),:)=panel_color(fnd2(1),:);
                    else
                        pan_color(numel(panel_list),:)=[1 1 1];
                    end
                end
            end
            active_preset=0;
            set(currently_editing,'string','CUSTOM');
            clear_advanced
            close(panel_ui)
        end
                
        function cancl(hObject,eventdata)
            close(panel_ui)
        end
       
        function close_extra(hObject,eventdata)
            new_pos=get(hObject,'position');
            window_positions.extra=new_pos(1:2);
        end
    
    end

%%
%function to allow user to remover panels from the advanced pane or move
%them to the extra panel
    function hide_panel(hObject4,eventdata)
        %set a recursion flag
        addexflag=0;
        adv=get(hObject4,'parent');
        %find which panels are currently open already
        %use unique in order to not display panels that may be split up
        %more than once
        panels_open=get(findobj('type','uipanel','parent',adv),'title');
        if ~iscell(panels_open)
            panels_open={panels_open}; %prevent error if only one panel is open
        else
            panels_open=unique(panels_open);
        end
        %create the ui with check boxes for each panel
        h_panel_ui=figure(808);
        set(h_panel_ui,'toolbar','none','resize','off','menubar','none',...
            'numbertitle','off','name','Hide Tool Panels',...
            'position',[300 300 300 300]);
        %create the check-boxes for each open panel
        ch_box=cell(numel(panels_open,1));
        chk_y=240;
        for pp = 1 : numel (panels_open)
            ch_box{pp}=uicontrol('parent',h_panel_ui,'style','checkbox','units','pixels',...
                'position',[10 chk_y 270 30],'string',panels_open{pp});
            chk_y=chk_y-25;
        end
        uicontrol('parent',h_panel_ui,'style','pushbutton','units','pixels','position',[50 270 75 25],...
            'string','Hide','callback',@hide);
        uicontrol('parent',h_panel_ui,'style','pushbutton','units','pixels','position',[200 270 75 25],...
            'string','Cancel','callback',@cancl);
        uicontrol('parent',h_panel_ui,'style','pushbutton','units','pixels','position',[125 270 75 25],...
            'string','Move to Extra','callback',@add_in_window2);
        
        
        function add_in_window2(hObject,eventdata)
            %function to move panels to the extra window
           addexflag=1;
           hide %first we take them off of the advanced window
           re_panel_list=panel_list;
            panel_list={};
            %check if the extra panel is already open
            if ishandle(1010)
                %if it is open we need to poll its data to find its
                %location as well as what panels are already open in it
                %then we clear it to make room to redraw with the new
                %additions
                main_window=figure(1010);
                pos=get(main_window,'position');
                window_positions.extra=pos(1:2);
                frame=findobj('parent',main_window,'type','uipanel');
                adv=get(frame,'children');
                panel_list=get(findobj('type','uipanel','parent',adv),'title');
                delete(main_window)
            end
            main_window=figure(1010);
            set(main_window,'tag','advanced','toolbar','none','resize','off','menubar','none','color',[0 0 0],...
                'numbertitle','off','name','Extra Panel','deletefcn',@close_extra);
            re_main_width=main_width;
            re_pan_color=pan_color;
            %draw_tools uses all of these variables, so we want to keep
            %them for use in the main window's advanced pane
            main_width=10;
            for qq=1:numel (panels_open)
                %poll the checkboxes and add all checked values to the list
                %of panels to draw
                if get(ch_box{qq},'value')
                    panel_list=[[panel_list(:)]',panels_open(qq)];
                    fnd1=strfind(data(1,:),panels_open{qq});
                    findex=cellfun('isempty',fnd1);
                    fnd2=find(~findex)-3;
                    if fnd2>0
                        pan_color(numel(panel_list),:)=panel_color(fnd2(1),:);
                    else
                        pan_color(numel(panel_list),:)=[1 1 1];
                    end
                end
            end
            %draw the new panels on the masked extra window
            active_preset=0;
            draw_tools
            pos=get(main_window,'position');
            set(main_window,'position',[window_positions.extra pos(3:4)]);
            set(currently_editing,'string','CUSTOM');
            %recover variables
            pan_color=re_pan_color;
            panel_list=re_panel_list;
            main_width=re_main_width;
            main_window=figure(999);
            close(h_panel_ui)
            figure(1010);
        end
        
        function hide(hObject,eventdata)
            %function to hide panels that are open in the main window's advanced pane
            for qq = 1 : numel (panels_open)
                if get(ch_box{qq},'value')
                    %the reason this is different is because the resulting
                    %panel_list of a findobj as used above is a cell array,
                    %and needs to be handled diffeently
                    rem1=strfind(panel_list,panels_open{qq});
                    remdex=cellfun('isempty',rem1);
                    rem2=find(~remdex);
                    panel_list(rem2)=[];                    
                end
            end
            active_preset=0;
            set(currently_editing,'string','CUSTOM');
            clear_advanced
            if addexflag~=1  %prevent infinate recursion
                close(h_panel_ui)
            end
        end
        
        function close_extra(hObject,eventdata)
            new_pos=get(hObject,'position');
            window_positions.extra=new_pos(1:2);
        end
        
        function cancl(hObject,eventdata)
            close(h_panel_ui)
        end
    
    end
%%
%Callback of default selection buttons to set current settings to the right
%default   Also contains a check to preventthe user from losing data
    function sel_default(hObject,eventdata)
        if strcmpi(get(currently_editing,'string'),'custom')
            %make sure the user doens't lose data by accident
            figure(303)
            set(303,'toolbar','none','resize','off','menubar','none','color',[0 0 0],...
                'numbertitle','off','name','Save Current Custom System?','pos',[300 300 400 75]);
            uicontrol('parent',303,'style','text','string',{'You have made changes to a Custom O.M. System','Do you want to'},'units','pixels','pos',[5 45 390 30]);
            uicontrol('parent',303,'style','pushbutton','string','Save It','units','pixels','pos',[10 10 75 30],'callback',@ersave);
            uicontrol('parent',303,'style','pushbutton','string','Delete It','units','pixels','pos',[165 10 75 30],'callback',@ergo);
            uicontrol('parent',303,'style','pushbutton','string','Go Back','units','pixels','pos',[308 10 75 30],'callback',@erback);
        elseif nargin==0
            return
        else
            sel
        end
        
        function sel()
            %load current settings from data
            if ishandle(1010)
                new_pos=get(hObject,'position');
                window_positions.extra=new_pos(1:2);
                close(1010);
            end
            newpos=get(main_window,'position');
            window_positions.main=[newpos(1),newpos(2)];
            active_preset=get(hObject,'userdata');
            set(currently_editing,'string',def_n{active_preset-3});
            for k=2:size(data,1)
                str=data{k,1};
                current.(str)=data{k,active_preset};
            end
            clear_advanced
        end
        
        function ergo(hObject1,eventdata)
            %continue without saving
            close(303)
            if ~ishandle(999)
                return
            end
            sel
        end
        
        function erback(hObject2,eventdata)
            %go back to the previous system
            close(303)
            if ~ishandle(999)
                main_window = figure(999);
                set(main_window,'toolbar','none','resize','off','menubar','none','color',[0 0 0],...
                    'numbertitle','off','name','DD_Omlab OMS Model V1.6.0','visible','off','deletefcn',@err_delete);
                draw_main
            end
        end
        
        function ersave(hObject3,eventdata)
            %save the system before replacing
            close(303)
            save_current
            if ~ishandle(999)
                return
            end
            sel
        end
        
    end

%%
%Function to load a custom O.M. Systems file
    function load_current(hObject,eventdata)
        [fln,pthn]=uigetfile({'*.oms;*.mat','O.M. System FIles'});
        %first we check to see if the cancel button was pressed
        if fln==0
            cd(cur_dir);
            set(level_1_buttons,'enable','on');
            return
        end
        try
            cd(pthn);
            %only want to overwrite the struct fields in the loaded file so if its
            %an old file all new settings will be given default values
            %So we give current all default values first
            for k=2:size(data,1)
                str=data{k,1};      current.(str)=data{k,4};
            end
            %try to load variables in the gui file format, if fails, try to
            %load in the old format before error
            loadin=load('-mat',fln);
            currentload=loadin.current;
            active_preset=loadin.active_preset;
            panel_list=loadin.panel_list;
            set_names=fieldnames(currentload);
            %overwrite defaults with loaded fields
            for k = 1:numel(set_names)
                str=set_names{k};   current.(str)=currentload.(str);
            end
            %redraw the advanced window if open
            clear_advanced
            %reset active default to custom now that the correct panel_list
            %is formed
            %*****NOTE this is why panel_list is a preallocated global  in
            %draw_tools, if active_preset is 0 it uses the predefined
            %panel list
            active_preset=0;
            set(currently_editing,'string',fln);
            cd(cur_dir);
        catch
            %before declaring an error we can first try and check if the
            %loaded file is from an old model version predating the current
            %gui
            try
                old_loadin=load('-mat',fln,'mdlparamlist');
                loadin.old=old_loadin.mdlparamlist;
                mdlparamlist=loadin.old;
                str={'PMC_Gain','PMC_Tau_2','PMC_Tau_3','Vel_Noise','CNS_Gain','Tonic_Gain',...
                    'Phasic_Gain','Sacc_Refract','SP_Gain','Alex_Law','Vel_Recon_SW','Lt_Drk',...
                    'Fs_Switch','Fs_Scale','Fs_Delay_Calc','Bs_Switch','BS_Scale','BSFS_V_Crit',...
                    'BSFS_A_Crit','Vol_Sacc_switch','Reset','PMC_Init','Reset_IC','Attention_Level',...
                    'Tentomy_Effect','G_Angle_Variation'};
                for ol= 1 : numel(mdlparamlist)
                    namevar=str{ol};
                    current.(namevar)=num2str(mdlparamlist(ol));
                end
                %we also need to define what panels to draw, since the old
                %saves have none of this data
                %***NOTE all old saves only used tools found on the
                %General_Tools Panel
                panel_list={'General_Tools'};
                clear_advanced
                active_preset=0;
                set(currently_editing,'string',fln);
                cd(cur_dir);
            catch
                %error handling for errors loading a file
                %should be called if unable to load in either the new or
                %the old format
                ld_error=figure(10);
                set(ld_error,'toolbar','none','position',[699 448 300 90],'menubar','none','resize','off',...
                'numbertitle','off','name','LOAD ERROR','deletefcn',@oerr)
                uicontrol('parent',ld_error,'style','pushbutton','string','OK','position',[125 10 60 30],'callback',@ok);
                uicontrol('parent',ld_error,'style','text','string',...
                    {'Incorrect File Type or Incompatible Version!!','Data not loaded! System Set to NORMAL'},'position',[20 50 260 30]);
                active_preset=4;
                set(level_1_buttons,'enable','off');
                set(currently_editing,'string',data{1,active_preset});
            end
        end
        
        function oerr(hObject,eventdata)
            cd(cur_dir);
            set(level_1_buttons,'enable','on');
        end
        
        function ok(hObject,eventdata)
                cd(cur_dir);
                close(10)
                set(level_1_buttons,'enable','on');
        end
    end

%%
%Function to allow user to save a Custom O.M. System
    function save_current(hObject,eventdata)
        [fln,pth]=uiputfile({'*.oms','O.M. System File'},'Save Current Settings');
        if fln==0
            return
        end
        cd(pth);
        save (fln, 'current', 'active_preset', 'panel_list');
        if ~ishandle(999)
            return
        end
        set(currently_editing,'string',fln);
        cd(cur_dir);
    end

%%
%Function to draw tools in any window that has tools
    function draw_tools(hObject,eventdata)
        %determine if draw_tools was called by the advanced button or the
        %run_gui
        if strcmp(get(main_window,'visible'),'off')
            tparent=run_gui;
            pos='run_gui';
        else
            tparent=main_window;
            pos='main';
        end
        %check if drawing in the main window or in the extra panel and
        %correcting the tool index i so as not to overwrite the index of
        %any panels in the main window
        if strcmp(get(main_window,'name'),'Extra Panel')
            %we shift the index of the extra window by the maximum number
            %of panels that can be drawn so even if panels are added to the
            %main window they wlll not overlap
            index_init=numel(unique(data(2:size(data,1),2)));
        else
            index_init=0;
        end
        %form a new panel list or if active_preset is custom, use the
        %previously formed list
        try
            %its better to reparse the panel list from data because it may
            %have been changed in the edit_settings
            dat_p=data{1,active_preset};
            sep3=regexp(dat_p,'&&','split');
            panel_list=regexp(sep3{1},'#','split');
            panel_list(1)=[];
        catch
            panel_list=panel_list;  %#ok<ASGSL> %I know this isnt necissary, but its there for mental continuity
        end
        %draw the tool panels       put1 & 2 are the x y locations to draw
        %panels that are determined programmatically but start at 0 25
        put1=0; put2=25; 
        set(tparent,'position',[window_positions.(pos) main_width+put2+415 main_height]);
        %use frame and advanced panel to allow slider use when it gets too
        %big
        frame=uipanel('parent',tparent,'units','pixels','position',[main_width 5 435 590],'tag','advanced','visible','on','backgroundcolor',[0.1 0.1 0.1]);
        advanced=uipanel('parent',frame,'units','pixels','position',[0 0 435 590],'tag','advanced','visible','on','backgroundcolor',[0.1 0.1 0.1]);
        if tparent == main_window %don't want to add tools to the run window
            uicontrol('parent',advanced,'style','pushbutton','units','pixels','backgroundcolor',[1 1 1],'position',[10 325 20 220],...
                'string','<HTML><center>A<br>d<br>d<br> <br>T<br>o<br>o<br>l<br>s<br>',...
                'fontweight','bold','callback',@add_panel);
            if tparent==figure(999)  %don't want hide panel button on the extra panel cuz it wouldn't work
                uicontrol('parent',advanced,'style','pushbutton','units','pixels','backgroundcolor',[1 1 1],'position',[10 45 20 220],...
                    'string','<HTML><center>H<br>i<br>d<br>e<br> <br>T<br>o<br>o<br>l<br>s<br>',...
                    'fontweight','bold','callback',@hide_panel);
            end
        end
        panel={};
        %set tool vertical spacing
        try
            tool_size=def_set.settings.tool_size;
        catch
            tool_size=22; 
            def_set.settings.tool_size=tool_size;
        end
        %set tool font
        try
            tool_font=def_set.settings.tool_font;
        catch
            tool_font=12; 
            def_set.settings.tool_font=tool_font;
        end
        try %#ok<TRYNC>
            delete(sldd);  %get rid of the slider if it was made and then panels were hidden
        end
        %draw each panel
        for i = (1+index_init):(size(panel_list,2)+index_init)
            %we need to be able to access the unshifted index i of the
            %tools for the panel_list names
            i_i=i-index_init;
            overflow=0; %initialize as not overflowing
            border=20;
            max_size=main_height-border; 
            tool_index=find(ismember(data(:,2),panel_list{i_i})==1); %find all tools on the current panel
            num_tools=numel(tool_index); %get the number of tools on the current panel
            %find out how many slider labels there are
            slid_index=strfind(data(tool_index,3),'slider');
            slidin=cellfun('isempty',slid_index);
            slid_index=find(~slidin);
            slid_index=tool_index(slid_index); %#ok<FNDSB>
            num_sl_labels=numel(slid_index)-numel(strfind([data{slid_index,3}],'%%%%'));
            %find the total height needed for the panel
            total_height_needed=num_tools*tool_size+tool_size+num_sl_labels*20;
            %check if we're at the bottom of the current column
            if put1 > max_size-tool_size-25
                put1=0;
                put2=put2+415;
                set(tparent,'position',[window_positions.(pos) main_width+put2+435 main_height]);
                set(frame,'visible','off','position',[main_width 5 420+put2 590]);
                set(advanced,'visible','off','position',[0 0 420+put2 590]);
            end
            %check if there's room for the next panel in the current column
            if total_height_needed > max_size-put1
                height = max_size-put1-25;
                height2 = total_height_needed - height+25;
                overflow=1;
            else
                height = total_height_needed;
            end
            scrsz=get(0,'screensize');
            if (put2+main_width) > scrsz(3)-300  %add a slider if the advanced window wouldn't fit in screen
               sldd=uicontrol('parent',tparent,'style','slider','position',[main_width 5 200 15],...
                    'min',0','max',put2+main_width-scrsz(3)+415,'callback',@ad_scroll,'sliderstep',[.25 .75]);
            else
                try delete(sldd); end %#ok<TRYNC>
            end
            %panel color is determined by a switch so we can preset static
            %colors for secondary panels that show up in multiple Presets
            switch panel_list{i_i}
                %if you want a panel that's white (no color set) then add a
                %switch here
                case 'General_Tools'
                    pan_color(i,:)=panel_color(1,:);
                case 'Therapy'
                    pan_color(i,:)=[1 1 1];
                case 'Inputs'
                    pan_color(i,:)=[1 1 1];
                case 'Run_Settings'
                    pan_color(i,:)=[1 1 1]; 
                case 'Waveforms'
                    pan_color(i,:)=[224 176 255]./255;
                otherwise
                    %first we can try to set a color based on the name of
                    %the panel  i.e. if its INS Therepy, it has INS in the
                    %name so will get the same color as INS
                        fnd1=strfind(data(1,:),panel_list{i_i});
                        findex=cellfun('isempty',fnd1);
                        fnd2=find(~findex)-3;
                        if fnd2>0
                            pan_color(i,:)=panel_color(fnd2(1),:);
                        else
                            %otherwise we set it to a default while
                            pan_color(i,:)=[1 1 1];
                        end
            end
            panel{i}=uipanel('visible','off','units','pixels','parent',advanced,'fontsize',9,...
                'position',[10+put2 main_height-height-put1-10 400 height]...
                ,'title',panel_list{i_i},'tag','advanced','visible','off','backgroundcolor',pan_color(i,:));
            put1=put1+height+10;
            if overflow  %if there are more tools in the panel then there is room in the current column
                put2=put2+415;
                subpanel{i}=uipanel('visible','off','parent',advanced,'units','pixels','fontsize',9,...
                'position',[10+put2 main_height-height2-10 400 height2]...
                ,'title',panel_list{i},'tag','advanced','visible','off','backgroundcolor',pan_color(i,:)); %#ok<AGROW>
                set(tparent,'position',[window_positions.(pos) main_width+put2+435 main_height]);
                set(advanced,'position',[0 0 420+put2 590]);
                set(frame,'pos',[main_width 5 420+put2 590]);
                put1=height2+10;
            end
            tool_y=0;
            sub_flag=0; %used to check if we need to draw in the sub panel or not
            for j = 1 : num_tools
                name=data{tool_index(j),1};
                try current.(name); %#ok<VUNUS>
                   %try to load the current field.  If it doesn't exist in
                   %the save / default file... fill it with default from
                   %normal
                catch
                    current.(name)=def_set.(name);
                end
                pparent=panel{i};
                %set overflow tools to draw on the new panel
                if tool_y > height-(tool_size+5)
                    tool_y=0;
                    sub_flag=1;
                    height=height2;
                end
                if sub_flag
                    pparent=subpanel{i};
                end
                %seperate all of the different flags in the ctrl_type data
                %slot to prep for putting in properties
                ctrl_data=data{tool_index(j),3};
                split_data_tooltip=regexp(ctrl_data,'&&','split');
                split_data_controls=split_data_tooltip{1};    
                seperate=regexp(split_data_controls,'%%','split');
                ctr_type=regexp(seperate{1},'#','split');
                %we need a try whenever calling the split off chunk of a
                %split since if there is no tooltip etc then calling it
                %would produce an error
                try
                    tooltip=split_data_tooltip{2};
                catch
                    tooltip=name;
                end
                %first we draw the textbox names of each tool
                tagxy=[5 height-tool_y-36 112 25];
                n_ha{i,j}=uicontrol('style','text','units','pixels','userdata',{name,i,j},...
                   'string',name,'parent',pparent,'position',tagxy,'tag','advanced',...
                   'tooltipstring',tooltip,'fontunits','pixels','fontsize',tool_font,'visible','on','backgroundcolor',pan_color(i,:));
                ext=get(n_ha{i,j},'extent');
                set(n_ha{i,j},'position',[tagxy(1:3),ext(4)]);
                tool_y=tool_y+tool_size;
                boxxy=[125 tagxy(2)-2 44 25];
                %and every tool has an edit box, visible or not, that holds
                %it current value
                t_h{i,j}=uicontrol('parent',pparent,'style','edit','userdata',{name,i,j},...
                   'string',current.(name),'position',boxxy,...
                   'callback',@set_current);
                %SECONDARY TOOLS
                tool2xy=[175 tagxy(2)-6 150 25];
                if strcmp(ctr_type{1},'none')
                elseif strcmp(ctr_type{1},'switch')
                   set(t_h{i,j},'visible','off'); %hide the edit box since its not need for a switch
                   %make switch
                   pxy=[boxxy(1)-5 boxxy(2) boxxy(3)+10 tagxy(4)+1];
                   p_h{i,j}=uicontrol('style','togglebutton','value',str2double(current.(name)),...
                    'position',pxy,'parent',pparent,...
                    'userdata',{name,i,j},'callback',@set_current_2);
                    %detect if on or off and set label accordingly
                    if str2double(current.(name))==1
                        set(p_h{i,j},'string','ON','foregroundcolor',[0.1 0.5 0.2])
                    elseif str2double(current.(name))==0
                        set(p_h{i,j},'string','OFF','foregroundcolor',[1 0 0])
                    end
                elseif strcmp(ctr_type{1},'slider')
                    %make slider
                    %get properties from ctrl_type splits or set to defauls
                    try
                        min=str2double(ctr_type{2});
                        max=str2double(ctr_type{3});
                    catch
                        min=0; max=1;
                    end
                    if isnan([min max])
                        min=0; max=1;
                    end
                    try
                        slide_st_set=regexp(seperate{3},'#','split');
                        slide_step(1)=str2double(slide_st_set{1})/(max-min);
                        slide_step(2)=str2double(slide_st_set{2})/(max-min);
                    catch
                        slide_step=[.1 .1];
                    end
                    if isnan(slide_step)
                        slide_step=[.1 .1];
                    end
                    tool2xy(3)=tool2xy(3)+60;
                    try
                        %if there are no labels we don't want to resize the
                        %panel, so we fail safely back to the loop
                        labels=regexp(seperate{2},'#','split');
                        if isempty([labels{:}])
                            dontdrawlabels
                        end
                        tool2xy(2)=tool2xy(2)-15;
                        set(n_ha{i,j},'pos',[tagxy(1) tagxy(2)-20 tagxy(3:4)]);
                        set(t_h{i,j},'pos',[boxxy(1) boxxy(2)-15 boxxy(3:4)]);
                        tool_y=tool_y+20;
                        %set labels to be equally spaced along the slider
                        label_spacing=(tool2xy(3))/(numel(labels)+1);
                        %locate and draw the labels
                        for l= 1:numel(labels)
                            l_x=tool2xy(1)+2+(l)*label_spacing-0.5*label_spacing;
                            l_y=tool2xy(2)+27;
                            l_w=6*numel(labels{l});
                            lab{i,j,l}=uicontrol('units','pixels','parent',pparent,...
                                'style','text','fontsize',8,'string',labels{l},'position',...
                                [l_x,l_y,l_w,12],'backgroundcolor',pan_color(i,:));
                        end
                    catch
                    end
                    p_h{i,j}=uicontrol('style','slider','value',str2double(current.(name)),...
                        'min',min,'max',max,'sliderstep',slide_step,...
                        'position',tool2xy,'parent',pparent,...
                        'userdata',{name,i,j},'callback',@set_current_2,'tooltip',['min: ' num2str(min) ' max: ' num2str(max)]);
                    %delimiter for new cell i.e. slider min and max is a #
                    %symbol
                elseif strcmp(ctr_type{1},'drop')
                    %make a dropdown menu
                    set(t_h{i,j},'visible','off');
                    tool2xy(2)=tool2xy(2)+2;
                    tool2xy(1)=tool2xy(1)+25;
                    p_h{i,j}=uicontrol('style','popupmenu','value',str2double(current.(name)),...
                        'string',ctr_type(2:numel(ctr_type)),'position',tool2xy,...
                        'parent',pparent,'userdata',{name,i,j},'callback',@set_current_2);
                    %delimiter for new cell i.e. menu items is a # symbol
                end
                %disable the tool if its driver switches are off
                try %#ok<TRYNC>
                    switch_driven=regexp(seperate{4},'#','split');
                    %need to reset the tag so it doesn't get turned back on
                    %may as well make it something relevent
                    set(n_ha{i,j},'tag',seperate{4})
                    for nn = 1:numel(switch_driven)
                        sw_name=switch_driven{nn};
                        on(nn)=str2double(current.(sw_name)); %#ok<AGROW>
                        if mean(on)<1
                            set(t_h{i,j},'visible','off');
                            set(n_ha{i,j},'visible','off');
                            set(p_h{i,j},'visible','off');
                            set([lab{i,j,:}],'visible','off');
                        end
                    end
                end
            end
        end
        %hopefully by doing all the legwork while hidden, speed is
        %increased and there's less flicker
        adv_hdl=findobj('tag','advanced');
        set(adv_hdl,'visible','on');
        
            function ad_scroll(hObject,eventdata)
                tparent=get(hObject,'parent');
                frame=findobj('parent',tparent,'type','uipanel');
                adv=findobj('parent',frame,'type','uipanel');
                oldpos=get(adv,'pos');
                chg=get(hObject,'value');
                newpos=[-chg oldpos(2:4)];
                set(adv,'pos',newpos);
                scrob=findobj('parent',adv);  %this is a lazy workaround for the bug in uipanel clipping
                for scof = 1 : numel(scrob)
                    pos = get(scrob(scof),'pos');
                    if pos(1)< chg
                        set(scrob(scof),'visible','off');
                    else
                        set(scrob(scof),'visible','on');
                    end
                end
            end

    end

%%
%called on editing a numerical box for a tool
%writes the new editied value into the current settings
%structure and updates any secondary tools
    function set_current(hObject,eventdata)
        %retrieve the name and data of the tool
        set(currently_editing,'string','CUSTOM');
        active_preset=0;
        ret_active=0;
        gdata=get(hObject,'string');
        gind=get(hObject,'userdata');
        gname=gind{1};
        i=gind{2};
        j=gind{3};
        %test if the value entered is actually a number
        tester=str2double(gdata);
        if isnan(tester)
            set(hObject,'string','0');
            gdata='0';
        end
        %update the current settings list
        current.(gname)=gdata;
        try
            %change the value of any secondary tools (i.e. slider) to
            %account for the new value entered into the text box
            set(p_h{i,j},'value',str2double(gdata))
            stl = get(p_h{i,j},'style');
            %check to make sure the typed in setting fits between the
            %boundary min and max, and corrects if neciccsary
            if strcmp(stl,'slider')
                min=get(p_h{i,j},'min');
                max=get(p_h{i,j},'max');
                if str2double(gdata)>max
                    set(p_h{i,j},'value',max);
                    set(t_h{i,j},'string',max);
                    current.(gname)=num2str(max);
                elseif str2double(gdata)<min
                    set(p_h{i,j},'value',min);
                    set(t_h{i,j},'string',min);
                    current.(gname)=num2str(min);
                end
            end
        catch
        end
    end

%%
%called upon changing a secondary tool
%updates the current setting of that tool as well as the number box value
    function set_current_2(hObject,eventdata)
        %see set_current for similar sructure
        active_preset=0;
        ret_active=0;
        set(currently_editing,'string','CUSTOM');
        gdata=get(hObject,'value');
        gind=get(hObject,'userdata');
        gname=gind{1};
        i=gind{2};
        j=gind{3};
        gdata=num2str(gdata);
        %set variable precision for the slider and box significant digits
        try %#ok<TRYNC>
            gdata=str2double(gdata(1:5));
        catch
            gdata=str2double(gdata);
        end
        current.(gname)=num2str(gdata);
        set(t_h{i,j},'string',num2str(gdata));
        %correct the label on a switch after being pressed
        stl=get(hObject,'style');
        if strcmp(stl,'togglebutton')
            check_sw(gname)
            if gdata==1;
                set(p_h{i,j},'string','ON','foregroundcolor',[0.1 0.5 0.2])
            elseif gdata==0;
                set(p_h{i,j},'string','OFF','foregroundcolor',[1 0 0])
            end
        end
    end

%%
%Check all of the tools that the calling switch drives, as well as
%check to see if all the other driving switches for a tool are on
%as well
    function check_sw(gname)
        %this is the only way I found to search for a string within a
        %cell array...yay matlab..so we find any controls that have the
        %switch named in the cntrl_type box and enable/disable as
        %appropriate
        driven_by_this_switch=strfind(data(:,3),gname);
        driven_index=cellfun('isempty',driven_by_this_switch);
        driven_ind=find(~driven_index);
        driven_data=cell(1,numel(driven_ind));
        %since we want to set the tag, box ,and secondary tool, the best
        %way is by finding the indecies of the handles...
        %but we also need to find if the tool in question relies on more
        %than one switch
        for oo=1:numel(driven_ind)
            %for each of the tools the calling switch controls, we get its
            %handle and i j indecies, as well as the tools control data to
            %see what else controls it
            driven_handles=findobj('string',data{driven_ind(oo),1});
            ddata2{oo}=data{driven_ind(oo),3};
            temp_ct=regexp(ddata2{oo},'&&','split');
            temp_sep=regexp(temp_ct{1},'%%','split');
            try
            ddata2{oo}=temp_sep{4};
            catch
                return
            end
            if numel(driven_handles)>1
                delete(driven_handles(2));
            end
            driven_data{oo}=get(driven_handles(1),'userdata');
        end    
        for pp=1:numel(driven_ind)
            %now we evaluaate each indecies
            dij=driven_data{pp};
            ii=dij{2}; jj=dij{3};
            all_drivers=regexp(ddata2{pp},'#','split');
            if isempty(all_drivers{:})
                return
            end
            for po = 1 :numel(all_drivers)
                %and here we check all of a tools controls
                obj=findobj('string',all_drivers{po});
                dr_dat=get(obj,'userdata');
                val=get(p_h{dr_dat{2},dr_dat{3}},'value');
                sw_state(po)=val;
            end
            if mean(sw_state)==1
                %the idea being that if even one switch is off the mean
                %will be less than 1
                onstate='on';
            else
                onstate='off';
            end
            set(n_ha{ii,jj},'visible',onstate,'tag',ddata2{pp});
            set(t_h{ii,jj},'visible',onstate);
            try %#ok<TRYNC>
            set(p_h{ii,jj},'visible',onstate);
            if strcmp(get(p_h{ii,jj},'style'),'popupmenu')
                set(t_h{ii,jj},'visible','off');
            end
            set([lab{ii,jj,:}],'visible',onstate);
            end
        end
        
    end

%%
%Function to create the run window
    function run_window(hObject,eventdata)
        %hide the main window rather than close to increase load speed on
        %returning
        set(main_window,'visible','off')
        run_gui=figure(111);
        ret_width=main_width;
        ret_high=main_height;
        main_height=300;
        main_width=5;
        %size set to the same as the main window for conveniance
        set(run_gui,'color',[0 0 0],'position',[window_positions.run_gui main_width main_height],'visible','on',...
            'toolbar','none','resize','off','menubar','none','deletefcn',@ret_main,...
            'numbertitle','off','name','DD_Omlab OMS Model V1.6.0    Simulation Settings');
        qt=uicontrol('style','pushbutton','string','Return to Main Window','position',[50 50 160 30],'callback',@ret_main);
        rn=uicontrol('style','pushbutton','string','RUN','position',[50 80 160 30],'callback',@run_mdl);
        sigedit=uicontrol('style','pushbutton','string','Edit input signals','parent',111,'pos',[50 110 160 30],'callback',@inp_edit);
        %there has to be a uiwait somewhere in the model while running
        %because nothing is workable on the command line while running
        
        %uicontrol('style','pushbutton','string','STOP','position',[50 140 160 30],'callback',@force_stop);
        
        %the below values are used by draw_tools, and since we want to use
        %draw_tools to make the run window we need to store the previous
        %values so as to restore the work environment when the user returns
        %to the main window
        ret_active=active_preset;
        no_recursion=0;
        active_preset=0;
        ret_p_list=panel_list;
        ret_p_color=pan_color;
        panel_list={'Inputs','Run_Settings'};
        draw_tools
        
        function inp_edit(hObject,eventdata)
            fullmdlp=gcs;
            mdlsep=regexp(fullmdlp,sep,'split');
            mdl=mdlsep{1};
            in_c=[mdl sep 'Input Choices'];
            set_param(gcb,'selected','off');
            root=sfroot;
            root.set('CurrentSystem',mdl); 
            root.getCurrentSystem.set('CurrentBlock','Input Choices');
            set_param(in_c,'selected','on');
            sigbuilder_block('open',[437.6 199.2 550.4 400 ]);
        end
            
        function run_mdl(hObjec,eventdata)     
            %redlight
            set([qt rn sigedit],'enable','off');
            %must run the simulation from base workspace in order to save
            %the ouptuts
            fullmdlp=gcs;
            mdlsep=regexp(fullmdlp,sep,'split');
            mdl=mdlsep{1};
            set_param([mdl sep 'Eye' sep sep 'Tgt Scope'],'TimeRange',current.Run_time)
            
            evalin('base',['sim(''' mdl ''',' (current.Run_time) ')'])
            set([qt rn sigedit],'enable','on');
            %greenlight
        end
 
        function force_stop(hObject,eventdata)
            set_param(mdl, 'SimulationCommand','stop')
            set([qt rn sigedit],'enable','on');
        end
            
        function ret_main(hObject,eventdata)
            % prevent closing the run_gui with the return button from
            % calling its own delete function
            if no_recursion
                return
            end
            %restore the previous work environment
            main_height=ret_high;
            main_width=ret_width;
            active_preset=ret_active;
            panel_list=ret_p_list;
            pan_color=ret_p_color;
            runpos=get(run_gui,'position');
            window_positions.run_gui=runpos(1:2);
            %test if ret_main was called by the button or the delete icon
            if strcmp('off',get(run_gui,'beingdeleted'))
                no_recursion=1;
                close(run_gui)                
            end
            sw_advanced=get(main_buttons(5),'value');
            editing=get(currently_editing,'string');
            delete(level_1_buttons);
            set(main_window,'visible','on');
            draw_main
            set(currently_editing,'string',editing);
            set(main_window,'visible','on');
            set(main_buttons(5),'value',sw_advanced);
            clear_advanced
        end        
    end

%%
%Function for the edit settings window
%called by main_window
    function edit_settings(hObject,eventdata)
        set(main_window,'visible','off');
        edit_gui=figure(909);
        edit_size=220;
        set(edit_gui,'toolbar','none','color',[0 0 0],'position',[window_positions.edit_gui edit_size 600],'menubar','none','resize','off','numbertitle','off','name','Edit GUI Settings','deletefcn',@call_main)
        %draw all of the buttons and fields
        call_edit_data=uicontrol('parent',edit_gui,'style','pushbutton'...
            ,'string','Edit GUISettings Database','position',[10 80 200 30],'callback',@edit_data,...
            'tooltip','Make Changes to the Surce Database of the GUI ||FOR ADVANCED USERS ONLY||  Check the user manual for syntax');
        dirs= uicontrol('parent',edit_gui,'style','text','string',data_direct,'position',[10 200 200 40]);
        set_work_dir = uicontrol('parent',edit_gui,'style','pushbutton','string','Load Settings File','position',[10 325 200 30],'callback',@load_sets,...
            'tooltip','Load a different copy of guisettings.mat with its set pre-sets, saved window positions, tool-spacing and tool font size');
        uicontrol('parent',edit_gui,'style','text','units','pixels','position',[10 250 200 25],'string','Current Setting File Location');
        sav_cop = uicontrol('parent',edit_gui,'style','pushbutton','string','Save Copy','position',[10 285 200 30],'callback',@save_copy,...
            'tooltip','Save a copy of the current guisettings.mat file');
        add_def = uicontrol('parent',edit_gui,'style','pushbutton','string','Add or Edit a Preset','position',[10 160 200 30],'callback',@add_default,...
            'tooltip','Make Changes to a Pre-Set System, or add a whole new one');
        ed_set = uicontrol('parent',edit_gui,'style','pushbutton','string','Add or Edit a Tool','position',[10 120 200 30],'callback',@ed_tool,...
            'tooltip','Change anything about a tool from its type, to its name or default settings, or add a whole new tool');
        admin_tog=uicontrol('parent',edit_gui,'style','pushbutton','string','Change User Mode','pos',[10 560 200 30],'callback',@admin_ui,...
            'tooltip','Switch between an Administrator and a standard User');
        set1=uicontrol('parent',edit_gui,'style','edit','string',num2str(def_set.settings.tool_size),'pos',[150 362 30 30],'callback',@set_tool_space);
        uicontrol('style','text','parent',edit_gui,'string','Tool Spacing (pixels)','fontunits','pixels','fontsize',12,'pos',[10 365 120 15],...
            'tooltip','Set the vertical spacing between different tools');
        set2=uicontrol('parent',edit_gui,'style','edit','string',num2str(def_set.settings.tool_font),'pos',[150 392 30 30],'callback',@set_tool_font);
        uicontrol('style','text','parent',edit_gui,'string','Tool Font Size (pixels)','fontunits','pixels','fontsize',12,'pos',[10 395 120 15],...
            'tooltip','Set the font size of the text label for tools');
        set2ds=uicontrol('parent',edit_gui,'style','pushbutton','string','Set Sizes to Default','pos',[10 425 200 30],'callback',@sets_to_def,...
            'tooltip','Set both the tool spacing and font size to their default values');
        admin_buttons=[add_def,ed_set call_edit_data];
        %check what mode we're in and set things to visible as appropriate
        if ~admin_flag
            set(admin_buttons,'visible','off');
            usr_m='User';
        else
            set(admin_buttons,'visible','on');
            usr_m='Administrator';
        end
        user_mode=uicontrol('style','text','parent',edit_gui,'string',{'User Mode:',usr_m},'pos',[10 510 200 40]);
        mode=[]; pw_enter=[]; pw_prompt=[]; admin_p=[];
        close_edit=uicontrol('parent',edit_gui,'style','pushbutton','string','Return to Main',...
            'position',[10 15 200 40],'callback',@call_main,'tooltip','Close the edit window and return to the main window');        
        %by putting all of the button handles into an array, we can
        %enable/disable all of the buttons in a sinle command
        buttons_in_edit_settings=[close_edit call_edit_data set_work_dir sav_cop add_def ed_set admin_tog set1 set2 set2ds];
        
        %callback for tool font size input      
        function set_tool_font(hObject,eventdata)
            newsize=str2double(get(hObject,'string'));
            if isnan(newsize) %check if input is a number
                newsize=12;
                set(hObject,'string',num2str(newsize))
            elseif newsize < 6 %set min
                newsize=6;
                set(hObject,'string',num2str(newsize))
            elseif newsize > 18 %set max
                newsize=18;
                set(hObject,'string',num2str(newsize))
            end
            def_set.settings.tool_font=newsize;
        end
        
        %callback for tool spacing input
        function set_tool_space(hObject,eventdata)
            newsize=str2double(get(hObject,'string'));
            if isnan(newsize)
                newsize=25;
                set(hObject,'string',num2str(newsize))
            elseif newsize < 19
                newsize=19;
                set(hObject,'string',num2str(newsize))
            elseif newsize > 30
                newsize=30;
                set(hObject,'string',num2str(newsize))
            end
            def_set.settings.tool_size=newsize;
        end
        
        function admin_ui(hObject,eventdata)
            %UI window for setting the user mode
            set(buttons_in_edit_settings,'Enable','off');
            admin_p=figure(404);
            set(admin_p,'toolbar','none','color',[0 0 0],'position',[[window_positions.edit_gui]+[10 500] 220 100],...
                'menubar','none','resize','off','numbertitle','off','name','Change User Mode','deletefcn',@ad_close);
            current_mode=admin_flag+1;
            mode{2}=uicontrol('parent',admin_p,'style','radiobutton','pos',[10 75 100 20],'string','Administrator','callback',@chk_p,'foregroundcolor',[1 1 1]);
            mode{1}=uicontrol('parent',admin_p,'style','radiobutton','pos',[110 75 100 20],'string','User','callback',@chk_p,'foregroundcolor',[1 1 1]);
            set(mode{current_mode},'value',1);
            pw_prompt=uicontrol('parent',admin_p,'style','text','string','Enter Password','position',[10 40 80 20]);
            pw_enter=uicontrol('parent',admin_p,'style','edit','pos',[95 40 100 25]);
            chk_p %check if we need to display password entry
            uicontrol('parent',admin_p,'style','pushbutton','string','OK','pos',[80 5 60 30],'callback',@mode_set);
        end
        
        function ad_close(hObject,eventdata)
            set(buttons_in_edit_settings,'Enable','on');
        end
        
        function mode_set(hObject,eventdata)
            %function to test pword and / or change the user mode
            if get(mode{1},'value') %set to user
                usr_m='User';
                admin_flag=0;
                set(buttons_in_edit_settings,'Enable','on');
                close(admin_p)
                set(admin_buttons,'visible','off');
            elseif strcmp(get(pw_enter,'visible'),'on') && strcmp(get(pw_enter,'string'),'0mlab') %pword is correct
                set(admin_buttons,'visible','on');
                usr_m='Administrator';
                admin_flag=1;
                set(buttons_in_edit_settings,'Enable','on');
                close(admin_p)
            elseif admin_flag==1 && get(mode{2},'value')
                set(buttons_in_edit_settings,'Enable','on');
                close(admin_p)
            else
                %incorrect passowrd
            end    
            set(user_mode,'string',{'User Mode:',usr_m});
        end
        
        function chk_p(hObject,eventdata)
            %function to hide the password entry field if not needed
            if nargin > 0
                set(setdiff([mode{:}],hObject),'value',0);
                set(hObject,'value',1);
            end
            if get(mode{2},'value') && ~admin_flag
                set([pw_prompt,pw_enter],'visible','on');
            else
                set([pw_prompt,pw_enter],'visible','off');
            end            
        end
        
        function call_main(hObject,eventdata)
            %function to return to the main window
            if ~strcmp(get(edit_gui,'beingdeleted'),'on')
                close(edit_gui)
                return
            end
            editpos=get(edit_gui,'position');
            window_positions.edit_gui=editpos(1:2);
            sw_advanced=get(main_buttons(5),'value');
            editing=get(currently_editing,'string');
            delete([level_1_buttons])
            draw_main
            set(currently_editing,'string',editing);
            set(main_buttons(5),'value',sw_advanced);
            set(main_window,'visible','on');
            clear_advanced
        end        
        
    end

%%
%function to restore default settings to the display options
    function sets_to_def(hObject,eventdata)
        set(set1,'string','22');
        def_set.settings.tool_size=22;
        set(set2,'string','12');
        def_set.settings.tool_font=12;
    end

%%
%function to add or edit a pre-set with the edit preset
%expansion tab
%called by edit settings  
    function add_default(hObject,eventdata)
        %draw the initial list to select a preset or add new
        newpos=get(edit_gui,'position');
        window_positions.edit_gui=[newpos(1),newpos(2)];
        set(edit_gui,'position',[window_positions.edit_gui edit_size+375 600]);
        set(buttons_in_edit_settings,'Enable','off');
        %find the names of all the defaults from the buttons on the main
        %window
        def_names=get(def_buttons,'string');
        def_names=['Add a New Preset O.M. System';def_names];
        editor4=uipanel('Parent',edit_gui,'units','pixels','Title','Add or Edit a Preset','Position',[edit_size 5 230 590]);
        uicontrol('parent',editor4,'style','text','units','pixels','position',[5 550 220 20],'string','Select an O.M. System to Edit');
        d_select=uicontrol('parent',editor4,'style','listbox','max',1,'min',0,'string',def_names,'position',[5 40 220 510],'value',1);        
        uicontrol('style','pushbutton','parent',editor4,'string','Cancel','position',[5 10 75 30],'callback',@canc);
        uicontrol('style','pushbutton','parent',editor4,'string','Next','position',[150 10 75 30],'callback',@nextd);
        edit_table3=[]; editor3=[]; test_new=[]; def_num=[]; pan_ad=[]; all_panels={}; ch_box={}; add_d=[]; dtltip=[];
        
        
        function nextd(hObject,eventdata)
            %create the editing page
            set(editor4,'visible','off');
            test_new=get(d_select,'value');
            if test_new == 1  %are we making a new one?  if so set some defaults
                set_list=data(:,1);
                set_list(:,2)=data(:,4);
                set_list(1,2)={'ENTER NAME'};
                panels={};
                dtooltip='SET TOOL-TIP';
            else  %otherwise get all the data
                set_list=data(:,1);
                def_num=get(d_select,'value')+2;
                panel_data=data{1,def_num};
                sep3=regexp(panel_data,'&&','split');
                panel_data=regexp(sep3{1},'#','split');
                try
                    dtooltip=sep3{2};
                catch
                    dtooltip=def_names{test_new};
                end
                panels=panel_data(2:numel(panel_data));
                set_list(:,2)=data(:,def_num);
                set_list(1,2)=def_names(test_new);
            end
            %now draw the UI
            editor3=uipanel('Parent',edit_gui,'units','pixels','Title','Add or Edit a Preset','Position',[edit_size 5 360 590]);
            edit_table3=uitable('Parent',editor3,'Data',set_list,'Position',[15 5 200 530]);
            set(edit_table3,'datachangedcallback',@test_name);
            add_d=uicontrol('style','pushbutton','parent',editor3,'string','Add / Edit','position',[235 50 75 30],'callback',@add_new);
            dtltip=uicontrol('style','edit','parent',editor3,'string',dtooltip,'units','pixels','pos',[75 540 150 20]);
            test_name  %make sure the name is valid
            uicontrol('style','text','parent',editor3,'string','Tool-Tip','units','pixels','position',[10 537 60 20]);
            uicontrol('style','pushbutton','parent',editor3,'string','Cancel','position',[235 10 75 30],'callback',@canc);
            uicontrol('parent',editor3,'style','text','string',{'*NOTE* Due ','To a Bug in ','MATLAB RC2008a ','SELECT a NEW CELL ','OR Press ENTER','Before Saving'},'position',[235 440 100 115]);
            p_a_ui=uipanel('parent',editor3,'title','Pick Panels to Draw','units','pixels','position',[220 90 130 350]);
            all_panels=unique(data(2:size(data,1),2));
            ch_box=cell(numel(all_panels,1));
            chk_y=305;
            on_index=find(ismember(all_panels,panels));  %find what panels are in the preset
            for pp = 1 : numel (all_panels)
                ch_box{pp}=uicontrol('parent',p_a_ui,'style','checkbox','units','pixels',...
                    'position',[10 chk_y 100 30],'string',all_panels{pp});
                chk_y=chk_y-25;
            end
            for qq = 1 : numel(on_index)
                set(ch_box{on_index(qq)},'value',1);
            end
        end
        
        function test_name(hObject,eventdata)
            %make sure the name is a valid var-name, otherwise disable the
            %add button
            dat= get(edit_table3,'data');
            dat=dat(:,2);
            dat=cell(dat);
            n_test= isvarname(dat{1});
            if n_test
                set(add_d,'enable','on')
            else
                set(add_d,'enable','off')
            end
        end
        
        function canc(hObject,eventdata)
            newpos=get(edit_gui,'position');
            window_positions.edit_gui=[newpos(1),newpos(2)];
            delete([editor3,editor4]);
            set(edit_gui,'position',[window_positions.edit_gui edit_size 600]);
            set(buttons_in_edit_settings,'Enable','on');
        end
        
        function add_new(hObject,eventdata)
            %parse all of the ui data
            newtltp=get(dtltip,'string');
            new_def=get(edit_table3,'data');
            new_def=cell(new_def);
            newdata_cell=new_def(:,2);
            for qq=1:numel (all_panels)
                %poll the checkboxes and add all checked values to the list
                %of panels to draw
                if get(ch_box{qq},'value')
                    newdata_cell(1)={[newdata_cell{1} '#' all_panels{qq}]};
                end
            end
            %put all the info into the data format
            newdata_cell(1)={[newdata_cell{1} '&&' newtltp]};
            if test_new ==1  %check if editing old or adding new
                data=[data,newdata_cell];
            else
                data(:,def_num)=newdata_cell;                
            end
            cd(data_direct)
            save guisettings.mat def_set data window_positions
            cd(cur_dir);
            canc(hObject,eventdata)
        end

    end  

%%
%Function to add or edit a tool
%called by edit settings
    function ed_tool(hObject,eventdata)
        newpos=get(edit_gui,'position');
        window_positions.edit_gui=[newpos(1),newpos(2)];
        set(edit_gui,'position',[window_positions.edit_gui edit_size+245 600]);
        set(buttons_in_edit_settings,'Enable','off');
        all_tools=data(2:size(data,1),1);
        editor3=uipanel('Parent',edit_gui,'units','pixels','Title','Add or Edit a Tool','Position',[edit_size 5 230 590]);
        uicontrol('parent',editor3,'style','text','units','pixels','position',[5 550 220 20],'string','Select a Tool to Edit');
        all_tools=['Add a New Tool';all_tools];
        t_select=uicontrol('parent',editor3,'style','listbox','max',1,'min',0,'string',all_tools,'position',[5 40 220 510],'value',1);        
        uicontrol('style','pushbutton','parent',editor3,'string','Cancel','position',[5 10 75 30],'callback',@cancc);
        uicontrol('style','pushbutton','parent',editor3,'string','Next','position',[150 10 75 30],'callback',@next);
        def_names=get(def_buttons,'string');
        %we need to initialize some variables to pass back and forth
        all_panels=[]; all_types=[]; editor2=[]; new_name=[]; p_choice=[]; new_p_name=[]; new_p_n_t=[];
        t_choice=[]; tooltip=[]; sw_depend=[]; t_choice=[]; min_s=[]; max_s=[]; edit_table2=[];
        labels_s=[]; choices_s=[]; sm_step_s=[]; big_step_s=[]; switches={}; dyn_w=[]; add_t=[];
        
        
        function next(hObject,eventdata)
            set(editor3,'visible','off');
            add_set_ui %create the ui for all the info
            test_new=get(t_select,'value');
            if test_new ~= 1  %only need to read info if we're editing an old tool
                %read all of the tool's data
                name=all_tools{test_new};
                tl_find=strcmp(data(:,1),name);
                tl_ind=find(tl_find);
                ctrl_data=data{tl_ind,3};
                split_data_tooltip=regexp(ctrl_data,'&&','split');
                split_data_controls=split_data_tooltip{1};    
                seperate=regexp(split_data_controls,'%%','split');
                ctr_type=regexp(seperate{1},'#','split');
                try
                    tooltip_s=split_data_tooltip{2};
                catch
                    tooltip_s=name;
                end
                set(tooltip,'string',tooltip_s);
                set(new_name,'string',name);
                pl_find=strcmp(data{tl_ind,2},all_panels);
                pl_ind=find(pl_find);
                set(p_choice,'value',pl_ind);
                def_data=cell(numel(def_names),2);
                def_data(:,1)=def_names;
                def_data(:,2)=data(tl_ind,4:size(data,2));
                set(edit_table2,'data',def_data);
                try %#ok<TRYNC>
                    switch_driven=regexp(seperate{4},'#','split');
                    sw_find=[];
                    for ss = 1 :numel(switch_driven)
                        sw_find=[sw_find;strfind(switches,switch_driven{ss})]; %#ok<AGROW>
                    end
                    sw_index=cellfun('isempty',sw_find);
                    sw_ind=find(~sw_index);
                    set(sw_depend,'value',sw_ind);
                end
                switch ctr_type{1} %parse style dependent data
                    case 'switch'
                        set(t_choice,'value',1);
                    case 'slider'
                        set(t_choice,'value',3);
                        set_dyn
                        try %#ok<TRYNC>
                        set(min_s,'string',ctr_type{2});
                        set(max_s,'string',ctr_type{3});
                        end
                        try %#ok<TRYNC>
                            slide_st_set=regexp(seperate{3},'#','split');
                            slide_step(1)=str2double(slide_st_set{1});
                            slide_step(2)=str2double(slide_st_set{2});
                            set(sm_step_s,'string',num2str(slide_step(1)));
                            set(big_step_s,'string',num2str(slide_step(2)));
                        end
                        try %#ok<TRYNC>
                        labels_tx=regexp(seperate{2},'#','split');
                        set(labels_s,'string',labels_tx);
                        end
                    case 'drop'
                        set(t_choice,'value',4);
                        set_dyn
                        set(choices_s,'string',ctr_type(2:numel(ctr_type)));
                    otherwise
                        set(t_choice,'value',2);
                end
                check_fields
            end
        end
        
        function add_set_ui(hObject,eventdata)
            newpos=get(edit_gui,'position');
            window_positions.edit_gui=[newpos(1),newpos(2)];
            set(edit_gui,'position',[window_positions.edit_gui edit_size+245 600]);
            set(buttons_in_edit_settings,'Enable','off');
            all_panels=unique(data(2:size(data,1),2));
            all_panels=['Select a Panel';'Add in New Panel';all_panels(:)];
            all_types={'switch','number box','slider','drop-down menu'};
            editor2=uipanel('Parent',edit_gui,'units','pixels','Title','Add a Tool','Position',[edit_size 5 230 590]);
            new_name=uicontrol('parent',editor2,'style','edit','position',[75 550 150 25],'string',['Tool_' num2str(size(data,1))],'callback',@check_fields);
            p_choice=uicontrol('parent',editor2,'style','popupmenu','string',all_panels,'position',[75 520 150 25],'callback',@check_fields); %^^^
            new_p_name=uicontrol('parent',editor2,'style','edit','position',[75 494 150 25],'visible','off','callback',@check_fields);
            t_choice=uicontrol('parent',editor2,'style','popupmenu','string',all_types,'position',[75 460 150 25],'callback',@set_dyn);
            tooltip=uicontrol('parent',editor2','style','edit','position',[75 440 150 25],'string',['Tool_' num2str(size(data,1))]);
            sw_find=strfind(data(:,3),'switch'); %find all the driving switches
            sw_index=cellfun('isempty',sw_find);
            sw_ind=find(~sw_index);
            switches=data(sw_ind,1); %#ok<FNDSB>
            cur_tools=fieldnames(current);
            sw_depend=uicontrol('parent',editor2,'style','listbox','max',numel(cur_tools),'min',0,'string',switches,'position',[75 375 150 65],'value',[]);
            uicontrol('parent',editor2,'style','text','position',[3 550 70 20],'string','Tool Name',...
                'tooltip','<html>Enter a name for the tool (must be valid variable name) <br>- begin with a letter <br>- no spaces <br>- no special characters)');
            uicontrol('parent',editor2,'style','text','position',[3 520 70 20],'string','Put In Panel',...
                'tooltip','Select which panel to add the tool to');
            new_p_n_t=uicontrol('parent',editor2,'style','text','position',[3 490 75 20],'string','New Panel','visible','off',...
                'tooltip','Enter a name for the new panel');
            uicontrol('parent',editor2,'style','text','position',[3 460 70 20],'string','Tool Type',...
                'tooltip','Select a tool type');
            uicontrol('parent',editor2,'style','text','position',[3 438 70 20],'string','Tool-Tip',...
                'tooltip','Enter a tool-tip for this tool');
            uicontrol('parent',editor2,'style','text','position',[3 380 70 40],'string','Depends on Switches',...
                'tooltip','Select any switches that must be on for this tool to be visible');
            add_t=uicontrol('style','pushbutton','parent',editor2,'string','Add / Edit','position',[30 40 150 30],'callback',@add_new,'enable','off',...
                'tooltip','Only enabled if all fields set correctly');
            uicontrol('style','pushbutton','parent',editor2,'string','Cancel','position',[30 10 150 30],'callback',@canc);
            styl=[];
            dyn_w=uipanel('parent',editor2,'units','pixels','position',[15 70 200 300]);
            set_dyn

            function canc(hObject,eventdata)
                newpos=get(edit_gui,'position');
                window_positions.edit_gui=[newpos(1),newpos(2)];
                delete(editor2)
                set(edit_gui,'position',[window_positions.edit_gui edit_size 600]);
                set(buttons_in_edit_settings,'Enable','on');
                uiresume
            end

            function add_new(hObject,eventdata)
                %check if we need to delete the old verison of a tool when
                %editing to prevent duplicates
                check_delete(get(new_name,'string'));
                %read out of the ui all of the tool's info
                def_data=get(edit_table2,'data');
                def_data=cell(def_data(:,2))';
                for dd = 1 : numel(def_data)
                    def_data(dd)={num2str(def_data{dd})};
                end
                if get(p_choice,'value')==2
                    panel=get(new_p_name,'string');
                else
                    panel=all_panels{get(p_choice,'value')};
                end
                %now read based on dynamic window
                switch get(t_choice,'value')
                    case 1 %switch
                        styl='switch';
                        newdata_cell={get(new_name,'string') panel [styl '%%%%%%' switches{get(sw_depend,'value')} '&&' get(tooltip,'string')] def_data{:}};
                    case 2 %box
                        styl='none';
                        newdata_cell={get(new_name,'string') panel [styl '%%%%%%' switches{get(sw_depend,'value')} '&&' get(tooltip,'string')] def_data{:}};
                    case 3 %slider
                        styl='slider';
                        labelget=get(labels_s,'string');
                        labels={};
                        for l = 1 : size(labelget,1)
                            if ~isempty(labelget(l,:))
                                if l < size(labelget,1)
                                    labels(l)={[labelget(l,:) '#']}; %#ok<AGROW>
                                else
                                   labels(l)={[labelget(l,:)]}; %#ok<AGROW> prevent adding a trailing blank label
                                end
                            end
                        end
                        if ~iscell(labels{1})  %for some reason the data type can change between reading and writing to data (shrug)
                            labels=[labels{:}];
                        else
                            labels=[labels{:}];
                            labels=[labels{:}];
                        end
                        newdata_cell={get(new_name,'string') panel...
                            [styl '#' get(min_s,'string') '#' get(max_s,'string') '%%'...
                            labels '%%' get(sm_step_s,'string') '#' get(big_step_s,'string') '%%'...
                            switches{get(sw_depend,'value')} '&&'...
                            get(tooltip,'string')]...
                            def_data{:}};
                    case 4 %dropdown
                        styl='drop';
                        choiceget=get(choices_s,'string');
                        for l = 1 : size(choiceget,1)
                            if ~isempty(choiceget(l,:)) %prevent adding empty choices
                                choices(l,:)=['#' choiceget(l,:)]; %#ok<AGROW>
                            end
                        end
                        choices=choices';
                        choices=choices(:)';
                        if ~iscell(choices)
                            %choices=choices';   %again....(shrug) may be a
                            %PC error with get()
                        else
                            choices=[choices{:}];
                        end
                        newdata_cell={get(new_name,'string') panel [styl choices '%%%%%%' switches{get(sw_depend,'value')} '&&' get(tooltip,'string')] def_data{:}};
                end
                data=[data;newdata_cell];
                %sort the database based on tool name
                [void,ind]=sortrows(data(:,1));
                data=data(ind,:);
                str=get(new_name,'string');
                %update the def_set and current fields
                def_set.(str)=def_data{1};
                if active_preset == 0
                        current.(str)=def_data{1};
                else
                        current.(str)=def_data{active_preset-3};
                end
                %save the changes
                cd(data_direct)
                save guisettings.mat def_set data window_positions
                cd(cur_dir);
                canc(hObject,eventdata)
            end
        end
        
        function check_fields(hObject,eventdata)
            %make sure all of the fields are valid before allowing the user
            %to add a new tool
            if isempty(get(new_name,'string'))||... %must be a name for the tool
                    (isempty(get(new_p_name,'string'))&&get(p_choice,'value')==2)||... %user must have picked a name for the new panel if adding to new
                    get(p_choice,'value')==1||... %user must have picked a panel
                    (get(t_choice,'value')==4&&ishandle(choices_s)&&size(get(choices_s,'string'),1)<2)||... %must be at least 2 choices in a drop box
                    ~isvarname(get(new_name,'string'))||...  %new name must be valid variable name
                    (~isempty(get(new_p_name,'string'))&&~isvarname(get(new_p_name,'string')))||... %new panel name must be a valid varaible name
                    (get(p_choice,'value')==2&&~numel(setdiff(get(new_p_name,'string'),all_panels)));  %new panel cannot have same name as an existing
                set(add_t,'enable','off')
            else
                set(add_t,'enable','on')
            end
            if get(p_choice,'value')==2
                set([new_p_name new_p_n_t],'visible','on')
            else
                set([new_p_name new_p_n_t],'visible','off')
            end
        end

        function set_dyn(hObject,eventdata)
            %function to draw the dynamic field window
            if ~isempty(edit_table2) %only want to refresh the table if its empty aka not lose any enterd data
                def_data=get(edit_table2,'data');
                def_data=cell(def_data);
            else
                def_data=cell(numel(def_names),2);
                def_data(:,1)=def_names;
                def_data(:,2)=num2cell(zeros(numel(def_names,1)));
            end
            del1=get(dyn_w,'children'); %clear the dynamic window to make room for the new stuff
            delete(del1);
            edit_table2=uitable('parent',dyn_w,'data',def_data,'position',[1 5 200 135],'columnnames',{'O.M. Syst','Default'});
            switch get(t_choice,'value')
                case 1 %switch
                    styl='switch';
                case 2 %box
                    styl='none';
                case 3 %slider
                    styl='slider';
                    min_s=uicontrol('parent',dyn_w,'style','edit','position',[45 270 50 25]);
                    uicontrol('parent',dyn_w,'style','text','string','min','position',[5 270 30 20],...
                        'tooltip','Set the minimum value for the slider');
                    max_s=uicontrol('parent',dyn_w,'style','edit','position',[140 270 50 25]);
                    uicontrol('parent',dyn_w,'style','text','string','max','position',[105 270 30 20],...
                        'tooltip','Set the maximum value for the slider');
                    sm_step_s=uicontrol('parent',dyn_w,'style','edit','position',[45 230 50 25]);
                    uicontrol('parent',dyn_w,'style','text','string','small step','position',[5 222 30 30],...
                        'tooltip','Set the amount the slider changes when clicking a slider arrow');
                    big_step_s=uicontrol('parent',dyn_w,'style','edit','position',[140 230 50 25]);
                    uicontrol('parent',dyn_w,'style','text','string','big step','position',[105 222 30 30],...
                        'tooltip','Set the amount the slider changes when clicking on the slider track');
                    labels_s=uicontrol('parent',dyn_w,'style','edit','position',[55 155 120 60],'max',30);
                    uicontrol('parent',dyn_w,'style','text','string','labels','position',[5 175 35 30],...
                        'tooltip','Enter each label on a new line.  Labels will be evenly spaced along the slider,');
                case 4 %drop
                    styl='drop';
                    choices_s=uicontrol('parent',dyn_w,'style','edit','position',[55 155 135 135],'max',30,'callback',@check_fields);
                    uicontrol('parent',dyn_w,'style','text','string','choices','position',[5 200 45 30],...
                        'tooltip','Enter each choice on a new line.');
            end
            check_fields
        end
        
        function check_delete(name)
            %function to see if the user was editing a tool or adding a new
            %one, and deleting the old before adding to prevent duplicates
            test_new=get(t_select,'value');
                if test_new ~= 1
                    old_tools=get(t_select,'string');
                    oldname=old_tools{test_new};
                    tl_find=strfind(data(:,1),oldname);
                    tl_index=cellfun('isempty',tl_find);
                    tl_ind=find(~tl_index);
                    data(tl_ind,:)=[];
                    data(:,3)=regexprep(data(:,3),oldname,name);
                end
        end
            
        function cancc(hObject,eventdata)
            newpos=get(edit_gui,'position');
            window_positions.edit_gui=[newpos(1),newpos(2)];
            delete(editor3)
            set(edit_gui,'position',[window_positions.edit_gui edit_size 600]);
            set(buttons_in_edit_settings,'Enable','on');
            uiresume
        end
        
    end
        
%%
%function to save a copy of the settings file in a user defined directory
%called by edit_settings
    function save_copy(hObject,eventdata)
        set(buttons_in_edit_settings,'Enable','off');
        [fln,pth]=uiputfile('*.mat','Save a Copy of guisettings.mat','guisettings');
        %error handling
        if (fln==0) %user pressed cancel
            set(buttons_in_edit_settings,'Enable','on');
            return
        end
        if ~strcmp(fln,'guisettings.mat')
            uiwait(msgbox('GUI Settings must be saved in a file of name guisettings.mat','Error, Invalid Name','modal'));
            save_copy
            return
        end
        if exist([pth sep 'guisettings.mat'],'file')
            uiwait(msgbox('There is already a guisettings file in this directory. Change save location and try again.','Error, NO OVERWRITING!','modal'));
            save_copy
            return
        end
        cd(pth);
        save guisettings.mat data window_positions def_set
        cd(cur_dir);
        set(buttons_in_edit_settings,'Enable','on');
    end

%%
%Function to load a different settings file than the one currently in use
%called by edit_settings
    function load_sets(hObject,eventdata)
        set(buttons_in_edit_settings,'Enable','off');
        old_dir=work_direct;
        [fln,pth]=uigetfile;
        if (fln==0)
            work_direct=old_dir;
            set(buttons_in_edit_settings,'Enable','on');
            return
        end
        work_direct=pth;
        cd(work_direct);
        fln=[pth 'guisettings.mat'];
        %check if the current directory has a settings file
        try
            loadin=load(fln);
        catch
             % if no setting file exists, show error dialog
            figure(15)
            set(15,'position',[100 450 420 75],'toolbar','none','menubar','none','resize','off','numbertitle','off','name','Create New?');
            uicontrol('style','text','string','No Settings File Exists in this Directory','position',[50 50 330 20]);
            uicontrol('string','OK','position',[210 10 150 30],'callback',@canc);
            return
        end   
        data=loadin.data;
        def_set=loadin.def_set;
        if active_preset>0; active_preset=4; end %incase the loaded settings file has a different number of presets, prevent errors
        try %load display settings
            set(set1,'string',num2str(def_set.settings.tool_size));
            set(set2,'string',num2str(def_set.settings.tool_font));
        catch
            sets_to_def;
        end
        window_positions=loadin.window_positions;
        set(dirs,'string',work_direct);
        data_direct=work_direct;
        work_direct=old_dir;
        cd(cur_dir);
        set(buttons_in_edit_settings,'Enable','on');
            
            function canc(hObject,eventdata)
                cd(old_dir);
                set(buttons_in_edit_settings,'Enable','on');
                close(15)
                work_direct=old_dir;
            end

    end

%%
%Function for edit guisettings database expansion tab
%called by edit_settings
    function edit_data(hObject,eventdata)
        newpos=get(edit_gui,'position');
        window_positions.edit_gui=[newpos(1),newpos(2)];
        set(edit_gui,'position',[window_positions.edit_gui edit_size+800 600]);
        set(buttons_in_edit_settings,'Enable','off');
        editor=uipanel('Parent',edit_gui,'units','pixels','Title','Edit the GUI Data and Settings File','Position',[edit_size 5 785 590]);
        edit_table=uitable('Parent',editor,'Data',data,'Position',[5 5 670 570]);
        uicontrol('parent',editor,'style','pushbutton','string','Cancel','position',[680 100 100 30],'callback',@cancel);
        uicontrol('parent',editor,'style','pushbutton','string','Save','position',[680 140 100 30],'callback',@save_data);
        uicontrol('parent',editor,'style','pushbutton','string','Save & Close','position',[680 180 100 30],'callback',@save_close);
        uicontrol('parent',editor,'style','text','string',{'*NOTE* Due ','To a Bug in ','MATLAB RC2008a ','SELECT a NEW CELL ','OR Press ENTER','Before Saving'},'position',[680 280 100 115]);
        
        function cancel(hObject,eventdata)
            newpos=get(edit_gui,'position');
            window_positions.edit_gui=[newpos(1),newpos(2)];
            set(editor,'visible','off');
            set(edit_table,'visible',0);
            set(edit_gui,'position',[window_positions.edit_gui edit_size 600]);
            set(buttons_in_edit_settings,'Enable','on');
        end
        
        function save_data(hObject,eventdata)
            dat=get(edit_table,'Data');
            data=cell(dat);
            cd(data_direct)
            save guisettings.mat def_set data window_positions
            cd(cur_dir);
        end
        
        function save_close(hObject,eventdata)
            save_data(hObject,eventdata)
            cancel(hObject,eventdata)
        end
        
    end

%%
%Function to create a settings file and the initial Presets from embedded
%information
%called by init_load and load_settings:on error
    function create_settings
        %created with gencode
        data{1, 1} = ' settingss';data{1, 2} = 'Tool_Panel_ID';data{1, 3} = 'cntrl_type';
        data{1, 4} = 'Normal#General_Tools';data{1, 5} = 'FMNS#General_Tools#FMNS#Therapy';
        data{1, 6} = 'INS#General_Tools#INS#INS_Therapy';
        data{1, 7} = 'Saccadic#General_Tools#SACC#Therapy';data{1, 8} = 'GEN#General_Tools#Therapy';
        data{2, 1} = 'A_Law_Asym';data{2, 2} = 'INS';
        data{2, 3} = 'switch&&Determine whether Alexander''s Law acts symmetrically or not.';
        data{2, 4} = '0';data{2, 5} = '0';data{2, 6} = '0';data{2, 7} = '0';data{2, 8} = '0';
        data{3, 1} = 'Alex_Law_LE';data{3, 2} = 'FMNS';
        data{3, 3} = 'slider#-0.1#0.05%%steep#shallow#flat#reverse%%0.01#0.01&&Set the asymetic slope for Alexander''s Law on the Left Side';
        data{3, 4} = '-0.03';data{3, 5} = '-0.03';data{3, 6} = '-0.03';data{3, 7} = '-0.03';data{3, 8} = '-0.03';
        data{4, 1} = 'Alex_Law_RE';data{4, 2} = 'FMNS';
        data{4, 3} = 'slider#-0.1#0.05%%steep#shallow#flat#reverse%%0.01#0.01&&Set the slope for Alexander''s Law';
        data{4, 4} = '-0.03';data{4, 5} = '-0.03';data{4, 6} = '-0.03';data{4, 7} = '-0.03';data{4, 8} = '-0.03';
        data{5, 1} = 'Attention_Level';data{5, 2} = 'General_Tools';data{5, 3} = 'none';data{5, 4} = '1';data{5, 5} = '1';
        data{5, 6} = '1';data{5, 7} = '1';data{5, 8} = '1';data{6, 1} = 'BSFS_A_Crit';data{6, 2} = 'General_Tools';
        data{6, 3} = 'none';data{6, 4} = '40';data{6, 5} = '40';data{6, 6} = '40';data{6, 7} = '40';
        data{6, 8} = '40';data{7, 1} = 'BSFS_V_Crit';data{7, 2} = 'General_Tools';data{7, 3} = 'none';
        data{7, 4} = '7';data{7, 5} = '7';data{7, 6} = '7';data{7, 7} = '7';data{7, 8} = '7';data{8, 1} = 'BS_Scale';
        data{8, 2} = 'General_Tools';data{8, 3} = 'none';data{8, 4} = '1';data{8, 5} = '1';data{8, 6} = '1';data{8, 7} = '1';
        data{8, 8} = '1';data{9, 1} = 'Bs_Switch';data{9, 2} = 'General_Tools';data{9, 3} = 'switch';data{9, 4} = '0';
        data{9, 5} = '1';data{9, 6} = '1';data{9, 7} = '0';data{9, 8} = '1';data{10, 1} = 'CNS_Gain';data{10, 2} = 'General_Tools';
        data{10, 3} = 'slider##%%%%NaN#NaN%%&&CNS_Gain';data{10, 4} = '1';data{10, 5} = '1';data{10, 6} = '1';
        data{10, 7} = '1';data{10, 8} = '1';data{11, 1} = 'Fix_Eye';data{11, 2} = 'General_Tools';
        data{11, 3} = 'drop#Right Eye#Left Eye%%%%%%&&Fix_Eye';data{11, 4} = '1';data{11, 5} = '1';data{11, 6} = '1';
        data{11, 7} = '1';data{11, 8} = '1';data{12, 1} = 'Flutter';data{12, 2} = 'SACC';data{12, 3} = 'switch';
        data{12, 4} = '0';data{12, 5} = '0';data{12, 6} = '0';data{12, 7} = '0';data{12, 8} = '0';data{13, 1} = 'Flutter_Dysmetria';
        data{13, 2} = 'SACC';data{13, 3} = 'switch';data{13, 4} = '0';data{13, 5} = '0';data{13, 6} = '0';data{13, 7} = '0';
        data{13, 8} = '0';data{14, 1} = 'Fs_Delay_Calc';data{14, 2} = 'General_Tools';data{14, 3} = 'none';data{14, 4} = '60';
        data{14, 5} = '60';data{14, 6} = '60';data{14, 7} = '60';data{14, 8} = '60';data{15, 1} = 'Fs_Scale';
        data{15, 2} = 'General_Tools';data{15, 3} = 'none';data{15, 4} = '1';data{15, 5} = '1';data{15, 6} = '1';
        data{15, 7} = '1';data{15, 8} = '1';data{16, 1} = 'Fs_Switch';data{16, 2} = 'General_Tools';data{16, 3} = 'switch';
        data{16, 4} = '0';data{16, 5} = '1';data{16, 6} = '1';data{16, 7} = '0';data{16, 8} = '1';data{17, 1} = 'G_Angle_Variation';
        data{17, 2} = 'INS';data{17, 3} = 'none%%%%%%&&G_Angle_Variation';data{17, 4} = '0';data{17, 5} = '0';data{17, 6} = '0';
        data{17, 7} = '0';data{17, 8} = '0';data{18, 1} = 'Gaze_Thresh';data{18, 2} = 'INS';data{18, 3} = 'none';data{18, 4} = '0';
        data{18, 5} = '0';data{18, 6} = '0';data{18, 7} = '0';data{18, 8} = '0';data{19, 1} = 'HO';data{19, 2} = 'SACC';
        data{19, 3} = 'switch';data{19, 4} = '0';data{19, 5} = '0';data{19, 6} = '0';data{19, 7} = '0';data{19, 8} = '0';
        data{20, 1} = 'HR';data{20, 2} = 'SACC';data{20, 3} = 'switch';data{20, 4} = '0';data{20, 5} = '0';data{20, 6} = '0';
        data{20, 7} = '0';data{20, 8} = '0';data{21, 1} = 'Input_Signal';data{21, 2} = 'Inputs';
        data{21, 3} = 'drop#2x 15 Pulse#5 10 15 Deg#Const 0    #Smooth Pers%%%%%%&&Select an Input Signal For the Model';
        data{21, 4} = '1';data{21, 5} = '1';data{21, 6} = '1';data{21, 7} = '1';data{21, 8} = '1';data{22, 1} = 'Kest_Eff';
        data{22, 2} = 'INS_Therapy';data{22, 3} = 'switch';data{22, 4} = '0';data{22, 5} = '0';data{22, 6} = '0';data{22, 7} = '0';
        data{22, 8} = '0';data{23, 1} = 'Latent_Comp';data{23, 2} = 'INS';data{23, 3} = 'switch';data{23, 4} = '0';data{23, 5} = '1';
        data{23, 6} = '0';data{23, 7} = '0';data{23, 8} = '0';data{24, 1} = 'Lt_Drk';data{24, 2} = 'General_Tools';
        data{24, 3} = 'none';data{24, 4} = '1';data{24, 5} = '1';data{24, 6} = '1';data{24, 7} = '1';data{24, 8} = '1';
        data{25, 1} = 'MSO';data{25, 2} = 'SACC';data{25, 3} = 'switch&&Macro-Saccadic Oscillation';data{25, 4} = '0';
        data{25, 5} = '0';data{25, 6} = '0';data{25, 7} = '0';data{25, 8} = '0';data{26, 1} = 'NZ_Waveform';
        data{26, 2} = 'Waveforms';data{26, 3} = 'drop#Pend. w. FS#Psudo Pend.#Jerk       %%%%%%Overide_Wave_Set&&<html>Select the Neutral Zone Waveform<br>overide settings located in loadmdlp.m';
        data{26, 4} = '1';data{26, 5} = '1';data{26, 6} = '1';data{26, 7} = '1';data{26, 8} = '1';data{27, 1} = 'Neutral_Zone';
        data{27, 2} = 'Waveforms';data{27, 3} = 'slider#0#30%%0 Deg #15 Deg#30 Deg%%1#5%%&&Select the threshold in degrees for the Neutral Zone';
        data{27, 4} = '0';data{27, 5} = '0';data{27, 6} = '0';data{27, 7} = '0';data{27, 8} = '0';data{28, 1} = 'Null';data{28, 2} = 'INS';
        data{28, 3} = 'slider#-30#30%%L far#L near#Center#R near#R far&&Select the location of the Null Point in gaze angle degrees';
        data{28, 4} = '0';data{28, 5} = '0';data{28, 6} = '0';data{28, 7} = '0';data{28, 8} = '0';data{29, 1} = 'Null_AL_L';
        data{29, 2} = 'INS';data{29, 3} = 'slider#-0.1#0.05%%steep#shallow#flat#reverse%%0.01#0.01%%A_Law_Asym&&Set the asymetic slope for Alexander''s Law on the Left Side';
        data{29, 4} = '-.03';data{29, 5} = '-.03';data{29, 6} = '-.03';data{29, 7} = '0';data{29, 8} = '0';data{30, 1} = 'Null_AL_R';
        data{30, 2} = 'INS';data{30, 3} = 'slider#-0.1#0.05%%steep#shallow#flat#reverse%%0.01#0.01&&Set the slope for Alexander''s Law.  If Alexander''s Law is Symmertric, setting the right side also determines the left';
        data{30, 4} = '-.03';data{30, 5} = '-.03';data{30, 6} = '-.03';data{30, 7} = '0';data{30, 8} = '0';data{31, 1} = 'Null_Time';
        data{31, 2} = 'INS';data{31, 3} = 'switch';data{31, 4} = '0';data{31, 5} = '0';data{31, 6} = '0';data{31, 7} = '0';data{31, 8} = '0';
        data{32, 1} = 'Overide_Wave_Set';data{32, 2} = 'Waveforms';data{32, 3} = 'switch%%%%%%&&<html>Select whether to override FS_Scale and BS_Switch in order to manually set NZ Waveform<br>overide settings located in loadmdlp.m';
        data{32, 4} = '0';data{32, 5} = '0';data{32, 6} = '0';data{32, 7} = '0';data{32, 8} = '0';data{33, 1} = 'PMC_Gain';data{33, 2} = 'General_Tools';
        data{33, 3} = 'slider#1#4%%%%#%%&&PMC_Gain';data{33, 4} = '1.1';data{33, 5} = '1.1';data{33, 6} = '3.025';data{33, 7} = '1.1';data{33, 8} = '1.1';
        data{34, 1} = 'PMC_Init';data{34, 2} = 'General_Tools';data{34, 3} = 'none';data{34, 4} = '0';data{34, 5} = '0';data{34, 6} = '0';data{34, 7} = '0';
        data{34, 8} = '0';data{35, 1} = 'PMC_Tau_2';data{35, 2} = 'General_Tools';data{35, 3} = 'none';data{35, 4} = '35';data{35, 5} = '35';data{35, 6} = '35';
        data{35, 7} = '35';data{35, 8} = '35';data{36, 1} = 'PMC_Tau_3';data{36, 2} = 'General_Tools';data{36, 3} = 'none';data{36, 4} = '30';
        data{36, 5} = '30';data{36, 6} = '40';data{36, 7} = '30';data{36, 8} = '30';data{37, 1} = 'Phasic_Gain';data{37, 2} = 'General_Tools';
        data{37, 3} = 'slider##%%%%#%%&&Phasic_Gain';data{37, 4} = '1';data{37, 5} = '1';data{37, 6} = '1';data{37, 7} = '1';data{37, 8} = '1';
        data{38, 1} = 'Reset';data{38, 2} = 'General_Tools';data{38, 3} = 'none';data{38, 4} = '0';data{38, 5} = '0';data{38, 6} = '0';
        data{38, 7} = '0';data{38, 8} = '0';data{39, 1} = 'Reset_IC';data{39, 2} = 'General_Tools';data{39, 3} = 'none';data{39, 4} = '0';
        data{39, 5} = '0';data{39, 6} = '0';data{39, 7} = '0';data{39, 8} = '0';data{40, 1} = 'Run_time';data{40, 2} = 'Run_Settings';
        data{40, 3} = 'slider#2#20%%2 sec#10  sec# 20 sec#%%0.5#1%%&&Run_time';data{40, 4} = '4';data{40, 5} = '4';data{40, 6} = '4';
        data{40, 7} = '4';data{40, 8} = '4';data{41, 1} = 'SP_Gain';data{41, 2} = 'General_Tools';data{41, 3} = 'none';data{41, 4} = '.95';
        data{41, 5} = '.95';data{41, 6} = '.95';data{41, 7} = '.95';data{41, 8} = '.95';data{42, 1} = 'SSI';data{42, 2} = 'SACC';
        data{42, 3} = 'switch&&Staircase Saccadic';data{42, 4} = '0';data{42, 5} = '0';data{42, 6} = '0';data{42, 7} = '0';
        data{42, 8} = '0';data{43, 1} = 'SWJ';data{43, 2} = 'SACC';data{43, 3} = 'switch';data{43, 4} = '0';data{43, 5} = '0';
        data{43, 6} = '0';data{43, 7} = '0';data{43, 8} = '0';data{44, 1} = 'SWJ_Amp';data{44, 2} = 'SACC';data{44, 3} = 'slider#0#1%%%%%%SWJ&&Square Wave Jerk Amplitude';
        data{44, 4} = '0';data{44, 5} = '0';data{44, 6} = '0';data{44, 7} = '0';data{44, 8} = '0';data{45, 1} = 'SWJ_Freq';data{45, 2} = 'SACC';
        data{45, 3} = 'slider%%%%%%SWJ';data{45, 4} = '0';data{45, 5} = '0';data{45, 6} = '0';data{45, 7} = '0';data{45, 8} = '0';
        data{46, 1} = 'SWO';data{46, 2} = 'SACC';data{46, 3} = 'switch';data{46, 4} = '0';data{46, 5} = '0';data{46, 6} = '0';data{46, 7} = '0';
        data{46, 8} = '0';data{47, 1} = 'SWO_Ampl';data{47, 2} = 'SACC';data{47, 3} = 'slider#0#1%%%%%%SWO&&Square Wave Oscillation Amplitude';
        data{47, 4} = '0';data{47, 5} = '0';data{47, 6} = '0';data{47, 7} = '0';data{47, 8} = '0';data{48, 1} = 'SWO_Freq';data{48, 2} = 'SACC';
        data{48, 3} = 'slider%%%%%%SWO';data{48, 4} = '0';data{48, 5} = '0';data{48, 6} = '0';data{48, 7} = '0';data{48, 8} = '0';
        data{49, 1} = 'SWP';data{49, 2} = 'SACC';data{49, 3} = 'switch&&Square Wave Pulse';data{49, 4} = '0';data{49, 5} = '0';
        data{49, 6} = '0';data{49, 7} = '0';data{49, 8} = '0';data{50, 1} = 'Sacc_Refract';data{50, 2} = 'General_Tools';
        data{50, 3} = 'none';data{50, 4} = '50';data{50, 5} = '50';data{50, 6} = '50';data{50, 7} = '50';data{50, 8} = '50';
        data{51, 1} = 'Smooth_Per';data{51, 2} = 'General_Tools';data{51, 3} = 'none';data{51, 4} = '0';data{51, 5} = '0';
        data{51, 6} = '0';data{51, 7} = '0';data{51, 8} = '0';data{52, 1} = 'Srabis_Ampl';data{52, 2} = 'FMNS';data{52, 3} = 'slider#0#50%%0#25#50%%1#5';
        data{52, 4} = '0';data{52, 5} = '0';data{52, 6} = '0';data{52, 7} = '0';data{52, 8} = '0';data{53, 1} = 'Strabis_type';
        data{53, 2} = 'FMNS';data{53, 3} = 'drop#Eccentripia#Excentripia';data{53, 4} = '1';data{53, 5} = '1';data{53, 6} = '1';
        data{53, 7} = '1';data{53, 8} = '1';data{54, 1} = 'Tentomy_Effect';data{54, 2} = 'INS_Therapy';
        data{54, 3} = 'slider#0#1%%Off#25%#50%#75%#100% %%0.01#0.1&&Select the magnitude of the effect of tentomy';data{54, 4} = '0';
        data{54, 5} = '0';data{54, 6} = '0';data{54, 7} = '0';data{54, 8} = '0';data{55, 1} = 'Therapy_Central';data{55, 2} = 'Therapy';
        data{55, 3} = 'switch';data{55, 4} = '0';data{55, 5} = '0';data{55, 6} = '0';data{55, 7} = '0';data{55, 8} = '0';
        data{56, 1} = 'Therapy_Periferal';data{56, 2} = 'Therapy';data{56, 3} = 'switch';data{56, 4} = '0';data{56, 5} = '0';
        data{56, 6} = '0';data{56, 7} = '0';data{56, 8} = '0';data{57, 1} = 'Tonic_Gain';data{57, 2} = 'General_Tools';
        data{57, 3} = 'none';data{57, 4} = '5';data{57, 5} = '5';data{57, 6} = '5';data{57, 7} = '5';data{57, 8} = '5';
        data{58, 1} = 'Vel_Noise';data{58, 2} = 'General_Tools';data{58, 3} = 'none';data{58, 4} = '0';data{58, 5} = '.0001';
        data{58, 6} = '.001';data{58, 7} = '0';data{58, 8} = '0';data{59, 1} = 'Vel_Recon_SW';data{59, 2} = 'General_Tools';
        data{59, 3} = 'none';data{59, 4} = '25';data{59, 5} = '25';data{59, 6} = '25';data{59, 7} = '25';data{59, 8} = '25';
        data{60, 1} = 'Vol_Sacc_switch';data{60, 2} = 'General_Tools';data{60, 3} = 'none';data{60, 4} = '1';data{60, 5} = '1';
        data{60, 6} = '1';data{60, 7} = '1';data{60, 8} = '1';data{61, 1} = 'World_Backg';data{61, 2} = 'World';data{61, 3} = 'none';
        data{61, 4} = '0';data{61, 5} = '0';data{61, 6} = '0';data{61, 7} = '0';data{61, 8} = '0';data{62, 1} = 'World_Vel';
        data{62, 2} = 'World';data{62, 3} = 'none';data{62, 4} = '0';data{62, 5} = '0';data{62, 6} = '0';data{62, 7} = '0';data{62, 8} = '0';
        for k=2:size(data,1)
            str=data{k,1};
            def_set.(str)=data{k,4};
        end
        window_positions.main=[10 50];
        window_positions.edit_gui=[50 50];
        window_positions.run_gui=[100 100];
        window_positions.extra=[500 50];
        cd(work_direct)
        save guisettings.mat def_set data window_positions
        cd(cur_dir);
    end

%%

end