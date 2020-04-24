% Pobranie n-tych danych z okno.fig i wyświetlenie ich
% w oknie 10, w folderze musi się znajdować okno.fig
n = 2;
[xy,col] = getData("okno.fig",n);
figure(10);
plot(xy(1,:),xy(2,:),'color',col);

% pobranie wszystkich danych z okno.fig
% wyswielenie ich w oknie 20

[X,Y] = getAllData("okno.fig");
for n = 1 : size(X,1)
    figure(20)
    hold on
    plot(X(n,:),Y(n,:));
end
