% Skrypt uzyskujący dane z wykresu

open okno.fig % Otwiera obiekt fig o nazwie okno
D=get(gca,'Children'); 
XData=get(D,'XData');       %XData ma komórki typu cell
YData=get(D,'YData'); 
%e = size(XData{1},2);
%t = size(size(XData,1));
%x = zeros(2,t);
%y = zeros(2,t);
x=[];y=[];
for m = 1 : size(XData,1)   % Wyłuskanie z XData danych wykresów
    z = (size(XData,1)+1)-m;
    xsize = size(XData{z},2);
    ysize = size(YData{z},2);
    x= [ x ; zeros(1,xsize) ];
    x(m,:) = XData{z};
    y = [ y ; zeros(1,ysize) ];
    y(m,:) = YData{z};
end

figure(120)
hold on                   % Wyprowadzenie wykresów na nowe okno
for m = 1 : size(XData,1)
    plot(x(m,:),y(m,:));
end
