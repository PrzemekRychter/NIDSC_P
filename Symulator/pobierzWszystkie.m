% Skrypt uzyskujący dane z wykresu
% umiesza kolejne dane w koljny wierszach X oraz Y
% druga pętla wyswietla dane w nowym oknie
% w folderze musi się znajdowac okno.fig

open okno.fig % Otwiera obiekt fig o nazwie okno
D=get(gca,'Children'); 
XData=get(D,'XData');       %XData ma komórki typu cell
YData=get(D,'YData'); 
X=[];Y=[];
for m = 1 : size(XData,1)   % Wyłuskanie z XData danych wykresów
    z = (size(XData,1)+1)-m;
    xsize = size(XData{z},2);
    ysize = size(YData{z},2);
    X= [ X ; zeros(1,xsize) ];
    X(m,:) = XData{z};
    Y = [ Y ; zeros(1,ysize) ];
    Y(m,:) = YData{z};
end

figure(120)
hold on                   % Wyprowadzenie wykresów na nowe okno
for m = 1 : size(XData,1)
    plot(X(m,:),Y(m,:));
end
