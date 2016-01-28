function createcsvfromdata2 ( name )
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

for i = 1:slices
    tmpp = zeros(1,51);
    tmpp(1) = resultcell{i,1}(1);
    curfreq = 1;
    for runner = 2:51 % we start at 2 as we do not care about the dc value
        tmparray = [resultcell{i,1}(curfreq+1), resultcell{i,1}(curfreq+2), resultcell{i,1}(curfreq+3), resultcell{i,1}(curfreq+4), resultcell{i,1}(curfreq+5)];
        tmpp(runner) = median(tmparray);
        curfreq = curfreq + 5;
    end
    resultcell{i,1} = tmpp;
end


atributecell = cell(slices,1);

outputcell = cell(slices, 2);

outmat = zeros(slices,51+1);
for i = 1:slices
    tmp = reshape(resultcell{i,1}.',[],1).'; % we have to transpose this twice as we need both reshape and csvwrite to have the right 'look at things
    tmpsize = size(tmp,2);
%    outmat = zeros(slices,tmpsize);
    outmat(i,1:end-1) = tmp; % we do this in order to have a place to store the T attribut
    outmat(i,end) = annotationm(i,2);
    % taken from http://stackoverflow.com/questions/2724020/how-do-you-concatenate-the-rows-of-a-matrix-into-a-vector-in-matlab
    atributecell{i,1} = annotationm(i,2);
    outputcell{i,1} = outmat(i,:);
    % taken from http://stackoverflow.com/questions/2724020/how-do-you-concatenate-the-rows-of-a-matrix-into-a-vector-in-matlab
    outputcell{i,2} = annotationm(i,2);
    
end

cd csv
for i = 1:slices
    csvwrite(strcat(name,'_', num2str(i),'.csv'), outputcell{i,1});
end
cd ..
