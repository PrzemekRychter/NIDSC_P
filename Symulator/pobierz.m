% Funkcja pobiera n-ty wykres z okna nazwaFig ('nazwa.fig')
% zapisuje x w 1 wierszu xy, y w 2 wierszu xy. 
% w wektorze col jest zapisany kolor RGB
%

function [xy,col]  = pobierz(nazwaFig,n)
    openfig(nazwaFig) % Otwiera obiekt fig o nazwie okno
    D=get(gca,'Children'); 
    XData=get(D,'XData');       %XData ma komórki typu cell
    YData=get(D,'YData'); 
    rozmiar = size(XData,1);
    ax =gca;
    colors = ax.ColorOrder ;
    
    for index  = ax.ColorOrderIndex : n     
        n_colors = size(colors,1);
        if index > n_colors
            n = 1;
        end
        nextC = colors(index,:);
    end
    xy(1,:) = XData{rozmiar +1 - n};
    xy(2,:) = YData{rozmiar +1 -n};
    col = nextC;
end

