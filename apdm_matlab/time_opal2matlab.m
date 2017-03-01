function matlab_time = time_opal2matlab(opal_sync_value)

%opal_time_value = whatever you got from the Opal

opal_time_to_seconds = 1e6;
seconds_per_day = 86400;

matlab_time = ((opal_sync_value/opal_time_to_seconds)/ seconds_per_day) + datenum(1970, 1, 1, 0, 0, 0);