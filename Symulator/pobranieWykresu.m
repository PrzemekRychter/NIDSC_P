% Pobranie n-tych danych z okna xyz.fig i wyświetlenie ich
% w folderze musi się znajdować okno xyz.fig

n = 1;
xy = pobierz(n);
figure();
plot(xy(1,:),xy(2,:));