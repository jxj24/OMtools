function data = parsesaccfile(data)

fn = data.filename; fn=strtok(fn,'.');
a = load([fn '_extras.mat']);
field_name = cell2mat( fieldnames(a) );
extras = eval([ 'a.' field_name] );

if isfield(extras, 'sacc')
   sacc = extras.sacc;
   if isempty(fieldnames(sacc)), return; end
   numsaccs=length(sacc.eye);
   data.start_times = extras.start_times;
   data.h_pix_z = extras.h_pix_z;
   data.h_pix_deg = extras.h_pix_deg;
   data.v_pix_z = extras.v_pix_z;
   data.v_pix_deg = extras.v_pix_deg;
   v_pix_z = extras.v_pix_z;
   v_pix_deg = extras.h_pix_deg;
   h_pix_z = extras.v_pix_z;
   h_pix_deg = extras.h_pix_deg;
   
   l_cnt = 0; r_cnt = 0;
   for i=1:numsaccs
      switch sacc.eye{i}
         case 'L'
            l_cnt = l_cnt+1;
            if ~isempty(sacc.xpos)
               data.lh.saccades.paramtype = 'EDF_PARSER';
               data.lh.saccades.sacclist.start(l_cnt) = sacc.start(i);
               data.lh.saccades.sacclist.end(l_cnt) = sacc.end(i);
               data.lh.saccades.sacclist.dur(l_cnt) = sacc.dur(i);
               data.lh.saccades.sacclist.startpos(l_cnt) = (sacc.xpos(i)-h_pix_z)/h_pix_deg;
               data.lh.saccades.sacclist.endpos(l_cnt) = (sacc.xposend(i)-h_pix_z)/h_pix_deg;
               data.lh.saccades.sacclist.ampl(l_cnt) = (sacc.ampl(i)-h_pix_z)/h_pix_deg;
               data.lh.saccades.sacclist.pvel(l_cnt) = sacc.pvel(i);
            end
            if ~isempty(sacc.ypos)
               data.lv.saccades.paramtype = 'EDF_PARSER';
               data.lv.saccades.sacclist.start(l_cnt) = sacc.start(i);
               data.lv.saccades.sacclist.end(l_cnt) = sacc.end(i);
               data.lv.saccades.sacclist.dur(l_cnt) = sacc.dur(i);
               data.lv.saccades.sacclist.startpos(l_cnt) = (sacc.ypos(i)-v_pix_z)/v_pix_deg;
               data.lv.saccades.sacclist.endpos(l_cnt) = (sacc.yposend(i)-v_pix_z)/v_pix_deg;
               data.lv.saccades.sacclist.ampl(l_cnt) = (sacc.ampl(i)-v_pix_z)/v_pix_deg;
               data.lv.saccades.sacclist.pvel(l_cnt) = sacc.pvel(i);
            end
            
         case 'R'
            r_cnt = r_cnt+1;
            if ~isempty(sacc.xpos)
               data.rh.saccades.paramtype = 'EDF_PARSER';
               data.rh.saccades.sacclist.start(r_cnt) = sacc.start(i);
               data.rh.saccades.sacclist.end(r_cnt) = sacc.end(i);
               data.rh.saccades.sacclist.dur(r_cnt) = sacc.dur(i);
               data.rh.saccades.sacclist.startpos(r_cnt) = (sacc.xpos(i)-h_pix_z)/h_pix_deg;
               data.rh.saccades.sacclist.endpos(r_cnt) = (sacc.xposend(i)-h_pix_z)/h_pix_deg;
               data.rh.saccades.sacclist.ampl(r_cnt) = (sacc.ampl(i)-h_pix_z)/h_pix_deg;
               data.rh.saccades.sacclist.pvel(r_cnt) = sacc.pvel(i);
            end
            if ~isempty(sacc.ypos)
               data.rv.saccades.paramtype = 'EDF_PARSER';
               data.rv.saccades.sacclist.start(r_cnt) = sacc.start(i);
               data.rv.saccades.sacclist.end(r_cnt) = sacc.end(i);
               data.rv.saccades.sacclist.dur(r_cnt) = sacc.dur(i);
               data.rv.saccades.sacclist.startpos(r_cnt) = (sacc.ypos(i)-v_pix_z)/v_pix_deg;
               data.rv.saccades.sacclist.endpos(r_cnt) = (sacc.yposend(i)-v_pix_z)/v_pix_deg;
               data.rv.saccades.sacclist.ampl(r_cnt) = (sacc.ampl(i)-v_pix_z)/v_pix_deg;
               data.rv.saccades.sacclist.pvel(r_cnt) = sacc.pvel(i);
            end
      end %switch
   end %for i
end % if sacc is a field of extras
