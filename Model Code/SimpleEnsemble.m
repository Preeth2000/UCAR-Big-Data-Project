myDir = uigetdir;                       %Allows us to choose Directory
myDir2 = uigetdir;                      %Allows us to choose a second directory
myFiles = dir(fullfile(myDir,'*.nc'));  %Gets all files with .nc extensions
myFilesCBE = dir(fullfile(myDir,'*.csv'));  %Gets all files with .csv extensions from first directory
myFilesOrig = dir(fullfile(myDir2,'*.csv')); %Gets all files with .csv extensions from second directory   
modelNc = zeros(700,400,25,7);                %Creates a 4D model of zeros to the specifications given for the O3 data
modelCBE = zeros(698,398,25);                 %Creates a 3d model of zeros to store CBE data
modelOrig = zeros(698,398,25);                %Creates a 3d model of zeros to store original data 

NumProcessors = 2; % change this to vary the number of processors used
if isempty(gcp('nocreate')) % checks if there is already a parallel pool
    parpool(NumProcessors);
end

for idxFile = 1:length(myFiles)             %For loop to iterate through each .nc file 
    baseFileName = myFiles(idxFile).name;
    fullFileName = fullfile(myDir, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName); %Prints out filename currently being read
    O3 = ncread(fullFileName,'unknown');    %Finds the data for O3 in .nc file and stores in O3
    modelNc(:,:,:,idxFile) = O3;            %Stores the O3 value at every point corresponding to the point in m and stores in m
end

for idxHour = 1:length(myFilesCBE)         %For loop to iterate through all CBE files 
  baseFileNameCBE = myFilesCBE(idxHour).name;
  fullFileNameCBE = fullfile(myDir, baseFileNameCBE);
  fprintf(1, 'Now reading %s\n', fullFileNameCBE);
  CBEdata=csvread(fullFileNameCBE);        %Data from CBE read into CBEdata
  FormatCBEdata = CBEdata.';               %Transposed to switch x and y values to fit 698x398 opposed to the 398x698 data is saved in
  ScaledCBEdata = FormatCBEdata./(10^6);   %Scale data down to original values
  modelCBE(:,:,idxHour) = ScaledCBEdata;   %Stores CBE data at each point into each point of modelCBE
end

for idxHour2 = 1:length(myFilesOrig)         %For loop to iterate through all original files 
  baseFileNameOrig = myFilesOrig(idxHour2).name;
  fullFileNameOrig = fullfile(myDir2, baseFileNameOrig);
  fprintf(1, 'Now reading %s\n', fullFileNameOrig);
  Origdata=csvread(fullFileNameOrig);        %Data from Original files read into Origdata
  FormatOrigdata = Origdata.';               %Transposed to switch x and y values to fit 698x398 opposed to the 398x698 data is saved in
  modelOrig(:,:,idxHour2) = FormatOrigdata;   %Stores Original data at each point into each point of modelOrig
end

sz = 700*400*25 %Size of model with O3 values from each .nc files stored in
reshapedO3 = reshape(modelNc,[sz,7]);   %Reshapes model to have 7 rows, each being the data from each individual .nc file

parfor idxRow = 1:sz                %Parallel processing iterating through every column
    Ans(idxRow) = mean(reshapedO3(idxRow,:));   %Stores mean of every column in Ans
end

MeanNc3D = reshape(Ans,[700,400,25]);    %Reshapes model to the same format as .nc file (Only 1 as it is a mean of all 7)

x = MeanNc3D(:,:,1);  %Gets x value from MeanNc model
y = MeanNc3D(:,:,2);  %Gets y value from MeanNc model
z = MeanNc3D(:,:,3);  %Gets z value from MeanNc model
figure('Name','3D Plot of Simple Ensemble'); plot3(x,y,z,'.-'); %Plots the data in MeanNc model
 
x2 = modelCBE(:,:,1);   %Gets x value from modelCBE model
y2 = modelCBE(:,:,2);   %Gets y value from modelCBE model
z2 = modelCBE(:,:,3);   %Gets z value from modelCBE model
figure('Name','3D Plot of Cluster-Based Ensemble'); plot3(x2,y2,z2,'.-');   %Plots the data in modelCBE model

x3 = modelOrig(:,:,1);   %Gets x value from modelOrig model
y3 = modelOrig(:,:,2);   %Gets y value from modelOrig model
z3 = modelOrig(:,:,3);   %Gets z value from modelOrig model
figure('Name','3D Plot of Original Data'); plot3(x3,y3,z3,'.-');   %Plots the data in modelOrig model

sz2 = 700*400
sz3 = 698*398

reshapedSimple = reshape(MeanNc3D,[sz2,25]);            %Reshapes 3d matrix of simple ensemble data to have 25 rows
parfor idxRow2 = 1:sz2                                  %Parallel processing iterating through every column
    Ans2(idxRow2) = mean(reshapedSimple(idxRow2,:));    %Gets mean of columns
end
MeanNc2D = reshape(Ans2,[700,400]);                     %Reshapes file into 2D matrix from 3D
    
reshapedCBE = reshape(modelCBE,[sz3,25]);               %Reshapes 3d matrix of CBE data to have 25 rows
parfor idxRow3 = 1:sz3                                  %Parallel processing iterating through every column
    Ans3(idxRow3) = mean(reshapedCBE(idxRow3,:));       %Gets mean of columns
end
MeanCBE2D = reshape(Ans3,[698,398]);                    %Reshapes file into 2D matrix from 3D

reshapedOrig = reshape(modelOrig,[sz3,25]);             %Reshapes 3d matrix of original data to have 25 rows 
parfor idxRow4 = 1:sz3                                  %Parallel processing iterating through every column
    Ans4(idxRow4) = mean(reshapedOrig(idxRow4,:));      %Gets mean of columns
end
MeanOrig2D = reshape(Ans4,[698,398]);                   %Reshapes file into 2D matrix from 3D


MeanNc2D(1,:) = [];  %Removes the first 2 columns and rows from modelCBE so both models are 698x398
MeanNc2D(1,:) = [];
MeanNc2D(:,1) = [];
MeanNc2D(:,1) = [];

finalmatrix = MeanNc2D - MeanCBE2D;   %Takes 2d model of modelCBE from 2d model of MeanNc
finalmatrix2 = MeanOrig2D - MeanNc2D; %Takes 2d model of modelOrig from 2d model of MeanNc
finalmatrix3 = MeanOrig2D - MeanCBE2D;%Takes 2d model of modelOrig from 2d model of MeanCBE

x4 = finalmatrix(:,1);  %Gets x value of finalMatrix
y4 = finalmatrix(:,2);  %Gets y value of finalMatrix
figure('Name','2D plot Comparison between Simple Ensemble and CBE'); plot(x4,y4,'.-');   %Plots finalMatrix showing a comparison of data from Simple ensemble and CBE

x5 = finalmatrix2(:,1);  %Gets x value of finalMatrix2
y5 = finalmatrix2(:,2);  %Gets y value of finalMatrix2
figure('Name','2D plot Comparison between Original data and Simple Ensemble'); plot(x5,y5,'.-');%Plots finalMatrix showing comparison of data from original data and simple ensemble

x6 = finalmatrix3(:,1);  %Gets x value of finalMatrix3
y6 = finalmatrix3(:,2);  %Gets y value of finalMatrix3
figure('Name','2D plot Comparison between Original data and CBE'); plot(x6,y6,'.-');   %Plots finalMatrix showing a comparison of data from original data and CBE
