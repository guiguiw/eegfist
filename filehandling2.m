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
    resultcell{i,1} = tempmat2;
    resultcell{i,2} = annotationm(i,2);
end;


atributecell = cell(slices,1);

outputcell = cell(slices, 2);

outmat = zeros(slices,32832);
for i = 1:slices

    tmp = reshape(resultcell{i,1}.',[],1).'; % we have to transpose this twice as we need both reshape and csvwrite to have the right 'look at things
    tmpsize = size(tmp,2);
%    outmat = zeros(slices,tmpsize);
    outmat(i,:) = tmp; % we do this in order to have a place to store the T attribut
    % taken from http://stackoverflow.com/questions/2724020/how-do-you-concatenate-the-rows-of-a-matrix-into-a-vector-in-matlab
    atributecell{i,1} = annotationm(i,2);
    
    outputcell{i,1} = outmat(i,:);
    % taken from http://stackoverflow.com/questions/2724020/how-do-you-concatenate-the-rows-of-a-matrix-into-a-vector-in-matlab
    outputcell{i,2} = annotationm(i,2);
    
end


write = true;

if write
    for i = 1:slices
        if resultcell{i,2} == 0
            cd 0
            %export(outputcell{i,1},'file',strcat(num2str(i),'.csv'),'Delimiter',',');
            %dlmwrite(strcat(num2str(i),'.csv'), outputcell{i,1}, 'delimiter', ',');
            csvwrite(strcat(num2str(i),'.csv'), outputcell{i,1});
            cd ..
        end
        if resultcell{i,2} == 1
            cd 1
            csvwrite(strcat(num2str(i),'.csv'), outputcell{i,1});
            cd ..
        end
        if resultcell{i,2} == 2
            cd 2
            csvwrite(strcat(num2str(i),'.csv'), outputcell{i,1});
            cd ..
        end
    end
end

