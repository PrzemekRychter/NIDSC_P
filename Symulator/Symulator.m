classdef Symulator < handle
    properties 
        % Dane
        data;           % dane wejściowe
        eData;          % zakodowane dane
        tData;          % dane po transmisji
        dData;          % odkodowane dane
        ber;            % Rzeczywisty BER - widzany przez uzytownika
        typKodowania    % 0 - kody Haminga
        modelKanalu     % 0 - bsc  1 - gilberta
        % Parametry kodu
        n; k; rate; redundancy;         % n, k, sprawnosc, nadmiarowosc
        % Paramter dla BSC
        probability;
        % Parametry dla BNC burst noise channel - model gilberta
        abel;        	  % Avarage burst error length - średnia długosc błedu 
        probBurstError;   % Prawdopodobienstwo wystapienia błedu grupowego
        G2B;              % prawdopodobienstwo przejscia z ze stanu dobrego do zlego  G2B = probBurstE/((1-probBurstE)*abel)
        B2G;              % ze zlego do dobrego                                       B2G = 1/abel
        lossDensity;      % prawdopodobienstwa przklamania w stanie zlym 
        expectedERcec;    % spodziewany errorRate dla bnc (nie uwzglednia kodowan)
        % zmienne pomocnicze do symulacji
        change;           % interwał z jakim parametr się zmienia
        paramChange;      % parametr zmienny: probability, abel, probBurst, loss,  0,1,2,3
        endValueOfParam;  % wartosc końcowa parametu
        oY;
        oX;      
    end
    
    methods
        % KONSTRUKTOR
        function obj = Symulator()
        end
        % FUNKCJE KANAŁÓW
        function setParameterForBsc(obj,probability)        % Ustawienie prawdopodobiestwa
        obj.probability = probability;
        end
        function bsc(obj)                                   % Przejscie danych przez kanał BSC
            obj.tData = bscChannel(obj.eData,obj.probability);
        end
        function setParametersForBnc(obj,abel,probBurstE,lossDensity)      % Ustawienie parametrow dla Bnc - model gilberta
            obj.abel = abel;    obj.probBurstError = probBurstE;   obj.lossDensity = lossDensity;
            obj.B2G = 1/abel;
            obj.G2B = probBurstE/((1-probBurstE)*abel);
        end
        function bnc(obj)                                   % Przejscie danyc przez kanał Bnc
            obj.tData = bncChannel(obj.eData,obj.lossDensity,obj.G2B,obj.B2G);
        end
        %FUNKCJE KODOWANIA I ODKODOWYWANIA
        function setHamNK(obj,n,k)                          % Ustawienie parametrow n,k
        obj.n = n; obj.k = k;
        end
        function eHam(obj)              % kod hamminga typ - 0
            obj.eData = encodeHamming(obj.data,obj.n,obj.k);
        end
        function dHam(obj)              
            obj.dData = decodeHamming(obj.tData,obj.n,obj.k);
        end
        function eBch(obj)
            
            rem = mod(size(obj.data,1),obj.k);
            for yy = size(obj.data,1) : (obj.k-rem) + size(obj.data,1)
                obj.data(yy,1) = 0;
            end
            words = size(obj.data,1)/obj.k;
            m = 0;
            macierz = zeros(words,obj.k);
            for x = 1:words
                for ii = 1: obj.k
                    m = m + 1;
                     macierz(x,ii) = obj.data(m,1);
                end
            end
            msg = gf(macierz);
            
            obj.eData = bchenc(msg,obj.n,obj.k);
        end
        function dBch(obj)
            words = size(obj.data,1)/obj.k;
            decoded = bchdec(obj.tData,obj.n,obj.k);
            %decodedDouble = gf2dec(decoded,words,obj.k);
            gg = 0;
            for x = 1:words
                for ii = 1: obj.k
                    gg = gg + 1;
                    
                    obj.dData(gg,1) = decoded.x(x,ii); 
                end
            end
        end
        
        
        % FUNCKJE DODATKOWE
        function calculateBer(obj)
           % Uzupelnienie wdlugosci wektora danych do wektora zdekodowanego
           % Czasami wiadomosc zdekodowana jest dluzsza np dla 15,11 i
           % dlugosci 500000
            s1 = size(obj.data,1);
            sx = size(obj.dData,1);
            s3 = 0;
            if sx>s1
                s3 = sx-s1;
                for m = 1 : s3
                 obj.data(s1+m,1)= 8;
                end
            end
            % dodatkow bity uzupelnione ósemkami czyli zostana zaliczone
            % jako blad
            errors = obj.data~=obj.dData;
            
            obj.ber = sum(errors,1)/(size(obj.data,1)-s3);
        end
        function calculateERbnc(obj)        % liczy spodziewany ER dla bnc
        obj.expectedERcec = (obj.G2B/(obj.B2G + obj.G2B))*obj.lossDensity;
        end
        function calculateHam(obj)         % Cechy kodu hamminga
        obj.rate = obj.k/obj.n;
        obj.redundancy = 1 - obj.rate;
        end
        
        % FUNCKJA SYMULACJI
        function wykres = simulate(obj) 
        l = input(" Podaj dlugość danych na jakich będą przeprowadzane kodowania transmisje i dekodowania : "); % WYBOR DLUGOSCI DANYCH
        obj.data = generateData(l);
        obj.typKodowania = input(" Podaj typ kodowania: 0 - kody hamminga. 1 - BCH. 2 - kod powtórzeniowy : ");       % WYBOR TYPU KODOWANIA
        if obj.typKodowania == 0                                                                 % 0 - kod hamminga
            obj.n = input(" Wybrano kod hamminga, podaj wartosc n: ");
            obj.k = input("                       podaj wartosc k: ");
            obj.calculateHam(); % oblicza sprawnosc i nadmiarowosc
       end
       if obj.typKodowania == 1
           obj.n = input(" Wybrano rodzinę kodów BCH, podaj wartosc n: ");
           obj.k = input("                            podaj wartosc k: ");
           obj.calculateHam(); % oblicza sprawnosc i nadmiarowosc (dla hamminga jest takasam dla wszystkich kodow blokowych);
       end
        if obj.typKodowania == 2                                                             % 2 - repetition code
            disp(" Wybrano kod powtórzeniowy");
            obj.n = 3; obj.k = 1;
            obj.calculateHam(); % oblicza sprawnosc i nadmiarowosc
       end
       obj.modelKanalu = input(" Podaj model kanału. 0 - BSC - błedy niezależne. 1 - BNC - błedy grupowe: ");  % WYBOR KANALU
       if obj.modelKanalu == 0
       obj.paramChange = 0;
       z = input(" Wybrany kanał: BSC - błedy pojedyncze. Podaj poczatkowe prawdopodobieństwo wystąpienia błędu: ");
       obj.setParameterForBsc(z);
       else
       abelx = input(" Wybrany kanał: BNC - błedy grupowe. Podaj początkowe wartości dla parametrów modelu Gilberta\n ABEL - Avarage burst error length - Średnia długość błedu grupowego: ");  
       probBurstE = input(" Probability of burst error - Prawdopodobieństwo wystąpienia błedu grupowego: ");
       loss = input(" Loss Density - Prawdopodobieństwo wystąpienia błędu w stanie złym: ");
       setParametersForBnc(obj,abelx,probBurstE,loss);
       obj.paramChange = input(" Wybierz zmienny parametr.\n 1 - Avarage burst error length. 2 - Probability of burst error. 3 - Loos density: ");
       end
       obj.change = input(" Podaj interwał z jakim parametr ma się zmieniać: ");
       obj.endValueOfParam = input(" Podaj końcową wartość zmiennego parametru: ");
      
       switch obj.paramChange                       % Utworzenie osi Y
           case 0
               obj.oY = obj.probability : obj.change : obj.endValueOfParam;
           case 1
                obj.oY = obj.abel : obj.change : obj.endValueOfParam;
           case 2
                obj.oY = obj.probBurstError : obj.change : obj.endValueOfParam;
           case 3
               obj.oY = obj.lossDensity : obj.change : obj.endValueOfParam;       
       end
       ileRazy = (obj.oY(1,length(obj.oY))-obj.oY(1,1))/obj.change;
       j = 0;
       disp('**********************************************************');
       disp('ROZPOCZYNAM SYMULACJE');
       fprintf(' Symulacja w trakcie. Powtarzam %d razy proces:\n', ileRazy);
       fprintf(' generacja danych o wielkości %d bitów -> kodowanie -> dekodowanie -> obliczanie ber\n',l);
       tic
       for index = obj.oY    % GŁOWNA PĘTLA SYMULACJI 
           j = j+1;
           switch obj.paramChange   % zmiana parametru dla kolejnej iteracji
                  case 0
                      obj.probability = obj.oY(1,j);
                  case 1
                       obj.abel = obj.oY(1,j);
                  case 2
                      obj.probBurstError = obj.oY(1,j);
                  case 3
                       obj.lossDensity = obj.oY(1,j);      
           end
           if (obj.paramChange == 1 || obj.paramChange == 2 || obj.paramChange == 3 )
             setParametersForBnc(obj,obj.abel,obj.probBurstError,obj.lossDensity);     % przeliczenie B2G,G2B oraz loosDensity dla bnc
             calculateERbnc(obj);
           end
           switch obj.typKodowania  % Kodowanie
               case 0       % hamming code
                   eHam(obj);
               case 1        % jakis inny kod (wczsniej podane dane, zmienny parametr, i parametry kodu!!!)
                    eBch(obj);
               case 2
                   eHam(obj);
           end 
          if obj.modelKanalu == 0     % TRANSMISJA   0 - BSC 1 - BNC
              bsc(obj);
          else
              bnc(obj);
          end                             
          % DEKODOWANIE
          switch obj.typKodowania
               case 0     % hamming code
                   dHam(obj);
               case 1        % jakis inny kod (wczsniej podane dane, zmienny parametr, i parametry kodu!!!)
                    dBch(obj);
               case 2 % ....
                   dHam(obj);
          end
          % OBLICZENIE BER (oraz innych parametrow jezeli beda potrzebne)
           calculateBer(obj);
           obj.oX(1,j) = obj.ber;           % Dodanie ber na os X
           
           obj.data = 0; obj.eData = 0;     % Wyzerowanie danych dla pewnosci
           obj.tData = 0; obj.dData = 0;
           obj.ber = 0;
           
           obj.data = generateData(l);      % Nowe dane
         
         
        
          
          leng = length(obj.oY);                          % Te dwie linie bez znaczenia
          obj.oX(length(obj.oX)+1:leng) = 0;
       end
        toc
        disp('SYMULACJA ZAKOŃCZONA');
        disp('**********************************************************');
        
       figure
       plot(obj.oY,obj.oX);
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
   
       
       if obj.modelKanalu == 0
           str = {'Binary symmetric channel'};
           annotation('textbox',[.15 .8 .1 .1],'String',str,'FitBoxToText','on');  
       else
           str = {'Burst-noise channel'};
          annotation('textbox',[.15 .8 .1 .1],'String',str,'FitBoxToText','on'); 
       end  
       %Opis Z prawej strony
       switch obj.typKodowania
           case 0           % Opis dla  hamming code
            typ = sprintf('Hamming (%d,%d)',obj.n,obj.k);
            rateS = sprintf('Rate: %.2f', obj.rate);
            redunS = sprintf('Redundancy: %.2f', obj.redundancy);
            % ZDOLNOSC KOREKCYJNA DLA KODWO HAMINGA = 1;
            paramKodu = {'Code parameters','----------------------',typ,rateS,redunS};
           case 1
             typ = sprintf('BCH (%d,%d)',obj.n,obj.k);
             rateS = sprintf('Rate: %.2f', obj.rate);
             redunS = sprintf('Redundancy: %.2f', obj.redundancy);
             zdol = sprintf('Error-correction capability: %d', bchnumerr(obj.n,obj.k));
             paramKodu = {'Code parameters','----------------------',typ,rateS,redunS,zdol};
             
           case 2   
              % Opis dla  repetition code
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
      
     wykres  = zeros(2, length(obj.oY));
     for m = 1 : length(obj.oY)
        wykres(1,m) = obj.oY(1,m);
     end
     for w =  1 : length(obj.oX)
       wykres(2,w) = obj.oX(1,w);
     end
    end
end
end
