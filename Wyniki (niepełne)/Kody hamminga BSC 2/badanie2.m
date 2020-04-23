% Skrypt został uzyty do wyciecia z wykresu odcinka o BSC np 0-5%
% a nastepnie stworzenie wykresu zaleznosci BER od nadmiarowosci

open hamming_bsc.fig %open your fig file, data is the name I gave to my file
D=get(gca,'Children'); %get the handle of the line object
XData=get(D,'XData'); %get the x data
YData=get(D,'YData'); %get the y data
Data=[XData' YData']; %join the 
red = [ 0.67 0.43 0.27 0.16 0.1 0.06 0.03 ];
odkad = 41;  % prcent
dokad = 81;  % 2 procent 

for m = 1: 7
k= 8-m;
x = XData{k};

y = YData{k};  
mean(y(odkad:dokad)); %  Średni Ber dla danego kodu dla kanału z pp od 0 do "dokad"
figure(10)
hold on
plot(red(1,m),mean(y(odkad:dokad)),'d');
figure(20);
hold on
plot(x(odkad:dokad),y(odkad:dokad));
end
xlabel('BSC_p - crossover probability');
ylabel('BER - bit error ratio');
legend('(3,1)','(7,4)','(15,11)','(31,26)','(63,57)','(127,120)','(255,247)','Location','northwest');
title('Hamming codes with BSC');
pos=get(gca,'position');  % retrieve the current values
        pos(3)=0.7*pos(3);        % try reducing width 10%
        set(gca,'position',pos)
        set(gcf, 'Position', [500, 500, 900, 500]);
        str = {'   Code           |  Redundancy','--------------------------------------','   (3,1)            |   0.67','   (7,4)            |   0.43','   (15,11)        |   0.27','   (31,26)        |   0.16','   (63,57)        |   0.10','   (127,120)    |   0.06','   (255,247)    |   0.03'};
       annotation('textbox',[.7 .8 .1 .1],'String',str,'FitBoxToText','on'); 
figure(10)
xlabel('Redundancy');
ylabel('Avarage BER for BSC with BSC_p from 2 to 4%');
title('Humming - redundancy and avarage BER')
legend('(3,1)','(7,4)','(15,11)','(31,26)','(63,57)','(127,120)','(255,247)','Location','northeast');

