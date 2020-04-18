%-----------------------------------------
k = 1;       %liczba bitów w message
n = 3;       %liczba bitów w codeWord
size = 3;   %rozmiar wiadomoœci
sigma = 20;   %odchylenie standardowe

%----------GENERATOR----------
message = randi([0,1],1,size) %tablica 0 i 1 o wielkoœci 1 x size

disp ('Wiadomoœæ =') %wypisanie codeWord w Command Window
disp(message);
%----------KODER----------
codeWord = 1 : n * length(message); %rozmiar tablicy codeWord - n razy d³u¿sza ni¿ message
m = 1; %zmienna pomocnicza 

for i = 1 : length(message) %pêtla przechodz¹ca przez ca³¹ tablicê message
  for j= 1 : n %pêtla potrajaj¹ca bity
    codeWord(m) = message(i);
    m++;
  endfor
endfor

disp ('S³owo kodowe =') %wypisanie codeWord w Command Window
disp(codeWord);
%----------KANA£----------
codeWordwNoise = codeWord + normrnd(0, sigma, [1, length(codeWord)]);
    
for i = 1 : length(codeWordwNoise)
  if codeWordwNoise(i) <= 0
    codeWordwNoise(i) = 0;
  else
    codeWordwNoise(i) = 1;
  endif
endfor

disp ('S³owo kodowe po przejœciu przez kana³ =') %wypisanie codeWordwNoise w Command Window
disp(codeWordwNoise);
%----------DEKODER----------
messageAfterTransmition = 1 : length(codeWordwNoise) / n; %tablica messageAfterTransmition - wiadomoœæ po zdekodowaniu
u = 1; %zmienna pomocnicza
sum = 0; %suma bloku n - elementowego

for i = 1 : length(codeWordwNoise)
  if codeWordwNoise(i) == 1
    sum ++; %wyznaczanie sumy znaków bloku n - elementowego
  endif
  if mod(i, n) == 0 %w momencie w którym doszliœmy do koñca bloku zostaje sprawdzona wartoœæ sumy
    if sum > 1
      messageAfterTransmition(u) = 1; %kombinacje takie jak: 011,101,110,111. Sum = 2 lub 3 (ogólnie > 1)
    else
      messageAfterTransmition(u) = 0; %kombinacje takie jak: 000,001,010,100. Sum = 0 lub 1 (ogólnie <= 1)
    endif
    sum = 0;
    u++;
  endif
endfor

disp ('Wiadomoœæ po przejœciu przez kana³ =') %wypisanie messageAfterTransmition w Command Window
disp(messageAfterTransmition);
%----------WYNIKI PROGRAMU----------
errorBits = 0; %zmienna przechowuj¹ca iloœæ bitów przek³amanych

for i = 1 : length(codeWord)
  if codeWord(i) != codeWordwNoise(i) %porównanie s³owa kodowego przed i po przejœciu przez kana³
    errorBits++; %zliczanie bitów przek³amanych 
  endif
endfor

BER = errorBits / length(codeWord); %wyznaczenie BER = iloœæ bitów b³êdnie odebranych / iloœæ bitów wys³anych 

disp ('Bit Error Rate =') %wypisanie wartoœci BER
disp(BER);
%-----------------------------------