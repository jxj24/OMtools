function data = parseblinkfile(data)

fn = data.filename; fn=strtok(fn,'.');
a = load([fn '_extras.mat']);
field_name = cell2mat( fieldnames(a) );
extras = eval([ 'a.' field_name] );

if isfield(extras, 'blink')
	blink = extras.blink;   
   if isempty(fieldnames(blink)), return; end
	numblinks=length(blink.eye);
	data.start_times = extras.start_times;
	data.h_pix_z = extras.h_pix_z;
	data.h_pix_deg = extras.h_pix_deg;
	data.v_pix_z = extras.v_pix_z;
	data.v_pix_deg = extras.v_pix_deg;
	
	l_cnt = 0; r_cnt = 0;
	for i=1:numblinks
		switch blink.eye{i}
			case 'L'
				l_cnt = l_cnt+1;
				data.lh.blink.paramtype = 'EDF_PARSER';
				data.lh.blink.blinklist.start(l_cnt) = blink.start(i);
				data.lh.blink.blinklist.end(l_cnt) = blink.end(i);
				data.lh.blink.blinklist.dur(l_cnt) = blink.dur(i);
				data.lv.blink.paramtype = 'EDF_PARSER';
				data.lv.blink.blinklist.start(l_cnt) = blink.start(i);
				data.lv.blink.blinklist.end(l_cnt) = blink.end(i);
				data.lv.blink.blinklist.dur(l_cnt) = blink.dur(i);
				
			case 'R'
				r_cnt = r_cnt+1;
				data.rh.blink.paramtype = 'EDF_PARSER';
				data.rh.blink.blinklist.start(r_cnt) = blink.start(i);
				data.rh.blink.blinklist.end(r_cnt) = blink.end(i);
				data.rh.blink.blinklist.dur(r_cnt) = blink.dur(i);
				data.rv.blink.paramtype = 'EDF_PARSER';
				data.rv.blink.blinklist.start(r_cnt) = blink.start(i);
				data.rv.blink.blinklist.end(r_cnt) = blink.end(i);
				data.rv.blink.blinklist.dur(r_cnt) = blink.dur(i);
		end %switch
	end %for i
end %blinks field exists