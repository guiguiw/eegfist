%http://www.cs.ccsu.edu/~markov/weka-tutorial.pdf

cd ~/datafiles
load('S108R03_edfm.mat');
data = val;
cd annot
load('S108R03.edf.annot');
annotationm=S108R03_edf;
slices = size(S108R03_edf,1)-1; %we have size-1 here as well just have 29 intervalls by 30 entries ...
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
    fftcell{i,1} = tempmat2;
    fftcell{i,2} = annotationm(i,2);
end;

tempoutcell = cell(slices,64);
for i = 1:slices
    for runner = 1:64
        tmpmat = zeros(1,12);
        tmpmat(1) = std(datacell{i,1}(runner,:)); % standard derivation
        tmpmat(2) = var(datacell{i,1}(runner,:)); % variance
        [mymin,minpos] = min(datacell{i,1}(runner,:));
        tmpmat(3) = mymin; 
        tmpmat(4) = minpos;
        [mymax,maxpos] = max(datacell{i,1}(runner,:));
        tmpmat(5) = mymax;
        tmpmat(6) = maxpos;
        
        tmpmat(7) = std(fftcell{i,1}(runner,:));
        tmpmat(8) = var(fftcell{i,1}(runner,:));
        [mymin,minpos] = min(fftcell{i,1}(runner,:));
        tmpmat(9) = mymin; 
        tmpmat(10) = minpos;
        [mymax,maxpos] = max(fftcell{i,1}(runner,:));
        tmpmat(11) = mymax;
        tmpmat(12) = maxpos;
        tempoutcell{i,runner} = tmpmat;
    end
end


atributecell = cell(slices,1);

outputcell = cell(slices, 2);

outmat = zeros(slices,64*12+1);
for i = 1:slices
    tmp = zeros(1,12*64);
    for curpos = 1:64
        %size(reshape(tempoutcell{i,curpos}.',[],1).')
        %size(tmp(((curpos-1)*12)+1:(curpos*12)))
        tmp(((curpos-1)*12)+1:(curpos*12)) = reshape(tempoutcell{i,curpos}.',[],1).'; % we have to transpose this twice as we need both reshape and csvwrite to have the right 'look at things
    end
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

%tends to be usefull: http://linuxconfig.org/how-to-count-number-of-columns-in-csv-file-using-bash-shell

write = false;
cd csv
for i = 1:slices
    if fftcell{i,2} == 0
        if write == true
            csvwrite(strcat(num2str(i),'.csv'), outputcell{i,1});
            write = false;
        else 
            write = true;
        end
    else
        csvwrite(strcat(num2str(i),'.csv'), outputcell{i,1});
    end
end
cd ..