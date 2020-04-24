% Skrypt demonstrujący użycie symulatora
dataL = 100000;
Hamming = 0;
BSC = 1;
n = 15; k = 11;
BSCp = 0;
BSCpFinal = 0.5;
interval = 0.001;
ABEL = 3;
burstProb = 0.05;
loss = 0.95;
zmiennyParam = 1; % 1-ABEL 2-burstProb 3-loss
interval2 = 0.001;
finalVal = 8;
symulator = Symulator();                                                  % Stworzenie obiektu
% simUSR() pobierane dane od użytkownika
symulacja_1 = symulator.simUSR();                                         % Uruchomienie symulacji
% W tym momencie należy podać niezbędne dane 
symulator.clearData();                                                    % Wyczyszczenie danych
symulacja_2 = symulator.simBSC(dataL,Hamming,n,k,BSCp,interval,BSCpFinal);                  % Uruchomienie symulacji
symulator.clearData();                                                    % Wyczyszczenie danych
symulacja_3 = symulator.simBNC(dataL,BSC,n,k,ABEL,burstProb,loss,zmiennyParam,interval2,finalVal);        % Uruchomienie symulacji

% Wykres będzie "nie odczytywalny" ponieważ BER w 3 symulacji
% jest liczone w funkcji długosci błedu grupowego
% ale jest rysowany prawidłowo
figure(50);
hold on;
plot(symulacja_1(1,:),symulacja_1(2,:));
plot(symulacja_2(1,:),symulacja_2(2,:));
plot(symulacja_3(1,:),symulacja_3(2,:));