function createcsvfromdata ( name )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%http://www.cs.ccsu.edu/~markov/weka-tutorial.pdf

cd ~/datafiles
matpath = strcat(name,'_edfm.mat');
load(matpath);
data = val;
cd annot
annotpath = strcat(name, '.edf.annot');

annotationm=load(annotpath);
slices = size(annotationm,1)-1; %we have size-1 here as well just have 29 intervalls by 30 entries ...
datacell = cell(slices,2);
resultcell = cell(slices,2);
for i=1:slices
    curbeginning = annotationm(i,1);
    curend = annotationm(i+1,1);
    tempmat = data(1:64,curbeginning+1:curend);
    datacell{i,1} = tempmat;
    datacell{i,2} = annotationm(i,2);
end

Fs = 160;
L = length(datacell{i,1});
n = 2^nextpow2(L);
%tmp = [1:513]; !!
for i = 1:slices
    tempmat2 = zeros(64,n/2+1); 
    % we have to add an additional line at the top of our resultmatrix, containing the
    % headlines; otherwise weka would have some trouble importing our csvs.
    %tempmat2(1,:) = tmp; !!
    for runner = 1:64
        %runner = runner+16;
        mydata = datacell{i,1}(runner,:);
        fftval = fft(mydata,n);
        f = Fs*(0:(n/2))/n;
        P1 = abs(fftval/n);
        %size(P1(1:n/2+1))
        %size(tempmat(i,:))
        % we do the indexshifting here as the code is more readable this
        % way
        tempmat2(runner,:) = P1(1:n/2+1);
        %figure(1);
        %subplot(8,8,runner);
        %plot(f,P1(1:n/2+1));
    end;
    resultcell{i,1} = tempmat2;
    resultcell{i,2} = annotationm(i,2);
end;

outputcell = cell(slices, 2);

for i = 1:slices
    tmp = reshape(resultcell{i,1}.',[],1).'; % we have to transpose this twice as we need both reshape and csvwrite to have the right 'look at things
    tmpsize = size(tmp,2);
    outmat = zeros(2,tmpsize+1);
    outmat(1,:) = [1:tmpsize+1];
    outmat(2,1:tmpsize) = tmp; % we do this in order to have a place to store the T attribute
    outmat(2,tmpsize+1) = resultcell{i,2};
    
    outputcell{i,1} = outmat;
    % taken from http://stackoverflow.com/questions/2724020/how-do-you-concatenate-the-rows-of-a-matrix-into-a-vector-in-matlab
    outputcell{i,2} = annotationm(i,2);
end

cd csv
for i = 1:2
    csvwrite(strcat(name,'.csv'), outputcell{i,1});
end
cd ..

end

