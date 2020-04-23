classdef Symulator < handle
    properties 
        % DANE, PARAMETRY, ZMIENNE POMOCNICZE
        % długość danych, dane wejściowe, zakodowane, po transmisji, odkodowane
        leng; data;   eData;  tData; dData;         
        ber;   % ber - Rzeczywisty BER - widzany przez użytkownika
        typKodowania;   % 0 - kody Hamminga(BCH o t =1) 
                        % 1 - BCH
                        % 2 - repetiton(Hamming (3,1))
        modelKanalu;    % 0 - BSC 
                        % 1 - Gilberta
        % Parametry kodu: n, k, sprawnosc, nadmiarowosc
        n; k; rate; redundancy;       
        % koder i dekoder BCH - tworzone po podaniu danych
        bchEncoder; bchDecoder;        
        % Parametr dla BSC - binary symmetric channel
        probability;    
        % Parametry dla BNC -  burst noise channel - model Gilberta
        abel;        	  % Avarage burst error length - średnia długosc błedu 
        probBurstError;   % Prawdopodobienstwo wystapienia błedu grupowego
        G2B;              % prawdopodobienstwo przejscia ze stanu dobrego do zlego  G2B = probBurstE/((1-probBurstE)*abel)
        B2G;              % prawdopodobieństwo przejścia ze zlego do dobrego        B2G = 1/abel
        lossDensity;      % prawdopodobienstwa przklamania w stanie zlym 
        expectedERcec;    % spodziewany error rate dla BNC (nie uwzglednia kodowań)       
        % zmienne pomocnicze do symulacji
        change;           % interwał z jakim parametr się zmienia
        paramChange;      % parametr zmienny: probability, abel, probBurst, loss,  0,1,2,3
        endValueOfParam;  % wartosc końcowa parametu
        oY;  % tak naprawde oX
        oX;  % oY
    end
 
    methods
        %KONSTRUKTOR
        function obj = Symulator()                   
        end
        % FUNKCJE KANAŁÓW
        % Ustawienie prawdopodobieństwa przekłamania dla BSC - błedy pojedyńcze
        function setParamBSC(obj,probability)        
            obj.probability = probability;
        end
        % Ustawienie parametrow dla BNC - błedy grupowe
        function setParamBNC(obj,a,prob,loss)        
            obj.abel = a;    
            obj.probBurstError = prob; 
            obj.lossDensity = loss;
            obj.B2G = 1/a;
            obj.G2B = prob/((1-prob)*a);
        end
        % Transmisja danych przez kanał BSC
        function bsc(obj)                            
            obj.tData = bsc(obj.eData,obj.probability);
        end
        % Transmisja danych przez kanał BNC
        function bnc(obj)                                   
            obj.tData = bncChannel(obj.eData,obj.lossDensity,obj.G2B,obj.B2G);
        end
        
        %FUNKCJE KODOWANIA I DEKODOWANIA
        % Koduj kodem Hamminga
        function eHam(obj)              
            obj.eData = encode(obj.data,obj.n,obj.k,'hamming/binary');
        end
        % Dekoduj kod Hamminga
        function dHam(obj)              
            obj.dData = decode(obj.tData,obj.n,obj.k,'hamming/binary');
        end
        % Koduj kodem BCH
        function eBch(obj)
            % Wyrównanie danych tak aby były wielokrotnością k
            rem = mod(size(obj.data,1),obj.k);
            for yy = size(obj.data,1) : (obj.k-rem) + size(obj.data,1)
                obj.data(yy,1) = 0;
            end
            %words = size(obj.data,1)/obj.k;
            obj.eData = step(obj.bchEncoder, obj.data);    % Encoder bierze wektor kolumnowy i sam tworzy GF
        end
        % Dekoduj kod BCH
        function dBch(obj) 
            obj.dData = step(obj.bchDecoder,obj.tData);
        end
        
        % FUNCKJE DODATKOWE
        function roznica = popraw(obj)          % Uzupelnienie dlugości wektora danych do wektora zdekodowanego    
            s1 = size(obj.data,1);              % Czasami wiadomosc zdekodowana jest dluzsza np dla ham(15,11) 
            s2 = size(obj.dData,1);             % i dlugosci data 500 000 bitow po zdekodowaniu jest 500 005.
            roznica = 0;                        % Dodatkowe bity traktujemy jako bład, funkcja wyrównuje wektor
            if s2>s1                            % danych do wektora zdekodowanego, aby wyliczyć ilość błedów.
                roznica = s2-s1;                     
                for m = 1 : roznica
                 obj.data(s1+m,1)= 8;
                end
            end
        end
        % Oblicz Bit error ratio
        function calcBER(obj)
            roznica = popraw(obj);
            errors = obj.data~=obj.dData;
            obj.ber = sum(errors,1)/(size(obj.data,1)-roznica);
        end
        % Oblicz spodziewany BER dla BNC (funkcja nie używana)
        function calcERbnc(obj)        
             obj.expectedERcec = (obj.G2B/(obj.B2G + obj.G2B))*obj.lossDensity;
        end
        % Oblicza sprawność oraz nadmiarowość kodu blokowego
        function calcRR(obj)         
             obj.rate = obj.k/obj.n;
            obj.redundancy = 1 - obj.rate;
        end
        % Ustawia n i k
        function setNK(obj,n,k)
            obj.n = n; obj.k = k;
        end
        
        % FUNCKJA SYMULACJI
        function dane = simulate(obj) 
            obj.leng = input("Enter the data length: ");
            obj.data = randi([0 1],obj.leng,1);
            % WYBOR TYPU KODOWANIA
            obj.typKodowania = input("Enter code type: 0 - Hamming code 1 - BCH code. 2 - Repetition code: ");       
            if obj.typKodowania == 0        % 0 - Hamming code
                obj.n = input("Hamming code selected, enter n: ");
                obj.k = input("                       enter k: ");
            end
            if obj.typKodowania == 1         % 1 - BCH code
                obj.n = input("BCH code family selected, enter n: ");
                obj.k = input("                          enter k: ");
                obj.bchEncoder = comm.BCHEncoder(obj.n,obj.k);   % Stworz obiekty kodera i dekodera
                obj.bchDecoder = comm.BCHDecoder(obj.n,obj.k);                
            end
            if obj.typKodowania == 2       % 2 - Repetition code
                disp("Repetition code selected");
                setNK(obj,3,1);
            end
            calcRR(obj);    % Oblicz sprawność i nadmiarowość
            
            % WYBOR KANALU
            obj.modelKanalu = input("Enter channel model. 0 - BSC  1 - BNC: ");  
            if obj.modelKanalu == 0     % BSC
                obj.paramChange = 0;
                obj.setParamBSC(input("Selected channel: BSC. Enter the initial error probability: "));
            else                        %BNC
                abelx = input("Selected channel: BNC. Eneter the initial values ​​for the parameters of the gilbert model.\nABEL - Avarage burst error length: ");  
                probBurstE = input("Probability of burst error: ");
                loss = input("Loss Density: ");
                setParamBNC(obj,abelx,probBurstE,loss);
                obj.paramChange = input("Select a variable parameter. 1 - Avarage burst error length. 2 - Probability of burst error. 3 - Loos density: ");
            end
            obj.change = input("Enter the value used to change parameter with every iteration: ");
            obj.endValueOfParam = input("Enter final value of a variable parameter: ");
            % TWORZENIE OSI X
            switch obj.paramChange                       
                 case 0
                     obj.oX = obj.probability : obj.change : obj.endValueOfParam;
                 case 1
                     obj.oX = obj.abel : obj.change : obj.endValueOfParam;
                 case 2
                     obj.oX = obj.probBurstError : obj.change : obj.endValueOfParam;
                 case 3
                     obj.oX = obj.lossDensity : obj.change : obj.endValueOfParam;       
            end
            ileRazy = (obj.oX(1,length(obj.oX))-obj.oX(1,1))/obj.change;
            j = 0;
            fprintf("-------------------STARTING THE SIMULATION-------------------\n");
            fprintf("\t %d bit data generation -> coding -> transmitting -> decoding -> calculating BER \n",size(obj.data,1));
            fprintf("\t Performing the above steps. %d times\n",ileRazy);
            tic; proc = -1; % zmienna pomocnicza do wyswietlania postępu       
            % GŁOWNA PĘTLA SYMULACJI 
            for index = obj.oX    
                 j = j+1;
                switch obj.paramChange   % zmiana zmiennego parametru dla kolejnej iteracji
                    case 0
                        obj.probability = obj.oX(1,j);
                    case 1
                         obj.abel = obj.oX(1,j);
                    case 2
                         obj.probBurstError = obj.oX(1,j);
                    case 3
                         obj.lossDensity = obj.oX(1,j);      
                end
                if (obj.paramChange == 1 || obj.paramChange == 2 || obj.paramChange == 3 )
                    setParamBNC(obj,obj.abel,obj.probBurstError,obj.lossDensity);     % przeliczenie B2G,G2B oraz loosDensity dla bnc
                    %calcERbnc(obj);
                end
                % KODOWANIE
                switch obj.typKodowania  
                    case 0       % Hamming code
                        eHam(obj);
                    case 1       % BCH
                        eBch(obj);
                    case 2       % Repetition 
                        eHam(obj);
                end
                % TRANSMISJA
                if obj.modelKanalu == 0     
                    bsc(obj);
                else
                    bnc(obj);
                end                             
                % DEKODOWANIE
                switch obj.typKodowania
                    case 0     % Hamming code
                        dHam(obj);
                    case 1      % BCH  
                        dBch(obj);
                    case 2 %    % Repetition
                        dHam(obj);
                end
                % OBLICZENIE BER I INNYCH PARAMETRÓW W ZALEŻNOŚCI OD KODU
                calcBER(obj);
                obj.oY(1,j) = obj.ber;           
                obj.data = 0; obj.eData = 0; obj.tData = 0; obj.dData = 0; obj.ber = 0;   
                obj.data = randi([0 1],obj.leng,1);
                % Wyswietlenie postępu
                proc = viewStage(proc,j,ileRazy);
            end % KONIEC GŁÓWNEJ PĘTLI SYMULACJI
            fprintf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
            fprintf("\t 100%% of simulation completed.\n"); 
            czas = toc;
            fprintf("\t Elapsed time is %.6f seconds.\n",czas);
            fprintf("-------------------SIMULATION COMPLETED---------------------\n");
            figure
            plot(obj.oX,obj.oY);
            ylabel('BER - bit error ratio');
            
            % OPIS WYKRESU
            switch obj.paramChange  
                  case 0
                      xlabel('BSC_p -  crossover probability');
                  case 1
                      xlabel('Avarage burst error length '); 
                  case 2
                      xlabel('Probability of burst error'); 
                  case 3
                       xlabel('Loss density');
            end
            % Notatka jaki kanał -  z lewej u góry
            if obj.modelKanalu == 0
                str = {'Binary symmetric channel'};
                annotation('textbox',[.15 .8 .1 .1],'String',str,'FitBoxToText','on');  
            else
                str = {'Burst-noise channel'};
                annotation('textbox',[.15 .8 .1 .1],'String',str,'FitBoxToText','on'); 
            end  
            % Notatka odnośnie zastosowanego kodu i jego parametrów
            switch obj.typKodowania
                case 0           % Opis dla  hamming code
                    typ = sprintf('Hamming (%d,%d)',obj.n,obj.k);
                    rateS = sprintf('Rate: %.2f', obj.rate);
                    redunS = sprintf('Redundancy: %.2f', obj.redundancy);
                    % ZDOLNOSC KOREKCYJNA DLA KODWO HAMINGA = 1;
                    paramKodu = {'Code parameters','----------------------',typ,rateS,redunS};
                case 1  % Opis dla BCH
                    typ = sprintf('BCH (%d,%d)',obj.n,obj.k);
                    rateS = sprintf('Rate: %.2f', obj.rate);
                    redunS = sprintf('Redundancy: %.2f', obj.redundancy);
                    zdol = sprintf('Error-correction capability: %d', bchnumerr(obj.n,obj.k));
                    paramKodu = {'Code parameters','----------------------',typ,rateS,redunS,zdol}; 
                case 2   % Opis dla  repetition code
                    typ = sprintf('Repetition code - Hamming (%d,%d)',obj.n,obj.k);
                    rateS = sprintf('Rate: %.2f', obj.rate);
                    redunS = sprintf('Redundancy: %.2f', obj.redundancy);
                    paramKodu = {'Code parameters','----------------------',typ,rateS,redunS}; 
            end
            % Opis - parametry stale kanalu
            paramKanalu = 'Channel constant parameters';
            if obj.modelKanalu == 1
                switch obj.paramChange
                    case 1
                        probStr = sprintf('Prob. of burst error: %.2f',obj.probBurstError);
                        lossStr = sprintf('Loss density: %.2f',obj.lossDensity);
                        opis = {paramKanalu,'-----------------------------',probStr,lossStr};
                    case 2
                        abelStr = sprintf('Avarage burst error length: %.2f',obj.abel);
                        lossStr = sprintf('Loss density: %.2f',obj.lossDensity);
                        opis = {paramKanalu,'-------------------------',abelStr,lossStr};
                    case 3
                         probStr = sprintf('Prob. of burst error: %.2f',obj.probBurstError);
                        abelStr = sprintf('Avarage burst error length: %.2f',obj.abel);
                        opis = {paramKanalu,'-------------------------',probStr,abelStr};
                end  
            end
            pos=get(gca,'position');  % retrieve the current values
            pos(3)=0.7*pos(3);        % try reducing width 10%
            set(gca,'position',pos)
            set(gcf, 'Position', [500, 500, 900, 500]);
            annotation('textbox',[.7 .8 .1 .1],'String',paramKodu,'FitBoxToText','on');
            if obj.modelKanalu == 1
                annotation('textbox',[.7 .5 .1 .1],'String',opis,'FitBoxToText','on');
            end
            % ZWRACANIE DANYCH W MACIERZY dane: 1 wiersz to oX 2 to oY
            dane  = zeros(2, length(obj.oY));
            for w =  1 : length(obj.oX)
                dane(1,w) = obj.oX(1,w);
            end
            for m = 1 : length(obj.oY)
                dane(2,m) = obj.oY(1,m);
            end  
        end
end
end
