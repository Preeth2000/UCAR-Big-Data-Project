%% Script to demonstrate how simple Matlab parallel processing can be!
clear

%% Creat a big array of data
BigData = rand(200,10000); % a 200 x 10k array

%% start a parallel pool
% If you don't explicitly do this, and use a parallel processing command,
% Matlab will pause and create the parallel pool automatically

NumProcessors = 2; % change this to vary the number of processors used
if isempty(gcp('nocreate')) % check if we already have a parallel pool?
    parpool(NumProcessors);
end

%% Sequential processing of simple calculation
% This steps through each location in the BigData array, sums the data in
% the row and saves the value to an array.
AnswerSeq = zeros(size(BigData));
tic
for idx1 = 1: size(BigData,1) % standard for loop
    for idx2 = 1: size(BigData,2) % standard for loop
    AnswerSeq(idx1, idx2) = sum(BigData(idx1,:)); % add the values in the row
    end
end
t2 = toc;
fprintf('Sequential processing time: %.3f\n', t2)

%% parallel processing
% This steps through each array location in a row to carry out the
% calculations. However, the rows are processed in parallel by the 'parfor'
% command.
AnswerPar = zeros(size(BigData));
LoopSize = size(AnswerPar,2);
tic
parfor idx1 = 1: size(BigData,1) % parallel for loop ### note, the only change is the loop command!
    for idx2 = 1: LoopSize % standard for loop
    AnswerPar(idx1, idx2) = sum(BigData(idx1,:)); % Simple calculation add the values in the row
    end
end
t2 = toc;
fprintf('Parallel processing time: %.3f\n', t2)

%% Advanced parallel processing
% This method requires some pre- and post-processing of the data, which
% adds a small overhead. However, every calculation is parallelized, not
% just each row so large files show a further increase in speed.

tic
% Pre-process data array into vector
RowLength = size(BigData,2);
BigData2 = BigData'; % Transpose array
BigData2 = BigData2(:); % transform to vector
parfor idx1 = 1: size(BigData2,1) % parallel for loop ### note, the only change is the loop command!
    StartCalc = (fix((idx1-1)/RowLength) * RowLength)+1;
    AnswerPar2(idx1) = sum(BigData2(StartCalc:StartCalc + RowLength -1  ,:)); % Simple calculation, add the values in the row
    
end

% Post-process results array to original format
AnswerPar2 = reshape(AnswerPar2, flip(size(BigData)))';

t2 = toc;
fprintf('Advanced parallel processing time: %.3f\n', t2)