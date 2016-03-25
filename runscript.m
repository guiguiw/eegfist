pwd
parfor i = 1:109
   for j = [3,4,7,8,11,12]
        filename = 'S';
        if i < 10
            filename = strcat(filename, '00');
        else i < 100
            filename = strcat(filename, '0');
        end
        filename = strcat(filename,num2str(i),'R');
        if j < 10
            filename = strcat(filename, '0');
        end
        filename = strcat(filename, num2str(j));
        createcsvfromdata2(filename);
    end
end