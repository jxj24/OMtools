% nafxfig.m:  take output of NAFX 'show' function (as used with NAFXprep)% and tart it up for savingtemp = findHotW;if temp>0   figure(temp) else   disp('No open Figure.')   returnendnafxFig = findme('NAFXwindow');if nafxFig>=1   global numFovNAFXH   nafx_numfov = get(numFovNAFXH, 'string'); else   disp('You need to be running the NAFX GUI to use "nafxfig."')   returnendage_range_str={'under 6 years old'; '6 to 12 years old'; '12+ to 40 years old'; ...               '40+ to 60 years old'; '60+ years old'; 'canine (any age)'};ageStr = age_range_str{age_range-1};              snel = va2nafx(2,NAFXval,age_range-1,1);xaxshift(nafx_start)gtext(['NAFX = ' num2str(NAFXval,3) '    (' snel ' -- ' ageStr ')' ])gtext(['cycles by manual count: ' num2str(nafx_numfov)])gtext(['y=0 was originally ' num2str(nafx_shift)])clear temp nafxFig