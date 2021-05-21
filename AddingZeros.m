myDir = uigetdir;                       
myFiles = dir(fullfile(myDir,'*.nc'));  
myFilesCBE = dir(fullfile(myDir,'*.csv'));
modelNc = zeros(700,400,25,7);                
modelCBE = zeros(698,398,25); 

NumProcessors = 2; 
if isempty(gcp('nocreate')) 
    parpool(NumProcessors);
end

for idxFile = 1:length(myFiles)
    baseFileName = myFiles(idxFile).name;
    fullFileName = fullfile(myDir, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    O3 = ncread(fullFileName,'unknown');
    modelNc(:,:,:,idxFile) = O3;
end

for idxHour = 1:length(myFilesCBE)
  baseFileNameCBE = myFilesCBE(idxHour).name;
  fullFileNameCBE = fullfile(myDir, baseFileNameCBE);
  fprintf(1, 'Now reading %s\n', fullFileNameCBE);
  CBEdata=csvread(fullFileNameCBE);
  FormatCBEdata = CBEdata.';
  ScaledCBEdata = FormatCBEdata./(10^6); 
  modelCBE(:,:,idxHour) = ScaledCBEdata;
end

sz = 700*400*25 %Change this so its not numbers but variables of index or whatever
reshapedO3 = reshape(modelNc,[sz,7]);

parfor idxRow = 1:sz
    Ans(idxRow) = mean(reshapedO3(idxRow,:));
end

MeanNc = reshape(Ans,[700,400,25]);

x = MeanNc(:,:,1);
y = MeanNc(:,:,2);
z = MeanNc(:,:,3);
figure; plot3(x,y,z,'.-');
 
x2 = modelCBE(:,:,1);     
y2 = modelCBE(:,:,2);
z2 = modelCBE(:,:,3);
figure; plot3(x2,y2,z2,'.-');
 
compare = mean(MeanNc,3);
compare2 = mean(modelCBE,3);

zc = zeros(size(compare2,1),1);
newmatrix = [compare2, zc, zc];

compare2Formatted = newmatrix.';

zd = zeros(size(compare2Formatted,1),1);
newmatrixt = [compare2Formatted, zd, zd];

compare2Final = newmatrixt.';

finalmatrix = compare - compare2Final;

x3 = finalmatrix(:,1);
y3 = finalmatrix(:,2);
figure; plot(x3,y3,'.-');
