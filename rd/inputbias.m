% inputbias.m:
% Prompt user for the necessary adjustments for the data.

% written by: Jonathan Jacobs
%             February 2004  (last mod: 01/25/04)


% we are here after having read in data using:
% rd_ascii, rd_asd, rd_bin, rd_labv, rd_ober2 or rd_rtrv
%
% we DO know:    number of columns for all formats
% we DON'T know: names of data for ascii or rawbin
% we DON'T know: samp_freq of data for asyst, ascii or rawbin


if exist('tempSampFreq','var')
    y_or_n = input( ['Found a sampling frequency of ' num2str(tempSampFreq)...
        'Hz in the header.  Is this right? (y/n) '], 's');
    if( lower(y_or_n) == 'n' )
        tempSampFreq = input('What is the sampling frequency? ');
    end
else
    tempSampFreq = input('What is the sampling frequency? ');
end

rectype = input('Data type: (I)R, (V)ideo-Eyelink, (C)oil, (R)obinson coil ', 's');

if dat_cols == 0   %% rawbin format
    dat_cols = input('How many channels of data are in the file? ');
    chan_count = dat_cols;
end

chName = char(chan_count,2);
z_adj = NaN(chan_count,1); c_scale = NaN(chan_count,1);
max_adj = NaN(10,chan_count); min_adj = NaN(10,chan_count);

for ii = 1:dat_cols
    switch lower(fileformat)
        % formats that have channel name info in header
        case {'asyst','retrieve','labview','ober2'}
            y_or_n = input( ['Assuming channel "' chanName(ii,:) '".  '...
                'Is this the proper channel name? (y/n) '], 's');
            if( lower(y_or_n) == 'n' )
                chName(ii,:) = input('Enter the channel name (eg lh): ', 's');
            else
                chName(ii,:) = chanName(ii,:);
            end
            
            % formats that DON'T
        case {'rawbin','ascii'}
            chName(ii,:) = input('Enter the channel name (eg lh): ', 's');
    end
    
    switch lower(rectype(1))
        case {'c','s'}
            z_adj(ii) = input(' Enter the zero shift: ');
            c_scale(ii) = input('Enter the scale factor: ');
        case {'i'}
            calpairs = input('How many calibration points? ');
            z_adj(ii)    = input(' Enter the zero shift: ');
            for j = 1:calpairs
                max_adj(j,ii)  = input([' Enter max scale value ' num2str(j) ': ']);
                min_adj(j,ii)  = input([' Enter min scale value ' num2str(j) ': ']);
            end
    end
end