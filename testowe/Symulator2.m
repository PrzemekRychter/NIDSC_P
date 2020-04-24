classdef Symulator < handle
    properties
        %TEST 
        ileb; oY2;
        %TEST
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
        G2B;              % prawdopodobienstwo przejscia ze stanu dobrego do zlego  probBurstError = G2B
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

    methods ( Access = public ) 
        function obj = Symulator()  % Konstruktor
        end

        % Funkcja przeprowadzająca symulacje
        % w oparciu o dane pobrane od użytkownika
        function dane = simUSR(obj)
            enterUserData(obj);
            performSimulation(obj);
            describeFigure(obj);
            dane = returnData(obj);
        end
        
        % Funkcja przeprowadzająca symulacje - BSC
        function dane = simBSC(obj,dataLength,codeType,n,k,BSCp,interval,finalBSCp)
            obj.leng = dataLength; obj.typKodowania = codeType; obj.n = n; obj.k = k;
            obj.probability = BSCp; obj.paramChange = 0; obj.change = interval; obj.endValueOfParam = finalBSCp;
            obj.modelKanalu = 0;
            if obj.typKodowania == 1         % 1 - BCH code
                obj.bchEncoder = comm.BCHEncoder(obj.n,obj.k);
                obj.bchDecoder = comm.BCHDecoder(obj.n,obj.k);
            end
            calcRR(obj);
            performSimulation(obj);
            describeFigure(obj);
            dane = returnData(obj);
            
        end
        
        % Funkcja przeprowadzająca symulacje  - BNC
        function dane = simBNC(obj,dataLength,codeType,n,k,ABEL,burstProb,loss,zmiennyParametr,interval,finalVal)
            obj.leng = dataLength; obj.typKodowania = codeType; obj.n = n; obj.k = k;
            obj.abel = ABEL; obj.probBurstError = burstProb; obj.lossDensity = loss;
            obj.paramChange = zmiennyParametr; % 1,2 lub 3 - ABEL, burstProb, loss
            obj.change = interval; obj.endValueOfParam = finalVal;
            obj.modelKanalu = 1;
            if obj.typKodowania == 1         % 1 - BCH code
                obj.bchEncoder = comm.BCHEncoder(obj.n,obj.k);
                obj.bchDecoder = comm.BCHDecoder(obj.n,obj.k);
            end
            calcRR(obj);
            performSimulation(obj);      
            describeFigure(obj);
            dane = returnData(obj);
        end
        
        % Funkcja zerująca wszystkie atrybuty symulacji
        function clearData(obj)
            obj.leng=0; obj.data=0;   obj.eData=0;  obj.tData=0; obj.dData=0;
            obj.ber=0;    obj.typKodowania=0; obj.modelKanalu =0;
            obj.n = 0; obj.k = 0; obj.rate = 0; obj.redundancy=0;
            obj.bchEncoder = 0; obj.bchDecoder = 0;
            obj.probability = 0; obj.abel =0; obj.probBurstError = 0;
            obj.G2B = 0; obj.B2G = 0; obj.lossDensity =0; obj.expectedERcec =0;
            obj.change = 0; obj.paramChange = 0; obj.endValueOfParam =0;
            obj.oY =0; obj.oX = 0;
        end
    end
    
    methods ( Access = private )
        % FUNKCJE KANAŁÓW
        % Ustawienie parametrow dla BNC - błedy grupowe
        function setParamBNC(obj,a,prob,loss)
            obj.abel = a;
            obj.probBurstError = prob;
            obj.lossDensity = loss;
            obj.B2G = 1/a;
            obj.G2B = obj.probBurstError;
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
            % m = 0;
            % macierz = zeros(words,obj.k);
            % for x = 1:words
            %     for ii = 1: obj.k
            %         m = m + 1;
            %          macierz(x,ii) = obj.data(m,1);
            %     end
            % end
            % msg = gf(macierz);
            % obj.eData = bchenc(msg,obj.n,obj.k);
        end
        % Dekoduj kod BCH
        function dBch(obj)
            obj.dData = step(obj.bchDecoder,obj.tData);
            % words = size(obj.data,1)/obj.k;
            % decoded = bchdec(obj.tData,obj.n,obj.k);
            % gg = 0;
            % for x = 1:words
            %    for ii = 1: obj.k
            %        gg = gg + 1;
            %
            %        %obj.dData(gg,1) = decoded.x(x,ii);   % Ta linia długo zajmuje tak z 30 sekuund (ustawilem brake pointy)
            %    end
            %end
        end
        
        % FUNCKJE DODATKOWE
        % Opis w środku funkcji
        function roznica = popraw(obj)
            % Uzupelnienie dlugości wektora danych do wektora zdekodowanego
            % Czasami wiadomosc zdekodowana jest dluzsza np dla ham(15,11)
            % i dlugosci data 500 000 bitow po zdekodowaniu jest 500 005.
            % Dodatkowe bity traktujemy jako bład, funkcja wyrównuje wektor
            % danych do wektora zdekodowanego, aby wyliczyć ilość błedów.
            s1 = size(obj.data,1);
            s2 = size(obj.dData,1);
            roznica = 0;
            if s2>s1
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
        
        % Funkcja przeprowadzająca symulacje
        function performSimulation(obj)
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
            fprintf("\t %d bit data generation -> coding -> transmitting -> decoding -> calculating BER \n",obj.leng);
            fprintf("\t Performing the above steps. %d times\n",ileRazy);
            tic; proc = -1; % zmienna pomocnicza do wyswietlania postępu
            % GŁOWNA PĘTLA SYMULACJI
            for index = obj.oX
                j = j+1;
                obj.data = randi([0 1],obj.leng,1);
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
                %TEST
                er = obj.eData ~= obj.tData;
                obj.ileb = sum(er,'all')/(numel(obj.eData));
                obj.oY2(1,j) = obj.ileb;
                %TEST
                calcBER(obj);
                obj.oY(1,j) = obj.ber;
                obj.data = 0; obj.eData = 0; obj.tData = 0; obj.dData = 0; obj.ber = 0;

                % Wyswietlenie postępu
                proc = viewStage(proc,j,ileRazy);
            end
            fprintf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
            fprintf("\t 100%% of simulation completed.\n");
            czas = toc;
            fprintf("\t Elapsed time is %.6f seconds.\n",czas);
            fprintf("-------------------SIMULATION COMPLETED---------------------\n");
            figure
            plot(obj.oX,obj.oY);
            %TEST
            hold on
            plot(obj.oX,obj.oY2);
            %TEST
            ylabel('BER - bit error ratio');
        end
        
        % Funkcja pobierająca dane od użytkownika
        function enterUserData(obj)
            obj.leng = input("Enter the data length: ");
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
                obj.n = 3; obj.k = 1;
            end
            calcRR(obj);    % Oblicz sprawność i nadmiarowość
            % WYBOR KANALU
            obj.modelKanalu = input("Enter channel model. 0 - BSC  1 - BNC: ");
            if obj.modelKanalu == 0     % BSC
                obj.paramChange = 0;
                obj.probability = input("Selected channel: BSC. Enter the initial error probability: ");
            else                        %BNC
                abelx = input("Selected channel: BNC. Eneter the initial values ​​for the parameters of the gilbert model.\nABEL - Avarage burst error length: ");
                probBurstE = input("Probability of burst error: ");
                loss = input("Loss Density: ");
                setParamBNC(obj,abelx,probBurstE,loss);
                obj.paramChange = input("Select a variable parameter. 1 - Avarage burst error length. 2 - Probability of burst error. 3 - Loos density: ");
            end
            obj.change = input("Enter the value used to change parameter with every iteration: ");
            obj.endValueOfParam = input("Enter final value of a variable parameter: ");
        end
        
        % Funkcja opisująca wykres
        function describeFigure(obj)
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
        end
        
        % Funkcja zwracająca dane w 2 wierszowej macierzy
        % 1 wiersz - oX 2 wiersz - oY
        function dane = returnData(obj)
            dane  = zeros(2, length(obj.oX));
            for m = 1 : length(obj.oX)
                dane(1,m) = obj.oX(1,m);
            end
            for w =  1 : length(obj.oY)
                dane(2,w) = obj.oY(1,w);
            end
        end
    end
end


