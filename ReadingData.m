NcModel1='W_fr-meteofrance,MODEL,CHIMERE+FORECAST+SURFACE+O3+0H24H_C_LFPW_20180701000000.nc';
longitude = ncread(NcModel1,'longitude');
latitude = ncread(NcModel1,'latitude');
time = ncread(NcModel1,'time');

first = csvread('24HR_Orig_25.csv');
first(1,1)

myDir = uigetdir; %gets directory
myFiles = dir(fullfile(myDir,'*.csv')); %gets all csv files in struct

for idxHour = 1:length(myFiles)
  baseFileName = myFiles(idxHour).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  test=csvread(fullFileName);
  test(2,3)
  for idxLon = 1:398
      for idxLat = 1:698
          test(idxLon,idxLat)
      end
  end
end
