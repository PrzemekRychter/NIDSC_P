% Pobranie n-tych danych z okno.fig i wyświetlenie ich
% w folderze musi się znajdować okno.fig

n = 2;
[xy,col] = pobierz("okno.fig",n);
figure();
plot(xy(1,:),xy(2,:),'color',col);

