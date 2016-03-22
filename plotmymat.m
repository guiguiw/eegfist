%will plot the first 16 featurevectors after running createcsvfromdata
figure(1)
for i = 1:16
    subplot(4,4,i);
    plot(mymat(i+16,:));
end
