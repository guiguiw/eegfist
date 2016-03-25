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

Hd = mylowpassfilt();
lowfilt = filt50hz();

annotationm=load(annotpath);
slices = size(annotationm,1)-1; %we have size-1 here as well just have 29 intervalls by 30 entries ...
datacell = cell(slices,2);
fftcell = cell(slices,2);
for i=1:slices
    curbeginning = annotationm(i,1);
    curend = annotationm(i+1,1);
    tempmat = data(1:64,curbeginning+1:curend);
    %tempmat = filter(Hd,tempmat); % low pass filter cutting off at 70 hz
    %tempmat = filter(lowfilt,tempmat); % filtering 50 hz
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
    fftcell{i,1} = tempmat2;
    fftcell{i,2} = annotationm(i,2);
end;

tempoutcell = cell(slices,3);
for i = 1:slices
    curpos = 1;
    for runner = [9,10,11,12,13]
        tmpmat = zeros(1,25);
        tmpmat(1) = std(datacell{i,1}(runner,:)); % standard derivation
        tmpmat(2) = var(datacell{i,1}(runner,:)); % variance
        [mymin,minpos] = min(datacell{i,1}(runner,:));
        tmpmat(3) = mymin; 
        tmpmat(4) = minpos;
        [mymax,maxpos] = max(datacell{i,1}(runner,:));
        tmpmat(5) = mymax;
        tmpmat(6) = maxpos;
        
        tmpmat(7) = moment(datacell{i,1}(runner,:),2);
        tmpmat(8) = moment(datacell{i,1}(runner,:),3);
        
        %tmpmat(9) = moment(fftcell{i,1}(runner,:),2);
        %tmpmat(10) = moment(fftcell{i,1}(runner,:),3);
        
        %tmpmat(11) = std(fftcell{i,1}(runner,:));
        %tmpmat(12) = var(fftcell{i,1}(runner,:));
        [mymin,minpos] = min(fftcell{i,1}(runner,:));
        tmpmat(9) = mymin; 
        tmpmat(10) = minpos;
        [mymax,maxpos] = max(fftcell{i,1}(runner,:));
        tmpmat(11) = mymax;
        tmpmat(12) = maxpos;
        fiverunner = 1;
        for j = 13:1:25
            tmp = [fftcell{i,1}(runner,fiverunner), fftcell{i,1}(runner,fiverunner+1), fftcell{i,1}(runner,fiverunner+2), fftcell{i,1}(runner,fiverunner+3), fftcell{i,1}(runner,fiverunner+4)];
            tmpmat(j) = median(tmp);
            fiverunner = fiverunner + 10;
        end
        
        
        %moment(x,order)
        
        tempoutcell{i,curpos} = tmpmat;
        curpos = curpos + 1;
    end
end


atributecell = cell(slices,1);

outputcell = cell(slices, 2);

outmat = zeros(slices,5*25+1);
for i = 1:slices
    tmp = zeros(1,25*5);
    for curpos = 1:5
        %size(tempoutcell)
        %size(reshape(tempoutcell{i,curpos}.',[],1).')
        %size(tmp(((curpos-1)*12)+1:(curpos*12)))
        tmp(((curpos-1)*25)+1:(curpos*25)) = reshape(tempoutcell{i,curpos}.',[],1).'; % we have to transpose this twice as we need both reshape and csvwrite to have the right 'look at things
    end
    tmpsize = size(tmp,2);
%    outmat = zeros(slices,tmpsize);
    outmat(i,1:end-1) = tmp; % we do this in order to have a place to store the T attribut
    outmat(i,end) = annotationm(i,2);
    
    switch annotationm(i,2)
       case 1
           outmat(i,end) = 1;
       case 2
           outmat(i,end) = 1;
       otherwise
           outmat(i,end) = 0;
    end
    
    % taken from http://stackoverflow.com/questions/2724020/how-do-you-concatenate-the-rows-of-a-matrix-into-a-vector-in-matlab
    atributecell{i,1} = annotationm(i,2);
    outputcell{i,1} = outmat(i,:);
    % taken from http://stackoverflow.com/questions/2724020/how-do-you-concatenate-the-rows-of-a-matrix-into-a-vector-in-matlab
    
    % IMPORTANT: this would be required for three classes. we now reduce
    % the problem to two classes
    %outputcell{i,2} = annotationm(i,2);
   
        
end

%tends to be usefull: http://linuxconfig.org/how-to-count-number-of-columns-in-csv-file-using-bash-shell
cd csv
for i = 1:slices
    if true % fftcell{i,2} ~= 0
        csvwrite(strcat(name,'_', num2str(i),'.csv'), outputcell{i,1});
    else
       % csvwrite(strcat(name,'_', num2str(i),'.csv'), outputcell{i,1});
    end
end
cd ..
