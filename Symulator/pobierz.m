% Funkcja pobiera n-ty wykres z okna xyz.fig
% zapisuje x w 1 wierszu xy, y w 2 wierszu xy

function xy  = pobierz(n)
    open xyz.fig % Otwiera obiekt fig o nazwie okno
    D=get(gca,'Children'); 
    XData=get(D,'XData');       %XData ma komórki typu cell
    YData=get(D,'YData'); 
    rozmiar = size(XData,1);
    xy(1,:) = XData{rozmiar +1 - n};
    xy(2,:) = YData{rozmiar +1 -n};
end

