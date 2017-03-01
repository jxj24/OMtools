classdef emData
   % emData Contains necessary data for analyzing eye movements
   %   Detailed explanation goes here
   
   properties
      recmeth = '';   % IR, VID, COIL, RCOIL
      start_times = []; % if sharing common timebase w/external data samples
      filename = '';
      comments = '';
      %iscalibrated=0;
      calibrations = [];
      samp_freq = 0; % uint?
      numsamps =  0; % ?, uint32?
      h_pix_z = 0; h_pix_deg = 0;
      v_pix_z = 0; v_pix_deg = 0;
      
      rh=struct( 'data', [], 'dataraw',[],'channel', 'rh', 'chan_comment',[], ...
         'saccades',struct('paramtype',[],'sacclist',struct()),...
         'fixation',struct('paramtype',[],'fixlist', struct()) );
      lh=struct( 'data', [], 'channel', 'lh', 'chan_comment',[], ...
         'saccades',struct('paramtype',[],'sacclist',struct()),...
         'fixation',struct('paramtype',[],'fixlist', struct()) );
      rv=struct( 'data', [], 'channel', 'rv', 'chan_comment',[], ...
         'saccades',struct('paramtype',[],'sacclist',struct()),...
         'fixation',struct('paramtype',[],'fixlist', struct()) );
      lv=struct( 'data', [], 'channel', 'lv', 'chan_comment',[], ...
         'saccades',struct('paramtype',[],'sacclist',struct()),...
         'fixation',struct('paramtype',[],'fixlist', struct()) );
      rt=struct( 'data', [], 'channel', 'rt', 'chan_comment',[], ...
         'saccades',struct('paramtype',[],'sacclist',struct()),...
         'fixation',struct('paramtype',[],'fixlist', struct()) );
      lt=struct( 'data',[ ], 'channel', 'lt', 'chan_comment',[], ...
         'saccades',struct('paramtype',[],'sacclist',struct()),...
         'fixation',struct('paramtype',[],'fixlist', struct()) );
      hh=struct('data',[], 'channel','hh','chan_comment',[]);
      hv=struct('data',[], 'channel','hv','chan_comment',[]);
      st=struct('data',[], 'channel','st','chan_comment',[]);
      sv=struct('data',[], 'channel','sv','chan_comment',[]);
      ds=struct('data',[], 'channel','ds','chan_comment',[]);
      tl=struct('data',[], 'channel','tl','chan_comment',[]);
      
   end
                                                        
   methods
      % export basic data to base workspace
      % save filled emData struct as .mat file
   end
   
end

