% Funkcja uzyskująca dane z wykresu
% umiesza kolejne dane w kolejnych wierszach X oraz Y
function [X,Y] = getAllData(nazwa)
    openfig(nazwa);
    D=get(gca,'Children');
    XData=get(D,'XData');       
    YData=get(D,'YData');
    X=[];Y=[];
    for m = 1 : size(XData,1)   
        z = (size(XData,1)+1)-m;
        xsize = size(XData{z},2);
        ysize = size(YData{z},2);
        X= [ X ; zeros(1,xsize) ];
        X(m,:) = XData{z};
        Y = [ Y ; zeros(1,ysize) ];
        Y(m,:) = YData{z};
    end

end

